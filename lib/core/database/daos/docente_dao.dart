import 'package:drift/drift.dart';
import '../tables/docentes_table.dart';
import '../app_database.dart';

part 'docente_dao.g.dart';

@DriftAccessor(tables: [DocentesTable])
class DocenteDao extends DatabaseAccessor<AppDatabase> with _$DocenteDaoMixin {
  DocenteDao(super.db);

  Future<List<DocenteDrift>> getAll() => select(docentesTable).get();

  Future<DocenteDrift?> getById(String id) =>
      (select(docentesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insert(DocenteDrift docente) =>
      into(docentesTable).insertOnConflictUpdate(docente);

  Future<int> updateEntity(DocenteDrift docente) =>
      (update(docentesTable)..where((t) => t.id.equals(docente.id))).write(docente);

  Future<int> upsertAll(List<DocenteDrift> docentes) async {
    var count = 0;
    for (final d in docentes) {
      count += await into(docentesTable).insertOnConflictUpdate(d);
    }
    return count;
  }

  Future<void> deleteById(String id) =>
      (delete(docentesTable)..where((t) => t.id.equals(id))).go();

  Future<void> markSynced(String id) async {
    await (update(docentesTable)..where((t) => t.id.equals(id)))
        .write(DocentesTableCompanion(syncedAt: Value(DateTime.now())));
  }

  Future<DateTime?> getLastSyncedAt() async {
    final result = await (select(docentesTable)
          ..orderBy([(t) => OrderingTerm.asc(t.syncedAt)])
          ..limit(1))
        .get();
    if (result.isEmpty) return null;
    return result.first.syncedAt;
  }
}
