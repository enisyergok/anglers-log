import 'package:adair_flutter_lib/utils/date_time.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:mobile/location_data_fetcher.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:quiver/strings.dart';
import 'package:timezone/timezone.dart';

import '../../utils/string_utils.dart';
import 'app_manager.dart';
import 'model/gen/anglers_log.pb.dart';
import 'utils/network_utils.dart';
import 'utils/number_utils.dart';
import 'widgets/fetch_input_header.dart';
import 'wrappers/http_wrapper.dart';

/// Fetches tide data from the free TideTurtle API (no API key).
class TideFetcher extends LocationDataFetcher<Tide?> {
  /// TideTurtle heights are relative to mean sea level (MSL).
  static const datum = "MSL";

  static const _authority = "tideturtle.com";
  static const _path = "/api/v1/tides";

  final Log log;
  final TZDateTime dateTime;

  HttpWrapper get _httpWrapper => AppManager.get.httpWrapper;

  TideFetcher(
    this.dateTime,
    super._latLng, {
    this.log = const Log("TideFetcher"),
  });

  @override
  Future<FetchInputResult<Tide?>> fetch(BuildContext context) async {
    var strings = Strings.of(context);

    var result = await super.fetch(context);
    if (result != null) {
      return result;
    }

    if (latLng == null) {
      return FetchInputResult();
    }

    log.d("Fetching TideTurtle data...");

    var json = await _get();
    if (json == null) {
      return FetchInputResult();
    }

    // TideTurtle may return an error field, or empty tides for inland spots.
    var error = json["error"];
    if (error is String && isNotEmpty(error)) {
      if (error.toLowerCase().contains("location") ||
          error.toLowerCase().contains("inland")) {
        return FetchInputResult(
          data: null,
          errorMessage: strings.tideFetcherErrorNoLocationFound,
        );
      }
      log.e("Tide fetch error: $error");
      return FetchInputResult();
    }

    var tides = json["tides"];
    if (!isValidJsonMap(tides)) {
      log.e("TideTurtle response missing tides object");
      return FetchInputResult(
        data: null,
        errorMessage: strings.tideFetcherErrorNoLocationFound,
      );
    }

    var data = tides["data"];
    if (!isValidJsonMap(data)) {
      log.e("TideTurtle response missing tides.data");
      return FetchInputResult(
        data: null,
        errorMessage: strings.tideFetcherErrorNoLocationFound,
      );
    }

    var extrema = data["extrema"];
    var heights = data["heights"];

    var tide = Tide(timeZone: dateTime.locationName);

    if (heights is List) {
      _parseHeightsSeries(tide, heights);
    }

    if (extrema is List) {
      _parseExtrema(tide, extrema);
    }

    // If no heights series, synthesize from extrema so charts still have points.
    if (tide.daysHeights.isEmpty && tide.hasFirstHighHeight()) {
      _synthesizeDaysHeightsFromExtrema(tide);
    } else if (tide.daysHeights.isEmpty) {
      // Collect extrema-as-heights even if high/low assignment was empty.
      if (extrema is List) {
        for (var item in extrema) {
          if (item is! Map) {
            continue;
          }
          var height = _heightFromExtremaMap(Map<String, dynamic>.from(item));
          if (height != null && _isSameCalendarDay(height.timestamp.toInt())) {
            tide.daysHeights.add(height);
          }
        }
        if (!tide.hasHeight() && tide.daysHeights.isNotEmpty) {
          _setCurrentFromNearest(tide);
        }
      }
    }

    if (!tide.isValid) {
      // Microtides / inland: no usable extrema in the returned window.
      log.d("No usable tide extrema for location/date");
      return FetchInputResult(
        data: null,
        errorMessage: strings.tideFetcherErrorNoLocationFound,
      );
    }

    return FetchInputResult(data: tide);
  }

  void _parseHeightsSeries(Tide tide, List<dynamic> jsonHeights) {
    int? currentMsDifference;
    Tide_Height? currentTideHeight;

    for (var item in jsonHeights) {
      if (item is! Map) {
        continue;
      }
      var map = Map<String, dynamic>.from(item);
      var height = _heightFromSeriesMap(map);
      if (height == null) {
        continue;
      }
      if (!_isSameCalendarDay(height.timestamp.toInt())) {
        continue;
      }

      tide.daysHeights.add(height);

      var diff = (height.timestamp.toInt() - dateTime.millisecondsSinceEpoch)
          .abs();
      if (currentMsDifference == null || diff < currentMsDifference) {
        currentMsDifference = diff;
        currentTideHeight = height;
      }
    }

    if (currentTideHeight == null) {
      return;
    }

    tide.height = currentTideHeight;

    var indexOfCurrent = tide.daysHeights.indexOf(currentTideHeight);
    if (indexOfCurrent > 0) {
      var prev = tide.daysHeights[indexOfCurrent - 1].value;
      if (prev < currentTideHeight.value) {
        tide.type = TideType.incoming;
      } else if (prev > currentTideHeight.value) {
        tide.type = TideType.outgoing;
      }
    }
  }

