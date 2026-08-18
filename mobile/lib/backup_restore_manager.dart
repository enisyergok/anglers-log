import 'dart:async';
import 'dart:typed_data';

import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/wrappers/file_picker_wrapper.dart';
import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:adair_flutter_lib/wrappers/path_provider_wrapper.dart';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/wrappers/share_plus_wrapper.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import 'app_manager.dart';
import 'bait_manager.dart';
import 'local_database_manager.dart';
import 'mera/mera_boat_profile.dart';
import 'mera/mera_catch_activity_store.dart';
import 'mera/mera_no_catch_manager.dart';
import 'mera/mera_route_manager.dart';
import 'model/gen/anglers_log.pb.dart';
import 'navigation/mera_manager.dart';

enum BackupRestoreAuthState { signedOut, signedIn, error, networkError }

enum BackupRestoreProgressEnum {
  // Errors
  authClientError(true),
  createFolderError(true),
  folderNotFound(true),
  apiRequestError(true),
  databaseFileNotFound(true),
  accessDenied(true),
  networkError(true),
  signedOut(true),
  storageFull(true),

  // Progress states
  authenticating(false),
  fetchingFiles(false),
  creatingFolder(false),
  backingUpData(false),
  restoringDatabase(false),
  restoringImages(false),
  reloadingData(false),
  finished(false),
  cleared(false);

  final bool isError;

  const BackupRestoreProgressEnum(this.isError);
}

class BackupRestoreProgress {
  final BackupRestoreProgressEnum value;
  final Object? apiError;
  final int? percentage;

  BackupRestoreProgress(this.value, {this.apiError, this.percentage});

  String get percentageString => percentage == null ? "" : " ($percentage%)";

  bool get isError => value.isError;
}

/// Local zip backup / restore (no Google Drive).
///
/// Backup creates a zip of the SQLite database + images and shares it via the
/// system share sheet. Restore picks a zip with the file picker and reloads.
class BackupRestoreManager {
  static BackupRestoreManager of(BuildContext context) =>
      AppManager.get.backupRestoreManager;

  static const _databaseName = "anglerslog.db";
  static const _imagesFolderName = "images";
  static const _backupFilePrefix = "mera-asistani-backup";

  /// Mera JSON files stored under app documents (see mera_* managers).
  static const meraJsonFileNames = [
    'mera_spots.json',
    'mera_routes.json',
    'mera_catch_activity.json',
    'mera_no_catch.json',
    'mera_boat_profile.json',
    'mera_fish_env_cache.json',
    'mera_tracks.json',
  ];

  /// Rate limit how often automatic backups are made.
  static const _autoBackupInterval = Duration.millisecondsPerMinute * 5;

  final _log = const Log("BackupRestoreManager");
  final _authController = StreamController<BackupRestoreAuthState>.broadcast();
  final _progressController =
      StreamController<BackupRestoreProgress>.broadcast();

  /// True if a backup or restore is in progress; false otherwise.
  var _isInProgress = false;

  BackupRestoreProgress? _lastProgressError;

  /// Used so we don't show multiple [BackupRestorePage] instances when a user
  /// taps the backup error notification.
  bool isBackupRestorePageShowing = false;

  BaitManager get _baitManager => AppManager.get.baitManager;

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.get;

  ImageManager get _imageManager => AppManager.get.imageManager;

  TripManager get _tripManager => AppManager.get.tripManager;

  SharePlusWrapper get _sharePlusWrapper => AppManager.get.sharePlusWrapper;

  BackupRestoreManager();

  /// A [Stream] that fires events when a user's authentication changes.
  Stream<BackupRestoreAuthState> get authStream => _authController.stream;

  /// A [Stream] that fires events when the progress of a backup or restore
  /// changes.
  Stream<BackupRestoreProgress> get progressStream =>
      _progressController.stream;

  /// Always null — Google Sign-In is disabled for local backups.
  /// Legacy Google account accessor; always null for local-only backups.
  Object? get currentUser => null;

  BackupRestoreProgress? get lastProgressError => _lastProgressError;

  bool get hasLastProgressError => lastProgressError != null;

  /// Local backups do not require cloud auth.
  bool get isSignedIn => true;

  bool get isInProgress => _isInProgress;

  int? get lastBackupAt => UserPreferenceManager.get.lastBackupAt;

  Future<void> initialize() async {
    UserPreferenceManager.get.stream.listen((_) {
      // Local-only: keep preference in sync but no cloud connect/disconnect.
    });
    CatchManager.get.listen(_createEntityListener<Catch>());
    _tripManager.listen(_createEntityListener<Trip>());
    _baitManager.listen(_createEntityListener<Bait>());
    _fishingSpotManager.listen(_createEntityListener<FishingSpot>());

    // Auth is always ready for local backups.
    _authController.add(BackupRestoreAuthState.signedIn);
    UserPreferenceManager.get.setDidSetupBackup(true);
  }

