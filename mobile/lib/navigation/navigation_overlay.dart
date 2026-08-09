import 'dart:async';
import 'dart:io';

import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/utils/date_time.dart';
import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/map/map_region_manager.dart';
import 'package:mobile/navigation/mera_manager.dart';
import 'package:mobile/navigation/marine_telemetry.dart';
import 'package:mobile/navigation/nav_geo.dart';
import 'package:mobile/navigation/nmea_udp_listener.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/wrappers/share_plus_wrapper.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../model/gen/anglers_log.pb.dart';

/// High-contrast marine HUD + BALIK ALDIM + route/mera tools on the map.
class NavigationOverlay extends StatefulWidget {
  const NavigationOverlay({super.key});

  @override
  State<NavigationOverlay> createState() => _NavigationOverlayState();
}

class _NavigationOverlayState extends State<NavigationOverlay> {
  MarineTelemetry? _telemetry;
  NmeaSnapshot? _nmea;
  StreamSubscription? _locSub;
  StreamSubscription? _nmeaSub;
  Timer? _telemetryTimer;

  ll.LatLng? _routeA;
  ll.LatLng? _routeB;
  var _routeMode = false;
  var _shallowHit = false;
  var _savingCatch = false;

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
        if (mounted) {
          setState(() {});
        }
      });
      _nmeaSub = NmeaUdpListener.get.stream.listen((s) {
        if (mounted) {
          setState(() => _nmea = s);
        }
      });
    });
  }

  @override
  void dispose() {
    _locSub?.cancel();
    _nmeaSub?.cancel();
    _telemetryTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshTelemetry() async {
    final pos = _location.currentLatLng;
    if (pos == null) {
      return;
    }
    try {
      final t = await MarineTelemetry.fetch(pos.lat, pos.lng);
      if (mounted) {
        setState(() => _telemetry = t);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final sog = _nmea?.sogKnots;
    final depth = _nmea?.depthM;
    final wind = _telemetry?.windSpeedKmh;
    final wave = _telemetry?.waveHeightM;
    final water = _telemetry?.waterTempC;

    return Stack(
      children: [
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 56, 12, 0),
              child: Material(
                color: const Color(0xE6121A24),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      color: Color(0xFFE8F1FF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Row(
                      children: [
                        _HudCell(
                          label: 'SOG',
                          value: sog != null
                              ? '${sog.toStringAsFixed(1)} kn'
                              : '—',
                        ),
                        _HudCell(
                          label: 'DERİNLİK',
                          value: depth != null
                              ? '${depth.toStringAsFixed(1)} m'
                              : '—',
                        ),
                        _HudCell(
                          label: 'RÜZGAR',
                          value: wind != null
                              ? '${wind.toStringAsFixed(0)} km/s'
                              : '—',
                        ),
                        _HudCell(
                          label: 'DALGA',
                          value: wave != null
                              ? '${wave.toStringAsFixed(1)} m'
                              : '—',
                        ),
                        _HudCell(
                          label: 'SU',
                          value: water != null
                              ? '${water.toStringAsFixed(0)}°C'
                              : '—',
                        ),
                      ],
                    ),
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
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ToolBtn(
                    icon: Icons.straighten,
                    active: _routeMode,
                    tooltip: 'Rota A–B',
                    onTap: () => setState(() {
                      _routeMode = !_routeMode;
                      if (!_routeMode) {
                        _routeA = null;
                        _routeB = null;
                        _shallowHit = false;
                      }
                    }),
                  ),
                  const SizedBox(height: 8),
                  _ToolBtn(
                    icon: Icons.wifi_tethering,
                    active: NmeaUdpListener.get.isRunning,
                    tooltip: 'NMEA UDP',
                    onTap: _toggleNmea,
                  ),
                  const SizedBox(height: 8),
                  _ToolBtn(
                    icon: Icons.ios_share,
                    tooltip: 'Mera paylaş',
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
                      : const Color(0xE6121A24),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      _routeLabel(),
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
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
              padding: const EdgeInsets.only(bottom: 24),
              child: FloatingActionButton.extended(
                heroTag: 'balik_aldim',
                backgroundColor: const Color(0xFF0B6E4F),
                foregroundColor: Colors.white,
                onPressed: _savingCatch ? null : _onBalikAldim,
                icon: _savingCatch
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.set_meal),
                label: Text(
                  _savingCatch ? 'Kaydediliyor…' : 'BALIK ALDIM',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
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

  String _routeLabel() {
    if (_routeA == null) {
      return 'Rota modu: dokun → nokta A (mevcut GPS)';
    }
    if (_routeB == null) {
      return 'Nokta B için tekrar dokun (mevcut GPS)';
    }
    final dist = NavGeo.haversineMeters(_routeA!, _routeB!);
    final brg = NavGeo.bearingDegrees(_routeA!, _routeB!);
    final warn = _shallowHit ? '\n⚠ Sığlık poligonu ile kesişiyor!' : '';
    return 'Mesafe: ${(dist / 1852).toStringAsFixed(2)} Nm  ·  '
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

  Future<void> _toggleNmea() async {
    final nmea = NmeaUdpListener.get;
    try {
      if (nmea.isRunning) {
        await nmea.stop();
        showNoticeSnackBar(context, 'NMEA dinleyici kapalı');
      } else {
        await nmea.start(port: 10110);
        showSuccessSnackBar(context, 'NMEA UDP :10110 dinleniyor');
      }
      setState(() {});
    } catch (e) {
      showErrorSnackBar(context, 'NMEA: $e');
    }
  }

  Future<void> _shareMera() async {
    try {
      final dir = await getTemporaryDirectory();
      final path = p.join(dir.path, 'mera_export.json');
      await File(path).writeAsString(MeraManager.get.exportJson());
      await SharePlusWrapper.of(context).shareFiles([XFile(path)], null);
    } catch (e) {
      await SharePlusWrapper.of(
        context,
      ).share(MeraManager.get.exportJson(), null);
    }
  }

  Future<void> _onBalikAldim() async {
    setState(() => _savingCatch = true);
    try {
      final speciesList = SpeciesManager.of(context).list();
      if (speciesList.isEmpty) {
        showErrorSnackBar(context, 'Önce bir tür ekleyin (Diğer → Türler)');
        return;
      }
      final species = speciesList.first;
      final now = TimeManager.get.currentDateTime;
      final loc = _location.currentLatLng;

      Id? spotId;
      if (loc != null) {
        final spot = FishingSpot()
          ..id = randomId()
          ..lat = loc.lat
          ..lng = loc.lng
          ..name =
              'Hızlı av ${now.hour}:${now.minute.toString().padLeft(2, '0')}'
          ..notes =
              'BALIK ALDIM'
              '${_nmea?.depthM != null ? ' | derinlik=${_nmea!.depthM!.toStringAsFixed(1)}m' : ''}';
        await FishingSpotManager.get.addOrUpdate(spot);
        spotId = spot.id;

        await MeraManager.get.add(
          lat: loc.lat,
          lng: loc.lng,
          depthM: _nmea?.depthM,
          bottomType: 'hızlı-av',
          note: 'BALIK ALDIM',
        );
      }

      final cat = Catch()
        ..id = randomId()
        ..timestamp = Int64(now.millisecondsSinceEpoch)
        ..timeZone = now.locationName
        ..speciesId = species.id;
      if (spotId != null) {
        cat.fishingSpotId = spotId;
      }

      final ok = await CatchManager.get.addOrUpdate(cat);
      if (!mounted) {
        return;
      }
      if (ok) {
        showSuccessSnackBar(context, 'Av kaydedildi (${species.name})');
      } else {
        showErrorSnackBar(context, 'Av kaydedilemedi');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Hata: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _savingCatch = false);
      }
    }
  }
}

class _HudCell extends StatelessWidget {
  final String label;
  final String value;

  const _HudCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF8FA3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool active;

  const _ToolBtn({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? const Color(0xFF1B6CA8) : const Color(0xE6121A24),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}
