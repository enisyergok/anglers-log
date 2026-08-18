import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/utils/date_range.dart';
import 'package:adair_flutter_lib/widgets/padded_checkbox.dart';
import 'package:adair_flutter_lib/widgets/text_input.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/angler_list_page.dart';
import 'package:mobile/pages/bait_list_page.dart';
import 'package:mobile/pages/body_of_water_list_page.dart';
import 'package:mobile/pages/fishing_spot_list_page.dart';
import 'package:mobile/pages/gear_list_page.dart';
import 'package:mobile/pages/method_list_page.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/pages/save_report_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/pages/water_clarity_list_page.dart';
import 'package:mobile/utils/atmosphere_utils.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/date_range_picker_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/timezone.dart';

import '../../../../adair-flutter-lib/test/mocks/mocks.mocks.dart';
import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  // Must be set to the time zone within which the tests are run. This is due
  // to a dependency on Flutter's date and time pickers.
  const currentTimeZone = "America/New_York";

  // Sunday, September 13, 2020 12:26:40 PM GMT
  TZDateTime now() => TZDateTime.fromMillisecondsSinceEpoch(
    getLocation(currentTimeZone),
    1600000000000,
  );

  var anglerList = <Angler>[
    Angler()
      ..id = randomId()
      ..name = "Cohen",
    Angler()
      ..id = randomId()
      ..name = "Someone",
  ];

  var baitList = <Bait>[
    Bait()
      ..id = randomId()
      ..name = "Rapala",
    Bait()
      ..id = randomId()
      ..name = "Spoon",
  ];

  var baitAttachmentList = <BaitAttachment>[
    BaitAttachment(baitId: baitList[0].id),
    BaitAttachment(baitId: baitList[1].id),
  ];

  var fishingSpotList = <FishingSpot>[
    FishingSpot()
      ..id = randomId()
      ..name = "A",
    FishingSpot()
      ..id = randomId()
      ..name = "B",
  ];

  var methodList = <Method>[
    Method()
      ..id = randomId()
      ..name = "Casting",
    Method()
      ..id = randomId()
      ..name = "Kayak",
  ];

  var speciesList = <Species>[
    Species()
      ..id = randomId()
      ..name = "Steelhead",
    Species()
      ..id = randomId()
      ..name = "Catfish",
  ];

  var gearList = <Gear>[
    Gear()
      ..id = randomId()
      ..name = "Pike Rod",
    Gear()
      ..id = randomId()
      ..name = "Bass Rod",
  ];

  var waterClarityList = <WaterClarity>[
    WaterClarity()
      ..id = randomId()
      ..name = "Açık",
    WaterClarity()
      ..id = randomId()
      ..name = "Stained",
  ];

  var bodyOfWaterList = <BodyOfWater>[
    BodyOfWater()
      ..id = randomId()
      ..name = "Lake Huron",
    BodyOfWater()
      ..id = randomId()
      ..name = "Tennessee River",
  ];

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.anglerManager.displayName(any, any),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(
      managers.anglerManager.id(any),
    ).thenAnswer((invocation) => invocation.positionalArguments[0].id);
    when(
      managers.anglerManager.idSet(
        entities: anyNamed("entities"),
        ids: anyNamed("ids"),
      ),
    ).thenReturn(anglerList.map((e) => e.id).toSet());
    when(managers.anglerManager.list(any)).thenReturn(anglerList);
    when(
      managers.anglerManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn(anglerList);

    when(
      managers.baitCategoryManager.displayName(any, any),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(
      managers.baitCategoryManager.id(any),
    ).thenAnswer((invocation) => invocation.positionalArguments[0].id);
    when(
      managers.baitCategoryManager.idSet(
        entities: anyNamed("entities"),
        ids: anyNamed("ids"),
      ),
    ).thenReturn({});
    when(
      managers.baitCategoryManager.listSortedByDisplayName(any),
    ).thenReturn([]);

    when(
      managers.baitManager.name(any),
    ).thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(managers.baitManager.entity(any)).thenAnswer(
      (invocation) => baitList.firstWhereOrNull(
        (e) => e.id == invocation.positionalArguments.first,
      ),
    );
    when(managers.baitManager.list(any)).thenReturn(baitList);
    when(
      managers.baitManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn(baitList);
    when(managers.baitManager.filteredList(any, any)).thenReturn(baitList);
    when(managers.baitManager.attachmentsDisplayValues(any, any)).thenAnswer((
      invocation,
    ) {
      var result = <String>[];
      for (var attachment in invocation.positionalArguments[1]) {
        result.add(baitList.firstWhere((e) => e.id == attachment.baitId).name);
      }
      return result;
    });
    when(managers.baitManager.variantFromAttachment(any)).thenReturn(null);
    when(managers.baitManager.attachmentList()).thenReturn(baitAttachmentList);
    when(managers.baitManager.numberOfCatches(any)).thenReturn(0);
    when(managers.baitManager.numberOfCatchQuantities(any)).thenReturn(0);

    when(
      managers.bodyOfWaterManager.displayName(any, any),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(
      managers.bodyOfWaterManager.id(any),
    ).thenAnswer((invocation) => invocation.positionalArguments[0].id);
    when(
      managers.bodyOfWaterManager.idSet(
        entities: anyNamed("entities"),
        ids: anyNamed("ids"),
      ),
    ).thenReturn(bodyOfWaterList.map((e) => e.id).toSet());
    when(managers.bodyOfWaterManager.list(any)).thenReturn(bodyOfWaterList);
    when(
      managers.bodyOfWaterManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn(bodyOfWaterList);

    managers.lib.stubCurrentTime(now(), timeZone: currentTimeZone);

    when(
      managers.reportManager.addOrUpdate(any),
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.reportManager.delete(any, notify: anyNamed("notify")),
    ).thenAnswer((_) => Future.value(false));
    when(managers.reportManager.nameExists(any)).thenReturn(false);

    when(
      managers.fishingSpotManager.displayName(
        any,
        any,
        includeBodyOfWater: anyNamed("includeBodyOfWater"),
        includeLatLngLabels: anyNamed("includeLatLngLabels"),
      ),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(managers.fishingSpotManager.list(any)).thenReturn(fishingSpotList);
    when(
      managers.fishingSpotManager.filteredList(any, any),
    ).thenReturn(fishingSpotList);
    when(
      managers.fishingSpotManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn(fishingSpotList);
    when(
      managers.fishingSpotManager.idSet(
        entities: anyNamed("entities"),
        ids: anyNamed("ids"),
      ),
    ).thenReturn(fishingSpotList.map((e) => e.id).toSet());
    when(
      managers.fishingSpotManager.id(any),
    ).thenAnswer((invocation) => invocation.positionalArguments[0].id);

    when(
      managers.methodManager.displayName(any, any),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(
      managers.methodManager.id(any),
    ).thenAnswer((invocation) => invocation.positionalArguments[0].id);
    when(
      managers.methodManager.idSet(
        entities: anyNamed("entities"),
        ids: anyNamed("ids"),
      ),
    ).thenReturn(methodList.map((e) => e.id).toSet());
    when(managers.methodManager.list(any)).thenReturn(methodList);
    when(
      managers.methodManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn(methodList);

    when(
      managers.speciesManager.displayName(any, any),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(
      managers.speciesManager.id(any),
    ).thenAnswer((invocation) => invocation.positionalArguments[0].id);
    when(
      managers.speciesManager.idSet(
        entities: anyNamed("entities"),
        ids: anyNamed("ids"),
      ),
    ).thenReturn(speciesList.map((e) => e.id).toSet());
    when(managers.speciesManager.list(any)).thenReturn(speciesList);
    when(
      managers.speciesManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn(speciesList);

    when(
      managers.gearManager.displayName(any, any),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(
      managers.gearManager.id(any),
    ).thenAnswer((invocation) => invocation.positionalArguments[0].id);
    when(
      managers.gearManager.idSet(
        entities: anyNamed("entities"),
        ids: anyNamed("ids"),
      ),
    ).thenReturn(gearList.map((e) => e.id).toSet());
    when(managers.gearManager.list(any)).thenReturn(gearList);
    when(
      managers.gearManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn(gearList);
    when(managers.gearManager.numberOfCatchQuantities(any)).thenReturn(0);

    when(
      managers.userPreferenceManager.waterDepthSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.waterTemperatureSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.catchLengthSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.catchWeightSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.catchWeightSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.airTemperatureSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.airVisibilitySystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.airPressureSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.airPressureImperialUnit,
    ).thenReturn(Unit.inch_of_mercury);
    when(
      managers.userPreferenceManager.windSpeedSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.windSpeedMetricUnit,
    ).thenReturn(Unit.kilometers_per_hour);
    when(managers.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(managers.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(
      managers.waterClarityManager.displayName(any, any),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(
      managers.waterClarityManager.id(any),
    ).thenAnswer((invocation) => invocation.positionalArguments[0].id);
    when(
      managers.waterClarityManager.idSet(
        entities: anyNamed("entities"),
        ids: anyNamed("ids"),
      ),
    ).thenReturn(waterClarityList.map((e) => e.id).toSet());
    when(managers.waterClarityManager.list(any)).thenReturn(waterClarityList);
    when(
      managers.waterClarityManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn(waterClarityList);

    var timeZoneLocation = MockTimeZoneLocation();
    when(timeZoneLocation.displayNameUtc).thenReturn("America/New York");
    when(timeZoneLocation.name).thenReturn("America/New_York");
    when(
      managers.lib.timeManager.filteredLocations(
        any,
        exclude: anyNamed("exclude"),
      ),
    ).thenReturn([timeZoneLocation]);
  });

  Future<void> selectItems(tester, String startText, List<String> items) async {
    await tester.ensureVisible(find.text(startText));
    await tapAndSettle(tester, find.text(startText));
    for (var item in items) {
      await tester.tap(
        find.descendant(
          of: find.widgetWithText(InkWell, item),
          matching: find.byType(Checkbox),
        ),
      );
    }
    await tapAndSettle(tester, find.byType(BackButton));
  }

  void stubCatchFields(BuildContext context, Id excludeId) {
    var allFields = allCatchFields(context);
    allFields.removeWhere((e) => e.id == excludeId);
    when(
      managers.userPreferenceManager.catchFieldIds,
    ).thenReturn(allFields.map<Id>((e) => e.id).toList());
  }

  void stubAtmosphereFields(BuildContext context, Id excludeId) {
    var allFields = allAtmosphereFields(context);
    allFields.removeWhere((e) => e.id == excludeId);
    when(
      managers.userPreferenceManager.atmosphereFieldIds,
    ).thenReturn(allFields.map((e) => e.id).toList());
  }

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));
    expect(find.text("Yeni Rapor"), findsOneWidget);
  });

  testWidgets("Edit title", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => SaveReportPage.edit(
          Report()
            ..id = randomId()
            ..name = "Özet"
            ..type = Report_Type.summary,
        ),
      ),
    );
    expect(find.text("Raporu Düzenle"), findsOneWidget);
  });

  testWidgets("Type defaults to summary", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));
    expect(
      find.descendant(
        of: find.widgetWithText(Row, "Özet"),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
  });

  testWidgets("Date range defaults to all", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));
    expect(find.text("All dates"), findsOneWidget);
  });

  testWidgets("Save button state updates when name changes", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    // Save button starts disabled.
    expect(findFirstWithText<ActionButton>(tester, "SAVE").onPressed, isNull);

    // Entering valid text updates state.
    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextField, "Name"),
      "Report Name",
    );
    expect(
      findFirstWithText<ActionButton>(tester, "SAVE").onPressed,
      isNotNull,
    );
  });

  testWidgets("Selecting type updates date range pickers", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    // Default summary only has 1 date picker.
    expect(find.byType(DateRangePickerInput), findsOneWidget);

    // Switch to comparison shows end date picker.
    await tapAndSettle(tester, find.widgetWithText(InkWell, "Karşılaştırma"));
    expect(find.byType(DateRangePickerInput), findsNWidgets(2));
    expect(
      find.widgetWithText(DateRangePickerInput, "Karşılaştır"),
      findsOneWidget,
    );
    expect(find.widgetWithText(DateRangePickerInput, "Bitiş"), findsOneWidget);

    // Switching back to summary removes end date picker.
    await tapAndSettle(tester, find.widgetWithText(InkWell, "Özet"));
    expect(find.byType(DateRangePickerInput), findsNWidgets(1));
    expect(find.widgetWithText(DateRangePickerInput, "Karşılaştır"), findsNothing);
    expect(find.widgetWithText(DateRangePickerInput, "Bitiş"), findsNothing);
  });

  testWidgets("Picking start date updates state", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tapAndSettle(tester, find.text("All dates"));
    await tapAndSettle(tester, find.text("This week"));
    expect(find.byType(PickerPage), findsNothing);
    expect(find.text("This week"), findsOneWidget);
  });

  testWidgets("Picking end date updates state", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tapAndSettle(tester, find.widgetWithText(InkWell, "Karşılaştırma"));
    await tapAndSettle(tester, find.text("Bitiş"));
    await tapAndSettle(tester, find.text("Last week"));
    expect(find.byType(PickerPage), findsNothing);
    expect(find.text("Last week"), findsOneWidget);
  });

  testWidgets("Species picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm türler"));
    await tapAndSettle(tester, find.text("Tüm türler"));
    expect(find.byType(SpeciesListPage), findsOneWidget);
  });

  testWidgets("Bait picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm yemler"));
    await tapAndSettle(tester, find.text("Tüm yemler"));
    expect(find.byType(BaitListPage), findsOneWidget);
  });

  testWidgets("Gear picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm ekipman"));
    await tapAndSettle(tester, find.text("Tüm ekipman"));
    expect(find.byType(GearListPage), findsOneWidget);
  });

  testWidgets("Fishing spot picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm av noktaları"));
    await tapAndSettle(tester, find.text("Tüm av noktaları"));
    expect(find.byType(FishingSpotListPage), findsOneWidget);
  });

  testWidgets("Body of water picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm su kütleleri"));
    await tapAndSettle(tester, find.text("Tüm su kütleleri"));
    expect(find.byType(BodyOfWaterListPage), findsOneWidget);
  });

  testWidgets("Angler picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm balıkçılar"));
    await tapAndSettle(tester, find.text("Tüm balıkçılar"));
    expect(find.byType(AnglerListPage), findsOneWidget);
  });

  testWidgets("Water clarity picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm su berraklıkları"));
    await tapAndSettle(tester, find.text("Tüm su berraklıkları"));
    expect(find.byType(WaterClarityListPage), findsOneWidget);
  });

  testWidgets("Methods picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm balık tutma yöntemleri"));
    await tapAndSettle(tester, find.text("Tüm balık tutma yöntemleri"));
    expect(find.byType(MethodListPage), findsOneWidget);
  });

  testWidgets("Periods picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm günün zamanları"));
    await tapAndSettle(tester, find.text("Tüm günün zamanları"));
    expect(find.text("Günün Zamanlarını Seç"), findsOneWidget);
  });

  testWidgets("Seasons picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm mevsimler"));
    await tapAndSettle(tester, find.text("Tüm mevsimler"));
    expect(find.text("Mevsim Seç"), findsOneWidget);
  });

  testWidgets("Picking all species shows single chip", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm türler"));
    await tapAndSettle(tester, find.text("Tüm türler"));
    expect(
      (tester.widget(
                find.descendant(
                  of: find.widgetWithText(ManageableListItem, "Tümü"),
                  matching: find.byType(PaddedCheckbox),
                ),
              )
              as PaddedCheckbox)
          .isChecked,
      isTrue,
    );

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("Tüm türler"), findsOneWidget);
  });

  testWidgets("Picking all baits shows single chip", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm yemler"));
    await tapAndSettle(tester, find.text("Tüm yemler"));
    expect(
      (tester.widget(
                find.descendant(
                  of: find.widgetWithText(ManageableListItem, "Tümü"),
                  matching: find.byType(PaddedCheckbox),
                ),
              )
              as PaddedCheckbox)
          .isChecked,
      isTrue,
    );

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("Tüm yemler"), findsOneWidget);
  });

  testWidgets("Picking all gear shows single chip", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm ekipman"));
    await tapAndSettle(tester, find.text("Tüm ekipman"));
    expect(
      (tester.widget(
                find.descendant(
                  of: find.widgetWithText(ManageableListItem, "Tümü"),
                  matching: find.byType(PaddedCheckbox),
                ),
              )
              as PaddedCheckbox)
          .isChecked,
      isTrue,
    );

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("Tüm ekipman"), findsOneWidget);
  });

  testWidgets("Picking all fishing spots shows single chip", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm av noktaları"));
    await tapAndSettle(tester, find.text("Tüm av noktaları"));
    expect(
      (tester.widget(
                find.descendant(
                  of: find.widgetWithText(ManageableListItem, "Tümü"),
                  matching: find.byType(PaddedCheckbox),
                ),
              )
              as PaddedCheckbox)
          .isChecked,
      isTrue,
    );

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("Tüm av noktaları"), findsOneWidget);
  });

  testWidgets("Picking all bodies of water shows single chip", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm su kütleleri"));
    await tapAndSettle(tester, find.text("Tüm su kütleleri"));
    expect(
      (tester.widget(
                find.descendant(
                  of: find.widgetWithText(ManageableListItem, "Tümü"),
                  matching: find.byType(PaddedCheckbox),
                ),
              )
              as PaddedCheckbox)
          .isChecked,
      isTrue,
    );

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("Tüm su kütleleri"), findsOneWidget);
  });

  testWidgets("Picking all anglers shows single chip", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm balıkçılar"));
    await tapAndSettle(tester, find.text("Tüm balıkçılar"));
    expect(
      (tester.widget(
                find.descendant(
                  of: find.widgetWithText(ManageableListItem, "Tümü"),
                  matching: find.byType(PaddedCheckbox),
                ),
              )
              as PaddedCheckbox)
          .isChecked,
      isTrue,
    );

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("Tüm balıkçılar"), findsOneWidget);
  });

  testWidgets("Picking all water clarities shows single chip", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm su berraklıkları"));
    await tapAndSettle(tester, find.text("Tüm su berraklıkları"));
    expect(
      (tester.widget(
                find.descendant(
                  of: find.widgetWithText(ManageableListItem, "Tümü"),
                  matching: find.byType(PaddedCheckbox),
                ),
              )
              as PaddedCheckbox)
          .isChecked,
      isTrue,
    );

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("Tüm su berraklıkları"), findsOneWidget);
  });

  testWidgets("Picking all fishing methods shows single chip", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm av noktaları"));
    await tapAndSettle(tester, find.text("Tüm av noktaları"));
    expect(
      (tester.widget(
                find.descendant(
                  of: find.widgetWithText(ManageableListItem, "Tümü"),
                  matching: find.byType(PaddedCheckbox),
                ),
              )
              as PaddedCheckbox)
          .isChecked,
      isTrue,
    );

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("Tüm av noktaları"), findsOneWidget);
  });

  testWidgets("Picking all periods shows single chip", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm günün zamanları"));
    await tapAndSettle(tester, find.text("Tüm günün zamanları"));
    expect(
      findSiblingOfText<PaddedCheckbox>(tester, ListItem, "Tümü").isChecked,
      isTrue,
    );

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("Tüm günün zamanları"), findsOneWidget);
  });

  testWidgets("Picking all seasons shows single chip", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm mevsimler"));
    await tapAndSettle(tester, find.text("Tüm mevsimler"));
    expect(
      findSiblingOfText<PaddedCheckbox>(tester, ListItem, "Tümü").isChecked,
      isTrue,
    );

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("Tüm mevsimler"), findsOneWidget);
  });

  testWidgets("Picking all tides shows single chip", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await tester.ensureVisible(find.text("Tüm gelgitler"));
    await tapAndSettle(tester, find.text("Tüm gelgitler"));
    expect(
      findSiblingOfText<PaddedCheckbox>(tester, ListItem, "Tümü").isChecked,
      isTrue,
    );

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("Tüm gelgitler"), findsOneWidget);
  });

  testWidgets("Add report with all fields modified", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextField, "Name"),
      "Report Name",
    );
    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextField, "Açıklama"),
      "A brief description.",
    );
    await tapAndSettle(tester, find.widgetWithText(InkWell, "Karşılaştırma"));
    await tapAndSettle(tester, find.text("Karşılaştır"));
    await tapAndSettle(tester, find.text("Last month"));
    await tapAndSettle(tester, find.text("Bitiş"));
    await tapAndSettle(tester, find.text("This month"));
    await tapAndSettle(tester, find.text("Saat Dilimi"));
    await tapAndSettle(tester, find.text("America/New York"));
    await selectItems(tester, "Tüm balıkçılar", ["Tümü", "Cohen"]);
    await selectItems(tester, "Tüm türler", ["Tümü", "Catfish"]);
    await selectItems(tester, "Tüm yemler", ["Tümü", "Spoon"]);
    await selectItems(tester, "Tüm ekipman", ["Tümü", "Bass Rod"]);

    await tester.ensureVisible(find.text("Tüm balık tutma yöntemleri"));
    await selectItems(tester, "Tüm balık tutma yöntemleri", ["Tümü", "Casting"]);

    await tester.ensureVisible(find.text("Tüm av noktaları"));
    await selectItems(tester, "Tüm av noktaları", ["Tümü", "B"]);

    await tester.ensureVisible(find.text("Tüm su kütleleri"));
    await selectItems(tester, "Tüm su kütleleri", ["Tümü", "Lake Huron"]);

    await tester.ensureVisible(find.text("Tüm günün zamanları"));
    await selectItems(tester, "Tüm günün zamanları", ["Tümü", "Öğleden sonra"]);

    await tester.ensureVisible(find.text("Tüm mevsimler"));
    await selectItems(tester, "Tüm mevsimler", ["Tümü", "Yaz"]);

    await tester.ensureVisible(find.text("Tüm su berraklıkları"));
    await selectItems(tester, "Tüm su berraklıkları", ["Tümü", "Stained"]);

    await tester.ensureVisible(find.text("Su Derinliği"));
    await tapAndSettle(tester, find.text("Su Derinliği"));
    await tapAndSettle(tester, find.text("Büyüktür (>)"));
    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextInput, "Değer"),
      "10",
    );
    await tapAndSettle(tester, find.byType(BackButton));

    await tester.ensureVisible(find.text("Su Sıcaklığı"));
    await tapAndSettle(tester, find.text("Su Sıcaklığı"));
    await tapAndSettle(tester, find.text("Küçüktür (<)"));
    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextInput, "Değer"),
      "15",
    );
    await tapAndSettle(tester, find.byType(BackButton));

    await tester.ensureVisible(find.text("Boy"));
    await tapAndSettle(tester, find.text("Boy"));
    await tapAndSettle(tester, find.text("Eşittir (=)"));
    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextInput, "Değer"),
      "20",
    );
    await tapAndSettle(tester, find.byType(BackButton));

    await tester.ensureVisible(find.text("Ağırlık"));
    await tapAndSettle(tester, find.text("Ağırlık"));
    await tapAndSettle(tester, find.text("Aralık"));
    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextInput, "Başlangıç"),
      "10",
    );
    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextInput, "Bitiş"),
      "15",
    );
    await tapAndSettle(tester, find.byType(BackButton));

    await tester.ensureVisible(find.text("Adet"));
    await tapAndSettle(tester, find.text("Adet"));
    await tapAndSettle(tester, find.text("Herhangi"));
    await tapAndSettle(tester, find.byType(BackButton));

    await tester.ensureVisible(find.text("Hava Sıcaklığı"));
    await tapAndSettle(tester, find.text("Hava Sıcaklığı"));
    await tapAndSettle(tester, find.text("Eşittir (=)"));
    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextInput, "Değer"),
      "20",
    );
    await tapAndSettle(tester, find.byType(BackButton));

    await tester.ensureVisible(find.text("Hava Nemi"));
    await tapAndSettle(tester, find.text("Hava Nemi"));
    await tapAndSettle(tester, find.text("Eşittir (=)"));
    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextInput, "Değer"),
      "20",
    );
    await tapAndSettle(tester, find.byType(BackButton));

    await tester.ensureVisible(find.text("Hava Görüşü"));
    await tapAndSettle(tester, find.text("Hava Görüşü"));
    await tapAndSettle(tester, find.text("Eşittir (=)"));
    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextInput, "Değer"),
      "20",
    );
    await tapAndSettle(tester, find.byType(BackButton));

    await tester.ensureVisible(find.text("Atmosfer Basıncı"));
    await tapAndSettle(tester, find.text("Atmosfer Basıncı"));
    await tapAndSettle(tester, find.text("Eşittir (=)"));
    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextInput, "Değer"),
      "20",
    );
    await tapAndSettle(tester, find.byType(BackButton));

    await tester.ensureVisible(find.text("Rüzgar Hızı"));
    await tapAndSettle(tester, find.text("Rüzgar Hızı"));
    await tapAndSettle(tester, find.text("Eşittir (=)"));
    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextInput, "Değer"),
      "20",
    );
    await tapAndSettle(tester, find.byType(BackButton));

    await tester.ensureVisible(find.text("Tüm rüzgar yönleri"));
    await selectItems(tester, "Tüm rüzgar yönleri", ["Tümü", "KD"]);

    await tester.ensureVisible(find.text("Tüm gökyüzü koşulları"));
    await selectItems(tester, "Tüm gökyüzü koşulları", [
      "Tümü",
      "Bulutlu",
      "Çiseleme",
    ]);

    await tester.ensureVisible(find.text("Tüm ay evreleri"));
    await selectItems(tester, "Tüm ay evreleri", ["Tümü", "Dolunay"]);

    await tester.ensureVisible(find.text("Tüm gelgitler"));
    await selectItems(tester, "Tüm gelgitler", ["Tümü", "Çeken"]);

    expect(
      find.descendant(
        of: find.widgetWithText(InkWell, "Karşılaştır"),
        matching: find.text("Last month"),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(InkWell, "Bitiş"),
        matching: find.text("This month"),
      ),
      findsOneWidget,
    );
    expect(find.text("America/New York"), findsOneWidget);
    expect(find.text("Catfish"), findsOneWidget);
    expect(find.text("B"), findsOneWidget);
    expect(find.text("Spoon"), findsOneWidget);
    expect(find.text("Bass Rod"), findsOneWidget);
    expect(find.text("Cohen"), findsOneWidget);
    expect(find.text("Casting"), findsOneWidget);
    expect(find.text("Öğleden sonra"), findsOneWidget);
    expect(find.text("Yaz"), findsOneWidget);
    expect(find.text("Stained"), findsOneWidget);
    expect(find.text("> 10 m"), findsOneWidget);
    expect(find.text("< 15\u00B0C"), findsOneWidget);
    expect(find.text("= 20 cm"), findsOneWidget);
    expect(find.text("10 kg - 15 kg"), findsOneWidget);
    expect(find.text("= 20\u00B0C"), findsOneWidget);
    expect(find.text("= 20%"), findsOneWidget);
    expect(find.text("= 20 km"), findsOneWidget);
    expect(find.text("= 20 MB"), findsOneWidget);
    expect(find.text("= 20 km/h"), findsOneWidget);
    expect(find.text("Wind: NE"), findsOneWidget);
    expect(find.text("Çiseleme"), findsOneWidget);
    expect(find.text("Bulutlu"), findsOneWidget);
    expect(find.text("Full Moon"), findsOneWidget);
    expect(find.text("Herhangi"), findsOneWidget);
    expect(find.text("Çeken Gelgit"), findsOneWidget);
    expect(find.text("Lake Huron"), findsOneWidget);

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.reportManager.addOrUpdate(captureAny));
    result.called(1);

    Report report = result.captured.first;
    expect(report.name, "Report Name");
    expect(report.description, "A brief description.");
    expect(report.hasFromDateRange(), isTrue);
    expect(report.fromDateRange.period, DateRange_Period.lastMonth);
    expect(report.hasToDateRange(), isTrue);
    expect(report.toDateRange.period, DateRange_Period.thisMonth);
    expect(report.anglerIds.length, 1);
    expect(report.baits.length, 1);
    expect(report.gearIds.length, 1);
    expect(report.speciesIds.length, 1);
    expect(report.fishingSpotIds.length, 1);
    expect(report.bodyOfWaterIds.length, 1);
    expect(report.methodIds.length, 1);
    expect(report.waterClarityIds.length, 1);
    expect(report.periods.length, 1);
    expect(report.seasons.length, 1);
    expect(report.windDirections.length, 1);
    expect(report.skyConditions.length, 2);
    expect(report.moonPhases.length, 1);
    expect(report.hasIsFavoritesOnly(), isFalse);
    expect(report.type, Report_Type.comparison);
    expect(report.hasWaterDepthFilter(), isTrue);
    expect(report.hasWaterTemperatureFilter(), isTrue);
    expect(report.hasLengthFilter(), isTrue);
    expect(report.hasWeightFilter(), isTrue);
    expect(report.hasQuantityFilter(), isFalse);
    expect(report.hasAirTemperatureFilter(), isTrue);
    expect(report.hasAirVisibilityFilter(), isTrue);
    expect(report.hasAirHumidityFilter(), isTrue);
    expect(report.hasAirPressureFilter(), isTrue);
    expect(report.hasWindSpeedFilter(), isTrue);
  });

  testWidgets("Add summary report with preset date range", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextField, "Name"),
      "Report Name",
    );
    await tapAndSettle(tester, find.widgetWithText(InkWell, "Özet"));
    await tapAndSettle(tester, find.text("All dates"));
    await tapAndSettle(tester, find.text("Last month"));

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.reportManager.addOrUpdate(captureAny));
    result.called(1);

    Report report = result.captured.first;
    expect(report.name, "Report Name");
    expect(report.hasFromDateRange(), isTrue);
    expect(report.fromDateRange.period, DateRange_Period.lastMonth);
    expect(report.fromDateRange.timeZone, currentTimeZone);
    expect(report.hasToDateRange(), isFalse);
    expect(report.timeZone, currentTimeZone);
    expect(report.anglerIds.isEmpty, isTrue);
    expect(report.baits.isEmpty, isTrue);
    expect(report.speciesIds.isEmpty, isTrue);
    expect(report.fishingSpotIds.isEmpty, isTrue);
    expect(report.methodIds.isEmpty, isTrue);
    expect(report.periods.isEmpty, isTrue);
    expect(report.seasons.isEmpty, isTrue);
    expect(report.waterClarityIds.isEmpty, isTrue);
    expect(report.hasIsFavoritesOnly(), isFalse);
    expect(report.type, Report_Type.summary);
    expect(report.hasWaterDepthFilter(), isFalse);
    expect(report.hasWaterTemperatureFilter(), isFalse);
    expect(report.hasLengthFilter(), isFalse);
    expect(report.hasWeightFilter(), isFalse);
    expect(report.hasQuantityFilter(), isFalse);
  });

  testWidgets("Add report with custom date ranges", (tester) async {
    late int expectedFromStartMs;
    late int expectedFromEndMs;
    late int expectedToStartMs;
    late int expectedToEndMs;
    await pumpContext(tester, (context) {
      // Custom DisplayDateRange default to "this month".
      var fromDateRange = DateRange(
        period: DateRange_Period.thisMonth,
        timeZone: currentTimeZone,
      );
      expectedFromStartMs = fromDateRange.startMs;
      expectedFromEndMs = fromDateRange.endMs;

      var toDateRange = DateRange(
        period: DateRange_Period.thisMonth,
        timeZone: currentTimeZone,
      );
      expectedToStartMs = toDateRange.startMs;
      expectedToEndMs = toDateRange.endMs;

      return const SaveReportPage();
    });

    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextField, "Name"),
      "Report Name",
    );
    await tapAndSettle(tester, find.widgetWithText(InkWell, "Karşılaştırma"));

    await tapAndSettle(tester, find.text("Karşılaştır"));
    // Scroll so "Custom" is visible.
    await tester.drag(find.text("Last year"), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text("Custom"));
    await tapAndSettle(tester, find.text("OK"));

    await tapAndSettle(tester, find.text("Bitiş"));
    // Scroll so "Custom" is visible.
    await tester.drag(find.text("Last year"), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text("Custom"));
    await tapAndSettle(tester, find.text("OK"));

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.reportManager.addOrUpdate(captureAny));
    result.called(1);

    Report report = result.captured.first;
    expect(report.name, "Report Name");
    expect(report.hasFromDateRange(), isTrue);
    expect(report.fromDateRange.period, DateRange_Period.custom);
    expect(report.fromDateRange.startMs, expectedFromStartMs);
    expect(report.fromDateRange.endTimestamp.toInt(), expectedFromEndMs);
    expect(report.fromDateRange.timeZone, currentTimeZone);
    expect(report.toDateRange.period, DateRange_Period.custom);
    expect(report.toDateRange.startTimestamp.toInt(), expectedToStartMs);
    expect(report.toDateRange.endTimestamp.toInt(), expectedToEndMs);
    expect(report.toDateRange.timeZone, currentTimeZone);
    expect(report.timeZone, currentTimeZone);
    expect(report.anglerIds, isEmpty);
    expect(report.baits, isEmpty);
    expect(report.speciesIds, isEmpty);
    expect(report.fishingSpotIds, isEmpty);
    expect(report.methodIds, isEmpty);
    expect(report.periods, isEmpty);
    expect(report.seasons, isEmpty);
    expect(report.waterClarityIds, isEmpty);
    expect(report.windDirections, isEmpty);
    expect(report.skyConditions, isEmpty);
    expect(report.moonPhases, isEmpty);
    expect(report.hasIsFavoritesOnly(), isFalse);
    expect(report.type, Report_Type.comparison);
    expect(report.hasWaterDepthFilter(), isFalse);
    expect(report.hasWaterTemperatureFilter(), isFalse);
    expect(report.hasLengthFilter(), isFalse);
    expect(report.hasWeightFilter(), isFalse);
    expect(report.hasQuantityFilter(), isFalse);
    expect(report.hasAirTemperatureFilter(), isFalse);
    expect(report.hasAirHumidityFilter(), isFalse);
    expect(report.hasAirVisibilityFilter(), isFalse);
    expect(report.hasAirPressureFilter(), isFalse);
    expect(report.hasWindSpeedFilter(), isFalse);
  });

  testWidgets("Add report with all entities selected sets empty collections", (
    tester,
  ) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextField, "Name"),
      "Report Name",
    );
    await tapAndSettle(tester, find.widgetWithText(InkWell, "Karşılaştırma"));
    await tapAndSettle(tester, find.text("Karşılaştır"));
    await tapAndSettle(tester, find.text("Last month"));
    await tapAndSettle(tester, find.text("Bitiş"));
    await tapAndSettle(tester, find.text("This month"));

    // Toggle none/all for good measure.
    await selectItems(tester, "Tüm balıkçılar", ["Tümü", "Tümü"]);
    await selectItems(tester, "Tüm türler", ["Tümü", "Tümü"]);
    await selectItems(tester, "Tüm yemler", ["Tümü", "Tümü"]);
    await selectItems(tester, "Tüm ekipman", ["Tümü", "Tümü"]);

    await tester.ensureVisible(find.text("Tüm av noktaları"));
    await selectItems(tester, "Tüm av noktaları", ["Tümü", "Tümü"]);

    await tester.ensureVisible(find.text("Tüm su kütleleri"));
    await selectItems(tester, "Tüm su kütleleri", ["Tümü", "Tümü"]);

    await tester.ensureVisible(find.text("Tüm balık tutma yöntemleri"));
    await selectItems(tester, "Tüm balık tutma yöntemleri", ["Tümü", "Tümü"]);

    await tester.ensureVisible(find.text("Tüm günün zamanları"));
    await selectItems(tester, "Tüm günün zamanları", ["Tümü", "Tümü"]);

    await tester.ensureVisible(find.text("Tüm mevsimler"));
    await selectItems(tester, "Tüm mevsimler", ["Tümü", "Tümü"]);

    await tester.ensureVisible(find.text("Tüm su berraklıkları"));
    await selectItems(tester, "Tüm su berraklıkları", ["Tümü", "Tümü"]);

    expect(find.text("Tüm balıkçılar"), findsOneWidget);
    expect(find.text("Tüm türler"), findsOneWidget);
    expect(find.text("Tüm yemler"), findsOneWidget);
    expect(find.text("Tüm ekipman"), findsOneWidget);
    expect(find.text("Tüm av noktaları"), findsOneWidget);
    expect(find.text("Tüm su kütleleri"), findsOneWidget);
    expect(find.text("Tüm balık tutma yöntemleri"), findsOneWidget);
    expect(find.text("Tüm günün zamanları"), findsOneWidget);
    expect(find.text("Tüm mevsimler"), findsOneWidget);
    expect(find.text("Tüm su berraklıkları"), findsOneWidget);

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.reportManager.addOrUpdate(captureAny));
    result.called(1);

    Report report = result.captured.first;
    expect(report.name, "Report Name");
    expect(report.anglerIds, isEmpty);
    expect(report.baits, isEmpty);
    expect(report.gearIds, isEmpty);
    expect(report.speciesIds, isEmpty);
    expect(report.fishingSpotIds, isEmpty);
    expect(report.bodyOfWaterIds, isEmpty);
    expect(report.waterClarityIds, isEmpty);
    expect(report.methodIds, isEmpty);
    expect(report.periods, isEmpty);
    expect(report.seasons, isEmpty);
  });

  testWidgets("Edit keeps old properties", (tester) async {
    var report = Report()
      ..id = randomId()
      ..name = "Report Name"
      ..description = "Report description"
      ..fromDateRange = DateRange(
        period: DateRange_Period.yesterday,
        timeZone: "America/Chicago",
      )
      ..toDateRange = DateRange(
        period: DateRange_Period.today,
        timeZone: "America/Chicago",
      )
      ..timeZone = "America/Chicago"
      ..isFavoritesOnly = true
      ..type = Report_Type.comparison
      ..waterDepthFilter = NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(unit: Unit.meters, value: 1),
        ),
      )
      ..waterTemperatureFilter = NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(unit: Unit.fahrenheit, value: 80),
        ),
      )
      ..lengthFilter = NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(unit: Unit.centimeters, value: 10),
        ),
      )
      ..weightFilter = NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(unit: Unit.kilograms, value: 2),
        ),
      )
      ..quantityFilter = NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(mainValue: Measurement(value: 50)),
      );
    report.anglerIds.addAll(anglerList.map((e) => e.id));
    report.gearIds.addAll(gearList.map((e) => e.id));
    report.baits.addAll(baitList.map((e) => BaitAttachment(baitId: e.id)));
    report.fishingSpotIds.addAll(fishingSpotList.map((e) => e.id));
    report.bodyOfWaterIds.addAll(bodyOfWaterList.map((e) => e.id));
    report.methodIds.addAll(methodList.map((e) => e.id));
    report.speciesIds.addAll(speciesList.map((e) => e.id));
    report.waterClarityIds.addAll(waterClarityList.map((e) => e.id));
    report.periods.addAll([Period.dawn, Period.afternoon]);
    report.seasons.addAll([Season.winter, Season.summer]);
    report.moonPhases.addAll([MoonPhase.full]);
    report.tideTypes.addAll([TideType.outgoing, TideType.incoming]);

    await tester.pumpWidget(Testable((_) => SaveReportPage.edit(report)));

    // Verify all fields are set correctly.
    expect(find.text("Report Name"), findsOneWidget);
    expect(find.text("Report description"), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(InkWell, "Karşılaştır"),
        matching: find.text("Yesterday"),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(InkWell, "Bitiş"),
        matching: find.text("Today"),
      ),
      findsOneWidget,
    );
    expect(find.text("America/Chicago"), findsOneWidget);
    expect(find.text("Cohen"), findsOneWidget);
    expect(find.text("Someone"), findsOneWidget);
    expect(find.text("Rapala"), findsOneWidget);
    expect(find.text("Spoon"), findsOneWidget);
    expect(find.text("Bass Rod"), findsOneWidget);
    expect(find.text("Pike Rod"), findsOneWidget);
    expect(find.text("A"), findsOneWidget);
    expect(find.text("B"), findsOneWidget);
    expect(find.text("Steelhead"), findsOneWidget);
    expect(find.text("Catfish"), findsOneWidget);
    expect(find.text("Casting"), findsOneWidget);
    expect(find.text("Kayak"), findsOneWidget);
    expect(find.text("Şafak"), findsOneWidget);
    expect(find.text("Öğleden sonra"), findsOneWidget);
    expect(find.text("Kış"), findsOneWidget);
    expect(find.text("Yaz"), findsOneWidget);
    expect(find.text("Açık"), findsOneWidget);
    expect(find.text("Stained"), findsOneWidget);
    expect(find.text("< 1 m"), findsOneWidget);
    expect(find.text("< 80\u00B0F"), findsOneWidget);
    expect(find.text("< 10 cm"), findsOneWidget);
    expect(find.text("< 2 kg"), findsOneWidget);
    expect(find.text("< 50"), findsOneWidget);
    expect(find.text("Full Moon"), findsOneWidget);
    expect(find.text("Çeken Gelgit"), findsOneWidget);
    expect(find.text("Gelen Gelgit"), findsOneWidget);
    expect(find.text("Lake Huron"), findsOneWidget);
    expect(find.text("Tennessee River"), findsOneWidget);

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.reportManager.addOrUpdate(captureAny));
    result.called(1);

    expect(result.captured.first, report);
  });

  testWidgets("Editing comparison with no end range does not crash", (
    tester,
  ) async {
    var report = Report(
      id: randomId(),
      name: "Test",
      type: Report_Type.comparison,
      fromDateRange: DateRange(period: DateRange_Period.yesterday),
    );

    await tester.pumpWidget(Testable((_) => SaveReportPage.edit(report)));

    await tapAndSettle(tester, find.text("SAVE"));
    expect(find.byType(SaveReportPage), findsNothing);
  });

  /// https://github.com/cohenadair/anglers-log/issues/463
  testWidgets("Editing with empty entity sets shows 'all' chip", (
    tester,
  ) async {
    var report = Report()
      ..id = randomId()
      ..name = "Report Name"
      ..description = "Report description"
      ..fromDateRange = DateRange(period: DateRange_Period.yesterday)
      ..toDateRange = DateRange(period: DateRange_Period.today);

    await tester.pumpWidget(Testable((_) => SaveReportPage.edit(report)));

    expect(find.text("Tüm balıkçılar"), findsOneWidget);
    expect(find.text("Tüm türler"), findsOneWidget);
    expect(find.text("Tüm av noktaları"), findsOneWidget);
    expect(find.text("Tüm yemler"), findsOneWidget);
    expect(find.text("Tüm ekipman"), findsOneWidget);
    expect(find.text("Tüm balık tutma yöntemleri"), findsOneWidget);
    expect(find.text("Tüm su kütleleri"), findsOneWidget);
    expect(find.text("Tüm günün zamanları"), findsOneWidget);
    expect(find.text("Tüm mevsimler"), findsOneWidget);
    expect(find.text("Tüm su berraklıkları"), findsOneWidget);
    expect(find.text("Tüm rüzgar yönleri"), findsOneWidget);
    expect(find.text("Tüm gökyüzü koşulları"), findsOneWidget);
    expect(find.text("Tüm ay evreleri"), findsOneWidget);
    expect(find.text("Tüm gelgitler"), findsOneWidget);
  });

  testWidgets("New report without changing date ranges", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextField, "Name"),
      "Test",
    );
    await tapAndSettle(tester, find.widgetWithText(InkWell, "Karşılaştırma"));

    // The test here is that the app doesn't crash. If the test passes, the
    // app doesn't crash.
    await tapAndSettle(tester, find.text("SAVE"));
  });

  testWidgets("Checking Favourites only sets property", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextField, "Name"),
      "Test",
    );
    await tapAndSettle(tester, find.widgetWithText(InkWell, "Karşılaştırma"));
    await tapAndSettle(tester, findListItemCheckbox(tester, "Yalnızca Favoriler"));

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.reportManager.addOrUpdate(captureAny));
    result.called(1);

    expect(result.captured.first.isFavoritesOnly, isTrue);
  });

  testWidgets("Checking catch and release only sets property", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveReportPage()));

    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextField, "Name"),
      "Test",
    );
    await tapAndSettle(tester, find.widgetWithText(InkWell, "Karşılaştırma"));
    await tapAndSettle(
      tester,
      findListItemCheckbox(tester, "Yalnızca Yakala ve Bırak"),
    );

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.reportManager.addOrUpdate(captureAny));
    result.called(1);

    expect(result.captured.first.isCatchAndReleaseOnly, isTrue);
  });

  testWidgets("Catch and release hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdCatchAndRelease);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Yalnızca Yakala ve Bırak"), findsNothing);
  });

  testWidgets("Favourites hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdFavorite);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Yalnızca Favoriler"), findsNothing);
  });

  testWidgets("Water depth hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdWaterDepth);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Su Derinliği"), findsNothing);
  });

  testWidgets("Water temperature hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdWaterTemperature);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Su Sıcaklığı"), findsNothing);
  });

  testWidgets("Length hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdLength);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Boy"), findsNothing);
  });

  testWidgets("Weight hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdWeight);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Ağırlık"), findsNothing);
  });

  testWidgets("Quantity hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdQuantity);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Adet"), findsNothing);
  });

  testWidgets("Periods hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdPeriod);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Tüm günün zamanları"), findsNothing);
  });

  testWidgets("Seasons hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdSeason);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Tüm mevsimler"), findsNothing);
  });

  testWidgets("Anglers hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdAngler);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Tüm balıkçılar"), findsNothing);
  });

  testWidgets("Species hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdSpecies);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Tüm türler"), findsNothing);
  });

  testWidgets("Gear hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdGear);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Tüm ekipman"), findsNothing);
  });

  testWidgets("Baits hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdBait);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Tüm yemler"), findsNothing);
  });

  testWidgets("Fishing spots hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdFishingSpot);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Tüm av noktaları"), findsNothing);
  });

  testWidgets("Bodies of water hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdFishingSpot);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Tüm su kütleleri"), findsNothing);
  });

  testWidgets("Methods hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdMethods);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Tüm balık tutma yöntemleri"), findsNothing);
  });

  testWidgets("Air temperature hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubAtmosphereFields(context, atmosphereFieldIdTemperature);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Hava Sıcaklığı"), findsNothing);
  });

  testWidgets("Air pressure hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubAtmosphereFields(context, atmosphereFieldIdPressure);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Atmosfer Basıncı"), findsNothing);
  });

  testWidgets("Air humidity hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubAtmosphereFields(context, atmosphereFieldIdHumidity);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Hava Nemi"), findsNothing);
  });

  testWidgets("Air visibility hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubAtmosphereFields(context, atmosphereFieldIdVisibility);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Hava Görüşü"), findsNothing);
  });

  testWidgets("Wind speeds hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubAtmosphereFields(context, atmosphereFieldIdWindSpeed);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Rüzgar Hızı"), findsNothing);
  });

  testWidgets("Wind directions hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubAtmosphereFields(context, atmosphereFieldIdWindDirection);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Tüm rüzgar yönleri"), findsNothing);
  });

  testWidgets("Sky conditions hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubAtmosphereFields(context, atmosphereFieldIdSkyCondition);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Tüm gökyüzü koşulları"), findsNothing);
  });

  testWidgets("Moon phases hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubAtmosphereFields(context, atmosphereFieldIdMoonPhase);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Tüm ay evreleri"), findsNothing);
  });

  testWidgets("Tides hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdTide);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Tüm gelgitler"), findsNothing);
  });

  testWidgets("Water clarities hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdWaterClarity);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Tüm su berraklıkları"), findsNothing);
  });

  testWidgets("Time zone hidden when not tracked", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        stubCatchFields(context, catchFieldIdTimeZone);
        return const SaveReportPage();
      }),
    );
    expect(find.text("Saat Dilimi"), findsNothing);
  });
}