  EntityListener<T> _createEntityListener<T>() {
    return EntityListener<T>(
      onAdd: (T _) => _autoBackupIfNeeded(),
      onDelete: (T _) => _autoBackupIfNeeded(),
      onUpdate: (T _) => _autoBackupIfNeeded(),
    );
  }

  Future<void> _autoBackupIfNeeded() async {
    // Auto-backup to the share sheet is not useful locally; skip.
    // Users can still toggle the preference; manual backup remains available.
    if (SubscriptionManager.get.isFree ||
        !UserPreferenceManager.get.autoBackup) {
      return;
    }

    var lastBackupAt = UserPreferenceManager.get.lastBackupAt;
    if (lastBackupAt != null &&
        TimeManager.get.currentTimestamp - lastBackupAt < _autoBackupInterval) {
      _log.d("Last backup was < interval, skipping...");
      return;
    }

    // Do not auto-invoke the share sheet on every entity change.
    _log.d("Skipping automatic local backup (manual share only)");
  }

  /// Notifies listeners if the user is signed out and has auto-backup enabled.
  /// No-op for local backups (always "signed in").
  void notifySignedOutIfNeeded() {}

  Future<void> backup() async {
    if (_isInProgress) {
      return;
    }

    try {
      _isInProgress = true;

      _notifyProgress(
        BackupRestoreProgress(BackupRestoreProgressEnum.authenticating),
      );
      _notifyProgress(
        BackupRestoreProgress(BackupRestoreProgressEnum.fetchingFiles),
      );
      _notifyProgress(
        BackupRestoreProgress(BackupRestoreProgressEnum.backingUpData, percentage: 0),
      );

      var archive = Archive();

      // Database.
      var db = IoWrapper.get.file(LocalDatabaseManager.get.databasePath());
      if (!db.existsSync()) {
        _notifyError(
          BackupRestoreProgress(BackupRestoreProgressEnum.databaseFileNotFound),
        );
        return;
      }
      var dbBytes = await db.readAsBytes();
      archive.addFile(ArchiveFile(_databaseName, dbBytes.length, dbBytes));

      // Images.
      var imageFiles = await _imageManager.imageFiles;
      var total = imageFiles.length + 1;
      var done = 1;
      _notifyProgress(
        BackupRestoreProgress(
          BackupRestoreProgressEnum.backingUpData,
          percentage: _percent(done, total),
        ),
      );

      for (var imagePath in imageFiles) {
        var file = IoWrapper.get.file(imagePath);
        if (!file.existsSync()) {
          continue;
        }
        var bytes = await file.readAsBytes();
        var name = "$_imagesFolderName/${basename(imagePath)}";
        archive.addFile(ArchiveFile(name, bytes.length, bytes));
        done++;
        _notifyProgress(
          BackupRestoreProgress(
            BackupRestoreProgressEnum.backingUpData,
            percentage: _percent(done, total),
          ),
        );
      }

      // Mera local JSON (spots, routes, catch activity, boat profile, etc.).
      var docs = await PathProviderWrapper.get.appDocumentsPath;
      for (var meraName in meraJsonFileNames) {
        var meraFile = IoWrapper.get.file(join(docs, meraName));
        if (!meraFile.existsSync()) {
          continue;
        }
        var bytes = await meraFile.readAsBytes();
        archive.addFile(ArchiveFile(meraName, bytes.length, bytes));
      }

      var encoded = ZipEncoder().encode(archive);
      var tmpDir = await PathProviderWrapper.get.temporaryPath;
      var stamp = TimeManager.get.currentTimestamp;
      var outPath = "$tmpDir/$_backupFilePrefix-$stamp.zip";
      var outFile = IoWrapper.get.file(outPath);
      await outFile.writeAsBytes(Uint8List.fromList(encoded), flush: true);

      await _sharePlusWrapper.shareFiles([XFile(outPath)], null);

      UserPreferenceManager.get.setLastBackupAt(TimeManager.get.currentTimestamp);

      _notifyProgress(
        BackupRestoreProgress(BackupRestoreProgressEnum.finished),
      );
      _isInProgress = false;
    } catch (error) {
      _log.d("Local backup error: ${error.runtimeType} - $error");
      _notifyError(
        BackupRestoreProgress(
          BackupRestoreProgressEnum.apiRequestError,
          apiError: error,
        ),
      );
    }
  }

