import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/mera/mera_records_page.dart';
import 'package:mobile/mera/mera_routes_page.dart';
import 'package:mobile/mera/mera_settings_page.dart';
import 'package:mobile/mera/mera_stats_page.dart';
import 'package:mobile/mera/mera_widgets.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/notification_manager.dart';
import 'package:mobile/pages/anglers_log_pro_page.dart';
import 'package:mobile/pages/backup_restore_page.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/widgets/fishing_spot_map.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../adair-flutter-lib/test/test_utils/disposable_tester.dart';
import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.backupRestoreManager.progressStream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(false);

    when(
      managers.baitCategoryManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn([]);

    when(managers.bodyOfWaterManager.list()).thenReturn([]);
    when(
      managers.bodyOfWaterManager.displayName(any, any),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(
      managers.catchManager.catches(
        any,
        filter: anyNamed("filter"),
        opt: anyNamed("opt"),
      ),
    ).thenReturn([]);
    when(managers.catchManager.hasEntities).thenReturn(false);
    when(managers.catchManager.list()).thenReturn([]);

    when(
      managers.catchManager.listen(any),
    ).thenAnswer((_) => MockStreamSubscription());
    when(managers.catchManager.stream).thenAnswer((_) => const Stream.empty());
    when(managers.catchManager.list()).thenReturn([]);
    when(managers.catchManager.entityCount).thenReturn(0);

    when(managers.fishingSpotManager.list()).thenReturn([]);
    when(managers.fishingSpotManager.listSortedByDisplayName(any)).thenReturn(
      [],
    );
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(managers.fishingSpotManager.entity(any)).thenReturn(null);

    when(managers.gpsTrailManager.stream).thenAnswer((_) => const Stream.empty());
    when(managers.gpsTrailManager.hasActiveTrail).thenReturn(false);
    when(managers.gpsTrailManager.activeTrial).thenReturn(null);

    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);
    when(managers.lib.ioWrapper.isIOS).thenReturn(false);

    when(managers.lib.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          appName: 'Mera',
          packageName: 'com.mera',
          version: '1.0.0',
          buildNumber: '1',
        ),
      ),
    );

    when(managers.lib.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(true));
    when(managers.lib.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(true));
    when(managers.lib.permissionHandlerWrapper.requestLocation())
        .thenAnswer((_) => Future.value(true));

    when(managers.lib.subscriptionManager.isPro).thenReturn(true);
    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.lib.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());

    when(managers.locationMonitor.currentLatLng).thenReturn(null);
    when(managers.locationMonitor.stream).thenAnswer((_) => const Stream.empty());

    when(managers.notificationManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(
      managers.notificationManager.requestPermission(any),
    ).thenAnswer((_) => Future.value(true));

    when(managers.pollManager.canVote).thenReturn(false);
    when(managers.pollManager.canVoteFree).thenReturn(false);
    when(managers.pollManager.canVotePro).thenReturn(false);
    when(managers.pollManager.stream).thenAnswer((_) => const Stream.empty());

    when(managers.propertiesManager.mapboxApiKey).thenReturn("");

    when(managers.reportManager.entityExists(any)).thenReturn(false);
    when(managers.reportManager.defaultReport).thenReturn(Report());
    when(managers.reportManager.displayName(any, any)).thenReturn("Test");
    when(managers.reportManager.list()).thenReturn([]);

    when(managers.speciesManager.entity(any)).thenReturn(null);
    when(managers.speciesManager.list()).thenReturn([]);

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
    when(managers.userPreferenceManager.didRateApp).thenReturn(false);
    when(managers.userPreferenceManager.proTimerStartedAt).thenReturn(0);
    when(
      managers.userPreferenceManager.setSelectedReportId(any),
    ).thenAnswer((_) => Future.value());
    when(managers.userPreferenceManager.mapType).thenReturn(null);
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.userPreferenceManager.autoBackup).thenReturn(false);

    when(
      managers.tripManager.listen(any),
    ).thenAnswer((_) => MockStreamSubscription());
  });

  testWidgets("Tapping nav item opens page", (tester) async {
    await tester.pumpWidget(Testable((_) => MainPage()));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.byType(MeraBottomBar), findsOneWidget);
    expect(findFirst<IndexedStack>(tester).index, 0);
    expect(find.byType(FishingSpotMap), findsWidgets);

    await tapAndSettle(tester, find.byIcon(Icons.route_outlined));
    expect(findFirst<IndexedStack>(tester).index, 1);
    expect(find.byType(MeraRoutesPage), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.bar_chart_outlined));
    expect(findFirst<IndexedStack>(tester).index, 2);
    expect(find.byType(MeraStatsPage), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.menu_book_outlined));
    expect(findFirst<IndexedStack>(tester).index, 3);
    expect(find.byType(MeraRecordsPage), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.settings_outlined));
    expect(findFirst<IndexedStack>(tester).index, 4);
    expect(find.byType(MeraSettingsPage), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.home_outlined));
    expect(findFirst<IndexedStack>(tester).index, 0);
  });

  testWidgets(
    "Tapping current nav item again pops all pages on current stack",
    (tester) async {
      await tester.pumpWidget(Testable((_) => MainPage()));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      await tapAndSettle(tester, find.byIcon(Icons.settings_outlined));
      expect(find.byType(MeraSettingsPage), findsOneWidget);

      // Re-tap root tab — stack reset is a no-op with a single route.
      await tapAndSettle(tester, find.byIcon(Icons.settings));
      expect(findFirst<IndexedStack>(tester).index, 4);
      expect(find.byType(MeraSettingsPage), findsOneWidget);
    },
  );

  testWidgets("ProPage shown", (tester) async {
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);
    when(
      managers.lib.subscriptionManager.subscriptions(),
    ).thenAnswer((_) => Future.value(null));

    when(managers.userPreferenceManager.didRateApp).thenReturn(true);
    when(managers.userPreferenceManager.proTimerStartedAt).thenReturn(1000);
    when(
      managers.userPreferenceManager.setProTimerStartedAt(any),
    ).thenAnswer((_) => Future.value(null));

    when(
      managers.lib.timeManager.currentTimestamp,
    ).thenReturn((Duration.millisecondsPerDay * 7 + 1500).round());

    var catchController = StreamController<EntityEvent<Catch>>.broadcast(
      sync: true,
    );
    var tripController = StreamController<EntityEvent<Trip>>.broadcast(
      sync: true,
    );
    when(managers.catchManager.listen(any)).thenAnswer(
      (invocation) => catchController.stream.listen(
        (event) => invocation.positionalArguments[0].onAdd(event.entity),
      ),
    );
    when(managers.catchManager.entityCount).thenReturn(5);
    when(managers.tripManager.listen(any)).thenAnswer(
      (invocation) => tripController.stream.listen(
        (event) => invocation.positionalArguments[0].onAdd(event.entity),
      ),
    );
    when(managers.tripManager.entityCount).thenReturn(5);

    await tester.pumpWidget(Testable((_) => MainPage()));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    catchController.add(EntityEvent<Catch>(EntityEventType.add, Catch()));

    await tester.pumpAndSettle();
    expect(find.byType(AnglersLogProPage), findsOneWidget);
    verify(managers.userPreferenceManager.setProTimerStartedAt(any)).called(1);
    await tapAndSettle(tester, find.byType(CloseButton));
    expect(find.byType(AnglersLogProPage), findsNothing);

    tripController.add(EntityEvent<Trip>(EntityEventType.add, Trip()));

    await tester.pumpAndSettle();
    expect(find.byType(AnglersLogProPage), findsOneWidget);
    verify(managers.userPreferenceManager.setProTimerStartedAt(any)).called(1);
    await tapAndSettle(tester, find.byType(CloseButton));
    expect(find.byType(AnglersLogProPage), findsNothing);
  });

  testWidgets("Feedback dialogs not shown if not enough activity", (
    tester,
  ) async {
    var catchController = StreamController<EntityEvent<Catch>>.broadcast(
      sync: true,
    );
    var tripController = StreamController<EntityEvent<Trip>>.broadcast(
      sync: true,
    );
    when(managers.catchManager.listen(any)).thenAnswer(
      (invocation) => catchController.stream.listen(
        (event) => invocation.positionalArguments[0].onAdd(event.entity),
      ),
    );
    when(managers.catchManager.entityCount).thenReturn(0);
    when(managers.tripManager.listen(any)).thenAnswer(
      (invocation) => tripController.stream.listen(
        (event) => invocation.positionalArguments[0].onAdd(event.entity),
      ),
    );
    when(managers.tripManager.entityCount).thenReturn(0);

    await tester.pumpWidget(Testable((_) => MainPage()));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    catchController.add(EntityEvent<Catch>(EntityEventType.add, Catch()));
    verify(managers.catchManager.entityCount).called(1);
    verifyNever(managers.lib.subscriptionManager.isFree);

    tripController.add(EntityEvent<Trip>(EntityEventType.add, Trip()));
    verify(managers.tripManager.entityCount).called(1);
    verifyNever(managers.lib.subscriptionManager.isFree);
  });

  testWidgets("Review requested if already pro", (tester) async {
    when(
      managers.inAppReviewWrapper.isAvailable(),
    ).thenAnswer((_) => Future.value(true));
    when(
      managers.inAppReviewWrapper.requestReview(),
    ).thenAnswer((_) => Future.value());

    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.didRateApp).thenReturn(true);

    var controller = StreamController<EntityEvent<Catch>>.broadcast(sync: true);
    when(managers.catchManager.listen(any)).thenAnswer(
      (invocation) => controller.stream.listen(
        (event) => invocation.positionalArguments[0].onAdd(event.entity),
      ),
    );
    when(managers.catchManager.entityCount).thenReturn(5);

    await tester.pumpWidget(Testable((_) => MainPage()));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    controller.add(EntityEvent<Catch>(EntityEventType.add, Catch()));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(AnglersLogProPage), findsNothing);
    verifyNever(managers.userPreferenceManager.setProTimerStartedAt(any));
    verify(managers.inAppReviewWrapper.isAvailable()).called(1);
    verify(managers.inAppReviewWrapper.requestReview()).called(1);
  });

  testWidgets("Review not requested if not available", (tester) async {
    when(
      managers.inAppReviewWrapper.isAvailable(),
    ).thenAnswer((_) => Future.value(false));

    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.didRateApp).thenReturn(true);

    var controller = StreamController<EntityEvent<Catch>>.broadcast(sync: true);
    when(managers.catchManager.listen(any)).thenAnswer(
      (invocation) => controller.stream.listen(
        (event) => invocation.positionalArguments[0].onAdd(event.entity),
      ),
    );
    when(managers.catchManager.entityCount).thenReturn(5);

    await tester.pumpWidget(Testable((_) => MainPage()));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    controller.add(EntityEvent<Catch>(EntityEventType.add, Catch()));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(AnglersLogProPage), findsNothing);
    verifyNever(managers.userPreferenceManager.setProTimerStartedAt(any));
    verify(managers.inAppReviewWrapper.isAvailable()).called(1);
    verifyNever(managers.inAppReviewWrapper.requestReview());
  });

  testWidgets("ProPage not shown if not enough time has passed", (
    tester,
  ) async {
    when(
      managers.inAppReviewWrapper.isAvailable(),
    ).thenAnswer((_) => Future.value(false));
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);

    when(managers.userPreferenceManager.didRateApp).thenReturn(true);
    when(managers.userPreferenceManager.proTimerStartedAt).thenReturn(1000);

    when(
      managers.lib.timeManager.currentTimestamp,
    ).thenReturn((Duration.millisecondsPerDay * 7 - 1500).round());

    var controller = StreamController<EntityEvent<Catch>>.broadcast(sync: true);
    when(managers.catchManager.listen(any)).thenAnswer(
      (invocation) => controller.stream.listen(
        (event) => invocation.positionalArguments[0].onAdd(event.entity),
      ),
    );
    when(managers.catchManager.entityCount).thenReturn(5);

    await tester.pumpWidget(Testable((_) => MainPage()));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    controller.add(EntityEvent<Catch>(EntityEventType.add, Catch()));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(AnglersLogProPage), findsNothing);
    verify(managers.userPreferenceManager.proTimerStartedAt).called(1);
    verifyNever(managers.userPreferenceManager.setProTimerStartedAt(any));
  });

  testWidgets("Notification shown via listener", (tester) async {
    var controller = StreamController<LocalNotificationType>.broadcast();
    when(
      managers.notificationManager.stream,
    ).thenAnswer((_) => controller.stream);

    await tester.pumpWidget(Testable((_) => MainPage()));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    controller.add(LocalNotificationType.backupProgressError);
    await untilCalled(
      managers.notificationManager.show(
        id: anyNamed("id"),
        title: anyNamed("title"),
        body: anyNamed("body"),
        details: anyNamed("details"),
      ),
    );
    verify(
      managers.notificationManager.show(
        id: anyNamed("id"),
        title: anyNamed("title"),
        body: anyNamed("body"),
        details: anyNamed("details"),
      ),
    ).called(1);
  });

  testWidgets("BackupPage shown on notification tap", (tester) async {
    when(
      managers.backupRestoreManager.authStream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.backupRestoreManager.lastProgressError).thenReturn(null);
    when(managers.backupRestoreManager.isInProgress).thenReturn(false);
    when(managers.backupRestoreManager.isSignedIn).thenReturn(false);
    when(
      managers.backupRestoreManager.isBackupRestorePageShowing,
    ).thenReturn(false);
    when(managers.userPreferenceManager.lastBackupAt).thenReturn(null);
    when(managers.lib.ioWrapper.isIOS).thenReturn(false);

    await tester.pumpWidget(Testable((_) => MainPage()));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    var result = verify(
      managers.notificationManager.onDidReceiveNotificationResponse =
          captureAny,
    );
    result.called(1);
    result.captured.first();

    await tester.pumpAndSettle();
    expect(find.byType(BackupPage), findsOneWidget);
  });

  testWidgets("BackupPage not shown if already showing", (tester) async {
    when(
      managers.backupRestoreManager.isBackupRestorePageShowing,
    ).thenReturn(true);

    await tester.pumpWidget(Testable((_) => MainPage()));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    var result = verify(
      managers.notificationManager.onDidReceiveNotificationResponse =
          captureAny,
    );
    result.called(1);
    result.captured.first();

    await tester.pumpAndSettle();
    verify(managers.backupRestoreManager.isBackupRestorePageShowing).called(1);
    expect(find.byType(BackupPage), findsNothing);
  });

  testWidgets("Permission requested on app start", (tester) async {
    when(managers.userPreferenceManager.autoBackup).thenReturn(true);
    when(
      managers.notificationManager.requestPermission(any),
    ).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(Testable((_) => MainPage()));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    verify(managers.notificationManager.requestPermission(any)).called(1);
  });

  testWidgets("Notification on app start", (tester) async {
    await tester.pumpWidget(Testable((_) => MainPage()));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    verify(managers.backupRestoreManager.notifySignedOutIfNeeded()).called(1);
  });

  testWidgets("NotificationManager state reset on dispose", (tester) async {
    await pumpContext(
      tester,
      (_) => DisposableTester(child: Testable((_) => MainPage())),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    var state = tester.firstState<DisposableTesterState>(
      find.byType(DisposableTester),
    );
    state.removeChild();
    await tester.pumpAndSettle();

    verify(
      managers.notificationManager.onDidReceiveNotificationResponse = null,
    ).called(1);
  });
}
