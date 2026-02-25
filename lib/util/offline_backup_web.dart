import 'package:flutter/foundation.dart';

/// Web stub: offline backup is not supported on web.
/// Data is synced via cloud instead.

Future<String?> createBackup({
  required String dbPath,
  required List<String> imagePaths,
}) async {
  debugPrint('createBackup: not supported on web (use cloud sync)');
  return null;
}

Future<void> shareBackup(String zipPath) async {
  debugPrint('shareBackup: not supported on web');
}

Future<String?> pickBackupFile() async {
  debugPrint('pickBackupFile: not supported on web');
  return null;
}

Future<bool> restoreBackup({
  required String zipPath,
  required String dbFolder,
  required String docsFolder,
  required String dbName,
}) async {
  debugPrint('restoreBackup: not supported on web (use cloud sync)');
  return false;
}