  Future<void> restore() async {
    if (_isInProgress) {
      return;
    }

    try {
      _isInProgress = true;

      _notifyProgress(
        BackupRestoreProgress(BackupRestoreProgressEnum.authenticating),
      );
      _notifyProgress(
        BackupRestoreProgress(BackupRestoreProgressEnum.fetchingFiles),
      );

      var pickResult = await FilePickerWrapper.get.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["zip"],
        withData: true,
      );

      if (pickResult == null || pickResult.files.isEmpty) {
        // User cancelled.
        _notifyProgress(
          BackupRestoreProgress(BackupRestoreProgressEnum.cleared),
          killProcess: true,
        );
        return;
      }

      var picked = pickResult.files.first;
      Uint8List? bytes = picked.bytes;
      if (bytes == null && picked.path != null) {
        bytes = await IoWrapper.get.file(picked.path!).readAsBytes();
      }
      if (bytes == null) {
        _notifyError(
          BackupRestoreProgress(
            BackupRestoreProgressEnum.apiRequestError,
            apiError: "Could not read selected zip file",
          ),
        );
        return;
      }

      var archive = ZipDecoder().decodeBytes(bytes);

      ArchiveFile? dbArchive;
      var imageArchives = <ArchiveFile>[];
      var meraArchives = <ArchiveFile>[];
      for (var file in archive.files) {
        if (!file.isFile) {
          continue;
        }
        var name = file.name.replaceAll("\\", "/");
        var base = basename(name);
        if (name == _databaseName || name.endsWith("/$_databaseName")) {
          dbArchive = file;
        } else if (meraJsonFileNames.contains(base)) {
          meraArchives.add(file);
        } else if (name.contains(ImageManager.imgExtension)) {
          imageArchives.add(file);
        }
      }

      if (dbArchive == null) {
        _notifyError(
          BackupRestoreProgress(BackupRestoreProgressEnum.databaseFileNotFound),
        );
        return;
      }

      _notifyProgress(
        BackupRestoreProgress(BackupRestoreProgressEnum.restoringDatabase),
      );

      await LocalDatabaseManager.get.closeAndDeleteDatabase();

      var dbOut = IoWrapper.get.file(LocalDatabaseManager.get.databasePath());
      await dbOut.parent.create(recursive: true);
      await dbOut.writeAsBytes(
        Uint8List.fromList(dbArchive.content),
        flush: true,
      );

      _notifyProgress(
        BackupRestoreProgress(
          BackupRestoreProgressEnum.restoringImages,
          percentage: 0,
        ),
      );

      var imagesDone = 0;
      for (var imageArchive in imageArchives) {
        var fileName = basename(imageArchive.name);
        var imageFile = _imageManager.imageFile(fileName);
        if (imageFile.existsSync()) {
          _log.d("Image $fileName already exists, skipping restore...");
        } else {
          await imageFile.parent.create(recursive: true);
          await imageFile.writeAsBytes(
            Uint8List.fromList(imageArchive.content),
            flush: true,
          );
        }
        imagesDone++;
        _notifyProgress(
          BackupRestoreProgress(
            BackupRestoreProgressEnum.restoringImages,
            percentage: _percent(imagesDone, imageArchives.length),
          ),
        );
      }

      if (meraArchives.isNotEmpty) {
        var docs = await PathProviderWrapper.get.appDocumentsPath;
        for (var meraArchive in meraArchives) {
          var fileName = basename(meraArchive.name);
          if (!meraJsonFileNames.contains(fileName)) {
            continue;
          }
          var out = IoWrapper.get.file(join(docs, fileName));
          await out.parent.create(recursive: true);
          await out.writeAsBytes(
            Uint8List.fromList(meraArchive.content),
            flush: true,
          );
        }
        // Force in-memory managers to reload from restored files.
        MeraManager.reset();
        MeraRouteManager.reset();
        MeraNoCatchManager.reset();
        MeraBoatProfileManager.reset();
        MeraCatchActivityStore.reset();
      }

      _notifyProgress(
        BackupRestoreProgress(BackupRestoreProgressEnum.reloadingData),
      );

      await AppManager.get.init(isStartup: false);

      _notifyProgress(
        BackupRestoreProgress(BackupRestoreProgressEnum.finished),
      );
      _isInProgress = false;
    } catch (error) {
      _log.d("Local restore error: ${error.runtimeType} - $error");
      _notifyError(
        BackupRestoreProgress(
          BackupRestoreProgressEnum.apiRequestError,
          apiError: error,
        ),
      );
    }
  }

  void clearLastProgressError() {
    if (_lastProgressError == null) {
      return;
    }

    _lastProgressError = null;
    _notifyProgress(
      BackupRestoreProgress(BackupRestoreProgressEnum.cleared),
      killProcess: true,
    );
  }

  int _percent(int done, int total) {
    if (total <= 0) {
      return 100;
    }
    return ((done / total) * 100).round().clamp(0, 100);
  }

  void _notifyProgress(
    BackupRestoreProgress progress, {
    bool killProcess = false,
  }) {
    if (killProcess) {
      _isInProgress = false;
    }
    _lastProgressError = progress.isError ? progress : null;
    _progressController.add(progress);
  }

  void _notifyError(BackupRestoreProgress error) =>
      _notifyProgress(error, killProcess: true);
}
