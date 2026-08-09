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

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);
  MeraMapInteraction get _interaction => MeraMapInteraction.instance;

  @override
  void initState() {
    super.initState();
    _mapFuture = Future.delayed(const Duration(milliseconds: 300), () => true);
    _fmController = fm.MapController();
    _controller = FlutterMapController(_fmController);
    _interaction.addListener(_onInteractionChanged);
  }

  void _onInteractionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _interaction.removeListener(_onInteractionChanged);
    _mbtilesProvider?.close();
    _controller.dispose();
    _fmController.dispose();
    super.dispose();
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
        final baseUrl = widget.style ?? _controller.mapType.url;
        final showBathymetry = UserPreferenceManager.get.showMapBathymetry;
        final showSeamarks = UserPreferenceManager.get.showMapSeamarks;
        final routePts = _interaction.routePoints;
        final children = <Widget>[
          if (baseProvider != null)
            fm.TileLayer(tileProvider: baseProvider)
          else
            fm.TileLayer(
              urlTemplate: baseUrl,
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: mapTileUserAgentPackageName,
            ),
          if (showBathymetry)
            Opacity(
              opacity: 0.72,
              child: fm.TileLayer(
                wmsOptions: fm.WMSTileLayerOptions(
                  baseUrl: openSeaMapBathymetryWmsBaseUrl,
                  layers: const [openSeaMapBathymetryWmsLayer],
                  format: 'image/png',
                  transparent: true,
                  version: '1.1.1',
                ),
                userAgentPackageName: mapTileUserAgentPackageName,
              ),
            ),
          if (showSeamarks)
            fm.TileLayer(
              urlTemplate: openSeaMapSeamarkUrl,
              userAgentPackageName: mapTileUserAgentPackageName,
            ),
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
          fm.MarkerLayer(
            markers: [
              ..._controller.markers,
              ..._routeEndpointMarkers(routePts),
            ],
          ),
          if (widget.isMyLocationEnabled)
            _MyLocationLayer(locationMonitor: _locationMonitor),
        ];

        return fm.FlutterMap(
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
              await _interaction.handleMapLongPress(point);
              if (mounted) {
                showSuccessSnackBar(context, 'İşaret eklendi');
              }
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
