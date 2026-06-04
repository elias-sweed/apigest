import '../../../core/database/app_database.dart';
import '../../../core/database/daos/equipo_dao.dart';
import '../../models/equipo_model.dart';

class EquipoLocalDatasource {
  final EquipoDao _dao;

  EquipoLocalDatasource(this._dao);

  Future<List<EquipoModel>> getAll() async {
    final results = await _dao.getAll();
    final valid = results.where((r) => r.id.isNotEmpty).toList();
    final invalid = results.where((r) => r.id.isEmpty).toList();
    if (invalid.isNotEmpty) {
      for (final r in invalid) {
        await _dao.deleteById(r.id);
      }
    }
    return valid.map(_toModel).toList();
  }

  Future<EquipoModel?> getById(String id) async {
    final result = await _dao.getById(id);
    if (result == null) return null;
    return _toModel(result);
  }

  Future<void> insert(EquipoModel model) async {
    await _dao.insert(_toDrift(model));
  }

  Future<void> update(EquipoModel model) async {
    await _dao.updateEntity(_toDrift(model));
  }

  Future<void> upsertAll(List<EquipoModel> models) async {
    await _dao.upsertAll(models.map(_toDrift).toList());
  }

  Future<void> markSynced(String id) async {
    await _dao.markSynced(id);
  }

  EquipoModel _toModel(EquipoDrift d) {
    return EquipoModel(
      id: d.id,
      codigoPatrimonial: d.codigoPatrimonial,
      tipo: d.tipo,
      marca: d.marca,
      modelo: d.modelo,
      numeroSerie: d.numeroSerie,
      estado: d.estado,
      observaciones: d.observaciones,
      imagenUrl: d.imagenUrl,
      createdAt: d.createdAt,
      updatedAt: d.updatedAt,
    );
  }

  EquipoDrift _toDrift(EquipoModel m) {
    return EquipoDrift(
      id: m.id,
      codigoPatrimonial: m.codigoPatrimonial,
      tipo: m.tipo,
      marca: m.marca,
      modelo: m.modelo,
      numeroSerie: m.numeroSerie,
      estado: m.estado,
      observaciones: m.observaciones,
      imagenUrl: m.imagenUrl,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
      syncedAt: null,
    );
  }
}
