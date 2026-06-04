// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docente_dao.dart';

// ignore_for_file: type=lint
mixin _$DocenteDaoMixin on DatabaseAccessor<AppDatabase> {
  $DocentesTableTable get docentesTable => attachedDatabase.docentesTable;
  DocenteDaoManager get managers => DocenteDaoManager(this);
}

class DocenteDaoManager {
  final _$DocenteDaoMixin _db;
  DocenteDaoManager(this._db);
  $$DocentesTableTableTableManager get docentesTable =>
      $$DocentesTableTableTableManager(_db.attachedDatabase, _db.docentesTable);
}
