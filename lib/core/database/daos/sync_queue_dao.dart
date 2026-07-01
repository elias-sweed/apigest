import 'package:drift/drift.dart';
import '../tables/sync_queue_table.dart';
import '../app_database.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueueTable])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<int> enqueue(SyncQueueTableCompanion entry) =>
      into(syncQueueTable).insert(entry);

  Future<List<SyncQueueEntryDrift>> getAll() =>
      select(syncQueueTable).get();

  Future<void> deleteById(int id) =>
      (delete(syncQueueTable)..where((t) => t.id.equals(id))).go();

  Future<void> incrementRetry(int id, String error) async {
    final current = await (select(syncQueueTable)..where((t) => t.id.equals(id))).getSingle();
    await (update(syncQueueTable)..where((t) => t.id.equals(id))).write(
      SyncQueueTableCompanion(
        retryCount: Value(current.retryCount + 1),
        lastError: Value(error),
      ),
    );
  }

  Future<int> pendingCount() => select(syncQueueTable).get().then((r) => r.length);
}
