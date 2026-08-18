import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/utils/date_time.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiver/strings.dart';
import 'package:timezone/timezone.dart';

import 'app_manager.dart';
import 'location_data_fetcher.dart';
import 'model/gen/anglers_log.pb.dart';
import 'user_preference_manager.dart';
import 'utils/network_utils.dart';
import 'utils/number_utils.dart';
import 'utils/protobuf_utils.dart';
import 'widgets/fetch_input_header.dart';
import 'wrappers/http_wrapper.dart';

/// Fetches atmosphere data from the free Open-Meteo API (no API key).
class AtmosphereFetcher extends LocationDataFetcher<Atmosphere?> {
  static const _forecastAuthority = "api.open-meteo.com";
  static const _archiveAuthority = "archive-api.open-meteo.com";
  static const _forecastPath = "/v1/forecast";
  static const _archivePath = "/v1/archive";

  static const _currentParams =
      "temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,"
      "wind_direction_10m,surface_pressure,visibility";
  static const _hourlyParams =
      "temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,"
      "wind_direction_10m,surface_pressure,visibility";
  static const _archiveHourlyParams =
      "temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,"
      "wind_direction_10m,pressure_msl";
  static const _dailyParams = "sunrise,sunset";

  final _log = const Log("AtmosphereFetcher");

  final TZDateTime dateTime;

  HttpWrapper get _httpWrapper => AppManager.get.httpWrapper;

  AtmosphereFetcher(this.dateTime, super._latLng);

  @override
  Future<FetchInputResult<Atmosphere?>> fetch(BuildContext context) async {
    var result = await super.fetch(context);
    if (result != null) {
      return result;
    }

    if (latLng == null) {
      return FetchInputResult();
    }

    _log.d("Fetching Open-Meteo data...");

    var json = await _get();
    if (json == null) {
      return FetchInputResult();
    }

    Atmosphere? atmosphere;
    try {
      atmosphere = _atmosphereFromOpenMeteo(json);
    } catch (e, stack) {
      _log.e(e, reason: "Error parsing Open-Meteo data", stackTrace: stack);
    }

    if (atmosphere == null) {
      return FetchInputResult();
    }

    return FetchInputResult<Atmosphere>(data: atmosphere);
  }

  Atmosphere? _atmosphereFromOpenMeteo(Map<String, dynamic> json) {
    Map<String, dynamic>? values;
    String? sunriseIso;
    String? sunsetIso;

    var current = json["current"];
    if (isValidJsonMap(current)) {
      values = Map<String, dynamic>.from(current as Map);
    } else {
      values = _valuesFromHourly(json);
    }

    if (values == null) {
      _log.e("Open-Meteo response missing current/hourly data: $json");
      return null;
    }

    var daily = json["daily"];
    if (isValidJsonMap(daily)) {
      sunriseIso = _firstString(daily["sunrise"]);
      sunsetIso = _firstString(daily["sunset"]);
    }

    return _atmosphereFromValues(
      values,
      sunriseIso: sunriseIso,
      sunsetIso: sunsetIso,
    );
  }

  Map<String, dynamic>? _valuesFromHourly(Map<String, dynamic> json) {
    var hourly = json["hourly"];
    if (!isValidJsonMap(hourly)) {
      return null;
    }

    var times = hourly["time"];
    if (times is! List || times.isEmpty) {
      return null;
    }

    var bestIndex = 0;
    var bestDiff = 1 << 62;
    for (var i = 0; i < times.length; i++) {
      var t = times[i];
      if (t is! String) {
        continue;
      }
      var parsed = DateTime.tryParse(t);
      if (parsed == null) {
        continue;
      }
      var diff = (parsed.millisecondsSinceEpoch - dateTime.millisecondsSinceEpoch)
          .abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestIndex = i;
      }
    }

    dynamic at(String key) {
      var list = hourly[key];
      if (list is! List || bestIndex >= list.length) {
        return null;
      }
      return list[bestIndex];
    }

