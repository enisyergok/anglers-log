import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide MapController;
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:mobile/map/map_controller.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:uuid/uuid.dart';

class FlutterMapController extends MapController with ChangeNotifier {
  final fm.MapController fmController;

  final _symbols = <Symbol>[];
  final _tapCallbacks = <OnSymbolTappedCallback>[];

  MapType _mapType;
  VoidCallback? _onMapMoveCallback;
  var _isCameraMoving = false;

  FlutterMapController(this.fmController, {required MapType mapType})
    : _mapType = mapType {
    fmController.mapEventStream.listen(_onMapEvent);
  }

  MapType get mapType => _mapType;

  @override
  set onMapMoveCallback(VoidCallback? callback) =>
      _onMapMoveCallback = callback;

  @override
  bool get isCameraMoving => _isCameraMoving;

  @override
  List<Symbol> get symbols => List.unmodifiable(_symbols);

  @override
  List<OnSymbolTappedCallback> get onSymbolTappedCallbacks =>
      List.unmodifiable(_tapCallbacks);

  @override
  void addOnSymbolTapped(OnSymbolTappedCallback onSymbolTapped) =>
      _tapCallbacks.add(onSymbolTapped);

  @override
  void removeOnSymbolTapped(OnSymbolTappedCallback onSymbolTapped) =>
      _tapCallbacks.remove(onSymbolTapped);

  /// Invoked by the marker widget built for a [Symbol] when it's tapped.
  void handleSymbolTap(Symbol symbol) {
    for (var callback in List.of(_tapCallbacks)) {
      callback(symbol);
    }
  }

  @override
  Future<void> addSymbol(Symbol symbol) => addSymbols([symbol]);

  @override
  Future<void> addSymbols(Iterable<Symbol> symbols) async {
    if (symbols.isEmpty) {
      return;
    }

    for (var symbol in symbols) {
      _symbols.add(symbol..id = const Uuid().v4());
    }
    notifyListeners();
  }

  @override
  Future<void> removeSymbol(Symbol symbol) => removeSymbols([symbol]);

  @override
  Future<void> removeSymbols(Iterable<Symbol> symbols) async {
    if (symbols.isEmpty) {
      return;
    }

    var ids = symbols.map((e) => e.id).toSet();
    _symbols.removeWhere((e) => ids.contains(e.id));
    notifyListeners();
  }

  @override
  Future<void> clearSymbols() async {
    _symbols.clear();
    notifyListeners();
  }

  @override
  Future<void> updateSymbol(Symbol symbol) async {
    var index = _symbols.indexWhere((e) => e.id == symbol.id);
    if (index >= 0) {
      _symbols[index] = symbol;
      notifyListeners();
    }
  }

  @override
  Future<void> setAllowSymbolOverlap(bool allowOverlap) async {
    // No native overlap-culling concept in flutter_map's basic MarkerLayer;
    // all symbols are always rendered, so there's nothing to toggle.
  }

  @override
  Future<CameraPosition> cameraPosition() async {
    var camera = fmController.camera;
    return CameraPosition(
      latLng: LatLng(lat: camera.center.latitude, lng: camera.center.longitude),
      zoom: camera.zoom,
    );
  }

  @override
  Future<void> moveCamera(CameraPosition position) async {
    fmController.move(position.latLng.point, position.zoom);
  }

  @override
  Future<void> animateCamera(
    CameraPosition position, {
    bool easeIn = false,
  }) async {
    // flutter_map's MapController.move() is instantaneous; no built-in
    // easing/flying animation is used here.
    fmController.move(position.latLng.point, position.zoom);
  }

  @override
  Future<void> animateToBounds(LatLngBounds? bounds) async {
    if (bounds == null) {
      return;
    }

    fmController.fitCamera(
      fm.CameraFit.bounds(
        bounds: fm.LatLngBounds(
          bounds.southwest.point,
          bounds.northeast.point,
        ),
        padding: const EdgeInsets.all(48),
      ),
    );
  }

  @override
  Future<void> updateLogoAndAttributionMarginBottom(double marginBottom) async {
    // Attribution is rendered by MapAttribution, a widget positioned by the
    // caller; there's no native ornament to offset here.
  }

  @override
  Future<void> setMapType(MapType type) async {
    _mapType = type;
    notifyListeners();
  }

  @override
  Future<void> redraw() async {
    // flutter_map repaints reactively; nothing to trigger manually.
  }

  /// Simulates a gesture-driven camera move for widget tests, since
  /// programmatic [fm.MapController] moves don't emit the same
  /// [fm.MapEventMoveStart]/[fm.MapEventMoveEnd] events a real drag gesture
  /// does.
  @visibleForTesting
  void debugSimulateMapMove({bool isMoving = false}) {
    _isCameraMoving = isMoving;
    _onMapMoveCallback?.call();
  }

  void _onMapEvent(fm.MapEvent event) {
    if (event is fm.MapEventMoveStart) {
      _isCameraMoving = true;
    } else if (event is fm.MapEventMoveEnd) {
      _isCameraMoving = false;
    }
    _onMapMoveCallback?.call();
  }
}

extension FlutterMapLatLngs on LatLng {
  latlong.LatLng get point => latlong.LatLng(lat, lng);
}

extension FlutterMapLatLngBoundsExt on fm.LatLngBounds {
  LatLngBounds get toLatLngBounds => LatLngBounds(
    southwest: LatLng(lat: southWest.latitude, lng: southWest.longitude),
    northeast: LatLng(lat: northEast.latitude, lng: northEast.longitude),
  );
}
