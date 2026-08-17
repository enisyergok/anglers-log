import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/widgets/static_fishing_spot_map.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
    when(managers.userPreferenceManager.mapType).thenReturn(MapType.light.id);
  });

  testWidgets("Map is rendered for the fishing spot", (tester) async {
    await pumpContext(
      tester,
      (_) => StaticFishingSpotMap(FishingSpot(lat: 1.2345, lng: 6.7891)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(fm.FlutterMap), findsOneWidget);
  });

  testWidgets("Attribution is shown for the current map type", (
    tester,
  ) async {
    await pumpContext(
      tester,
      (_) => StaticFishingSpotMap(FishingSpot(lat: 1.2345, lng: 6.7891)),
    );
    await tester.pumpAndSettle();

    expect(find.text(MapType.light.attribution), findsOneWidget);
  });
}
