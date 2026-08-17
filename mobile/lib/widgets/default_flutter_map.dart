import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide MapController;
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/map/flutter_map_controller.dart';
import 'package:mobile/map/map_controller.dart';
import 'package:mobile/widgets/static_fishing_spot_map.dart';

import '../model/gen/anglers_log.pb.dart';
import '../tile_cache_manager.dart';
import '../utils/map_utils.dart';
import '../utils/protobuf_utils.dart';

/// A [fm.FlutterMap] wrapper with default values/functionality set for this
/// app.
///
/// See:
///  - [StaticFishingSpotMap]
///  - [FishingSpotMap]
///  - [EditCoordinatesPage]
class DefaultFlutterMap extends StatefulWidget {
  final LatLng? startPosition;
  final double? startZoom;
  final MapType? mapType;
  final bool isMyLocationEnabled;

  final void Function(MapController)? onMapCreated;

  const DefaultFlutterMap({
    this.startPosition,
    Key? key,
    this.startZoom,
    this.mapType,
    this.isMyLocationEnabled = false,
    this.onMapCreated,
  });

  @override
  State<DefaultFlutterMap> createState() => _DefaultFlutterMapState();
}

class _DefaultFlutterMapState extends State<DefaultFlutterMap> {
  static const _pinSize = 30.0;
  static const _myLocationSize = 16.0;
  static const _myLocationConeSize = 60.0;
  static const _clusterSize = 40.0;

  late final fm.MapController _fmController;
  late final FlutterMapController _controller;
  var _didResolveContextMapType = false;

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);

  /// Exposed for tests to grab the real, already-created controller (see
  /// `StubbedMapController`) rather than trying to inject a substitute
  /// before [initState] synchronously invokes [DefaultFlutterMap.onMapCreated].
  @visibleForTesting
  FlutterMapController get controller => _controller;

  @override
  void initState() {
    super.initState();
    _fmController = fm.MapController();
    _controller = FlutterMapController(
      _fmController,
      mapType: widget.mapType ?? MapType.light,
    );
    widget.onMapCreated?.call(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // The default MapType depends on the current theme, which isn't
    // available until dependencies are resolved.
    if (!_didResolveContextMapType) {
      _didResolveContextMapType = true;
      if (widget.mapType == null) {
        _controller.setMapType(MapType.of(context));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var start =
        widget.startPosition ?? _locationMonitor.currentLatLng ?? LatLngs.zero;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        var mapType = _controller.mapType;

        return fm.FlutterMap(
          mapController: _fmController,
          options: fm.MapOptions(
            initialCenter: start.point,
            initialZoom: start.isSameLocation(LatLngs.zero)
                ? 2
                : widget.startZoom ?? mapZoomDefault,
          ),
          children: [
            fm.TileLayer(
              urlTemplate: mapType.urlTemplate,
              subdomains: mapType.subdomains,
              userAgentPackageName: "com.cohenadair.anglerslog",
              tileProvider: TileCacheManager.of(context).tileProvider(mapType),
            ),
            if (widget.isMyLocationEnabled) _buildMyLocationLayer(),
            _buildMarkerClusterLayer(),
          ],
        );
      },
    );
  }

  Widget _buildMyLocationLayer() {
    return StreamBuilder<LocationPoint>(
      stream: _locationMonitor.stream,
      builder: (context, snapshot) {
        var location = snapshot.data;
        var latLng = location?.latLng ?? _locationMonitor.currentLatLng;
        if (latLng == null) {
          return const SizedBox();
        }

        var heading = location?.heading;

        return fm.MarkerLayer(
          markers: [
            if (heading != null)
              fm.Marker(
                point: latLng.point,
                width: _myLocationConeSize,
                height: _myLocationConeSize,
                child: Transform.rotate(
                  angle: heading * (pi / 180),
                  child: CustomPaint(painter: _LocationConePainter()),
                ),
              ),
            fm.Marker(
              point: latLng.point,
              width: _myLocationSize,
              height: _myLocationSize,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMarkerClusterLayer() {
    return MarkerClusterLayerWidget(
      options: MarkerClusterLayerOptions(
        maxClusterRadius: 45,
        size: const Size(_clusterSize, _clusterSize),
        markers: _buildMarkers(),
        builder: (context, markers) => _buildClusterIcon(markers.length),
      ),
    );
  }

  List<fm.Marker> _buildMarkers() {
    return _controller.symbols.map((symbol) {
      return fm.Marker(
        point: symbol.latLng.point,
        width: _pinSize,
        height: _pinSize,
        child: GestureDetector(
          onTap: () => _controller.handleSymbolTap(symbol),
          child: _buildSymbolIcon(symbol),
        ),
      );
    }).toList();
  }

  Widget _buildClusterIcon(int count) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      alignment: Alignment.center,
      child: Text(
        "$count",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSymbolIcon(Symbol symbol) {
    switch (symbol.options.pin) {
      case SymbolOptions_PinType.direction_arrow:
        return Transform.rotate(
          angle: symbol.options.iconRotate * (3.14159265 / 180),
          child: const Icon(Icons.navigation, color: Colors.blue, size: 20),
        );
      case SymbolOptions_PinType.inactive:
        return Opacity(
          opacity: 0.55,
          child: SvgPicture.asset("assets/active-pin.svg"),
        );
      case SymbolOptions_PinType.active:
      default:
        return SvgPicture.asset("assets/active-pin.svg");
    }
  }
}

/// Draws a cone pointing "up" (north), representing device heading. The
/// containing widget is expected to rotate this to the actual heading.
class _LocationConePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var center = Offset(size.width / 2, size.height / 2);
    var path = Path()
      ..moveTo(center.dx, 0)
      ..lineTo(size.width * 0.2, size.height * 0.6)
      ..arcToPoint(
        Offset(size.width * 0.8, size.height * 0.6),
        radius: Radius.circular(size.width * 0.4),
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = Colors.blue.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
