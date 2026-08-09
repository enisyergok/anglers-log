import 'package:adair_flutter_lib/widgets/async_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;
import 'package:mobile/location_monitor.dart';
import 'package:mobile/map/flutter_map_controller.dart';
import 'package:mobile/map/map_controller.dart';

import '../model/gen/anglers_log.pb.dart';
import '../utils/map_utils.dart';
import '../utils/protobuf_utils.dart';

/// A [fm.FlutterMap] wrapper with default values/functionality set for this app.
///
/// See:
///  - [StaticFishingSpotMap]
///  - [FishingSpotMap]
///  - [EditCoordinatesPage]
class DefaultMapboxMap extends StatefulWidget {
  final LatLng? startPosition;
  final double? startZoom;

  /// Optional base tile URL template override. Defaults to [MapType.of] /
  /// [FlutterMapController.mapType].
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
  // Wait for navigation animations to finish before loading the map. This
  // allows for a smooth animation.
  late final Future<bool> _mapFuture;
  late final fm.MapController _fmController;
  late final FlutterMapController _controller;

  var _didNotifyCreated = false;

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
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final baseUrl = widget.style ?? _controller.mapType.url;
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
              children: [
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
              ],
            );
          },
        );
      },
    );
  }

  void _onMapReady() {
    if (_didNotifyCreated) {
      return;
    }
    _didNotifyCreated = true;
    // Sync without relying on notify for the initial type; parent style may
    // already be set.
    _controller.setMapType(MapType.of(context));
    widget.onMapCreated?.call(_controller);
  }
}
