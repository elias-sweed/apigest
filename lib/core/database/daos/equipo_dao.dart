import 'package:drift/drift.dart';
import '../tables/equipos_table.dart';
import '../app_database.dart';

part 'equipo_dao.g.dart';

@DriftAccessor(tables: [EquiposTable])
class EquipoDao extends DatabaseAccessor<AppDatabase> with _$EquipoDaoMixin {
  EquipoDao(super.db);

  Future<List<EquipoDrift>> getAll() => select(equiposTable).get();

  Future<EquipoDrift?> getById(String id) =>
      (select(equiposTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insert(EquipoDrift equipo) =>
      into(equiposTable).insertOnConflictUpdate(equipo);

  Future<int> updateEntity(EquipoDrift equipo) =>
      (update(equiposTable)..where((t) => t.id.equals(equipo.id))).write(equipo);

  Future<int> upsertAll(List<EquipoDrift> equipos) async {
    var count = 0;
    for (final e in equipos) {
      count += await into(equiposTable).insertOnConflictUpdate(e);
    }
    return count;
  }

  Future<void> deleteById(String id) =>
      (delete(equiposTable)..where((t) => t.id.equals(id))).go();

  Future<void> markSynced(String id) async {
    await (update(equiposTable)..where((t) => t.id.equals(id)))
        .write(EquiposTableCompanion(syncedAt: Value(DateTime.now())));
  }

  Future<DateTime?> getLastSyncedAt() async {
    final result = await (select(equiposTable)
          ..orderBy([(t) => OrderingTerm.asc(t.syncedAt)])
          ..limit(1))
        .get();
    if (result.isEmpty) return null;
    return result.first.syncedAt;
  }
}
