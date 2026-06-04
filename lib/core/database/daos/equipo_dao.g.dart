// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipo_dao.dart';

// ignore_for_file: type=lint
mixin _$EquipoDaoMixin on DatabaseAccessor<AppDatabase> {
  $EquiposTableTable get equiposTable => attachedDatabase.equiposTable;
  EquipoDaoManager get managers => EquipoDaoManager(this);
}

class EquipoDaoManager {
  final _$EquipoDaoMixin _db;
  EquipoDaoManager(this._db);
  $$EquiposTableTableTableManager get equiposTable =>
      $$EquiposTableTableTableManager(_db.attachedDatabase, _db.equiposTable);
}
