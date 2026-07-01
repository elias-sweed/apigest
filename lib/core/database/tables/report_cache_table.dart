import 'package:drift/drift.dart';

class ReportCacheTable extends Table {
  TextColumn get key => text()();
  TextColumn get data => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
