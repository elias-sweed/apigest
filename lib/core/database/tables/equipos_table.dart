import 'package:drift/drift.dart';

@DataClassName('EquipoDrift')
class EquiposTable extends Table {
  @override
  String get tableName => 'equipos';

  TextColumn get id => text()();
  TextColumn get codigoPatrimonial => text()();
  TextColumn get tipo => text()();
  TextColumn? get marca => text().nullable()();
  TextColumn? get modelo => text().nullable()();
  TextColumn? get numeroSerie => text().nullable()();
  TextColumn get estado => text()();
  TextColumn? get observaciones => text().nullable()();
  TextColumn? get imagenUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn? get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
