import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adair_flutter_lib/utils/page.dart';
import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as ll;
import 'package:mobile/location_monitor.dart';
import 'package:mobile/map/map_region_manager.dart';
import 'package:mobile/mera/mera_balik_aldim_sheet.dart';
import 'package:mobile/mera/mera_no_catch_sheet.dart';
import 'package:mobile/mera/mera_route_manager.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_weather_page.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/navigation/mera_manager.dart';
import 'package:mobile/navigation/marine_telemetry.dart';
import 'package:mobile/navigation/nav_geo.dart';
import 'package:mobile/navigation/nmea_udp_listener.dart';
import 'package:mobile/pages/map_region_page.dart';
import 'package:mobile/wrappers/share_plus_wrapper.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Mockup screen 01 — Ana sayfa harita HUD.
class MeraMapHud extends StatefulWidget {
  const MeraMapHud({super.key});

  @override
  State<MeraMapHud> createState() => _MeraMapHudState();
}

class _MeraMapHudState extends State<MeraMapHud> {
  MarineTelemetry? _telemetry;
  double? _airTempC;
  StreamSubscription? _locSub;
  StreamSubscription? _nmeaSub;
  Timer? _telemetryTimer;

  ll.LatLng? _routeA;
  ll.LatLng? _routeB;
  var _routeMode = false;
  var _shallowHit = false;
  final _search = TextEditingController();

