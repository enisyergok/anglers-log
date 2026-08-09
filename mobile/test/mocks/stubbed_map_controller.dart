import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/widgets/default_mapbox_map.dart';
import 'package:mockito/mockito.dart';

import 'mocks.mocks.dart';
import 'stubbed_managers.dart';

/// Map stubs for widget tests after Mapbox → flutter_map migration.
class StubbedMapController {
  /// Typed as [MockMapController] so Mockito `any` matches nullable mock params.
  late final MockMapController value;

  // Kept for call-site compatibility; unused after Mapbox removal.
  // ignore: unused_field
  final StubbedManagers _managers;

  StubbedMapController(this._managers) {
    value = MockMapController();
    when(value.symbols).thenReturn(const []);
    when(value.isCameraMoving).thenReturn(false);
    when(value.onSymbolTappedCallbacks).thenReturn(const []);
    when(value.fishingSpotSymbols).thenReturn(const []);
    when(value.cameraPosition()).thenAnswer(
      (_) async => CameraPosition(latLng: LatLng(lat: 0, lng: 0), zoom: 0),
    );
    when(value.addSymbols(any)).thenAnswer((_) async {});
    when(value.addSymbol(any)).thenAnswer((_) async {});
    when(value.removeSymbols(any)).thenAnswer((_) async {});
    when(value.removeSymbol(any)).thenAnswer((_) async {});
    when(value.clearSymbols()).thenAnswer((_) async {});
    when(value.updateSymbol(any)).thenAnswer((_) async {});
    when(value.setAllowSymbolOverlap(any)).thenAnswer((_) async {});
    when(value.animateCamera(any, easeIn: anyNamed('easeIn')))
        .thenAnswer((_) async {});
    when(value.moveCamera(any)).thenAnswer((_) async {});
    when(value.animateToBounds(any)).thenAnswer((_) async {});
    when(value.isTelemetryEnabled()).thenAnswer((_) async => false);
    when(value.setTelemetryEnabled(any)).thenAnswer((_) async {});
    when(
      value.updateLogoAndAttributionMarginBottom(any),
    ).thenAnswer((_) async {});
    when(value.setMapType(any)).thenAnswer((_) async {});
    when(value.redraw()).thenAnswer((_) async {});
  }

  /// Map ready callbacks aren't always fired in widget tests; invoke manually.
  Future<void> finishLoading(WidgetTester tester) async {
    final finder = find.byType(DefaultMapboxMap);
    if (finder.evaluate().isNotEmpty) {
      final map = tester.widget<DefaultMapboxMap>(finder.first);
      map.onMapCreated?.call(value);
    }
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
  }

  void moveMap({bool isMoving = false}) {
    // flutter_map gesture simulation is a no-op in unit/widget stubs.
  }

  void stubCameraPosition(CameraPosition position) {
    when(value.cameraPosition()).thenAnswer((_) async => position);
  }
}
