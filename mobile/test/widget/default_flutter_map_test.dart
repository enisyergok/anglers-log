import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/default_flutter_map.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
    when(managers.userPreferenceManager.mapType).thenReturn(MapType.light.id);
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);
  });

  fm.MapOptions optionsOf(WidgetTester tester) =>
      tester.widget<fm.FlutterMap>(find.byType(fm.FlutterMap)).options;

  testWidgets("Zoom set to world view if start position is 0", (
    tester,
  ) async {
    await pumpContext(
      tester,
      (_) => DefaultFlutterMap(startPosition: LatLngs.zero),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(optionsOf(tester).initialZoom, 2);
  });

  testWidgets("Zoom set to default if start position is valid", (
    tester,
  ) async {
    await pumpContext(
      tester,
      (_) => DefaultFlutterMap(startPosition: LatLng(lat: 1, lng: 2)),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(optionsOf(tester).initialZoom, mapZoomDefault);
  });

  testWidgets("Zoom set to start zoom", (tester) async {
    await pumpContext(
      tester,
      (_) => DefaultFlutterMap(
        startPosition: LatLng(lat: 1, lng: 2),
        startZoom: mapZoomDefault - 1,
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(optionsOf(tester).initialZoom, mapZoomDefault - 1);
  });
}