  LocationMonitor get _location => LocationMonitor.of(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshTelemetry();
      _telemetryTimer = Timer.periodic(
        const Duration(minutes: 10),
        (_) => _refreshTelemetry(),
      );
      _locSub = _location.stream.listen((_) {
        if (mounted) setState(() {});
      });
      _nmeaSub = NmeaUdpListener.get.stream.listen((_) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _locSub?.cancel();
    _nmeaSub?.cancel();
    _telemetryTimer?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _refreshTelemetry() async {
    final pos = _location.currentLatLng;
    if (pos == null) return;
    try {
      final t = await MarineTelemetry.fetch(pos.lat, pos.lng);
      // Air temp for top weather chip (mockup shows air °C).
      double? air;
      try {
        final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
          'latitude': pos.lat.toString(),
          'longitude': pos.lng.toString(),
          'current': 'temperature_2m',
        });
        final res = await http.get(uri);
        if (res.statusCode == 200) {
          final json = jsonDecode(res.body) as Map<String, dynamic>;
          air = (json['current']?['temperature_2m'] as num?)?.toDouble();
        }
      } catch (_) {}
      if (mounted) {
        setState(() {
          _telemetry = t;
          _airTempC = air;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final wind = _telemetry?.windSpeedKmh;
    final wave = _telemetry?.waveHeightM;
    final temp = _airTempC ?? _telemetry?.waterTempC;

    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: MeraColors.searchFill,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: MeraColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: MeraColors.textMuted,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _search,
                                style: const TextStyle(
                                  color: MeraColors.textPrimary,
                                  fontSize: 14,
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  hintText: 'Konum ara',
                                  hintStyle: TextStyle(
                                    color: MeraColors.textMuted,
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onSubmitted: (_) {
                                  showNoticeSnackBar(
                                    context,
                                    'Konum araması yakında — haritayı kaydırın',
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => present(context, const MeraWeatherPage()),
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: MeraColors.hudGlass,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: MeraColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.wb_sunny_outlined,
                              color: MeraColors.warning,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              temp == null
                                  ? '—'
                                  : '${temp.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              [
                                if (wind != null)
                                  '${wind.toStringAsFixed(0)}km',
                                if (wave != null)
                                  '${wave.toStringAsFixed(1)}m',
                              ].join(' '),
                              style: const TextStyle(
                                color: MeraColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _sideBtn(
                    Icons.layers_outlined,
                    'Katmanlar',
                    onTap: () => present(context, const MapRegionPage()),
                  ),
                  const SizedBox(height: 10),
                  _sideBtn(
                    Icons.cloud_outlined,
                    'Hava',
                    onTap: () => present(context, const MeraWeatherPage()),
                  ),
                  const SizedBox(height: 10),
                  _sideBtn(
                    Icons.route,
                    'Rotalar',
                    active: _routeMode,
                    onTap: () => setState(() {
                      _routeMode = !_routeMode;
                      if (!_routeMode) {
                        _routeA = null;
                        _routeB = null;
                        _shallowHit = false;
                      }
                    }),
                  ),
                  const SizedBox(height: 10),
                  _sideBtn(
                    Icons.push_pin_outlined,
                    'Pinler',
                    onTap: _shareMera,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_routeMode)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Material(
                  color: _shallowHit
                      ? const Color(0xE8B71C1C)
                      : MeraColors.hudGlass,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _routeLabel(),
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        if (_routeA != null && _routeB != null) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _saveRoute,
                            child: const Text(
                              'Rotayı kaydet',
                              style: TextStyle(color: MeraColors.green),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MeraPrimaryButton(
                    label: 'BALIK ALDIM',
                    icon: Icons.set_meal,
                    height: 56,
                    onPressed: () => showMeraBalikAldimSheet(context),
                  ),
                  TextButton(
                    onPressed: () => showMeraNoCatchSheet(context),
                    child: const Text(
                      'Balık almadım',
                      style: TextStyle(
                        color: MeraColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_routeMode)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _onRouteTap,
            ),
          ),
      ],
    );
  }

  Widget _sideBtn(
    IconData icon,
    String tip, {
    required VoidCallback onTap,
    bool active = false,
  }) {
    return Material(
      color: active ? MeraColors.blue : MeraColors.hudGlass,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        tooltip: tip,
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }

  String _routeLabel() {
    if (_routeA == null) {
      return 'Rota: dokun → nokta A (GPS)';
    }
    if (_routeB == null) {
      return 'Nokta B için tekrar dokun';
    }
    final dist = NavGeo.haversineMeters(_routeA!, _routeB!);
    final brg = NavGeo.bearingDegrees(_routeA!, _routeB!);
    final warn = _shallowHit ? '\n⚠ Sığlık kesişimi!' : '';
    return 'Mesafe: ${(dist / 1852).toStringAsFixed(2)} Nm · '
        'Kerteriz: ${brg.toStringAsFixed(0)}°$warn';
  }

  void _onRouteTap() {
    final pos = _location.currentLatLng;
    if (pos == null) {
      showErrorSnackBar(context, 'Konum yok — GPS açın');
      return;
    }
    final point = ll.LatLng(pos.lat, pos.lng);
    setState(() {
      if (_routeA == null || _routeB != null) {
        _routeA = point;
        _routeB = null;
        _shallowHit = false;
      } else {
        _routeB = point;
        final polys = ShallowPolygonCatalog.forRegion(
          MapRegionManager.get.activeRegionId,
        );
        _shallowHit = NavGeo.routeHitsShallows(_routeA!, _routeB!, polys);
      }
    });
  }

  Future<void> _saveRoute() async {
    if (_routeA == null || _routeB == null) return;
    final name =
        'Rota ${TimeOfDay.now().format(context)}';
    await MeraRouteManager.get.add(
      name: name,
      points: [
        MeraRoutePoint(lat: _routeA!.latitude, lng: _routeA!.longitude, label: 'A'),
        MeraRoutePoint(lat: _routeB!.latitude, lng: _routeB!.longitude, label: 'B'),
      ],
    );
    if (!mounted) return;
    showSuccessSnackBar(context, 'Rota kaydedildi');
    setState(() {
      _routeMode = false;
      _routeA = null;
      _routeB = null;
    });
  }

  Future<void> _shareMera() async {
    try {
      final dir = await getTemporaryDirectory();
      final path = p.join(dir.path, 'mera_export.json');
      await File(path).writeAsString(MeraManager.get.exportJson());
      await SharePlusWrapper.of(context).shareFiles([XFile(path)], null);
    } catch (_) {
      await SharePlusWrapper.of(
        context,
      ).share(MeraManager.get.exportJson(), null);
    }
  }
}
