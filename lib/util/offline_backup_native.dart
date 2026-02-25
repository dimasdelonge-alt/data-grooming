import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

Future<String?> createBackup({
  required String dbPath,
  required List<String> imagePaths,
}) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final backupDir = Directory(p.join(tempDir.path, 'backup_temp'));
    if (await backupDir.exists()) {
      await backupDir.delete(recursive: true);
    }
    await backupDir.create();

    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      await dbFile.copy(p.join(backupDir.path, 'grooming_database.db'));
    }
    
    final walFile = File('$dbPath-wal');
    if (await walFile.exists()) {
      await walFile.copy(p.join(backupDir.path, 'grooming_database.db-wal'));
    }
    
    final shmFile = File('$dbPath-shm');
    if (await shmFile.exists()) {
      await shmFile.copy(p.join(backupDir.path, 'grooming_database.db-shm'));
    }

    final imagesDir = Directory(p.join(backupDir.path, 'images'));
    await imagesDir.create();
    
    for (final imgPath in imagePaths) {
      final imgFile = File(imgPath);
      if (await imgFile.exists()) {
        final fileName = p.basename(imgPath);
        await imgFile.copy(p.join(imagesDir.path, fileName));
      }
    }

    final zipPath = p.join(tempDir.path, 'backup_${DateTime.now().millisecondsSinceEpoch}.zip');
    final encoder = ZipFileEncoder();
    encoder.create(zipPath);
    await encoder.addDirectory(backupDir);
    encoder.close();

    await backupDir.delete(recursive: true);
    return zipPath;
  } catch (e) {
    debugPrint('Backup Error: $e');
    return null;
  }
}

Future<void> shareBackup(String zipPath) async {
  await Share.shareXFiles([XFile(zipPath)], text: 'Jeni Cathouse Backup');
}

Future<String?> pickBackupFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['zip'],
  );
  return result?.files.single.path;
}

Future<bool> restoreBackup({
  required String zipPath,
  required String dbFolder,
  required String docsFolder,
  required String dbName,
}) async {
  try {
    debugPrint('Starting restore from: $zipPath');
    final bytes = File(zipPath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    debugPrint('Zip decoded. Found ${archive.length} files.');

    bool dbFound = false;

    for (final file in archive) {
      if (!file.isFile) continue;
      final filename = file.name;
      final ext = p.extension(filename).toLowerCase();
      final content = file.content as List<int>;

      bool isSqlite = false;
      if (content.length >= 16) {
        try {
           final header = String.fromCharCodes(content.sublist(0, 15));
           if (header == 'SQLite format 3') {
             isSqlite = true;
           }
        } catch (_) {}
      }

      if (isSqlite || ext == '.db') {
        debugPrint('Restoring DB file (Magic: $isSqlite): $filename -> $dbName');
        File(p.join(dbFolder, dbName))
          ..createSync(recursive: true)
          ..writeAsBytesSync(content);
        dbFound = true;
      } else if (filename.endsWith('.db-wal') || filename.endsWith('-wal') || filename.endsWith('wal')) {
         debugPrint('Restoring WAL file: $filename');
         File(p.join(dbFolder, '$dbName-wal'))
          ..createSync(recursive: true)
          ..writeAsBytesSync(content);
      } else if (filename.endsWith('.db-shm') || filename.endsWith('-shm') || filename.endsWith('shm')) {
         debugPrint('Restoring SHM file: $filename');
         File(p.join(dbFolder, '$dbName-shm'))
          ..createSync(recursive: true)
          ..writeAsBytesSync(content);
      } else if (ext == '.jpg' || ext == '.jpeg' || ext == '.png') {
        final imageBasename = p.basename(filename);
        File(p.join(docsFolder, imageBasename))
          ..createSync(recursive: true)
          ..writeAsBytesSync(content);
      }
    }
    
    if (!dbFound) {
      debugPrint('WARNING: No SQLite .db file found in ZIP!');
    }
    
    return true;
  } catch (e) {
    debugPrint('Restore Error: $e');
    return false;
  }
}
