import 'package:adair_flutter_lib/widgets/async_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;
import 'package:mobile/location_monitor.dart';
import 'package:mobile/map/flutter_map_controller.dart';
import 'package:mobile/map/map_controller.dart';
import 'package:mobile/map/map_region_manager.dart';
import 'package:mobile/map/mbtiles_tile_provider.dart';

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

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);

  @override
  void initState() {
    super.initState();
    _mapFuture = Future.delayed(const Duration(milliseconds: 300), () => true);
    _fmController = fm.MapController();
    _controller = FlutterMapController(_fmController);
  }

  @override
  void dispose() {
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
            return FutureBuilder<String?>(
              future: MapRegionManager.get.activeMbtilesPath(),
              builder: (context, pathSnap) {
                final path = pathSnap.data;
                if (path != null) {
                  return FutureBuilder<MbtilesTileProvider>(
                    future: _openMbtiles(path),
                    builder: (context, providerSnap) {
                      if (!providerSnap.hasData) {
                        if (providerSnap.hasError) {
                          return _buildMap(context, start);
                        }
                        return const Center(child: CircularProgressIndicator());
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
        final children = <Widget>[
          if (baseProvider != null)
            fm.TileLayer(tileProvider: baseProvider)
          else
            fm.TileLayer(
              urlTemplate: baseUrl,
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: mapTileUserAgentPackageName,
            ),
          fm.TileLayer(
            urlTemplate: openSeaMapSeamarkUrl,
            userAgentPackageName: mapTileUserAgentPackageName,
          ),
          fm.MarkerLayer(markers: _controller.markers),
        ];

        return fm.FlutterMap(
          mapController: _fmController,
          options: fm.MapOptions(
            initialCenter: ll.LatLng(start.lat, start.lng),
            initialZoom:
                start.lat == 0 ? 0 : widget.startZoom ?? mapZoomDefault,
            onMapReady: _onMapReady,
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

  void _onMapReady() {
    if (_didNotifyCreated) {
      return;
    }
    _didNotifyCreated = true;
    _controller.setMapType(MapType.of(context));

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
