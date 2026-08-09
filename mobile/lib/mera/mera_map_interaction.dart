import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:mobile/map/map_controller.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart' as pb;
import 'package:mobile/utils/map_utils.dart';

/// Shared map interaction state between [MeraMapHud] and [DefaultMapboxMap].
class MeraMapInteraction extends ChangeNotifier {
  static final MeraMapInteraction instance = MeraMapInteraction._();

  MeraMapInteraction._();

  MapController? mapController;

  bool routeMode = false;
  ll.LatLng? routeA;
  ll.LatLng? routeB;
  bool shallowHit = false;

  void attachMap(MapController controller) {
    mapController = controller;
  }

  void setRouteMode(bool enabled) {
    if (routeMode == enabled) return;
    routeMode = enabled;
    if (!enabled) {
      routeA = null;
      routeB = null;
      shallowHit = false;
    }
    notifyListeners();
  }

  void clearRoute() {
    routeA = null;
    routeB = null;
    shallowHit = false;
    notifyListeners();
  }

  /// Place A / B from a map tap (not GPS).
  void handleMapTap(ll.LatLng point) {
    if (!routeMode) return;
    if (routeA == null || routeB != null) {
      routeA = point;
      routeB = null;
      shallowHit = false;
    } else {
      routeB = point;
    }
    notifyListeners();
  }

  void setShallowHit(bool hit) {
    if (shallowHit == hit) return;
    shallowHit = hit;
    notifyListeners();
  }

  List<ll.LatLng> get routePoints {
    final a = routeA;
    final b = routeB;
    if (a == null) return const [];
    if (b == null) return [a];
    return [a, b];
  }

  Future<void> centerOn(pb.LatLng? loc, {double zoom = mapZoomDefault}) async {
    if (loc == null || mapController == null) return;
    await mapController!.animateCamera(
      pb.CameraPosition(latLng: loc, zoom: zoom),
    );
  }
}
