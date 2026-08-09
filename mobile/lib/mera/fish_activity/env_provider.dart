import 'dart:convert';
import 'dart:io';

import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/wrappers/path_provider_wrapper.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/mera/fish_activity/astronomy.dart';
import 'package:mobile/mera/fish_activity/models.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/tide_fetcher.dart';
import 'package:path/path.dart' as p;

/// Fetches weather + marine (+ optional reverse place) with short TTL cache.
/// Does not invent missing fields.
class FishEnvProvider {
  static final FishEnvProvider instance = FishEnvProvider._();
  FishEnvProvider._();

  FishEnvSnapshot? _cache;
  DateTime? _cacheAt;
  double? _cacheLat;
  double? _cacheLng;

  static const _ttl = Duration(minutes: 12);

  Future<FishEnvSnapshot> fetch({
    required double lat,
    required double lng,
    bool force = false,
  }) async {
    if (!force &&
        _cache != null &&
        _cacheAt != null &&
        _cacheLat != null &&
        _cacheLng != null &&
        DateTime.now().difference(_cacheAt!) < _ttl &&
        (lat - _cacheLat!).abs() < 0.01 &&
        (lng - _cacheLng!).abs() < 0.01) {
      return _cache!;
    }

    try {
      final snap = await _fetchOnline(lat: lat, lng: lng);
      _cache = snap;
      _cacheAt = DateTime.now();
      _cacheLat = lat;
      _cacheLng = lng;
      await _writeDisk(snap);
      return snap;
    } catch (e) {
      final stale = await _readDisk(lat, lng);
      if (stale != null) return stale;
      rethrow;
    }
  }