    return {
      "temperature_2m": at("temperature_2m"),
      "relative_humidity_2m": at("relative_humidity_2m"),
      "weather_code": at("weather_code"),
      "wind_speed_10m": at("wind_speed_10m"),
      "wind_direction_10m": at("wind_direction_10m"),
      "surface_pressure": at("surface_pressure") ?? at("pressure_msl"),
      "visibility": at("visibility"),
    };
  }

  Atmosphere _atmosphereFromValues(
    Map<String, dynamic> values, {
    String? sunriseIso,
    String? sunsetIso,
  }) {
    var result = Atmosphere();

    var temperature = doubleFromDynamic(values["temperature_2m"]);
    if (temperature != null) {
      result.temperature = _multiMeasurement(
        value: temperature,
        system: UserPreferenceManager.get.airTemperatureSystem,
        metricUnit: Unit.celsius,
        imperialUnit: Unit.fahrenheit,
        apiUnit: Unit.celsius,
      );
    }

    var humidity = intFromDynamic(values["relative_humidity_2m"]);
    if (humidity != null) {
      result.humidity = MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.percent,
          value: humidity.roundToDouble(),
        ),
      );
    }

    var windSpeed = doubleFromDynamic(values["wind_speed_10m"]);
    if (windSpeed != null) {
      result.windSpeed = _multiMeasurement(
        value: windSpeed,
        system: UserPreferenceManager.get.windSpeedSystem,
        metricUnit: Unit.kilometers_per_hour,
        imperialUnit: Unit.miles_per_hour,
        apiUnit: Unit.kilometers_per_hour,
      );
    }

    var windDirection = doubleFromDynamic(values["wind_direction_10m"]);
    if (windDirection != null) {
      result.windDirection = Directions.fromDegrees(windDirection);
    }

    var pressure = doubleFromDynamic(values["surface_pressure"]);
    if (pressure != null) {
      // Open-Meteo hPa ≈ millibars.
      result.pressure = _multiMeasurement(
        value: pressure,
        system: UserPreferenceManager.get.airPressureSystem,
        metricUnit: Unit.millibars,
        imperialUnit: UserPreferenceManager.get.airPressureImperialUnit,
        apiUnit: Unit.millibars,
      );
    }

    var visibilityMeters = doubleFromDynamic(values["visibility"]);
    if (visibilityMeters != null) {
      // Open-Meteo visibility is meters; convert to km for unit conversion.
      result.visibility = _multiMeasurement(
        value: visibilityMeters / 1000.0,
        system: UserPreferenceManager.get.airVisibilitySystem,
        metricUnit: Unit.kilometers,
        imperialUnit: Unit.miles,
        apiUnit: Unit.kilometers,
      );
    }

    var weatherCode = intFromDynamic(values["weather_code"]);
    if (weatherCode != null) {
      var conditions = _skyConditionTypesFromWmo(weatherCode);
      if (isNotEmpty(conditions)) {
        result.skyConditions.addAll(SkyConditions.fromTypes(conditions));
      }
    }

    var sunriseMs = _epochMsFromIso(sunriseIso);
    if (sunriseMs != null) {
      result.sunriseTimestamp = Int64(sunriseMs);
    }

    var sunsetMs = _epochMsFromIso(sunsetIso);
    if (sunsetMs != null) {
      result.sunsetTimestamp = Int64(sunsetMs);
    }

    // Moon phase is not provided by Open-Meteo forecast/archive; omit.

    result.timeZone = dateTime.locationName;
    return result;
  }

  /// Maps WMO weather codes to Visual Crossing-style type strings that
  /// [SkyConditions.fromTypes] already understands.
  String _skyConditionTypesFromWmo(int code) {
    if (code == 0 || code == 1) {
      return "type_43"; // clear
    }
    if (code == 2) {
      return "type_27"; // cloudy / partly cloudy
    }
    if (code == 3) {
      return "type_41"; // overcast
    }
    if (code == 45 || code == 48) {
      return "type_8"; // fog
    }
    if (code >= 51 && code <= 57) {
      return "type_2"; // drizzle
    }
    if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
      return "type_9"; // rain
    }
    if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
      return "type_1"; // snow
    }
    if (code == 95) {
      return "type_18"; // storm
    }
    if (code == 96 || code == 99) {
      return "type_16"; // hail
    }
    return "type_27"; // default cloudy
  }

  int? _epochMsFromIso(String? iso) {
    if (isEmpty(iso)) {
      return null;
    }
    var parsed = DateTime.tryParse(iso!);
    return parsed?.millisecondsSinceEpoch;
  }

  String? _firstString(dynamic value) {
    if (value is String) {
      return value;
    }
    if (value is List && value.isNotEmpty && value.first is String) {
      return value.first as String;
    }
    return null;
  }

  Future<Map<String, dynamic>?> _get() async {
    var dateStr = DateFormat("yyyy-MM-dd").format(dateTime);
    var now = TimeManager.get.currentDateTime;
    var isToday = dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;

    // Forecast covers roughly ± a couple of weeks; use archive for older days.
    var daysFromNow = dateTime
        .difference(TZDateTime(dateTime.location, now.year, now.month, now.day))
        .inDays;
    var useArchive = !isToday && daysFromNow < -1;

    if (useArchive) {
      var params = {
        "latitude": latLng!.latitudeString,
        "longitude": latLng!.longitudeString,
        "start_date": dateStr,
        "end_date": dateStr,
        "hourly": _archiveHourlyParams,
        "daily": _dailyParams,
        "timezone": "auto",
      };
      return await getRestJson(
        _httpWrapper,
        Uri.https(_archiveAuthority, _archivePath, params),
      );
    }

    var params = <String, String>{
      "latitude": latLng!.latitudeString,
      "longitude": latLng!.longitudeString,
      "daily": _dailyParams,
      "timezone": "auto",
    };

    if (isToday) {
      params["current"] = _currentParams;
    } else {
      params["start_date"] = dateStr;
      params["end_date"] = dateStr;
      params["hourly"] = _hourlyParams;
    }

    return await getRestJson(
      _httpWrapper,
      Uri.https(_forecastAuthority, _forecastPath, params),
    );
  }

  MultiMeasurement _multiMeasurement({
    required double value,
    required MeasurementSystem system,
    required Unit metricUnit,
    required Unit imperialUnit,
    required Unit apiUnit,
  }) {
    var unit = system == MeasurementSystem.metric ? metricUnit : imperialUnit;

    var convertedValue = unit.convertFrom(apiUnit, value);
    if (system == MeasurementSystem.imperial_whole) {
      convertedValue = convertedValue.roundToDouble();
    }

    return MultiMeasurement(
      system: system,
      mainValue: Measurement(unit: unit, value: convertedValue),
    );
  }
}
