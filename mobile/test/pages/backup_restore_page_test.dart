import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/pages/backup_restore_page.dart';
import 'package:mobile/widgets/async_feedback.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.backupRestoreManager.currentUser).thenReturn(null);
    when(managers.backupRestoreManager.isSignedIn).thenReturn(true);
    when(
      managers.backupRestoreManager.authStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      managers.backupRestoreManager.progressStream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.backupRestoreManager.isInProgress).thenReturn(false);
    when(managers.backupRestoreManager.lastProgressError).thenReturn(null);
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(false);

    when(managers.lib.subscriptionManager.isPro).thenReturn(false);

    when(managers.userPreferenceManager.autoBackup).thenReturn(false);
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.userPreferenceManager.lastBackupAt).thenReturn(null);
  });

  Future<void> sendProgressUpdate(
    WidgetTester tester,
    StreamController<BackupRestoreProgress> controller,
    BackupRestoreProgressEnum value,
  ) async {
    controller.add(BackupRestoreProgress(value));
    // Use pump() instead of pumpAndSettle() because a Loading() widget is
    // animating and will never settle.
    await tester.pump();
  }

  Future<void> verifyProgressUpdate(
    WidgetTester tester,
    StreamController<BackupRestoreProgress> controller,
    BackupRestoreProgressEnum value,
    String label,
  ) async {
    await sendProgressUpdate(tester, controller, value);
    expect(find.text(label), findsOneWidget);
  }

  testWidgets("BackupPage shows last backup as never", (tester) async {
    when(managers.userPreferenceManager.lastBackupAt).thenReturn(null);
    await pumpContext(tester, (_) => BackupPage());
    expect(find.text("Hiç"), findsOneWidget);
  });

  testWidgets("BackupPage shows last backup as a valid time", (tester) async {
    when(
      managers.userPreferenceManager.lastBackupAt,
    ).thenReturn(dateTime(2020, 1, 1).millisecondsSinceEpoch);
    await pumpContext(tester, (_) => BackupPage());
    expect(find.text("Jan 1, 2020 at 12:00 AM"), findsOneWidget);
  });

  testWidgets("Action is always enabled (no cloud auth gating)", (
    tester,
  ) async {
    await pumpContext(tester, (_) => BackupPage());
    expect(findFirst<AsyncFeedback>(tester).action, isNotNull);
  });

  testWidgets("Close button is disabled when in progress", (tester) async {
    when(managers.backupRestoreManager.isInProgress).thenReturn(true);
    await pumpContext(tester, (_) => BackupPage());
    expect(findFirst<IconButton>(tester).onPressed, isNull);
  });

  testWidgets("Close button is enabled when idle", (tester) async {
    when(managers.backupRestoreManager.isInProgress).thenReturn(false);
    await pumpContext(tester, (_) => BackupPage());
    expect(findFirst<IconButton>(tester).onPressed, isNotNull);
  });

  testWidgets("Progress state changes", (tester) async {
    var controller = StreamController<BackupRestoreProgress>.broadcast(
      sync: true,
    );
    when(
      managers.backupRestoreManager.progressStream,
    ).thenAnswer((_) => controller.stream);

    await pumpContext(tester, (_) => BackupPage());

    await verifyProgressUpdate(
      tester,
      controller,
      .authClientError,
      "Kimlik doğrulama hatası. Lütfen daha sonra tekrar deneyin.",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .createFolderError,
      "yedek klasörü oluşturulamadı, lütfen daha sonra tekrar deneyin.",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .folderNotFound,
      "Yedek klasör bulunamadı. Verilerinizin geri yükled olabilmesi için yedek yapmanız gerekir.",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .apiRequestError,
      "Ağ kesintiye uğramış olabilir. İnternet bağlantınızı doğrulayıp tekrar deneyin. Sorun devam ederse lütfen Geri Bildirim menüsünden bir rapor gönderin.",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .accessDenied,
      "The app doesn't have permission to create backup files on your device. Please check your device storage permissions and try again.",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .databaseFileNotFound,
      "Yedek veri dosyası bulunamadı. Verilerinizin geri yükled olabilmesi için yedek yapmanız gerekir.",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .authenticating,
      "Kimlik doğrulanıyor...",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .fetchingFiles,
      "Veriler getiriliyor...",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .creatingFolder,
      "yedek klasörü oluşturuluyor...",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .backingUpData,
      "Backing up data...",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .restoringDatabase,
      "Veritabanı indiriliyor...",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .restoringImages,
      "Downloading images...",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .reloadingData,
      "Veriler yeniden yükleniyor...",
    );

    await verifyProgressUpdate(tester, controller, .finished, "Başarılı!");

    await verifyProgressUpdate(
      tester,
      controller,
      .networkError,
      "Ağ bağlantısı sorunu nedeniyle otomatik yedek başarısız oldu. Lütfen manuel yedek yapın veya bir sonraki otomatik yedek denemesini bekleyin.",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .signedOut,
      "Kimlik doğrulama zaman aşımı nedeniyle otomatik yedek başarısız oldu. Lütfen tekrar oturum açın.",
    );

    await sendProgressUpdate(tester, controller, .cleared);
    expect(findFirst<AsyncFeedback>(tester).state, AsyncFeedbackState.none);
  });

  testWidgets("Access denied hides feedback button", (tester) async {
    var controller = StreamController<BackupRestoreProgress>.broadcast(
      sync: true,
    );
    when(
      managers.backupRestoreManager.progressStream,
    ).thenAnswer((_) => controller.stream);

    await pumpContext(tester, (_) => BackupPage());
    await verifyProgressUpdate(
      tester,
      controller,
      .accessDenied,
      "The app doesn't have permission to create backup files on your device. Please check your device storage permissions and try again.",
    );

    expect(find.text("SEND REPORT"), findsNothing);
  });

  testWidgets("Storage full hides feedback button", (tester) async {
    var controller = StreamController<BackupRestoreProgress>.broadcast(
      sync: true,
    );
    when(
      managers.backupRestoreManager.progressStream,
    ).thenAnswer((_) => controller.stream);

    await pumpContext(tester, (_) => BackupPage());
    await verifyProgressUpdate(
      tester,
      controller,
      .storageFull,
      "Cihazınızın depolama alanı dolu. Lütfen biraz yer açın ve tekrar deneyin.",
    );

    expect(find.text("SEND REPORT"), findsNothing);
  });

  testWidgets("Errors show feedback button", (tester) async {
    var controller = StreamController<BackupRestoreProgress>.broadcast(
      sync: true,
    );
    when(
      managers.backupRestoreManager.progressStream,
    ).thenAnswer((_) => controller.stream);

    await pumpContext(tester, (_) => BackupPage());
    await sendProgressUpdate(tester, controller, .apiRequestError);

    expect(find.text("SEND REPORT"), findsOneWidget);
  });

  testWidgets("Auto-backup checkbox", (tester) async {
    when(managers.lib.subscriptionManager.isPro).thenReturn(true);
    when(
      managers.notificationManager.requestPermission(any),
    ).thenAnswer((_) => Future.value(true));

    await pumpContext(tester, (_) => BackupPage());
    await tester.ensureVisible(find.byType(Checkbox));
    await tapAndSettle(tester, find.byType(Checkbox));

    // Enable auto-backup.
    verify(managers.userPreferenceManager.setAutoBackup(true)).called(1);
    verify(managers.notificationManager.requestPermission(any)).called(1);

    // Disable.
    await tapAndSettle(tester, find.byType(Checkbox));
    verify(managers.userPreferenceManager.setAutoBackup(false)).called(1);
    verifyNever(managers.notificationManager.requestPermission(any));
  });

  testWidgets("Backup progress error exists when page is shown", (
    tester,
  ) async {
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(true);
    when(
      managers.backupRestoreManager.lastProgressError,
    ).thenReturn(BackupRestoreProgress(.signedOut));

    await pumpContext(tester, (_) => BackupPage());

    verify(
      managers.backupRestoreManager.isBackupRestorePageShowing = true,
    ).called(1);
    expect(findFirst<AsyncFeedback>(tester).state, AsyncFeedbackState.error);
  });

  testWidgets("BackupRestoreManager state is reset on close", (tester) async {
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(true);
    when(
      managers.backupRestoreManager.lastProgressError,
    ).thenReturn(BackupRestoreProgress(.signedOut));

    await pumpContext(tester, (_) => BackupPage());
    await tapAndSettle(tester, find.byIcon(Icons.close));

    verify(managers.backupRestoreManager.clearLastProgressError()).called(1);
    verify(
      managers.backupRestoreManager.isBackupRestorePageShowing = false,
    ).called(1);
    expect(find.byType(BackupPage), findsNothing);
  });

  testWidgets("RestorePage", (tester) async {
    await pumpContext(tester, (_) => RestorePage());
    expect(find.text("Geri Yükle"), findsOneWidget);
  });
}
