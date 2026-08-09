import 'dart:async';
import 'dart:io';

import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/wrappers/path_provider_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/map/offline_map_region.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

/// Download / activate / delete regional MBTiles packages.
///
/// Online OSM tiles remain the fallback when no region file is active.
class MapRegionManager {
  static const _prefsActiveKey = 'map_region_active_id';
  static const _dirName = 'map_regions';

  static var _instance = MapRegionManager._();

  static MapRegionManager get get => _instance;

  @visibleForTesting
  static void set(MapRegionManager manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = MapRegionManager._();

  MapRegionManager._();

  final _log = const Log('MapRegionManager');
  final _controller = StreamController<void>.broadcast();

  SharedPreferences? _prefs;
  Directory? _dir;
  String? _activeId;
  String? _downloadingId;
  double _downloadProgress = 0;

  /// Fires when active region, download progress, or file set changes.
  Stream<void> get stream => _controller.stream;

  String? get activeRegionId => _activeId;

  OfflineMapRegion? get activeRegion => OfflineMapRegion.byId(_activeId);

  String? get downloadingId => _downloadingId;

  double get downloadProgress => _downloadProgress;

  bool get isDownloading => _downloadingId != null;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _activeId = _prefs?.getString(_prefsActiveKey);

    final docs = await PathProviderWrapper.get.appDocumentsPath;
    _dir = Directory(p.join(docs, _dirName));
    if (!await _dir!.exists()) {
      await _dir!.create(recursive: true);
    }

    // Drop stale preference if file was deleted outside the app.
    if (_activeId != null && !await isDownloaded(_activeId!)) {
      _log.w('Active region $_activeId missing on disk; clearing');
      await clearActive();
    }

    _notify();
  }

  List<OfflineMapRegion> get regions => OfflineMapRegion.catalog;

  Future<String> localPathFor(OfflineMapRegion region) async {
    await _ensureDir();
    return p.join(_dir!.path, region.fileName);
  }

  Future<bool> isDownloaded(String regionId) async {
    final region = OfflineMapRegion.byId(regionId);
    if (region == null) {
      return false;
    }
    final file = File(await localPathFor(region));
    return file.existsSync() && file.lengthSync() > 0;
  }

  Future<int> fileSizeBytes(String regionId) async {
    final region = OfflineMapRegion.byId(regionId);
    if (region == null) {
      return 0;
    }
    final file = File(await localPathFor(region));
    if (!file.existsSync()) {
      return 0;
    }
    return file.lengthSync();
  }

  /// Absolute path of the active MBTiles file, or null.
  Future<String?> activeMbtilesPath() async {
    final region = activeRegion;
    if (region == null) {
      return null;
    }
    if (!await isDownloaded(region.id)) {
      return null;
    }
    return localPathFor(region);
  }

  /// Back-compat alias.
  Future<String?> activePmtilesPath() => activeMbtilesPath();

  Future<void> setActive(String? regionId) async {
    if (regionId != null && !await isDownloaded(regionId)) {
      throw StateError('Bölge paketi indirilmemiş: $regionId');
    }
    _activeId = regionId;
    if (regionId == null) {
      await _prefs?.remove(_prefsActiveKey);
    } else {
      await _prefs?.setString(_prefsActiveKey, regionId);
    }
    _notify();
  }

  Future<void> clearActive() => setActive(null);

  /// Download [region] from [OfflineMapRegion.downloadUrl] with progress.
  Future<void> download(OfflineMapRegion region) async {
    final url = region.downloadUrl;
    if (url == null || url.isEmpty) {
      throw StateError(
        'Bu bölge için uzak indirme adresi yok. Dosyadan içe aktarın.',
      );
    }
    if (isDownloading) {
      throw StateError('Başka bir indirme sürüyor.');
    }

    _downloadingId = region.id;
    _downloadProgress = 0;
    _notify();

    final dest = File(await localPathFor(region));
    final tmp = File('${dest.path}.part');

    try {
      final client = http.Client();
      try {
        final request = http.Request('GET', Uri.parse(url));
        final response = await client.send(request);
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw HttpException(
            'İndirme başarısız (${response.statusCode})',
            uri: request.url,
          );
        }

        final total = response.contentLength ?? 0;
        var received = 0;
        final sink = tmp.openWrite();
        await for (final chunk in response.stream) {
          sink.add(chunk);
          received += chunk.length;
          if (total > 0) {
            _downloadProgress = received / total;
            _notify();
          }
        }
        await sink.close();

        if (await dest.exists()) {
          await dest.delete();
        }
        await tmp.rename(dest.path);
        _downloadProgress = 1;
      } finally {
        client.close();
      }

      // Auto-activate after successful download.
      await setActive(region.id);
    } catch (e, stack) {
      _log.e(e, reason: 'Download failed for ${region.id}', stackTrace: stack);
      if (await tmp.exists()) {
        await tmp.delete();
      }
      rethrow;
    } finally {
      _downloadingId = null;
      _downloadProgress = 0;
      _notify();
    }
  }

  /// Copy an existing `.mbtiles` file into the region slot and activate it.
  Future<void> importFile(OfflineMapRegion region, String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError('Dosya bulunamadı: $sourcePath');
    }
    final dest = File(await localPathFor(region));
    await source.copy(dest.path);
    await setActive(region.id);
  }

  Future<void> delete(OfflineMapRegion region) async {
    final file = File(await localPathFor(region));
    if (await file.exists()) {
      await file.delete();
    }
    if (_activeId == region.id) {
      await clearActive();
    } else {
      _notify();
    }
  }

  Future<void> _ensureDir() async {
    if (_dir != null) {
      return;
    }
    await init();
  }

  void _notify() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }
}
