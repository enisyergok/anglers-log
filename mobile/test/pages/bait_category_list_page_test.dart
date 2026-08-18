import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/bait_category_list_page.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  var baitCategories = [
    BaitCategory()
      ..id = randomId()
      ..name = "Yapay",
    BaitCategory()
      ..id = randomId()
      ..name = "Canlı",
  ];

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.baitCategoryManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn(baitCategories);
  });

  testWidgets("Picker title", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => BaitCategoryListPage(
          pickerSettings: ManageableListPagePickerSettings(
            onPicked: (_, __) => false,
            isMulti: false,
          ),
        ),
      ),
    );
    expect(find.text("Yem Kategorisi Seç"), findsOneWidget);
  });

  testWidgets("Normal title", (tester) async {
    await tester.pumpWidget(Testable((_) => const BaitCategoryListPage()));
    expect(find.text("Bait Categories (2)"), findsOneWidget);
  });

  testWidgets("Normal title filtered", (tester) async {
    await tester.pumpWidget(Testable((_) => const BaitCategoryListPage()));
    expect(find.text("Bait Categories (2)"), findsOneWidget);

    when(
      managers.baitCategoryManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn([baitCategories[0]]);

    await enterTextAndSettle(tester, find.byType(CupertinoTextField), "Herhangi");
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(find.text("Bait Categories (1)"), findsOneWidget);
  });

  testWidgets("onPicked callback invoked", (tester) async {
    BaitCategory? pickedCategory;
    await tester.pumpWidget(
      Testable(
        (_) => BaitCategoryListPage(
          pickerSettings: ManageableListPagePickerSettings.single(
            onPicked: (_, category) {
              pickedCategory = category;
              return false;
            },
          ),
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Yapay"));
    expect(pickedCategory, isNotNull);
    expect(pickedCategory, baitCategories[0]);
  });
}
