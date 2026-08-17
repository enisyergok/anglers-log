import 'package:adair_flutter_lib/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

import 'app_manager.dart';
import 'map/flutter_map_controller.dart';
import 'model/gen/anglers_log.pb.dart';
import 'utils/map_utils.dart';

/// Manages offline tile caching for the app's maps, backed by
/// flutter_map_tile_caching (FMTC). Each [MapType] (light/dark/satellite) is
/// cached in its own named store, since each uses a different, keyless tile
/// source (standard OSM, CARTO Dark Matter, and Esri World Imagery,
/// respectively). No API keys or paid tile providers are used.
class TileCacheManager {
  static TileCacheManager of(BuildContext context) =>
      AppManager.get.tileCacheManager;

  static const _log = Log("TileCacheManager");

  /// The zoom range downloaded when saving an area for offline use. This
  /// covers typical "zoomed in on a body of water" browsing without
  /// downloading an excessive number of tiles.
  static const minDownloadZoom = 10.0;
  static const maxDownloadZoom = 16.0;

  final AppManager _appManager;

  bool _initialized = false;

  TileCacheManager(this._appManager);

  /// Sets up the FMTC backend and ensures a store exists for each
  /// [MapType]. Must be called once before [tileProvider] or
  /// [saveAreaForOfflineUse] are used; if it fails (for example, on an
  /// unsupported platform), tiles are simply served directly from the
  /// network instead of the offline cache.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      await FMTCObjectBoxBackend().initialise();
      for (var mapType in MapType.values) {
        await FMTCStore(mapType.id).manage.create();
      }
      _initialized = true;
    } catch (e, stackTrace) {
      _log.e(
        e,
        reason: "Error initializing offline tile cache",
        stackTrace: stackTrace,
      );
    }
  }

  /// Returns a tile provider for [mapType] that serves tiles from the
  /// offline cache first, and falls back to the network otherwise. If the
  /// cache couldn't be initialized, a plain network tile provider is
  /// returned.
  fm.TileProvider tileProvider(MapType mapType) {
    if (!_initialized) {
      return fm.NetworkTileProvider();
    }
    return FMTCStore(mapType.id).getTileProvider();
  }

  /// Downloads all tiles for [mapType] within [bounds] so they're available
  /// offline. Returns a stream of download progress, as a percentage (0.0
  /// to 100.0). If the cache couldn't be initialized, an empty stream is
  /// returned.
  Stream<double> saveAreaForOfflineUse({
    required MapType mapType,
    required LatLngBounds bounds,
  }) {
    if (!_initialized) {
      return const Stream.empty();
    }

    var region = RectangleRegion(
      fm.LatLngBounds(bounds.southwest.point, bounds.northeast.point),
    );

    var downloadable = region.toDownloadable(
      minZoom: minDownloadZoom.round(),
      maxZoom: maxDownloadZoom.round(),
      options: fm.TileLayer(
        urlTemplate: mapType.urlTemplate,
        subdomains: mapType.subdomains,
      ),
    );

    var download = FMTCStore(
      mapType.id,
    ).download.startForeground(region: downloadable);

    return download.downloadProgress.map(
      (progress) => progress.percentageProgress,
    );
  }
}
