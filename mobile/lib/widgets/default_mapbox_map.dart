import 'dart:async';
import 'dart:math' as math;

import 'package:adair_flutter_lib/widgets/async_builder.dart';
import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;
import 'package:mobile/location_monitor.dart';
import 'package:mobile/map/flutter_map_controller.dart';
import 'package:mobile/map/map_controller.dart';
import 'package:mobile/map/map_region_manager.dart';
import 'package:mobile/map/mbtiles_tile_provider.dart';
import 'package:mobile/mera/mera_map_interaction.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/mera/mera_track_manager.dart';
import 'package:mobile/navigation/depth_sampler.dart';
import 'package:mobile/navigation/mera_manager.dart';
import 'package:mobile/user_preference_manager.dart';

import '../model/gen/anglers_log.pb.dart';
import '../utils/map_utils.dart';
import '../utils/protobuf_utils.dart';

/// A [fm.FlutterMap] wrapper with default values/functionality set for this app.
///
/// Uses online OSM tiles by default. When [MapRegionManager] has an active
/// regional MBTiles package, that file becomes the base layer (offline-first).
///
/// See:
///  - [StaticFishingSpotMap]
///  - [FishingSpotMap]
///  - [EditCoordinatesPage]
class DefaultMapboxMap extends StatefulWidget {
  final LatLng? startPosition;
  final double? startZoom;

  /// Optional base tile URL template override. Defaults to [MapType.of] /
  /// [FlutterMapController.mapType]. Ignored when an MBTiles region is active.
  final String? style;
  final bool isMyLocationEnabled;

  final void Function(MapController)? onMapCreated;

  /// Called when the map finishes moving (idle).
  final VoidCallback? onMapIdle;

  /// Called whenever the camera position changes.
  final ValueChanged<fm.MapCamera>? onCameraChangeListener;

  const DefaultMapboxMap({
    this.startPosition,
    super.key,
    this.startZoom,
    this.style,
    this.isMyLocationEnabled = false,
    this.onMapCreated,
    this.onMapIdle,
    this.onCameraChangeListener,
  });

  @override
  State<DefaultMapboxMap> createState() => _DefaultMapboxMapState();
}

class _DefaultMapboxMapState extends State<DefaultMapboxMap> {
  late final Future<bool> _mapFuture;
  late final fm.MapController _fmController;
  late final FlutterMapController _controller;

