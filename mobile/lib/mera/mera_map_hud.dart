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
import 'package:mobile/mera/mera_boat_profile.dart';
import 'package:mobile/mera/mera_map_interaction.dart';
import 'package:mobile/mera/mera_no_catch_sheet.dart';
import 'package:mobile/mera/mera_route_manager.dart';
import 'package:mobile/mera/mera_shell.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_weather_page.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/mera/place_search.dart';
import 'package:mobile/navigation/mera_manager.dart';
import 'package:mobile/navigation/marine_telemetry.dart';
import 'package:mobile/navigation/nav_geo.dart';
import 'package:mobile/navigation/nmea_udp_listener.dart';
import 'package:mobile/pages/map_region_page.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart' show LatLng;
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/map_utils.dart';
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
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  var _searching = false;

  LocationMonitor get _location => LocationMonitor.of(context);
  MeraMapInteraction get _mapIx => MeraMapInteraction.instance;

  @override
  void initState() {
    super.initState();
    _mapIx.addListener(_onMapIx);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MeraBoatProfileManager.get.ensureLoaded();
      _refreshTelemetry();
      _telemetryTimer = Timer.periodic(
        const Duration(minutes: 10),
        (_) => _refreshTelemetry(),
      );
      _locSub = _location.stream.listen((point) {
        _mapIx.updateNavigationPosition(
          ll.LatLng(point.latLng.lat, point.latLng.lng),
        );
        if (mounted) setState(() {});
      });
      _nmeaSub = NmeaUdpListener.get.stream.listen((_) {
        if (mounted) setState(() {});
      });
    });
  }

  void _onMapIx() {
    final pts = _mapIx.draftPoints;
    if (pts.length >= 2) {
      final polys = ShallowPolygonCatalog.forRegion(
        MapRegionManager.get.activeRegionId,
      );
      var hit = false;
      for (var i = 0; i < pts.length - 1; i++) {
        if (NavGeo.routeHitsShallows(pts[i], pts[i + 1], polys)) {
          hit = true;
          break;
        }
      }
      _mapIx.setShallowHit(hit);
    } else {
      _mapIx.setShallowHit(false);
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _mapIx.removeListener(_onMapIx);
    _locSub?.cancel();
    _nmeaSub?.cancel();
    _telemetryTimer?.cancel();
    _search.dispose();
    _searchFocus.dispose();
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

  Future<void> _runPlaceSearch() async {
    final q = _search.text.trim();
    if (q.isEmpty) {
      showNoticeSnackBar(context, 'Aramak için yer adı veya koordinat yazın');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _searching = true);
    try {
      final hits = await PlaceSearch.search(q);
      if (!mounted) return;
      if (hits.isEmpty) {
        showErrorSnackBar(context, 'Sonuç bulunamadı');
        return;
      }
      if (hits.length == 1) {
        await _goToPlace(hits.first);
        return;
      }
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: MeraColors.card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(MeraRadii.lg)),
        ),
        builder: (ctx) {
          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Text(
                    'Konum seç',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                ...hits.map(
                  (h) => ListTile(
                    leading: const Icon(Icons.place_outlined, color: MeraColors.blue),
                    title: Text(
                      h.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _goToPlace(h);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Arama başarısız: $e');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _goToPlace(PlaceSearchHit hit) async {
    _search.text = hit.name.split(',').first.trim();
    setState(() {});
    await _mapIx.centerOn(
      LatLng(lat: hit.lat, lng: hit.lng),
      zoom: 13,
    );
    if (!mounted) return;
    showSuccessSnackBar(context, hit.name.split(',').take(2).join(', '));
  }

  void _showMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: MeraColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(MeraRadii.lg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Menü',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.route, color: MeraColors.green),
                  title: const Text('Rotalarım'),
                  onTap: () {
                    Navigator.pop(ctx);
                    MeraShell.goRoutes();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.place_outlined, color: MeraColors.green),
                  title: const Text('İşaretlerim'),
                  onTap: () {
                    Navigator.pop(ctx);
                    MeraShell.goMarks();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.directions_boat_outlined, color: MeraColors.green),
                  title: const Text('Gemim'),
                  onTap: () {
                    Navigator.pop(ctx);
                    MeraShell.goBoat();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: MeraColors.green),
                  title: const Text('Ayarlar'),
                  onTap: () {
                    Navigator.pop(ctx);
                    MeraShell.switchTab?.call(MeraShell.tabSettings);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.layers_outlined, color: MeraColors.blue),
                  title: const Text('Harita katmanları'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showLayersSheet(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_outlined, color: MeraColors.blue),
                  title: const Text('Hava durumu'),
                  onTap: () {
                    Navigator.pop(ctx);
                    present(context, const MeraWeatherPage());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
            padding: EdgeInsets.fromLTRB(
              SirenScale.clampOf(context, 14, min: 10, max: 16),
              SirenScale.clampOf(context, 10, min: 8, max: 14),
              SirenScale.clampOf(context, 14, min: 10, max: 16),
              0,
            ),
            child: Row(
              children: [
                _chromeCircle(Icons.menu, onTap: _showMenu),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: SirenScale.clampOf(context, 48, min: 42, max: 50),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: MeraColors.searchFill,
                      borderRadius: BorderRadius.circular(MeraRadii.sm),
                      border: Border.all(color: MeraColors.borderSecondary),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: MeraColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _search,
                            focusNode: _searchFocus,
                            textInputAction: TextInputAction.search,
                            style: const TextStyle(
                              color: MeraColors.textPrimary,
                              fontSize: 13,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              hintText: 'Konum Ara',
                              hintStyle: TextStyle(
                                color: MeraColors.textMuted,
                                fontSize: 13,
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) => _runPlaceSearch(),
                          ),
                        ),
                        if (_searching)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else if (_search.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _search.clear();
                              setState(() {});
                            },
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: MeraColors.textMuted,
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: _runPlaceSearch,
                            child: const Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: MeraColors.blue,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(
                top: SirenScale.clampOf(context, 70, min: 58, max: 80),
                right: SirenScale.clampOf(context, 14, min: 10, max: 16),
              ),
              child: GestureDetector(
                onTap: () => present(context, const MeraWeatherPage()),
                child: Container(
                  width: SirenScale.clampOf(context, 120, min: 108, max: 132),
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  decoration: BoxDecoration(
                    color: MeraColors.hudGlass,
                    borderRadius: BorderRadius.circular(MeraRadii.sm),
                    border: Border.all(color: MeraColors.borderSecondary),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.wb_cloudy_outlined,
                            color: MeraColors.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            temp == null
                                ? '—'
                                : '${temp.toStringAsFixed(1)}°C',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        wind == null
                            ? 'Rüzgar —'
                            : 'Rüzgar ${(wind / 1.852).toStringAsFixed(0)} kn',
                        style: const TextStyle(
                          color: MeraColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        wave == null
                            ? 'Dalga —'
                            : 'Dalga ${wave.toStringAsFixed(1)} m',
                        style: const TextStyle(
                          color: MeraColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                    onTap: () => _showLayersSheet(context),
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
                    active: _mapIx.routeMode,
                    onTap: () {
                      final next = !_mapIx.routeMode;
                      _mapIx.setRouteMode(next);
                      if (next) {
                        showNoticeSnackBar(
                          context,
                          'Rota: haritaya dokunarak nokta ekleyin (çoklu waypoint)',
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _sideBtn(
                    Icons.push_pin_outlined,
                    _mapIx.pinMode
                        ? 'Pin modu açık (uzun bas → liste)'
                        : 'Pinler (uzun bas → pin modu)',
                    active: _mapIx.pinMode,
                    onTap: _showPins,
                    onLongPress: () {
                      final next = !_mapIx.pinMode;
                      _mapIx.setPinMode(next);
                      showNoticeSnackBar(
                        context,
                        next
                            ? 'Pin modu: haritaya dokunun veya uzun basın'
                            : 'Pin modu kapalı',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(
                right: SirenScale.clampOf(context, 14, min: 10, max: 16),
                bottom: SirenScale.clampOf(context, 118, min: 100, max: 130),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _chromeCircle(
                    Icons.my_location,
                    onTap: () async {
                      final pos = _location.currentLatLng;
                      if (pos == null) {
                        showErrorSnackBar(context, 'Konum yok — GPS açın');
                        return;
                      }
                      await _mapIx.centerOn(pos);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_mapIx.navActive)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Material(
                  color: MeraColors.hudGlass,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _navLabel(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: _mapIx.skipToPrevWaypoint,
                              child: const Text(
                                '◀',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            TextButton(
                              onPressed: _mapIx.skipToNextWaypoint,
                              child: const Text(
                                '▶',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _mapIx.stopNavigation();
                                showNoticeSnackBar(
                                  context,
                                  'WP rehberi bitti',
                                );
                              },
                              child: const Text(
                                'Durdur',
                                style: TextStyle(color: MeraColors.danger),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        else if (_mapIx.pinMode)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Material(
                  color: MeraColors.hudGlass,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Pin modu · haritaya dokun / uzun bas → işaret',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: _showPins,
                              child: const Text(
                                'Liste',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                );
                                MeraShell.goMarks();
                              },
                              child: const Text(
                                'İşaretler',
                                style: TextStyle(color: MeraColors.green),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _mapIx.setPinMode(false),
                              child: const Text(
                                'Kapat',
                                style: TextStyle(color: MeraColors.danger),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        else if (_mapIx.routeMode)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Material(
                  color: _mapIx.shallowHit
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
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_mapIx.draftPoints.isNotEmpty)
                              TextButton(
                                onPressed: _mapIx.undoLastWaypoint,
                                child: const Text(
                                  'Geri al',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            if (_mapIx.draftPoints.isNotEmpty)
                              TextButton(
                                onPressed: _mapIx.clearDraftPoints,
                                child: const Text(
                                  'Temizle',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            if (_mapIx.draftPoints.length >= 2)
                              TextButton(
                                onPressed: _saveRoute,
                                child: Text(
                                  _mapIx.editingRouteId != null
                                      ? 'Rotayı güncelle'
                                      : 'Rotayı kaydet',
                                  style: const TextStyle(color: MeraColors.green),
                                ),
                              ),
                          ],
                        ),
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
                    height: SirenScale.clampOf(context, 57, min: 50, max: 58),
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
      ],
    );
  }

  Widget _chromeCircle(IconData icon, {required VoidCallback onTap}) {
    return Material(
      color: MeraColors.searchFill,
      shape: const CircleBorder(
        side: BorderSide(color: MeraColors.borderSecondary),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: MeraColors.textPrimary),
        ),
      ),
    );
  }

  Widget _sideBtn(
    IconData icon,
    String tip, {
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    bool active = false,
  }) {
    return Tooltip(
      message: tip,
      child: Material(
        color: active ? MeraColors.blue : MeraColors.hudGlass,
        borderRadius: BorderRadius.circular(MeraRadii.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(MeraRadii.sm),
          onTap: onTap,
          onLongPress: onLongPress,
          child: SizedBox(
            width: 44,
            height: 52,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  String _routeLabel() {
    final pts = _mapIx.draftPoints;
    final edit = _mapIx.editingRouteId != null ? ' (düzenleme)' : '';
    if (pts.isEmpty) {
      return 'Rota$edit: haritaya dokunarak waypoint ekleyin';
    }
    if (pts.length == 1) {
      return '1 nokta — devam etmek için haritaya dokunun';
    }
    var meters = 0.0;
    for (var i = 0; i < pts.length - 1; i++) {
      meters += NavGeo.haversineMeters(pts[i], pts[i + 1]);
    }
    final warn = _mapIx.shallowHit ? '\n⚠ Sığlık kesişimi!' : '';
    final land = _mapIx.landRerouteFailed
        ? '\n⚠ Kara engeli — deniz rotası bulunamadı, waypoint ekleyin'
        : (_mapIx.landRerouted
            ? '\n✓ Kara engellendi — rota denizden düzeltildi'
            : '');
    return '${pts.length} nokta · ${(meters / 1852).toStringAsFixed(2)} Nm$warn$land';
  }

  String _navLabel() {
    final target = _mapIx.navTarget;
    final name = _mapIx.navRouteName ?? 'Rota';
    final idx = _mapIx.navWaypointIndex + 1;
    final total = _mapIx.navPoints.length;
    final pos = _location.currentLatLng;
    if (target == null || pos == null) {
      return 'WP rehberi · $name · WP $idx/$total · GPS bekleniyor';
    }
    final here = ll.LatLng(pos.lat, pos.lng);
    final dist = NavGeo.haversineMeters(here, target);
    final brg = NavGeo.bearingDegrees(here, target);
    final nmeaSog = NmeaUdpListener.get.latest?.sogKnots;
    final gpsSog = _location.currentLocation?.speedKnots;
    final sog = (nmeaSog != null && nmeaSog > 0.3)
        ? nmeaSog
        : (gpsSog != null && gpsSog > 0.3 ? gpsSog : null);
    final cruise = MeraBoatProfileManager.get.profile.cruiseKnots;
    final sogLabel = sog != null
        ? 'SOG ${sog.toStringAsFixed(1)} kn'
        : 'SOG —';
    String eta = '—';
    if (sog != null) {
      final hours = (dist / 1852) / sog;
      final mins = (hours * 60).round();
      eta = mins < 60 ? '$mins dk' : '${mins ~/ 60} sa ${mins % 60} dk';
    } else if (cruise > 0) {
      final hours = (dist / 1852) / cruise;
      final mins = (hours * 60).round();
      eta = '~$mins dk @ ${cruise.toStringAsFixed(1)} kn';
    }
    final distLabel = dist < 1000
        ? '${dist.toStringAsFixed(0)} m'
        : '${(dist / 1852).toStringAsFixed(2)} Nm';
    if (_mapIx.navArrived && dist < 80) {
      return 'WP rehberi · $name · Varış! · $distLabel';
    }
    return 'WP rehberi · $name · WP $idx/$total\n'
        '$distLabel · ${brg.toStringAsFixed(0)}° · $sogLabel · ETA $eta';
  }

  Future<void> _showLayersSheet(BuildContext context) async {
    final prefs = UserPreferenceManager.get;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MeraColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(MeraRadii.lg)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            final currentType =
                MapType.fromId(prefs.mapType) ?? MapType.satellite;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: MeraColors.cardBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Harita katmanları',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Harita stili',
                      style: TextStyle(
                        color: MeraColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _mapStyleChip(
                          label: 'Deniz HD',
                          selected: currentType == MapType.ocean,
                          onTap: () async {
                            await prefs.setMapType(MapType.ocean.id);
                            setModal(() {});
                          },
                        ),
                        _mapStyleChip(
                          label: 'Uydu',
                          selected: currentType == MapType.satellite,
                          onTap: () async {
                            await prefs.setMapType(MapType.satellite.id);
                            setModal(() {});
                          },
                        ),
                        _mapStyleChip(
                          label: 'Koyu',
                          selected: currentType == MapType.dark,
                          onTap: () async {
                            await prefs.setMapType(MapType.dark.id);
                            setModal(() {});
                          },
                        ),
                        _mapStyleChip(
                          label: 'Açık',
                          selected: currentType == MapType.light,
                          onTap: () async {
                            await prefs.setMapType(MapType.light.id);
                            setModal(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Derinlik (EMODnet HD)'),
                      subtitle: const Text(
                        'Avrupa/Türkiye kıyı derinliği + kontur — ücretsiz en iyi kaynak',
                        style: TextStyle(
                          color: MeraColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      value: prefs.showMapBathymetry,
                      activeThumbColor: MeraColors.blue,
                      onChanged: (v) async {
                        await prefs.setShowMapBathymetry(v);
                        setModal(() {});
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Seamark (şamandıra / fener)'),
                      subtitle: const Text(
                        'OpenSeaMap seyir işaretleri',
                        style: TextStyle(
                          color: MeraColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      value: prefs.showMapSeamarks,
                      activeThumbColor: MeraColors.blue,
                      onChanged: (v) async {
                        await prefs.setShowMapSeamarks(v);
                        setModal(() {});
                      },
                    ),
                    const Divider(color: MeraColors.cardBorder),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.download_outlined),
                      title: const Text('Çevrimdışı bölgeler'),
                      subtitle: const Text(
                        'MBTiles paketlerini yönet',
                        style: TextStyle(
                          color: MeraColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(ctx);
                        present(context, const MapRegionPage());
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _mapStyleChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: MeraColors.blue,
      backgroundColor: MeraColors.surface,
      labelStyle: TextStyle(
        color: selected ? Colors.white : MeraColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      side: BorderSide(
        color: selected ? MeraColors.blue : MeraColors.cardBorder,
      ),
    );
  }

  Future<void> _saveRoute() async {
    // Final pass: ensure no land-crossing legs are persisted.
    _mapIx.replanDraftAroundLand();
    final pts = _mapIx.draftPoints;
    if (pts.length < 2) return;
    var meters = 0.0;
    for (var i = 0; i < pts.length - 1; i++) {
      meters += NavGeo.haversineMeters(pts[i], pts[i + 1]);
    }
    if (meters < 20) {
      showErrorSnackBar(
        context,
        'Rota çok kısa — en az iki farklı noktaya dokunun',
      );
      return;
    }
    final points = [
      for (var i = 0; i < pts.length; i++)
        MeraRoutePoint(
          lat: pts[i].latitude,
          lng: pts[i].longitude,
          label: '${i + 1}',
        ),
    ];
    final editId = _mapIx.editingRouteId;
    if (editId != null) {
      await MeraRouteManager.get.updatePoints(editId, points);
      if (!mounted) return;
      showSuccessSnackBar(context, 'Rota güncellendi');
    } else {
      final name = 'Rota ${TimeOfDay.now().format(context)}';
      await MeraRouteManager.get.add(name: name, points: points);
      if (!mounted) return;
      showSuccessSnackBar(context, 'Rota kaydedildi');
    }
    _mapIx.setRouteMode(false);
  }

  Future<void> _showPins() async {
    final spots = MeraManager.get.spots;
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MeraColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final maxH = MediaQuery.sizeOf(ctx).height * 0.55;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mera pinleri',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (spots.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Henüz pin yok — pin modu veya uzun bas ile ekleyin',
                      style: TextStyle(color: MeraColors.textSecondary),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxH),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: spots.length,
                      itemBuilder: (_, i) {
                        final s = spots[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.push_pin,
                            color: MeraColors.green,
                          ),
                          title: Text(
                            s.note?.isNotEmpty == true ? s.note! : 'Pin',
                          ),
                          subtitle: Text(
                            '${s.lat.toStringAsFixed(4)}, '
                            '${s.lng.toStringAsFixed(4)}'
                            '${s.depthM != null ? ' · ${s.depthM!.toStringAsFixed(1)} m' : ''}',
                          ),
                          onTap: () async {
                            Navigator.pop(ctx);
                            await _mapIx.centerOn(
                              LatLng(lat: s.lat, lng: s.lng),
                              zoom: 14,
                            );
                          },
                        );
                      },
                    ),
                  ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    MeraShell.goMarks();
                  },
                  icon: const Icon(Icons.place_outlined),
                  label: const Text("İşaretler'e git"),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _shareMera();
                  },
                  icon: const Icon(Icons.ios_share),
                  label: const Text('Pinleri dışa aktar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareMera() async {
    try {
      final dir = await getTemporaryDirectory();
      final path = p.join(dir.path, 'mera_export.json');
      await File(path).writeAsString(MeraManager.get.exportJson());
      if (!mounted) return;
      await SharePlusWrapper.of(context).shareFiles([XFile(path)], null);
    } catch (_) {
      if (!mounted) return;
      await SharePlusWrapper.of(
        context,
      ).share(MeraManager.get.exportJson(), null);
    }
  }
}
