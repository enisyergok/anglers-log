import 'dart:async';

import 'package:adair_flutter_lib/utils/number.dart';
import 'package:adair_flutter_lib/utils/page.dart';
import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/mera/mera_boat_profile.dart';
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
  StreamSubscription? _profileSub;
  StreamSubscription? _locSub;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await MeraBoatProfileManager.get.ensureLoaded();
      if (mounted) setState(() {});
      _refresh();
      _timer = Timer.periodic(const Duration(minutes: 5), (_) => _refresh());
      _nmeaSub = NmeaUdpListener.get.stream.listen((_) {
        if (mounted) setState(() {});
      });
      _profileSub = MeraBoatProfileManager.get.stream.listen((_) {
        if (mounted) setState(() {});
      });
      _locSub = LocationMonitor.of(context).stream.listen((_) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nmeaSub?.cancel();
    _profileSub?.cancel();
    _locSub?.cancel();
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

  Future<void> _toggleNmea() async {
    final nmea = NmeaUdpListener.get;
    try {
      if (nmea.isRunning) {
        await nmea.stop();
        if (mounted) showNoticeSnackBar(context, 'NMEA dinleyici kapalı');
      } else {
        await nmea.start(port: 10110);
        if (mounted) {
          showSuccessSnackBar(context, 'NMEA UDP :10110 dinleniyor');
        }
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'NMEA: $e');
    }
  }

  Future<void> _editProfile() async {
    final p = MeraBoatProfileManager.get.profile;
    final captain = TextEditingController(text: p.captainName);
    final boat = TextEditingController(text: p.boatName);
    final fuel = TextEditingController(
      text: p.fuelPercent.toStringAsFixed(0),
    );
    final cruise = TextEditingController(
      text: p.cruiseKnots.toStringAsFixed(1),
    );
    final alarmDepth = TextEditingController(
      text: p.depthAlarmMeters.toStringAsFixed(1),
    );
    var alarmOn = p.depthAlarmEnabled;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: MeraColors.card,
          title: const Text('Tekne profili'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: captain,
                  decoration: const InputDecoration(labelText: 'Kaptan adı'),
                ),
                TextField(
                  controller: boat,
                  decoration: const InputDecoration(labelText: 'Tekne adı'),
                ),
                TextField(
                  controller: fuel,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Yakıt % (manuel)'),
                ),
                TextField(
                  controller: cruise,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Seyir hızı (kn)',
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Derinlik alarmı (NMEA)'),
                  value: alarmOn,
                  onChanged: (v) => setLocal(() => alarmOn = v),
                ),
                TextField(
                  controller: alarmDepth,
                  enabled: alarmOn,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Alarm eşiği (m)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final fuelVal = tryParseDouble(fuel.text.trim()) ?? p.fuelPercent;
    final cruiseVal = tryParseDouble(cruise.text.trim()) ?? p.cruiseKnots;
    final alarmVal =
        tryParseDouble(alarmDepth.text.trim()) ?? p.depthAlarmMeters;
    await MeraBoatProfileManager.get.save(
      p.copyWith(
        captainName: captain.text.trim().isEmpty ? 'Kaptan' : captain.text.trim(),
        boatName: boat.text.trim().isEmpty ? 'Teknem' : boat.text.trim(),
        fuelPercent: fuelVal.clamp(0, 100),
        cruiseKnots: cruiseVal.clamp(0.5, 60),
        depthAlarmEnabled: alarmOn,
        depthAlarmMeters: alarmVal.clamp(0.5, 100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routes = MeraRouteManager.get.routes;
    final last = routes.isEmpty ? null : routes.first;
    final nmea = NmeaUdpListener.get.latest;
    final nmeaOn = NmeaUdpListener.get.isRunning;
    final profile = MeraBoatProfileManager.get.profile;
    final gpsLoc = LocationMonitor.of(context).currentLocation;
    final nmeaSog = nmea?.sogKnots;
    final gpsSog = gpsLoc?.speedKnots;
    final speedKn = nmeaSog ?? gpsSog;
    final speedSource = nmeaSog != null
        ? 'NMEA'
        : (gpsSog != null ? 'GPS' : null);
    // Position always comes from phone GPS (NMEA has depth/SOG only).
    final gpsAcc = gpsLoc != null ? 'GPS' : '—';
    final nmeaDepth = nmea?.depthM;
    final fuelFrac = (profile.fuelPercent / 100).clamp(0.0, 1.0);

    return MeraPageScaffold(
      title: 'Gemim',
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          tooltip: 'Profili düzenle',
          onPressed: _editProfile,
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            'Hoş geldin, ${profile.captainName}',
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
                  onTap: _editProfile,
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
                      Text(
                        profile.boatName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(MeraRadii.sm),
                        child: LinearProgressIndicator(
                          value: fuelFrac,
                          minHeight: 6,
                          backgroundColor: MeraColors.borderSecondary,
                          color: fuelFrac < 0.25
                              ? MeraColors.danger
                              : MeraColors.blue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Yakıt ${profile.fuelPercent.toStringAsFixed(0)}% · Manuel giriş (canlı tank değil)',
                        style: const TextStyle(
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
                      if (speedSource != null)
                        Text(
                          speedSource,
                          style: const TextStyle(
                            color: MeraColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      const SizedBox(height: 10),
                      const Text(
                        'Konum',
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
                      if (nmeaDepth != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Derinlik',
                          style: TextStyle(
                            color: MeraColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '${nmeaDepth.toStringAsFixed(1)} m · NMEA',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ] else if (nmeaOn) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Derinlik / SOG',
                          style: TextStyle(
                            color: MeraColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        const Text(
                          'NMEA bekleniyor',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MeraCard(
            onTap: _toggleNmea,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  nmeaOn ? Icons.sensors : Icons.sensors_off,
                  color: nmeaOn ? MeraColors.green : MeraColors.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nmeaOn ? 'NMEA UDP açık' : 'NMEA UDP kapalı',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        nmeaOn
                            ? 'Port 10110 · DBT/DPT/VTG/RMC'
                            : 'Wi‑Fi multiplekser (:10110) · DBT/DPT/VTG/RMC',
                        style: const TextStyle(
                          color: MeraColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: nmeaOn,
                  activeThumbColor: MeraColors.green,
                  onChanged: (_) => _toggleNmea(),
                ),
              ],
            ),
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
                    '${_fmtEta(last.estimatedAt(knots: profile.cruiseKnots))} · '
                    '${profile.cruiseKnots.toStringAsFixed(1)} kn',
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
