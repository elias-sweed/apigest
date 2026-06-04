import 'package:drift/drift.dart';

@DataClassName('DocenteDrift')
class DocentesTable extends Table {
  @override
  String get tableName => 'docentes';

  TextColumn get id => text()();
  TextColumn get nombres => text()();
  TextColumn get apellidos => text()();
  TextColumn? get grado => text().nullable()();
  TextColumn? get seccion => text().nullable()();
  TextColumn? get turno => text().nullable()();
  IntColumn get activo => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn? get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