  void _parseExtrema(Tide tide, List<dynamic> jsonExtremes) {
    for (var item in jsonExtremes) {
      if (item is! Map) {
        continue;
      }
      var map = Map<String, dynamic>.from(item);
      var height = _heightFromExtremaMap(map);
      if (height == null) {
        continue;
      }
      if (!_isSameCalendarDay(height.timestamp.toInt())) {
        continue;
      }

      var isHigh = map["isHigh"];
      if (isHigh is! bool) {
        continue;
      }

      if (isHigh) {
        if (tide.hasFirstHighHeight()) {
          tide.secondHighHeight = height;
        } else {
          tide.firstHighHeight = height;
        }
      } else {
        if (tide.hasFirstLowHeight()) {
          tide.secondLowHeight = height;
        } else {
          tide.firstLowHeight = height;
        }
      }
    }

    if (!tide.hasHeight()) {
      _setCurrentFromNearest(tide);
    }
  }

  void _synthesizeDaysHeightsFromExtrema(Tide tide) {
    var points = <Tide_Height>[];
    if (tide.hasFirstLowHeight()) {
      points.add(tide.firstLowHeight);
    }
    if (tide.hasFirstHighHeight()) {
      points.add(tide.firstHighHeight);
    }
    if (tide.hasSecondLowHeight()) {
      points.add(tide.secondLowHeight);
    }
    if (tide.hasSecondHighHeight()) {
      points.add(tide.secondHighHeight);
    }
    points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    tide.daysHeights.addAll(points);

    if (!tide.hasHeight() && points.isNotEmpty) {
      _setCurrentFromNearest(tide);
    }

    if (!tide.hasType() && points.length >= 2) {
      var indexOfCurrent = tide.hasHeight()
          ? tide.daysHeights.indexWhere(
              (h) => h.timestamp == tide.height.timestamp,
            )
          : -1;
      if (indexOfCurrent > 0) {
        var prev = tide.daysHeights[indexOfCurrent - 1].value;
        if (prev < tide.height.value) {
          tide.type = TideType.incoming;
        } else if (prev > tide.height.value) {
          tide.type = TideType.outgoing;
        }
      }
    }
  }

  void _setCurrentFromNearest(Tide tide) {
    Tide_Height? nearest;
    int? bestDiff;
    void consider(Tide_Height h) {
      var diff = (h.timestamp.toInt() - dateTime.millisecondsSinceEpoch).abs();
      if (bestDiff == null || diff < bestDiff!) {
        bestDiff = diff;
        nearest = h;
      }
    }

    for (var h in tide.daysHeights) {
      consider(h);
    }
    if (tide.hasFirstLowHeight()) {
      consider(tide.firstLowHeight);
    }
    if (tide.hasFirstHighHeight()) {
      consider(tide.firstHighHeight);
    }
    if (tide.hasSecondLowHeight()) {
      consider(tide.secondLowHeight);
    }
    if (tide.hasSecondHighHeight()) {
      consider(tide.secondHighHeight);
    }

    if (nearest != null) {
      tide.height = nearest!;
      // Approximate type from which extreme is nearest.
      if (tide.hasFirstHighHeight() &&
          nearest!.timestamp == tide.firstHighHeight.timestamp) {
        tide.type = TideType.high;
      } else if (tide.hasSecondHighHeight() &&
          nearest!.timestamp == tide.secondHighHeight.timestamp) {
        tide.type = TideType.high;
      } else if (tide.hasFirstLowHeight() &&
          nearest!.timestamp == tide.firstLowHeight.timestamp) {
        tide.type = TideType.low;
      } else if (tide.hasSecondLowHeight() &&
          nearest!.timestamp == tide.secondLowHeight.timestamp) {
        tide.type = TideType.low;
      }
    }
  }

  Tide_Height? _heightFromExtremaMap(Map<String, dynamic> json) {
    var height = doubleFromDynamic(json["height"]);
    if (height == null) {
      return null;
    }

    var timeStr = json["time"];
    if (timeStr is! String || isEmpty(timeStr)) {
      return null;
    }
    var parsed = DateTime.tryParse(timeStr);
    if (parsed == null) {
      return null;
    }

    return Tide_Height(
      timestamp: Int64(parsed.toUtc().millisecondsSinceEpoch),
      value: height,
    );
  }

  Tide_Height? _heightFromSeriesMap(Map<String, dynamic> json) {
    var height = doubleFromDynamic(json["height"]);
    if (height == null) {
      return null;
    }

    // Support either ISO "time" or epoch seconds "dt".
    var timeStr = json["time"];
    if (timeStr is String && isNotEmpty(timeStr)) {
      var parsed = DateTime.tryParse(timeStr);
      if (parsed == null) {
        return null;
      }
      return Tide_Height(
        timestamp: Int64(parsed.toUtc().millisecondsSinceEpoch),
        value: height,
      );
    }

    var dt = intFromDynamic(json["dt"]);
    if (dt == null) {
      return null;
    }
    return Tide_Height(
      timestamp: Int64(dt * Duration.millisecondsPerSecond),
      value: height,
    );
  }

  bool _isSameCalendarDay(int timestampMs) {
    var heightDateTime = TZDateTime.fromMillisecondsSinceEpoch(
      dateTime.location,
      timestampMs,
    );
    return heightDateTime.year == dateTime.year &&
        heightDateTime.month == dateTime.month &&
        heightDateTime.day == dateTime.day;
  }

  Future<Map<String, dynamic>?> _get() async {
    var params = {
      "lat": latLng!.latitudeString,
      "lon": latLng!.longitudeString,
    };

    return await getRestJson(
      _httpWrapper,
      Uri.https(_authority, _path, params),
      returnNullOnHttpError: false,
    );
  }
}
