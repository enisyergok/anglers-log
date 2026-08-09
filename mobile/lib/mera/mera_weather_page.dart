import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/location_monitor.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/navigation/marine_telemetry.dart';

/// Mockup screen 09 — Hava durumu.
class MeraWeatherPage extends StatefulWidget {
  const MeraWeatherPage({super.key});

  @override
  State<MeraWeatherPage> createState() => _MeraWeatherPageState();
}

class _MeraWeatherPageState extends State<MeraWeatherPage> {
  Future<_WeatherBundle>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_WeatherBundle> _load() async {
    final loc = LocationMonitor.of(context).currentLatLng;
    final lat = loc?.lat ?? 41.01;
    final lng = loc?.lng ?? 28.98;

    final marine = await MarineTelemetry.fetch(lat, lng);

    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': lat.toString(),
      'longitude': lng.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
      'hourly': 'temperature_2m,weather_code',
      'forecast_hours': '6',
      'timezone': 'auto',
    });
    final res = await http.get(uri);
    Map<String, dynamic>? json;
    if (res.statusCode == 200) {
      json = jsonDecode(res.body) as Map<String, dynamic>;
    }
    final current = json?['current'] as Map<String, dynamic>?;
    final hourly = json?['hourly'] as Map<String, dynamic>?;
    final temps = (hourly?['temperature_2m'] as List?)?.cast<num>() ?? [];
    final codes = (hourly?['weather_code'] as List?)?.cast<num>() ?? [];
    final times = (hourly?['time'] as List?)?.cast<String>() ?? [];

    final hours = <_Hour>[];
    for (var i = 0; i < temps.length && i < 6; i++) {
      hours.add(
        _Hour(
          label: _hourLabel(times.length > i ? times[i] : null, i),
          tempC: temps[i].toDouble(),
          code: codes.length > i ? codes[i].toInt() : 0,
        ),
      );
    }

    return _WeatherBundle(
      place: loc == null ? 'İstanbul, Türkiye' : 'Mevcut konum',
      tempC: (current?['temperature_2m'] as num?)?.toDouble(),
      humidity: (current?['relative_humidity_2m'] as num?)?.toDouble(),
      windKmh:
          (current?['wind_speed_10m'] as num?)?.toDouble() ??
          marine?.windSpeedKmh,
      waveM: marine?.waveHeightM,
      code: (current?['weather_code'] as num?)?.toInt() ?? 0,
      hours: hours,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MeraPageScaffold(
      title: 'Hava Durumu',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => setState(() => _future = _load()),
        ),
      ],
      body: FutureBuilder<_WeatherBundle>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData) {
            return MeraEmptyState(
              icon: Icons.cloud_off,
              title: 'Hava alınamadı',
              subtitle: snap.error?.toString() ?? 'Bağlantıyı kontrol edin',
            );
          }
          final w = snap.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              MeraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w.place,
                      style: const TextStyle(color: MeraColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.tempC == null
                              ? '—'
                              : '${w.tempC!.toStringAsFixed(1)}°',
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _iconFor(w.code),
                          size: 56,
                          color: MeraColors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _labelFor(w.code),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _metric(
                      'Rüzgar',
                      w.windKmh == null
                          ? '—'
                          : '${w.windKmh!.toStringAsFixed(0)} km/s',
                      Icons.air,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _metric(
                      'Dalga',
                      w.waveM == null
                          ? '—'
                          : '${w.waveM!.toStringAsFixed(1)} m',
                      Icons.waves,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _metric(
                      'Nem',
                      w.humidity == null
                          ? '—'
                          : '%${w.humidity!.toStringAsFixed(0)}',
                      Icons.water_drop_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const MeraSectionHeader('SAATLİK TAHMİN'),
              MeraCard(
                child: Row(
                  children: [
                    for (final h in w.hours)
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              h.label,
                              style: const TextStyle(
                                color: MeraColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Icon(_iconFor(h.code), color: MeraColors.blue),
                            const SizedBox(height: 8),
                            Text(
                              '${h.tempC.toStringAsFixed(0)}°',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _metric(String label, String value, IconData icon) {
    return MeraCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: MeraColors.green, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(
            label,
            style: const TextStyle(
              color: MeraColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  static String _hourLabel(String? raw, int index) {
    if (raw == null || raw.isEmpty) return '${index + 1}';
    final part = raw.contains('T') ? raw.split('T').last : raw;
    if (part.length >= 5) return part.substring(0, 5);
    return part;
  }

  static IconData _iconFor(int code) {
    if (code == 0) return Icons.wb_sunny_outlined;
    if (code <= 3) return Icons.wb_cloudy_outlined;
    if (code <= 67) return Icons.grain;
    if (code <= 77) return Icons.ac_unit;
    return Icons.thunderstorm_outlined;
  }

  static String _labelFor(int code) {
    if (code == 0) return 'Açık';
    if (code <= 3) return 'Parçalı bulutlu';
    if (code <= 67) return 'Yağmurlu';
    if (code <= 77) return 'Karlı';
    return 'Fırtınalı';
  }
}

class _WeatherBundle {
  final String place;
  final double? tempC;
  final double? humidity;
  final double? windKmh;
  final double? waveM;
  final int code;
  final List<_Hour> hours;

  const _WeatherBundle({
    required this.place,
    required this.tempC,
    required this.humidity,
    required this.windKmh,
    required this.waveM,
    required this.code,
    required this.hours,
  });
}

class _Hour {
  final String label;
  final double tempC;
  final int code;
  const _Hour({required this.label, required this.tempC, required this.code});
}
