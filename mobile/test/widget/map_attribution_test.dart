import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/widgets/map_attribution.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  testWidgets("Shows attribution for explicit map type", (tester) async {
    await pumpContext(
      tester,
      (_) => const MapAttribution(mapType: MapType.satellite),
    );
    expect(find.text(MapType.satellite.attribution), findsOneWidget);
  });

  testWidgets("Shows attribution for the current theme's map type when null", (
    tester,
  ) async {
    when(managers.userPreferenceManager.mapType).thenReturn(MapType.dark.id);

    await pumpContext(tester, (_) => const MapAttribution());

    expect(find.text(MapType.dark.attribution), findsOneWidget);
  });
}
