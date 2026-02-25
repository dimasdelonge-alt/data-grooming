import 'package:flutter/foundation.dart';

// Conditional import
import 'offline_backup_native.dart' if (dart.library.js_interop) 'offline_backup_web.dart' as platform;

class OfflineBackupManager {
  Future<String?> createBackup({
    required String dbPath,
    required List<String> imagePaths,
  }) async {
    return platform.createBackup(dbPath: dbPath, imagePaths: imagePaths);
  }

  Future<void> shareBackup(String zipPath) async {
    return platform.shareBackup(zipPath);
  }

  Future<String?> pickBackupFile() async {
    return platform.pickBackupFile();
  }

  Future<bool> restoreBackup({
    required String zipPath,
    required String dbFolder,
    required String docsFolder,
    required String dbName,
  }) async {
    return platform.restoreBackup(
      zipPath: zipPath,
      dbFolder: dbFolder,
      docsFolder: docsFolder,
      dbName: dbName,
    );
  }
}
