import 'dart:math' as math;

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
  /// When set, saving the draft updates this route instead of creating one.
  String? editingRouteId;
  /// Multi-waypoint draft (route draw / edit).
  List<ll.LatLng> draftPoints = [];
  bool shallowHit = false;

  /// Active waypoint navigation (GPS → next waypoint guidance).
  bool navActive = false;
  String? navRouteName;
  List<ll.LatLng> navPoints = [];
  int navWaypointIndex = 0;

  void attachMap(MapController controller) {
    mapController = controller;
  }

  void setRouteMode(bool enabled) {
    if (!enabled) {
      if (!routeMode && editingRouteId == null && draftPoints.isEmpty) return;
      routeMode = false;
      editingRouteId = null;
      draftPoints = [];
      shallowHit = false;
      notifyListeners();
      return;
    }
    if (navActive) stopNavigation();
    routeMode = true;
    if (editingRouteId == null) {
      draftPoints = [];
    }
    shallowHit = false;
    notifyListeners();
  }

  void clearRoute() {
    editingRouteId = null;
    draftPoints = [];
    shallowHit = false;
    notifyListeners();
  }

  /// Clear waypoints but keep [editingRouteId] so save still updates.
  void clearDraftPoints() {
    draftPoints = [];
    shallowHit = false;
    notifyListeners();
  }

  /// Load an existing route for in-place geometry edit.
  Future<void> beginEditRoute({
    required String routeId,
    required List<ll.LatLng> points,
  }) async {
    if (navActive) stopNavigation();
    routeMode = true;
    editingRouteId = routeId;
    draftPoints = List<ll.LatLng>.from(points);
    shallowHit = false;
    notifyListeners();
    if (points.isNotEmpty && mapController != null) {
      if (points.length >= 2) {
        final mid = ll.LatLng(
          (points.first.latitude + points.last.latitude) / 2,
          (points.first.longitude + points.last.longitude) / 2,
        );
        await centerOnLatLng(mid, zoom: 12);
      } else {
        await centerOnLatLng(points.first, zoom: 13);
      }
    }
  }

  /// Append a waypoint from a map tap.
  void handleMapTap(ll.LatLng point) {
    if (!routeMode) return;
    draftPoints = [...draftPoints, point];
    notifyListeners();
  }

  void undoLastWaypoint() {
    if (draftPoints.isEmpty) return;
    draftPoints = List<ll.LatLng>.from(draftPoints)..removeLast();
    shallowHit = false;
    notifyListeners();
  }

  void setShallowHit(bool hit) {
    if (shallowHit == hit) return;
    shallowHit = hit;
    notifyListeners();
  }

  List<ll.LatLng> get routePoints {
    if (navActive && navPoints.isNotEmpty) return navPoints;
    return List<ll.LatLng>.unmodifiable(draftPoints);
  }

  ll.LatLng? get routeA => draftPoints.isEmpty ? null : draftPoints.first;
  ll.LatLng? get routeB =>
      draftPoints.length < 2 ? null : draftPoints.last;

  Future<void> centerOn(pb.LatLng? loc, {double zoom = mapZoomDefault}) async {
    if (loc == null || mapController == null) return;
    await mapController!.animateCamera(
      pb.CameraPosition(latLng: loc, zoom: zoom),
    );
  }

  Future<void> centerOnLatLng(
    ll.LatLng loc, {
    double zoom = mapZoomDefault,
  }) async {
    await centerOn(pb.LatLng(lat: loc.latitude, lng: loc.longitude), zoom: zoom);
  }

  /// Show a route polyline without entering edit mode.
  Future<void> previewRoute(
    List<ll.LatLng> points, {
    bool center = true,
  }) async {
    if (points.isEmpty) return;
    if (navActive) stopNavigation();
    routeMode = false;
    editingRouteId = null;
    draftPoints = List<ll.LatLng>.from(points);
    shallowHit = false;
    notifyListeners();
    if (center && mapController != null) {
      if (points.length >= 2) {
        final mid = ll.LatLng(
          (points.first.latitude + points.last.latitude) / 2,
          (points.first.longitude + points.last.longitude) / 2,
        );
        await centerOnLatLng(mid, zoom: 12);
      } else {
        await centerOnLatLng(points.first, zoom: 13);
      }
    }
  }

  Future<void> startNavigation(
    List<ll.LatLng> points, {
    String? name,
  }) async {
    if (points.length < 2) return;
    routeMode = false;
    editingRouteId = null;
    draftPoints = [];
    shallowHit = false;
    navActive = true;
    navRouteName = name;
    navPoints = List<ll.LatLng>.from(points);
    navWaypointIndex = 0;
    notifyListeners();
    await centerOnLatLng(points.first, zoom: 14);
  }

  void stopNavigation() {
    if (!navActive) return;
    navActive = false;
    navRouteName = null;
    navPoints = [];
    navWaypointIndex = 0;
    notifyListeners();
  }

  void skipToNextWaypoint() {
    if (!navActive || navWaypointIndex >= navPoints.length - 1) return;
    navWaypointIndex++;
    notifyListeners();
  }

  void skipToPrevWaypoint() {
    if (!navActive || navWaypointIndex <= 0) return;
    navWaypointIndex--;
    notifyListeners();
  }

  /// Advance when GPS is within [arrivalMeters] of the current waypoint.
  void updateNavigationPosition(ll.LatLng? pos, {double arrivalMeters = 80}) {
    if (!navActive || pos == null || navPoints.isEmpty) return;
    var changed = false;
    while (navWaypointIndex < navPoints.length - 1) {
      final target = navPoints[navWaypointIndex];
      final d = _haversine(pos, target);
      if (d > arrivalMeters) break;
      navWaypointIndex++;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  ll.LatLng? get navTarget {
    if (!navActive || navPoints.isEmpty) return null;
    final i = navWaypointIndex.clamp(0, navPoints.length - 1);
    return navPoints[i];
  }

  bool get navArrived {
    if (!navActive || navPoints.length < 2) return false;
    return navWaypointIndex >= navPoints.length - 1;
  }

  static double _haversine(ll.LatLng a, ll.LatLng b) {
    const r = 6371000.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final lat1 = _rad(a.latitude);
    final lat2 = _rad(b.latitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return 2 * r * math.asin(math.sqrt(h.clamp(0.0, 1.0)));
  }

  static double _rad(double d) => d * math.pi / 180.0;
}