  var _didNotifyCreated = false;
  MbtilesTileProvider? _mbtilesProvider;
  String? _mbtilesPath;
  Future<MbtilesTileProvider>? _mbtilesFuture;
  StreamSubscription? _trackSub;

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);
  MeraMapInteraction get _interaction => MeraMapInteraction.instance;

  @override
  void initState() {
    super.initState();
    _mapFuture = Future.delayed(const Duration(milliseconds: 300), () => true);
    _fmController = fm.MapController();
    _controller = FlutterMapController(_fmController);
    _interaction.addListener(_onInteractionChanged);
    MeraTrackManager.get.ensureLoaded();
    _trackSub = MeraTrackManager.get.stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  void _onInteractionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _trackSub?.cancel();
    _interaction.removeListener(_onInteractionChanged);
    _mbtilesProvider?.close();
    _controller.dispose();
    _fmController.dispose();
    super.dispose();
  }

  Future<void> _showDepthProbe(BuildContext context, ll.LatLng point) async {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: MeraColors.card,
      builder: (ctx) {
        return FutureBuilder<double?>(
          future: DepthSampler.sampleMeters(
            lat: point.latitude,
            lng: point.longitude,
          ),
          builder: (context, snap) {
            final waiting = snap.connectionState != ConnectionState.done;
            final depth = snap.data;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nokta derinliği',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${point.latitude.toStringAsFixed(5)}, '
                      '${point.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(
                        color: MeraColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (waiting)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (depth != null)
                      Text(
                        '≈ ${depth.toStringAsFixed(1)} m (EMODnet, yaklaşık)',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: MeraColors.blue,
                        ),
                      )
                    else
                      const Text(
                        'Derinlik alınamadı — çevrimdışı veya nokta karada olabilir.',
                        style: TextStyle(color: MeraColors.textSecondary),
                      ),
                    const SizedBox(height: 8),
                    const Text(
                      'Resmi seyir derinliği değildir.',
                      style: TextStyle(
                        color: MeraColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Kapat'),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: () async {
                            await MeraManager.get.add(
                              lat: point.latitude,
                              lng: point.longitude,
                              depthM: depth,
                              note: 'Harita pini',
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              showSuccessSnackBar(context, 'İşaret eklendi');
                            }
                          },
                          icon: const Icon(Icons.push_pin),
                          label: const Text('İşaret ekle'),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    final start =
        widget.startPosition ?? _locationMonitor.currentLatLng ?? LatLngs.zero;

    return AsyncBuilder<bool>.future(
      future: _mapFuture,
      errorReason: 'Loading map',
      builder: (context, _) {
        return StreamBuilder<void>(
          stream: MapRegionManager.get.stream,
          builder: (context, _) {
            return StreamBuilder<String>(
              stream: UserPreferenceManager.get.stream,
              builder: (context, _) {
                return FutureBuilder<String?>(
                  future: MapRegionManager.get.activeMbtilesPath(),
                  builder: (context, pathSnap) {
                    final path = pathSnap.data;
                    if (path != null) {
                      return FutureBuilder<MbtilesTileProvider>(
                        future: _mbtilesFutureFor(path),
                        builder: (context, providerSnap) {
                          if (!providerSnap.hasData) {
                            if (providerSnap.hasError) {
                              return _buildMap(context, start);
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return _buildMap(
                            context,
                            start,
                            baseProvider: providerSnap.data,
                          );
                        },
                      );
                    }
                    return _buildMap(context, start);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<MbtilesTileProvider> _mbtilesFutureFor(String path) {
    if (_mbtilesPath == path && _mbtilesFuture != null) {
      return _mbtilesFuture!;
    }
    _mbtilesPath = path;
    _mbtilesFuture = _openMbtiles(path);
    return _mbtilesFuture!;
  }

  Future<MbtilesTileProvider> _openMbtiles(String path) async {
    await _mbtilesProvider?.close();
    _mbtilesProvider = await MbtilesTileProvider.open(path);
    return _mbtilesProvider!;
  }

  Widget _buildMap(
    BuildContext context,
    LatLng start, {
    fm.TileProvider? baseProvider,
  }) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final mapType = _controller.mapType;
        final baseUrl = widget.style ?? mapType.url;
        final showBathymetry = UserPreferenceManager.get.showMapBathymetry;
        final showSeamarks = UserPreferenceManager.get.showMapSeamarks;
        final marine = baseUrl == MapType.ocean.url;
        final retina = MediaQuery.devicePixelRatioOf(context) > 1.5;
        final routePts = _interaction.routePoints;
        final trackPts = MeraTrackManager.get.livePoints
            .map((p) => ll.LatLng(p.lat, p.lng))
            .toList();

        Widget xyz(String url, {int maxNativeZoom = 18}) {
          return fm.TileLayer(
            urlTemplate: url,
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: mapTileUserAgentPackageName,
            maxZoom: 20,
            maxNativeZoom: maxNativeZoom,
            keepBuffer: 4,
            panBuffer: 2,
            retinaMode: retina,
            tileDisplay: const fm.TileDisplay.fadeIn(
              duration: Duration(milliseconds: 120),
            ),
          );
        }

        Widget wms({
          required String base,
          required List<String> layers,
          List<String> styles = const [],
          int maxNativeZoom = 14,
        }) {
          return fm.TileLayer(
            wmsOptions: fm.WMSTileLayerOptions(
              baseUrl: base,
              layers: layers,
              styles: styles,
              format: 'image/png',
              transparent: true,
              version: '1.1.1',
            ),
            userAgentPackageName: mapTileUserAgentPackageName,
            maxZoom: 18,
            maxNativeZoom: maxNativeZoom,
            keepBuffer: 3,
            panBuffer: 1,
            retinaMode: retina,
            tileDisplay: const fm.TileDisplay.fadeIn(
              duration: Duration(milliseconds: 140),
            ),
          );
        }

        final children = <Widget>[
          if (baseProvider != null)
            fm.TileLayer(tileProvider: baseProvider)
          else
            xyz(baseUrl, maxNativeZoom: marine ? 16 : 19),

          // Best free European coastal depth (EMODnet multicolour + contours).
          if (showBathymetry && marine) ...[
            Opacity(
              opacity: 0.58,
              child: wms(
                base: emodnetBathymetryWmsBaseUrl,
                layers: const [emodnetBathymetryWmsLayer],
                styles: const [emodnetBathymetryWmsStyle],
                maxNativeZoom: 13,
              ),
            ),
            Opacity(
              opacity: 0.78,
              child: wms(
                base: emodnetBathymetryWmsBaseUrl,
                layers: const [emodnetContoursWmsLayer],
                maxNativeZoom: 14,
              ),
            ),
          ],

          // Other basemaps: global GEBCO depth when toggle is on.
          if (showBathymetry && !marine)
            Opacity(
              opacity: 0.7,
              child: wms(
                base: openSeaMapBathymetryWmsBaseUrl,
                layers: const [openSeaMapBathymetryWmsLayer],
                maxNativeZoom: 12,
              ),
            ),

          // Chart-like labels / contours (Esri free Ocean Reference).
          if (marine) xyz(esriOceanReferenceUrl, maxNativeZoom: 16),

          if (showSeamarks) xyz(openSeaMapSeamarkUrl, maxNativeZoom: 18),

          if (routePts.length >= 2)
            fm.PolylineLayer(
              polylines: [
                fm.Polyline(
                  points: routePts,
                  strokeWidth: 4,
                  color: _interaction.shallowHit
                      ? const Color(0xFFFF514B)
                      : MeraColors.blue,
                ),
              ],
            ),
          if (trackPts.length >= 2)
            fm.PolylineLayer(
              polylines: [
                fm.Polyline(
                  points: trackPts,
                  strokeWidth: 3.5,
                  color: const Color(0xFFE8A838),
                ),
              ],
            ),
          fm.MarkerLayer(
            markers: [
              ..._controller.markers,
              ..._routeEndpointMarkers(routePts),
            ],
          ),
          if (widget.isMyLocationEnabled)
            _MyLocationLayer(locationMonitor: _locationMonitor),
        ];

        return Stack(
          fit: StackFit.expand,
          children: [
            fm.FlutterMap(
              mapController: _fmController,
              options: fm.MapOptions(
                initialCenter: ll.LatLng(start.lat, start.lng),
                initialZoom:
                    start.lat == 0 ? 0 : widget.startZoom ?? mapZoomDefault,
                onMapReady: _onMapReady,
                onTap: (_, point) async {
                  if (_interaction.routeMode || _interaction.pinMode) {
                    final wasPin = _interaction.pinMode;
                    await _interaction.handleMapTap(point);
                    if (wasPin && mounted) {
                      showSuccessSnackBar(context, 'İşaret eklendi');
                    }
                  }
                },
                onLongPress: (_, point) async {
                  if (_interaction.routeMode) return;
                  if (_interaction.pinMode) {
                    await _interaction.handleMapLongPress(point);
                    if (mounted) {
                      showSuccessSnackBar(context, 'İşaret eklendi');
                    }
                    return;
                  }
                  await _showDepthProbe(context, point);
                },
                onMapEvent: (event) {
                  _controller.handleMapEvent(event);
                  if (event is fm.MapEventMove) {
                    widget.onCameraChangeListener?.call(event.camera);
                  }
                  if (event is fm.MapEventMoveEnd) {
                    widget.onMapIdle?.call();
                  }
                },
              ),
              children: children,
            ),
            const Positioned(
              left: 8,
              right: 8,
              bottom: 6,
              child: IgnorePointer(
                child: Text(
                  'Resmi seyir haritası değildir',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xB3FFFFFF),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(color: Color(0x99000000), blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<fm.Marker> _routeEndpointMarkers(List<ll.LatLng> pts) {
    if (pts.isEmpty) return const [];
    final markers = <fm.Marker>[];
    final navIdx = _interaction.navActive
        ? _interaction.navWaypointIndex
        : -1;
    for (var i = 0; i < pts.length; i++) {
      final isTarget = i == navIdx;
      final label = i == 0
          ? 'A'
          : (i == pts.length - 1 ? 'B' : '${i + 1}');
      markers.add(
        _endpointMarker(
          pts[i],
          label,
          isTarget
              ? MeraColors.green
              : (i == 0
                  ? MeraColors.green
                  : (i == pts.length - 1
                      ? MeraColors.warning
                      : MeraColors.blue)),
        ),
      );
    }
    return markers;
  }

  fm.Marker _endpointMarker(ll.LatLng point, String label, Color color) {
    return fm.Marker(
      point: point,
      width: 34,
      height: 34,
      alignment: Alignment.center,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0x66000000), blurRadius: 6),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _onMapReady() {
    if (_didNotifyCreated) {
      return;
    }
    _didNotifyCreated = true;
    _controller.setMapType(MapType.of(context));
    _interaction.attachMap(_controller);

    final region = MapRegionManager.get.activeRegion;
    if (region != null) {
      _fmController.move(
        ll.LatLng(region.center.latitude, region.center.longitude),
        region.initialZoom,
      );
    }

    widget.onMapCreated?.call(_controller);
  }
}

/// Large, high-contrast GPS marker (Siren-style boat + halo).
class _MyLocationLayer extends StatelessWidget {
  const _MyLocationLayer({required this.locationMonitor});

  final LocationMonitor locationMonitor;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LocationPoint>(
      stream: locationMonitor.stream,
      builder: (context, snap) {
        final loc = snap.data ?? locationMonitor.currentLocation;
        if (loc == null || !loc.isValid) {
          return const SizedBox.shrink();
        }
        final heading = loc.heading;
        final hasHeading =
            heading != null && !heading.isNaN && heading >= 0 && heading <= 360;
        return fm.MarkerLayer(
          markers: [
            fm.Marker(
              point: ll.LatLng(loc.lat, loc.lng),
              width: 72,
              height: 72,
              alignment: Alignment.center,
              child: IgnorePointer(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MeraColors.blue.withValues(alpha: 0.22),
                        border: Border.all(
                          color: MeraColors.blue.withValues(alpha: 0.55),
                          width: 2,
                        ),
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MeraColors.blue,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x99000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    if (hasHeading)
                      Transform.rotate(
                        angle: heading * math.pi / 180,
                        child: const Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 16,
                        ),
                      )
                    else
                      const Icon(
                        Icons.directions_boat_filled,
                        color: Colors.white,
                        size: 14,
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
