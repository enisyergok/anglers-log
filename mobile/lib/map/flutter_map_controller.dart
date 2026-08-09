import 'dart:math';

import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:mobile/map/map_controller.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:uuid/uuid.dart';

import '../model/gen/anglers_log.pb.dart';
import '../utils/map_utils.dart';

/// [MapController] backed by [fm.MapController] and Flutter [Marker] widgets.
class FlutterMapController extends MapController with ChangeNotifier {
  static const _basePinSize = 40.0;

  final fm.MapController mapController;

  final _symbols = <Symbol>[];
  final _tapCallbacks = <OnSymbolTappedCallback>[];
  final _log = const Log('FlutterMapController');

  VoidCallback? _onMapMoveCallback;
  var _isCameraMoving = false;
  MapType _mapType = MapType.light;
  double _attributionMarginBottom = 0;

  FlutterMapController(this.mapController);

  MapType get mapType => _mapType;

  double get attributionMarginBottom => _attributionMarginBottom;

  /// Markers for the current [symbols] list.
  List<fm.Marker> get markers =>
      _symbols.map(_markerForSymbol).toList(growable: false);

  @override
  set onMapMoveCallback(VoidCallback? callback) =>
      _onMapMoveCallback = callback;

  @override
  List<Symbol> get symbols => List.unmodifiable(_symbols);

  @override
  List<OnSymbolTappedCallback> get onSymbolTappedCallbacks =>
      List.unmodifiable(_tapCallbacks);

  @override
  bool get isCameraMoving => _isCameraMoving;

  @override
  void addOnSymbolTapped(OnSymbolTappedCallback onSymbolTapped) {
    _tapCallbacks.add(onSymbolTapped);
  }

  @override
  void removeOnSymbolTapped(OnSymbolTappedCallback onSymbolTapped) {
    if (!_tapCallbacks.remove(onSymbolTapped)) {
      _log.w("Calling removeOnSymbolTapped for a callback that doesn't exist");
    }
  }

  @override
  Future<bool> isTelemetryEnabled() => Future.value(false);

  @override
  Future<void> setTelemetryEnabled(bool enabled) => Future.value();

  @override
  Future<void> updateLogoAndAttributionMarginBottom(double marginBottom) async {
    _attributionMarginBottom = max(marginBottom, paddingDefault);
    notifyListeners();
  }

  @override
  Future<void> setMapType(MapType type) async {
    if (_mapType == type) {
      return;
    }
    _mapType = type;
    notifyListeners();
  }

  @override
  Future<void> addSymbol(Symbol symbol) => addSymbols([symbol]);

  @override
  Future<void> addSymbols(Iterable<Symbol> symbols) async {
    if (symbols.isEmpty) {
      return;
    }

    for (final symbol in symbols) {
      if (symbol.id.isEmpty) {
        symbol.id = const Uuid().v4();
      }
      _symbols.add(symbol);
    }

    _log.d('Added ${symbols.length} symbols; total: ${_symbols.length}');
    notifyListeners();
  }

  @override
  Future<void> removeSymbol(Symbol symbol) async => removeSymbols([symbol]);

  @override
  Future<void> removeSymbols(Iterable<Symbol> symbols) async {
    if (symbols.isEmpty) {
      return;
    }

    final ids = symbols.map((s) => s.id).toSet();
    _symbols.removeWhere((s) => ids.contains(s.id));

    _log.d('Deleted ${symbols.length} symbols; total: ${_symbols.length}');
    notifyListeners();
  }

  @override
  Future<void> clearSymbols() async {
    _symbols.clear();
    notifyListeners();
  }

  @override
  Future<void> updateSymbol(Symbol symbol) async {
    final index = _symbols.indexWhere((s) => s.id == symbol.id);
    if (index < 0) {
      _log.w('updateSymbol: symbol ${symbol.id} not found');
      return;
    }
    _symbols[index] = symbol;
    notifyListeners();
  }

  @override
  Future<CameraPosition> cameraPosition() async {
    final camera = mapController.camera;
    return CameraPosition(
      latLng: LatLng(lat: camera.center.latitude, lng: camera.center.longitude),
      zoom: camera.zoom,
    );
  }

  @override
  Future<void> moveCamera(CameraPosition position) async {
    mapController.move(position.latLng.toLatLong2(), position.zoom);
  }

  @override
  Future<void> animateCamera(
    CameraPosition position, {
    bool easeIn = false,
  }) async {
    // flutter_map has no built-in animation; move immediately.
    // ignore: avoid_unused_constructor_parameters
    mapController.move(position.latLng.toLatLong2(), position.zoom);
  }

  @override
  Future<void> animateToBounds(LatLngBounds? bounds) async {
    if (bounds == null) {
      return;
    }

    mapController.fitCamera(
      fm.CameraFit.bounds(
        bounds: fm.LatLngBounds(
          bounds.southwest.toLatLong2(),
          bounds.northeast.toLatLong2(),
        ),
        padding: const EdgeInsets.all(paddingXL),
      ),
    );
  }

  @override
  Future<void> setAllowSymbolOverlap(bool allowOverlap) async {
    // Markers always may overlap; nothing to configure.
  }

  @override
  Future<void> redraw() async => notifyListeners();

  /// Called from [DefaultMapboxMap] when the underlying map reports movement.
  void handleMapEvent(fm.MapEvent event) {
    if (event is fm.MapEventMoveStart) {
      _isCameraMoving = true;
      _log.d('Camera is moving');
      _onMapMoveCallback?.call();
    } else if (event is fm.MapEventMoveEnd) {
      _isCameraMoving = false;
      _log.d('Camera is not moving');
      _onMapMoveCallback?.call();
    } else if (event is fm.MapEventMove) {
      _onMapMoveCallback?.call();
    }
  }

  void _onMarkerTapped(Symbol symbol) {
    for (final callback in List.of(_tapCallbacks)) {
      callback(symbol);
    }
  }

  fm.Marker _markerForSymbol(Symbol symbol) {
    final size = _basePinSize * (symbol.options.iconSize == 0
        ? 1.0
        : symbol.options.iconSize);

    return fm.Marker(
      point: symbol.latLng.toLatLong2(),
      width: size,
      height: size,
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () => _onMarkerTapped(symbol),
        child: Transform.rotate(
          angle: symbol.options.iconRotate * pi / 180,
          child: SvgPicture.asset(
            symbol.pinAssetPath,
            width: size,
            height: size,
          ),
        ),
      ),
    );
  }
}

extension FlutterMapLatLngs on LatLng {
  ll.LatLng toLatLong2() => ll.LatLng(lat, lng);
}

extension FlutterMapSymbols on Symbol {
  static const _pinActive = 'assets/active-pin.svg';
  static const _pinInactive = 'assets/inactive-pin.svg';
  static const _pinDirectionArrow = 'assets/direction-arrow.svg';

  String get pinAssetPath {
    switch (options.pin) {
      case SymbolOptions_PinType.active:
        return _pinActive;
      case SymbolOptions_PinType.direction_arrow:
        return _pinDirectionArrow;
      default:
        return _pinInactive;
    }
  }
}