  Future<FishEnvSnapshot> _fetchOnline({
    required double lat,
    required double lng,
  }) async {
    final now = DateTime.now();
    final forecastF = http.get(
      Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': lat.toStringAsFixed(5),
        'longitude': lng.toStringAsFixed(5),
        'current':
            'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,'
            'wind_direction_10m,surface_pressure,cloud_cover',
        'hourly':
            'temperature_2m,weather_code,wind_speed_10m,surface_pressure,cloud_cover',
        'daily': 'sunrise,sunset',
        'forecast_days': '1',
        'timezone': 'auto',
      }),
    );
    final marineF = _fetchMarine(lat, lng);
    final placeF = _reversePlace(lat, lng);
    final tideF = _fetchTide(lat, lng, now);

    final results = await Future.wait([forecastF, marineF, placeF, tideF]);
    final forecastRes = results[0] as http.Response;
    final marine = results[1] as Map<String, dynamic>?;
    final placeName = results[2] as String?;
    final tideSnap = results[3] as ({double? heightM, String? phaseLabel})?;

    if (forecastRes.statusCode != 200 && marine == null) {
      throw StateError('Env fetch failed (${forecastRes.statusCode})');
    }

    Map<String, dynamic>? forecast;
    if (forecastRes.statusCode == 200) {
      forecast = jsonDecode(forecastRes.body) as Map<String, dynamic>;
    }

    final current = forecast?['current'] as Map<String, dynamic>?;
    final daily = forecast?['daily'] as Map<String, dynamic>?;
    final mCurrent = marine?['current'] as Map<String, dynamic>?;

    DateTime? sunrise;
    DateTime? sunset;
    final sr = _firstString(daily?['sunrise']);
    final ss = _firstString(daily?['sunset']);
    if (sr != null) sunrise = DateTime.tryParse(sr);
    if (ss != null) sunset = DateTime.tryParse(ss);

    final pressureNow = (current?['surface_pressure'] as num?)?.toDouble();
    final pressureChange6h = _pressureChange6h(
      forecast?['hourly'] as Map<String, dynamic>?,
      pressureNow,
      now,
    );

    final moonIllum = AstronomyProvider.moonIllumination(now.toUtc());
    final moonLabel = AstronomyProvider.moonPhaseLabel(moonIllum, now.toUtc());

    final hourly = _mergeHourly(
      forecast?['hourly'] as Map<String, dynamic>?,
      marine?['hourly'] as Map<String, dynamic>?,
    );

    final currentMs = (mCurrent?['ocean_current_velocity'] as num?)?.toDouble();
    final currentKn = currentMs != null ? currentMs * 1.94384 : null;

    return FishEnvSnapshot(
      lat: lat,
      lng: lng,
      placeName: placeName,
      fetchedAt: now,
      airTempC: (current?['temperature_2m'] as num?)?.toDouble(),
      humidity: (current?['relative_humidity_2m'] as num?)?.toDouble(),
      windKmh: (current?['wind_speed_10m'] as num?)?.toDouble(),
      windDirDeg: (current?['wind_direction_10m'] as num?)?.toDouble(),
      pressureHpa: pressureNow,
      pressureChange6h: pressureChange6h,
      weatherCode: (current?['weather_code'] as num?)?.toInt(),
      cloudCover: (current?['cloud_cover'] as num?)?.toDouble(),
      sunrise: sunrise,
      sunset: sunset,
      waterTempC: (mCurrent?['sea_surface_temperature'] as num?)?.toDouble(),
      waveHeightM: (mCurrent?['wave_height'] as num?)?.toDouble(),
      wavePeriodS: (mCurrent?['wave_period'] as num?)?.toDouble(),
      currentSpeedKn: currentKn,
      currentDirDeg: (mCurrent?['ocean_current_direction'] as num?)?.toDouble(),
      salinityPsu: null,
      clarityM: null,
      dissolvedOxygenMgL: null,
      tideHeightM: tideSnap?.heightM,
      tidePhaseLabel: tideSnap?.phaseLabel,
      moonIllumination: moonIllum,
      moonPhaseLabel: moonLabel,
      hourly: hourly,
    );
  }

  Future<void> _writeDisk(FishEnvSnapshot snap) async {
    try {
      final file = await _diskFile();
      await file.writeAsString(jsonEncode(snap.toDiskJson()));
    } catch (_) {}
  }

  Future<FishEnvSnapshot?> _readDisk(double lat, double lng) async {
    try {
      final file = await _diskFile();
      if (!await file.exists()) return null;
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final snap = FishEnvSnapshot.fromDiskJson(json);
      if ((snap.lat - lat).abs() > 0.15 || (snap.lng - lng).abs() > 0.15) {
        return null;
      }
      final age = DateTime.now().difference(snap.fetchedAt);
      return snap.copyWith(stale: true, cacheAge: age);
    } catch (_) {
      return null;
    }
  }

  Future<File> _diskFile() async {
    final docs = await PathProviderWrapper.get.appDocumentsPath;
    return File(p.join(docs, 'mera_fish_env_cache.json'));
  }

  Future<({double? heightM, String? phaseLabel})?> _fetchTide(
    double lat,
    double lng,
    DateTime now,
  ) async {
    try {
      final fetcher = TideFetcher(
        TimeManager.get.dateTime(now.millisecondsSinceEpoch),
        LatLng(lat: lat, lng: lng),
      );
      final tide = await fetcher.fetchTideOnly();
      if (tide == null) return null;
      return (
        heightM: tide.hasHeight() ? tide.height.value : null,
        phaseLabel: TideFetcher.phaseLabel(tide),
      );
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchMarine(double lat, double lng) async {
    Future<Map<String, dynamic>?> tryParams(String current, String hourly) async {
      final res = await http.get(
        Uri.https('marine-api.open-meteo.com', '/v1/marine', {
          'latitude': lat.toStringAsFixed(5),
          'longitude': lng.toStringAsFixed(5),
          'current': current,
          'hourly': hourly,
          'forecast_days': '1',
          'timezone': 'auto',
        }),
      );
      if (res.statusCode != 200) return null;
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    final full = await tryParams(
      'sea_surface_temperature,wave_height,wave_period,'
      'ocean_current_velocity,ocean_current_direction',
      'sea_surface_temperature,wave_height,wave_period',
    );
    if (full != null) return full;
    return tryParams(
      'sea_surface_temperature,wave_height,wave_period',
      'sea_surface_temperature,wave_height,wave_period',
    );
  }

  Future<String?> _reversePlace(double lat, double lng) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': lat.toStringAsFixed(5),
        'lon': lng.toStringAsFixed(5),
        'format': 'json',
        'zoom': '12',
        'addressdetails': '1',
      });
      final res = await http.get(
        uri,
        headers: {'User-Agent': 'MeraAsistan/1.0 (local fishing app)'},
      );
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final addr = json['address'] as Map<String, dynamic>?;
      if (addr == null) return json['display_name'] as String?;
      final town = addr['town'] ??
          addr['city'] ??
          addr['village'] ??
          addr['municipality'] ??
          addr['county'];
      final suburb = addr['suburb'] ?? addr['neighbourhood'] ?? addr['hamlet'];
      if (town != null && suburb != null) return '$town - $suburb';
      if (town != null) return town.toString();
      return json['name'] as String? ?? json['display_name'] as String?;
    } catch (_) {
      return null;
    }
  }

  double? _pressureChange6h(
    Map<String, dynamic>? hourly,
    double? nowHpa,
    DateTime now,
  ) {
    if (hourly == null || nowHpa == null) return null;
    final times = (hourly['time'] as List?)?.cast<String>() ?? [];
    final pressures =
        (hourly['surface_pressure'] as List?)?.cast<num>() ?? [];
    if (times.isEmpty || pressures.isEmpty) return null;
    DateTime? best;
    double? bestP;
    for (var i = 0; i < times.length && i < pressures.length; i++) {
      final t = DateTime.tryParse(times[i]);
      if (t == null) continue;
      final age = now.difference(t).inMinutes;
      if (age >= 300 && age <= 420) {
        best = t;
        bestP = pressures[i].toDouble();
        break;
      }
      if (age > 180 && age < 480) {
        if (best == null ||
            (age - 360).abs() < (now.difference(best).inMinutes - 360).abs()) {
          best = t;
          bestP = pressures[i].toDouble();
        }
      }
    }
    if (bestP == null) return null;
    return nowHpa - bestP;
  }

  List<HourlyEnvSample> _mergeHourly(
    Map<String, dynamic>? weatherH,
    Map<String, dynamic>? marineH,
  ) {
    if (weatherH == null) return const [];
    final times = (weatherH['time'] as List?)?.cast<String>() ?? [];
    final air = (weatherH['temperature_2m'] as List?)?.cast<num>() ?? [];
    final wind = (weatherH['wind_speed_10m'] as List?)?.cast<num>() ?? [];
    final press = (weatherH['surface_pressure'] as List?)?.cast<num>() ?? [];
    final code = (weatherH['weather_code'] as List?)?.cast<num>() ?? [];
    final cloud = (weatherH['cloud_cover'] as List?)?.cast<num>() ?? [];
    final mTimes = (marineH?['time'] as List?)?.cast<String>() ?? [];
    final sst =
        (marineH?['sea_surface_temperature'] as List?)?.cast<num>() ?? [];
    final wave = (marineH?['wave_height'] as List?)?.cast<num>() ?? [];

    final out = <HourlyEnvSample>[];
    for (var i = 0; i < times.length && i < 24; i++) {
      final t = DateTime.tryParse(times[i]);
      if (t == null) continue;
      double? water;
      double? wh;
      final mi = mTimes.indexOf(times[i]);
      if (mi >= 0) {
        if (mi < sst.length) water = sst[mi].toDouble();
        if (mi < wave.length) wh = wave[mi].toDouble();
      }
      out.add(
        HourlyEnvSample(
          time: t,
          airTempC: i < air.length ? air[i].toDouble() : null,
          windKmh: i < wind.length ? wind[i].toDouble() : null,
          pressureHpa: i < press.length ? press[i].toDouble() : null,
          weatherCode: i < code.length ? code[i].toInt() : null,
          cloudCover: i < cloud.length ? cloud[i].toDouble() : null,
          waterTempC: water,
          waveHeightM: wh,
        ),
      );
    }
    return out;
  }

  static String? _firstString(dynamic v) {
    if (v is List && v.isNotEmpty) return v.first?.toString();
    if (v is String) return v;
    return null;
  }

  /// Compass / Turkish coastal wind names (heuristic labels only).
  static String windName(double? deg) {
    if (deg == null) return '—';
    const names = [
      'Poyraz',
      'Poyraz',
      'Doğu',
      'Keşişleme',
      'Lodos',
      'Lodos',
      'Batı',
      'Karayel',
    ];
    final i = ((deg % 360) / 45).floor() % 8;
    return names[i];
  }

  static String compass(double? deg) {
    if (deg == null) return '—';
    const dirs = ['K', 'KD', 'D', 'GD', 'G', 'GB', 'B', 'KB'];
    final i = (((deg % 360) + 22.5) / 45).floor() % 8;
    return dirs[i];
  }

  static String seaState(double? waveM) {
    if (waveM == null) return 'Veri yok';
    if (waveM < 0.3) return 'Sakin';
    if (waveM < 0.8) return 'Hafif çalkantı';
    if (waveM < 1.5) return 'Orta';
    if (waveM < 2.5) return 'Dalgalı';
    return 'Sert';
  }
}
