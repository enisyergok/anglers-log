import 'dart:async';

import 'package:adair_flutter_lib/utils/page.dart';
import 'package:flutter/material.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/mera/mera_route_detail_page.dart';
import 'package:mobile/mera/mera_route_manager.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_weather_page.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/navigation/marine_telemetry.dart';
import 'package:mobile/navigation/nmea_udp_listener.dart';

/// Siren — Gemim (boat / captain dashboard, Screen 02).
class MeraBoatPage extends StatefulWidget {
  const MeraBoatPage({super.key});

  @override
  State<MeraBoatPage> createState() => _MeraBoatPageState();
}

class _MeraBoatPageState extends State<MeraBoatPage> {
  MarineTelemetry? _telemetry;
  StreamSubscription? _nmeaSub;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
      _timer = Timer.periodic(const Duration(minutes: 5), (_) => _refresh());
      _nmeaSub = NmeaUdpListener.get.stream.listen((_) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nmeaSub?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final pos = LocationMonitor.of(context).currentLatLng;
    if (pos == null) return;
    try {
      final t = await MarineTelemetry.fetch(pos.lat, pos.lng);
      if (mounted) setState(() => _telemetry = t);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final routes = MeraRouteManager.get.routes;
    final last = routes.isEmpty ? null : routes.first;
    final nmea = NmeaUdpListener.get.latest;
    final speedKn = nmea?.sogKnots;
    final gpsAcc = LocationMonitor.of(context).currentLatLng != null
        ? '1.2 m'
        : '—';

    return MeraPageScaffold(
      title: 'Gemim',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            'Hoş geldin, Kaptan',
            style: TextStyle(
              fontSize: SirenScale.clampOf(context, 20, min: 18, max: 22),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Güvenli seyirler dileriz',
            style: TextStyle(color: MeraColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: MeraCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tekneniz',
                        style: TextStyle(
                          color: MeraColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'POSEIDON 48',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(MeraRadii.sm),
                        child: LinearProgressIndicator(
                          value: 0.68,
                          minHeight: 6,
                          backgroundColor: MeraColors.borderSecondary,
                          color: MeraColors.blue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Yakıt 68%',
                        style: TextStyle(
                          color: MeraColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MeraCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hız',
                        style: TextStyle(
                          color: MeraColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        speedKn != null
                            ? '${speedKn.toStringAsFixed(1)} kn'
                            : '— kn',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'GPS',
                        style: TextStyle(
                          color: MeraColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        gpsAcc,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MeraCard(
            onTap: () => present(context, const MeraWeatherPage()),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.wb_cloudy_outlined, color: MeraColors.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _telemetry?.waterTempC != null
                            ? '${_telemetry!.waterTempC!.toStringAsFixed(1)}°C'
                            : 'Hava',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        [
                          if (_telemetry?.windSpeedKmh != null)
                            'Rüzgar ${(_telemetry!.windSpeedKmh! / 1.852).toStringAsFixed(0)} kn',
                          if (_telemetry?.waveHeightM != null)
                            'Dalga ${_telemetry!.waveHeightM!.toStringAsFixed(1)} m',
                        ].join(' · '),
                        style: const TextStyle(
                          color: MeraColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: MeraColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const MeraSectionHeader('SON ROTA'),
          if (last == null)
            const MeraEmptyState(
              icon: Icons.route_outlined,
              title: 'Rota yok',
              subtitle: 'Rotalarım sekmesinden ekleyin',
            )
          else
            MeraCard(
              onTap: () => present(
                context,
                MeraRouteDetailPage(routeId: last.id),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    last.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${last.distanceNm.toStringAsFixed(1)} NM · '
                    '${_fmtEta(last.estimatedAt7kn)} · '
                    '${MeraRoute.cruiseKnots.toStringAsFixed(1)} kn',
                    style: const TextStyle(
                      color: MeraColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _fmtEta(Duration d) {
    if (d.inMinutes <= 0) return '—';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h <= 0) return '$m dk';
    return '$h sa $m dk';
  }
}
