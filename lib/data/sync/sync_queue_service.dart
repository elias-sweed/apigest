import 'dart:convert';
import '../../core/database/app_database.dart';
import '../../core/database/daos/sync_queue_dao.dart';

class SyncQueueService {
  final SyncQueueDao _dao;

  SyncQueueService(this._dao);

  Future<void> enqueue({
    required String entity,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    await _dao.enqueue(SyncQueueTableCompanion.insert(
      entity: entity,
      entityId: entityId,
      operation: operation,
      payload: jsonEncode(payload),
      createdAt: DateTime.now(),
    ));
  }

  Future<List<SyncQueueEntryDrift>> getAll() => _dao.getAll();

  Future<void> remove(int id) => _dao.deleteById(id);

  Future<void> markRetry(int id, String error) =>
      _dao.incrementRetry(id, error);

  Future<int> pendingCount() => _dao.pendingCount();
}
