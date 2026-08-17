import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide MapController;
import 'package:flutter_map/flutter_map.dart' as fm;
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
            fm.MarkerLayer(markers: _buildMarkers()),
          ],
        );
      },
    );
  }

  Widget _buildMyLocationLayer() {
    return StreamBuilder<LocationPoint>(
      stream: _locationMonitor.stream,
      builder: (context, snapshot) {
        var latLng = snapshot.data?.latLng ?? _locationMonitor.currentLatLng;
        if (latLng == null) {
          return const SizedBox();
        }

        return fm.MarkerLayer(
          markers: [
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
        return SvgPicture.asset("assets/active-pin.svg");
    }
  }
}
