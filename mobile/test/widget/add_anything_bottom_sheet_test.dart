import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/entity_utils.dart';
import 'package:mobile/widgets/add_anything_bottom_sheet.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingBaits).thenReturn(true);
    when(
      managers.userPreferenceManager.isTrackingFishingSpots,
    ).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingMethods).thenReturn(true);
    when(
      managers.userPreferenceManager.isTrackingWaterClarities,
    ).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingGear).thenReturn(true);
  });

  testWidgets("All entities are visible", (tester) async {
    await showPresentedWidget(
      tester,
      (context) => showAddAnythingBottomSheet(context),
    );

    expect(find.text("Balıkçı"), findsOneWidget);
    expect(find.text("Yem Kategorisi"), findsOneWidget);
    expect(find.text("Yem"), findsOneWidget);
    expect(find.text("Su Kütlesi"), findsOneWidget);
    expect(find.text("Av"), findsOneWidget);
    expect(find.text("Özel Alan"), findsOneWidget);
    expect(find.text("Balık Tutma Yöntemi"), findsOneWidget);
    expect(find.text("Türler"), findsOneWidget);
    expect(find.text("Gezi"), findsOneWidget);
    expect(find.text("Su Berraklığı"), findsOneWidget);
    expect(find.text("Ekipman"), findsOneWidget);
    expect(find.text("GPS İzi"), findsNothing);
  });

  testWidgets("Entities not tracked aren't visible", (tester) async {
    when(managers.userPreferenceManager.isTrackingMethods).thenReturn(false);
    await showPresentedWidget(
      tester,
      (context) => showAddAnythingBottomSheet(context),
    );
    expect(find.text("Balık Tutma Yöntemi"), findsNothing);
  });

  testWidgets("EntitySpec is returned when selected", (tester) async {
    EntitySpec? spec;
    await showPresentedWidget(
      tester,
      (context) =>
          showAddAnythingBottomSheet(context).then((value) => spec = value),
    );

    await tapAndSettle(tester, find.text("Balıkçı"));

    expect(spec, isNotNull);
    expect(spec!.icon, iconAngler);
  });
}
