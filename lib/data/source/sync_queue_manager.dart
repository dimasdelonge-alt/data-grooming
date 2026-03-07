import 'dart:async';
import 'package:http/http.dart' as http;
import 'database_helper.dart';

/// Manages a persistent queue of failed Firebase sync operations.
/// Items are stored in SQLite and retried periodically.
class SyncQueueManager {
  static const int _maxRetries = 5;
  static const String _firebaseBaseUrl =
      'https://smartgroomer-track-default-rtdb.asia-southeast1.firebasedatabase.app';

  final DatabaseHelper _dbHelper;
  final _pendingCountController = StreamController<int>.broadcast();
  Stream<int> get pendingCountStream => _pendingCountController.stream;

  int _pendingCount = 0;
  int get pendingCount => _pendingCount;

  SyncQueueManager(this._dbHelper);

  /// Enqueue a failed sync operation for later retry.
  Future<void> enqueue(String action, String path, String? payload) async {
    final db = await _dbHelper.database;
    await db.insert('sync_queue', {
      'action': action,
      'path': path,
      'payload': payload,
      'retryCount': 0,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'lastAttempt': 0,
    });
    await _refreshCount();
    print('SyncQueue: Enqueued $action $path (pending: $_pendingCount)');
  }

  /// Process all pending items in the queue.
  /// Returns the number of successfully synced items.
  Future<int> processQueue() async {
    final db = await _dbHelper.database;
    final items = await db.query('sync_queue',
        where: 'retryCount < ?',
        whereArgs: [_maxRetries],
        orderBy: 'createdAt ASC');

    if (items.isEmpty) return 0;

    print('SyncQueue: Processing ${items.length} pending items...');
    int successCount = 0;

    for (final item in items) {
      final id = item['id'] as int;
      final action = item['action'] as String;
      final path = item['path'] as String;
      final payload = item['payload'] as String?;
      final retryCount = item['retryCount'] as int;

      try {
        final url = Uri.parse('$_firebaseBaseUrl/$path.json');
        http.Response response;

        if (action == 'DELETE') {
          response = await http.delete(url).timeout(
              const Duration(seconds: 8));
        } else {
          response = await http.put(url, body: payload).timeout(
              const Duration(seconds: 8));
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success — remove from queue
          await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
          successCount++;
          print('SyncQueue: ✅ $action $path (retry #$retryCount)');
        } else {
          throw Exception('HTTP ${response.statusCode}');
        }
      } catch (e) {
        // Failed — increment retry count
        await db.update(
          'sync_queue',
          {
            'retryCount': retryCount + 1,
            'lastAttempt': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
        print('SyncQueue: ❌ $action $path retry #${retryCount + 1}: $e');
      }
    }

    // Clean up permanently failed items (retryCount >= maxRetries)
    await db.delete('sync_queue',
        where: 'retryCount >= ?', whereArgs: [_maxRetries]);

    await _refreshCount();
    if (successCount > 0) {
      print('SyncQueue: Synced $successCount items. Remaining: $_pendingCount');
    }
    return successCount;
  }

  /// Get the current number of pending sync items.
  Future<int> getPendingCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM sync_queue WHERE retryCount < ?',
        [_maxRetries]);
    return result.first['cnt'] as int? ?? 0;
  }

  /// Clear all pending sync items (e.g., after a full manual upload).
  Future<void> clearAll() async {
    final db = await _dbHelper.database;
    await db.delete('sync_queue');
    await _refreshCount();
    print('SyncQueue: Cleared all pending items.');
  }

  Future<void> _refreshCount() async {
    _pendingCount = await getPendingCount();
    _pendingCountController.add(_pendingCount);
  }

  /// Initial load of pending count.
  Future<void> init() async {
    await _refreshCount();
  }

  void dispose() {
    _pendingCountController.close();
  }
}
