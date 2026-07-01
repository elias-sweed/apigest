import 'dart:io';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/equipos_table.dart';
import 'tables/docentes_table.dart';
import 'tables/sync_queue_table.dart';
import 'tables/report_cache_table.dart';
import 'daos/equipo_dao.dart';
import 'daos/docente_dao.dart';
import 'daos/sync_queue_dao.dart';
import 'daos/report_cache_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    EquiposTable,
    DocentesTable,
    SyncQueueTable,
    ReportCacheTable,
  ],
  daos: [
    EquipoDao,
    DocenteDao,
    SyncQueueDao,
    ReportCacheDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? customConn}) : super(customConn ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(reportCacheTable);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      await dir.create(recursive: true);
      final file = File(p.join(dir.path, 'aipgest.db'));
      return NativeDatabase(file);
    });
  }
}
