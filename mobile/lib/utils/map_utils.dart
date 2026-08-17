import 'dart:math';

import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/res/theme.dart';
import 'package:adair_flutter_lib/utils/widget.dart';
import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:quiver/core.dart';

import '../catch_manager.dart';
import '../map/map_controller.dart';
import '../model/gen/anglers_log.pb.dart';
import 'protobuf_utils.dart';

// TODO: Move to map/ directory.

const mapZoomDefault = 13.0;

// From https://sciencing.com/convert-distances-degrees-meters-7858322.html.
const metersPerDegree = 111139;

// TODO: Move to its own class in the map/ directory.
class MapType {
  static MapType of(BuildContext context) =>
      MapType.fromId(UserPreferenceManager.get.mapType) ??
      (context.isDarkTheme ? MapType.dark : MapType.light);

  static MapType? fromId(String? id) =>
      _allTypes.firstWhereOrNull((e) => e.id == id);

  /// Standard OpenStreetMap raster tiles. Free, keyless, no usage limits.
  static const light = MapType._(
    "normal",
    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    [],
    "© OpenStreetMap contributors",
  );

  /// Esri World Imagery raster tiles. Free, keyless, no usage limits.
  static const satellite = MapType._(
    "satellite",
    "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/"
        "MapServer/tile/{z}/{y}/{x}",
    [],
    "Esri, Maxar, Earthstar Geographics, and the GIS User Community",
  );

  /// CARTO Dark Matter raster tiles. Free, keyless, no usage limits.
  static const dark = MapType._(
    "dark",
    "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
    ["a", "b", "c", "d"],
    "© OpenStreetMap contributors © CARTO",
  );

  static const _allTypes = [light, satellite, dark];

  final String id;

  /// The tile URL template, using {z}/{x}/{y} (and optionally {s}/{r})
  /// placeholders, as consumed by flutter_map's TileLayer.
  final String urlTemplate;

  /// Subdomains to cycle through for {s} in [urlTemplate], if any.
  final List<String> subdomains;

  /// Attribution text required by the tile provider.
  final String attribution;

  const MapType._(this.id, this.urlTemplate, this.subdomains, this.attribution);

  @override
  bool operator ==(Object other) =>
      other is MapType && other.id == id && other.urlTemplate == urlTemplate;

  @override
  int get hashCode => hash2(id, urlTemplate);
}

// TODO: Move to map/ directory.
class SymbolTrail {
  final MapController? _mapController;
  final void Function(Id catchId)? _onCatchSymbolTapped;
  final List<Symbol> _symbols = [];

  SymbolTrail(this._mapController, [this._onCatchSymbolTapped]) {
    _mapController?.addOnSymbolTapped(_onSymbolTapped);
  }

  Future<void> clear() async {
    _mapController?.removeSymbols(_symbols);
    _mapController?.removeOnSymbolTapped(_onSymbolTapped);
  }

  Future<void> draw(
    BuildContext context,
    GpsTrail trail, {
    bool includeCatches = false,
  }) async {
    // Nothing needs to be added, exit early.
    if (_symbols.length == trail.points.length) {
      return;
    }

    var symbols = <Symbol>[];
    for (int i = 0; i < trail.points.length; i++) {
      // Symbol already exists for this point.
      if (_symbols.length <= i) {
        symbols.add(Symbols.fromGpsTrailPoint(trail.points[i]));
      }
    }

    if (includeCatches) {
      var catches = CatchManager.get.catchesForGpsTrail(trail);
      for (var cat in catches) {
        final spot = FishingSpotManager.get.entity(cat.fishingSpotId)!;
        symbols.add(Symbols.fromFishingSpot(spot)..metadata.catchId = cat.id);
      }
    }

    await _mapController?.addSymbols(symbols);
    _symbols.addAll(symbols);
  }

  void _onSymbolTapped(Symbol symbol) {
    if (_onCatchSymbolTapped == null || !symbol.metadata.hasCatchId()) {
      return;
    }
    _onCatchSymbolTapped(symbol.metadata.catchId);
  }
}

/// Returns an approximate distance, in meters, between the given [LatLng]
/// objects.
// TODO: Move to LatLngs extension.
double distanceBetween(LatLng? latLng1, LatLng? latLng2) {
  if (latLng1 == null || latLng2 == null) {
    return 0;
  }

  var latDelta = (latLng1.lat - latLng2.lat).abs();
  var lngDelta = (latLng1.lng - latLng2.lng).abs();

  // A degree of longitude covers less ground the further it is from the
  // equator (it shrinks by a factor of cos(latitude)); without this, the
  // computed distance grows increasingly inaccurate at higher latitudes.
  var avgLatRadians = ((latLng1.lat + latLng2.lat) / 2) * (pi / 180);
  var latDistance = latDelta * metersPerDegree;
  var lngDistance = lngDelta * metersPerDegree * cos(avgLatRadians);

  return sqrt(pow(latDistance, 2) + pow(lngDistance, 2));
}

// TODO: Move to FishingSpots extension.
LatLngBounds? fishingSpotMapBounds(Iterable<FishingSpot> fishingSpots) {
  return latLngsToBounds(fishingSpots.map((e) => e.latLng));
}

// TODO: Move to LatLngBoundsExt.
LatLngBounds? latLngsToBounds(Iterable<LatLng> latLngs) {
  if (latLngs.isEmpty) {
    return null;
  }

  var mostWestLat = latLngs.first.lat;
  var mostEastLat = latLngs.first.lat;
  var mostNorthLng = latLngs.first.lng;
  var mostSouthLng = latLngs.first.lng;

  for (var latLng in latLngs) {
    var lat = latLng.lat;
    var lng = latLng.lng;

    if (lat < mostWestLat) {
      mostWestLat = lat;
    }

    if (lat > mostEastLat) {
      mostEastLat = lat;
    }

    if (lng < mostSouthLng) {
      mostSouthLng = lng;
    }

    if (lng > mostNorthLng) {
      mostNorthLng = lng;
    }
  }

  return LatLngBounds(
    southwest: LatLng(lat: mostWestLat, lng: mostSouthLng),
    northeast: LatLng(lat: mostEastLat, lng: mostNorthLng),
  );
}

// TODO: Should be part of the MapType class.
Color mapIconColor(MapType mapType) =>
    mapType == MapType.light ? Colors.black : Colors.white;

/// Updates the map's logo and attribution margin so they appear above the
/// widget identified by [detailsKey]. Uses the same formula as
/// [FishingSpotMap].
void updateMapAttributionMargin(
  GlobalKey detailsKey,
  MapController? controller,
  BuildContext context,
) {
  final height = detailsKey.globalPosition()?.height ?? 0;
  final androidBottomInset = IoWrapper.get.isAndroid
      ? MediaQuery.of(context).viewPadding.bottom
      : 0.0;
  controller?.updateLogoAndAttributionMarginBottom(
    (height > 0 ? height + 2 * paddingDefault : 0) + androidBottomInset,
  );
}
