import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/report_cache_table.dart';

part 'report_cache_dao.g.dart';

@DriftAccessor(tables: [ReportCacheTable])
class ReportCacheDao extends DatabaseAccessor<AppDatabase>
    with _$ReportCacheDaoMixin {
  ReportCacheDao(AppDatabase db) : super(db);

  Future<void> upsert(String key, String data) {
    return into(reportCacheTable).insertOnConflictUpdate(
      ReportCacheTableCompanion(
        key: Value(key),
        data: Value(data),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<String?> get(String key) async {
    final row = await (select(reportCacheTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.data;
  }

  Future<void> remove(String key) async {
    await (delete(reportCacheTable)..where((t) => t.key.equals(key))).go();
  }

  Future<void> clearAll() async {
    await delete(reportCacheTable).go();
  }
}
