import 'dart:async';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'mocks/mocks.dart';
import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;
  late BackupRestoreManager backupRestoreManager;

  const databaseName = "anglerslog.db";
  const databasePath = "path/to/db/anglerslog.db";
  const docsPath = "/docs";

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.catchManager.listen(any),
    ).thenAnswer((_) => MockStreamSubscription());
    when(
      managers.tripManager.listen(any),
    ).thenAnswer((_) => MockStreamSubscription());
    when(
      managers.baitManager.listen(any),
    ).thenAnswer((_) => MockStreamSubscription());
    when(
      managers.fishingSpotManager.listen(any),
    ).thenAnswer((_) => MockStreamSubscription());

    when(managers.userPreferenceManager.didSetupBackup).thenReturn(true);
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.userPreferenceManager.autoBackup).thenReturn(false);
    when(managers.userPreferenceManager.lastBackupAt).thenReturn(null);
    when(
      managers.userPreferenceManager.setLastBackupAt(any),
    ).thenAnswer((_) => Future.value());
    when(
      managers.userPreferenceManager.setDidSetupBackup(any),
    ).thenAnswer((_) => Future.value());

    when(
      managers.localDatabaseManager.databasePath(),
    ).thenReturn(databasePath);
    when(
      managers.localDatabaseManager.closeAndDeleteDatabase(),
    ).thenAnswer((_) => Future.value());

    when(
      managers.app.init(isStartup: anyNamed("isStartup")),
    ).thenAnswer((_) => Future.value());

    when(
      managers.sharePlusWrapper.shareFiles(
        any,
        any,
        subject: anyNamed("subject"),
        text: anyNamed("text"),
      ),
    ).thenAnswer((_) => Future.value());

    when(
      managers.lib.pathProviderWrapper.appDocumentsPath,
    ).thenAnswer((_) => Future.value(docsPath));
    when(
      managers.lib.pathProviderWrapper.temporaryPath,
    ).thenAnswer((_) => Future.value("/tmp"));

    when(managers.imageManager.imageFiles).thenAnswer((_) => Future.value([]));

    managers.lib.stubCurrentTime(DateTime(2023, 1, 1));

    // Default: any file not explicitly stubbed below doesn't exist, but can
    // still be written to (used for the output zip file, for example).
    when(managers.lib.ioWrapper.file(any)).thenAnswer((_) => MockFile());

    backupRestoreManager = BackupRestoreManager();
  });

  /// Registers [file] to be returned by IoWrapper.file(path) for the given
  /// [path].
  void stubFile(String path, MockFile file) {
    when(managers.lib.ioWrapper.file(path)).thenReturn(file);
  }

  MockFile fakeFile({
    required bool exists,
    Uint8List? bytes,
    MockDirectory? parent,
  }) {
    var file = MockFile();
    when(file.existsSync()).thenReturn(exists);
    when(file.readAsBytes()).thenAnswer(
      (_) => Future.value(bytes ?? Uint8List.fromList([1, 2, 3])),
    );
    when(
      file.writeAsBytes(any, flush: anyNamed("flush"), mode: anyNamed("mode")),
    ).thenAnswer((_) => Future.value(file));
    if (parent != null) {
      when(file.parent).thenReturn(parent);
    }
    return file;
  }

  MockDirectory fakeDirectory() {
    var dir = MockDirectory();
    when(dir.create(recursive: anyNamed("recursive"))).thenAnswer(
      (_) => Future.value(dir),
    );
    return dir;
  }

  /// Verifies events of [BackupRestoreManager.progressStream], in the order
  /// of [values].
  void verifyProgressStream(List<BackupRestoreProgressEnum> values) {
    int calls = 0;
    backupRestoreManager.progressStream.listen(
      expectAsync1((progress) {
        expect(progress.value, values[calls]);
        calls++;
      }, count: values.length),
    );
  }

  Uint8List buildZip(Map<String, List<int>> entries) {
    var archive = Archive();
    entries.forEach((name, bytes) {
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    });
    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  test("BackupRestoreProgress percentage is null", () async {
    expect(
      BackupRestoreProgress(
        BackupRestoreProgressEnum.apiRequestError,
        percentage: null,
      ).percentageString,
      "",
    );
  });

  test("BackupRestoreProgress percentage is not null", () async {
    expect(
      BackupRestoreProgress(
        BackupRestoreProgressEnum.apiRequestError,
        percentage: 50,
      ).percentageString,
      " (50%)",
    );
  });

  test("Initialize marks local backups as signed in and setup", () async {
    backupRestoreManager.authStream.listen(
      expectAsync1((state) {
        expect(state, BackupRestoreAuthState.signedIn);
      }),
    );

    await backupRestoreManager.initialize();

    verify(managers.userPreferenceManager.setDidSetupBackup(true)).called(1);
  });

  test("Initialize registers entity listeners without auto-sharing", () async {
    EntityListener<dynamic>? catchListener;
    when(managers.catchManager.listen(any)).thenAnswer((invocation) {
      catchListener = invocation.positionalArguments[0] as EntityListener;
      return MockStreamSubscription();
    });

    await backupRestoreManager.initialize();
    expect(catchListener, isNotNull);

    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    catchListener!.onAdd?.call(null);
    await Future<void>.delayed(Duration.zero);
    verifyNever(
      managers.sharePlusWrapper.shareFiles(
        any,
        any,
        subject: anyNamed("subject"),
        text: anyNamed("text"),
      ),
    );
  });

  test("Backup exits early if already in progress", () async {
    // Use a database file that exists so the first call suspends at an
    // `await` (leaving `_isInProgress` true) instead of returning
    // synchronously, giving the second call something to be blocked by.
    stubFile(databasePath, fakeFile(exists: true));

    var first = backupRestoreManager.backup();
    var second = backupRestoreManager.backup();

    verify(managers.localDatabaseManager.databasePath()).called(1);

    await first;
    await second;
  });

  test("Backup notifies databaseFileNotFound when db file is missing", () async {
    stubFile(databasePath, fakeFile(exists: false));

    verifyProgressStream([
      BackupRestoreProgressEnum.authenticating,
      BackupRestoreProgressEnum.fetchingFiles,
      BackupRestoreProgressEnum.backingUpData,
      BackupRestoreProgressEnum.databaseFileNotFound,
    ]);

    await backupRestoreManager.backup();
    expect(backupRestoreManager.isInProgress, isFalse);
  });

  test("Backup zips database, images, and available Mera JSON", () async {
    stubFile(databasePath, fakeFile(exists: true));

    when(managers.imageManager.imageFiles).thenAnswer(
      (_) => Future.value(["images/1.jpg", "images/2.jpg"]),
    );
    stubFile("images/1.jpg", fakeFile(exists: true));
    stubFile("images/2.jpg", fakeFile(exists: true));

    // Only one of the Mera JSON files is present; the rest should be
    // skipped silently.
    stubFile(join(docsPath, "mera_spots.json"), fakeFile(exists: true));
    for (var name in BackupRestoreManager.meraJsonFileNames.where(
      (n) => n != "mera_spots.json",
    )) {
      stubFile(join(docsPath, name), fakeFile(exists: false));
    }

    verifyProgressStream([
      BackupRestoreProgressEnum.authenticating,
      BackupRestoreProgressEnum.fetchingFiles,
      BackupRestoreProgressEnum.backingUpData,
      BackupRestoreProgressEnum.backingUpData,
      BackupRestoreProgressEnum.backingUpData,
      BackupRestoreProgressEnum.backingUpData,
      BackupRestoreProgressEnum.finished,
    ]);

    await backupRestoreManager.backup();

    verify(
      managers.sharePlusWrapper.shareFiles(
        any,
        any,
        subject: anyNamed("subject"),
        text: anyNamed("text"),
      ),
    ).called(1);
    verify(managers.userPreferenceManager.setLastBackupAt(any)).called(1);
    expect(backupRestoreManager.isInProgress, isFalse);
  });

  test("Backup reports apiRequestError on unexpected failure", () async {
    stubFile(databasePath, fakeFile(exists: true));
    when(
      managers.sharePlusWrapper.shareFiles(
        any,
        any,
        subject: anyNamed("subject"),
        text: anyNamed("text"),
      ),
    ).thenThrow(Exception("Share failed"));

    verifyProgressStream([
      BackupRestoreProgressEnum.authenticating,
      BackupRestoreProgressEnum.fetchingFiles,
      BackupRestoreProgressEnum.backingUpData,
      BackupRestoreProgressEnum.backingUpData,
      BackupRestoreProgressEnum.apiRequestError,
    ]);

    await backupRestoreManager.backup();
    expect(backupRestoreManager.isInProgress, isFalse);
    expect(backupRestoreManager.hasLastProgressError, isTrue);
  });

  test("Restore is cleared when the user cancels the file picker", () async {
    when(
      managers.lib.filePickerWrapper.pickFiles(
        type: anyNamed("type"),
        allowedExtensions: anyNamed("allowedExtensions"),
        allowMultiple: anyNamed("allowMultiple"),
        withData: anyNamed("withData"),
      ),
    ).thenAnswer((_) => Future.value(null));

    verifyProgressStream([
      BackupRestoreProgressEnum.authenticating,
      BackupRestoreProgressEnum.fetchingFiles,
      BackupRestoreProgressEnum.cleared,
    ]);

    await backupRestoreManager.restore();
    expect(backupRestoreManager.isInProgress, isFalse);
  });

  test("Restore reports apiRequestError when zip bytes can't be read", () async {
    when(
      managers.lib.filePickerWrapper.pickFiles(
        type: anyNamed("type"),
        allowedExtensions: anyNamed("allowedExtensions"),
        allowMultiple: anyNamed("allowMultiple"),
        withData: anyNamed("withData"),
      ),
    ).thenAnswer(
      (_) => Future.value(
        FilePickerResult([
          PlatformFile(name: "backup.zip", size: 0, bytes: null, path: null),
        ]),
      ),
    );

    verifyProgressStream([
      BackupRestoreProgressEnum.authenticating,
      BackupRestoreProgressEnum.fetchingFiles,
      BackupRestoreProgressEnum.apiRequestError,
    ]);

    await backupRestoreManager.restore();
  });

  test("Restore notifies databaseFileNotFound if zip has no database", () async {
    var zipBytes = buildZip({"images/1.jpg": [1, 2, 3]});
    when(
      managers.lib.filePickerWrapper.pickFiles(
        type: anyNamed("type"),
        allowedExtensions: anyNamed("allowedExtensions"),
        allowMultiple: anyNamed("allowMultiple"),
        withData: anyNamed("withData"),
      ),
    ).thenAnswer(
      (_) => Future.value(
        FilePickerResult([
          PlatformFile(name: "backup.zip", size: zipBytes.length, bytes: zipBytes),
        ]),
      ),
    );

    verifyProgressStream([
      BackupRestoreProgressEnum.authenticating,
      BackupRestoreProgressEnum.fetchingFiles,
      BackupRestoreProgressEnum.databaseFileNotFound,
    ]);

    await backupRestoreManager.restore();
  });

  test(
    "Restore writes the database, skips existing images, restores missing "
    "images and Mera JSON, and reloads the app",
    () async {
      var zipBytes = buildZip({
        databaseName: [9, 9, 9],
        "images/existing.jpg": [1],
        "images/missing.jpg": [2],
        "mera_spots.json": [3],
      });
      when(
        managers.lib.filePickerWrapper.pickFiles(
          type: anyNamed("type"),
          allowedExtensions: anyNamed("allowedExtensions"),
          allowMultiple: anyNamed("allowMultiple"),
          withData: anyNamed("withData"),
        ),
      ).thenAnswer(
        (_) => Future.value(
          FilePickerResult([
            PlatformFile(
              name: "backup.zip",
              size: zipBytes.length,
              bytes: zipBytes,
            ),
          ]),
        ),
      );

      var dbOutFile = fakeFile(exists: false, parent: fakeDirectory());
      stubFile(databasePath, dbOutFile);

      var existingImage = fakeFile(exists: true, parent: fakeDirectory());
      when(
        managers.imageManager.imageFile("existing.jpg"),
      ).thenReturn(existingImage);

      var missingImage = fakeFile(exists: false, parent: fakeDirectory());
      when(
        managers.imageManager.imageFile("missing.jpg"),
      ).thenReturn(missingImage);

      var meraOutFile = fakeFile(exists: false, parent: fakeDirectory());
      stubFile(join(docsPath, "mera_spots.json"), meraOutFile);

      verifyProgressStream([
        BackupRestoreProgressEnum.authenticating,
        BackupRestoreProgressEnum.fetchingFiles,
        BackupRestoreProgressEnum.restoringDatabase,
        BackupRestoreProgressEnum.restoringImages,
        BackupRestoreProgressEnum.restoringImages,
        BackupRestoreProgressEnum.restoringImages,
        BackupRestoreProgressEnum.reloadingData,
        BackupRestoreProgressEnum.finished,
      ]);

      await backupRestoreManager.restore();

      verify(
        dbOutFile.writeAsBytes(any, flush: anyNamed("flush"), mode: anyNamed("mode")),
      ).called(1);
      verifyNever(
        existingImage.writeAsBytes(
          any,
          flush: anyNamed("flush"),
          mode: anyNamed("mode"),
        ),
      );
      verify(
        missingImage.writeAsBytes(
          any,
          flush: anyNamed("flush"),
          mode: anyNamed("mode"),
        ),
      ).called(1);
      verify(
        meraOutFile.writeAsBytes(
          any,
          flush: anyNamed("flush"),
          mode: anyNamed("mode"),
        ),
      ).called(1);
      verify(managers.localDatabaseManager.closeAndDeleteDatabase()).called(1);
      verify(managers.app.init(isStartup: false)).called(1);
      expect(backupRestoreManager.isInProgress, isFalse);
    },
  );

  test("notifySignedOutIfNeeded is a no-op for local backups", () async {
    backupRestoreManager.notifySignedOutIfNeeded();
    expect(backupRestoreManager.hasLastProgressError, isFalse);
  });

  test("Clear last error notifies listeners when an error is set", () async {
    stubFile(databasePath, fakeFile(exists: false));
    await backupRestoreManager.backup();
    expect(backupRestoreManager.hasLastProgressError, isTrue);

    verifyProgressStream([BackupRestoreProgressEnum.cleared]);
    backupRestoreManager.clearLastProgressError();
    expect(backupRestoreManager.hasLastProgressError, isFalse);
  });

  test("Clear last error exits early if error isn't set", () async {
    var called = false;
    backupRestoreManager.progressStream.listen(
      expectAsync1((_) => called = true, count: 0),
    );

    backupRestoreManager.clearLastProgressError();
    expect(backupRestoreManager.hasLastProgressError, isFalse);
    expect(called, isFalse);
  });
}
