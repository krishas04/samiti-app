import 'package:samiti_app/core/database/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class OutboxLocalDb{
  Future<Database> get _db => DbHelper.instance.database;

  // add operations to queue
  Future<void> enqueue({
    required String id,
    required String operation,
    required String resource,
    required String endpoint,
    required String payload,
    required String method,
    String? pendingImagePath,
  })  async{
    final db= await _db;
    await db.insert(
        'outbox',
        {
          'id':id,
          'operation':operation,
          'resource': resource,
          'endpoint': endpoint,
          'payload': payload,
          'pending_image_path': pendingImagePath,
          'method': method,
          'retry_count': 0,
          'max_retries': 3,
          'created_at': DateTime.now().toIso8601String(),
          'status': 'pending',
          'last_error': null,
        });
  }

  // get all pending ops ordered by creation time
  Future<List<Map<String,dynamic>>> getPending() async{
    final db= await _db;
    return db.query(
        'outbox',
        where:" status IN ('pending', 'failed') AND retry_count < max_retries",
        orderBy: 'created_at ASC'
    );
  }

  // removed synced ops
  Future<void> remove(String id) async {
    final db= await _db;
    await db.delete(
        'outbox',
        where: 'id = ?',
        whereArgs: [id]
    );
  }

  // increment retry , save error message
  Future<void> markFailed(String id, String error, int currentRetry) async{
    final db= await _db;
    await db.update(
        'outbox',
        {
          'retry_count': currentRetry + 1,
          'last_error': error,
          'status': 'failed',
        },
        where: 'id = ?',
        whereArgs: [id],
    );
  }

  // count pending - used for UI indicator
  Future<int> pendingCount() async{
    final db= await _db;
    final result= await db.rawQuery(
        "SELECT COUNT(*) as count FROM outbox where status IN ('pending', 'failed') AND retry_count < max_retries",
    );
    return result.first['count'] as int;
  }

  // cleat all - used on logout
  Future<void> clear() async{
    final db= await _db;
    await db.delete('outbox');
  }
}