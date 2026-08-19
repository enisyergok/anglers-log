import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:mobile/map/map_controller.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart' as pb;
import 'package:mobile/navigation/land_polygon_catalog.dart';
import 'package:mobile/navigation/mera_manager.dart';
import 'package:mobile/navigation/nav_geo.dart';
import 'package:mobile/navigation/nmea_udp_listener.dart';
import 'package:mobile/navigation/water_route_planner.dart';
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

  /// True when the last auto-plan routed around land.
  bool landRerouted = false;

  /// True when land was detected but no water path was found.
  bool landRerouteFailed = false;

  /// Tap-to-drop [MeraSpot] mode.
  bool pinMode = false;

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
      landRerouted = false;
      landRerouteFailed = false;
      notifyListeners();
      return;
    }
    if (navActive) stopNavigation();
    if (pinMode) pinMode = false;
    routeMode = true;
    if (editingRouteId == null) {
      draftPoints = [];
    }
    shallowHit = false;
    landRerouted = false;
    landRerouteFailed = false;
    notifyListeners();
  }

  void setPinMode(bool enabled) {
    if (pinMode == enabled) return;
    if (enabled) {
      if (navActive) stopNavigation();
      routeMode = false;
      editingRouteId = null;
      draftPoints = [];
      shallowHit = false;
      landRerouted = false;
      landRerouteFailed = false;
    }
    pinMode = enabled;
    notifyListeners();
  }

  void clearRoute() {
    editingRouteId = null;
    draftPoints = [];
    shallowHit = false;
    landRerouted = false;
    landRerouteFailed = false;
    notifyListeners();
  }

  /// Clear waypoints but keep [editingRouteId] so save still updates.
  void clearDraftPoints() {
    draftPoints = [];
    shallowHit = false;
    landRerouted = false;
    landRerouteFailed = false;
    notifyListeners();
  }

  /// Load an existing route for in-place geometry edit.
  Future<void> beginEditRoute({
    required String routeId,
    required List<ll.LatLng> points,
  }) async {
    if (navActive) stopNavigation();
    if (pinMode) pinMode = false;
    routeMode = true;
    editingRouteId = routeId;
    draftPoints = List<ll.LatLng>.from(points);
    shallowHit = false;
    replanDraftAroundLand();
    if (points.isNotEmpty && mapController != null) {
      if (draftPoints.length >= 2) {
        final mid = ll.LatLng(
          (draftPoints.first.latitude + draftPoints.last.latitude) / 2,
          (draftPoints.first.longitude + draftPoints.last.longitude) / 2,
        );
        await centerOnLatLng(mid, zoom: 12);
      } else {
        await centerOnLatLng(draftPoints.first, zoom: 13);
      }
    }
  }

  /// True when the last route-mode tap was rejected because it landed on a
  /// known land polygon (see [handleMapTap]).
  bool lastTapRejectedOnLand = false;

  /// Append a waypoint (route mode) or drop a MeraSpot (pin mode).
  ///
  /// In route mode, if the new leg crosses land, intermediate water
  /// waypoints are inserted automatically. Route *endpoints* (this tap's
  /// point) are rejected outright if they fall on a known land polygon —
  /// there is no maritime-only directions backend here, only manual
  /// waypoints plus coarse land-avoidance, so this is the best available
  /// guard against a route starting/ending on land.
  ///
  /// Returns false when the tap was rejected (on land); callers should
  /// surface this to the user.
  Future<bool> handleMapTap(ll.LatLng point) async {
    if (routeMode) {
      if (NavGeo.isPointOnLand(point, LandPolygonCatalog.all)) {
        lastTapRejectedOnLand = true;
        notifyListeners();
        return false;
      }
      lastTapRejectedOnLand = false;
      if (draftPoints.isEmpty) {
        draftPoints = [point];
        landRerouted = false;
        landRerouteFailed = false;
      } else {
        final from = draftPoints.last;
        final plan = WaterRoutePlanner.planSegment(
          from,
          point,
          land: LandPolygonCatalog.all,
        );
        draftPoints = [...draftPoints, ...plan.points.skip(1)];
        landRerouted = plan.avoidedLand;
        landRerouteFailed = plan.failed;
      }
      notifyListeners();
      return true;
    }
    if (pinMode) {
      await _addPinAt(point);
    }
    return true;
  }

  /// Re-run land avoidance on the whole draft (e.g. after edit load).
  void replanDraftAroundLand() {
    if (draftPoints.length < 2) return;
    final plan = WaterRoutePlanner.planRoute(
      draftPoints,
      land: LandPolygonCatalog.all,
    );
    draftPoints = plan.points;
    landRerouted = plan.avoidedLand;
    landRerouteFailed = plan.failed;
    notifyListeners();
  }

  /// Long-press drops a pin unless route editing is active.
  Future<void> handleMapLongPress(ll.LatLng point) async {
    if (routeMode) return;
    await _addPinAt(point);
  }

  Future<void> _addPinAt(ll.LatLng point) async {
    final depth = NmeaUdpListener.get.latest?.depthM;
    await MeraManager.get.add(
      lat: point.latitude,
      lng: point.longitude,
      depthM: depth,
      note: 'Harita pini',
    );
    notifyListeners();
  }

  void undoLastWaypoint() {
    if (draftPoints.isEmpty) return;
    draftPoints = List<ll.LatLng>.from(draftPoints)..removeLast();
    shallowHit = false;
    landRerouted = false;
    landRerouteFailed = false;
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
    pinMode = false;
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
    pinMode = false;
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
