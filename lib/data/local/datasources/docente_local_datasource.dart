import '../../../core/database/app_database.dart';
import '../../../core/database/daos/docente_dao.dart';
import '../../models/docente_model.dart';

class DocenteLocalDatasource {
  final DocenteDao _dao;

  DocenteLocalDatasource(this._dao);

  Future<List<DocenteModel>> getAll() async {
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

  Future<DocenteModel?> getById(String id) async {
    final result = await _dao.getById(id);
    if (result == null) return null;
    return _toModel(result);
  }

  Future<void> insert(DocenteModel model) async {
    await _dao.insert(_toDrift(model));
  }

  Future<void> update(DocenteModel model) async {
    await _dao.updateEntity(_toDrift(model));
  }

  Future<void> upsertAll(List<DocenteModel> models) async {
    await _dao.upsertAll(models.map(_toDrift).toList());
  }

  Future<void> markSynced(String id) async {
    await _dao.markSynced(id);
  }

  DocenteModel _toModel(DocenteDrift d) {
    return DocenteModel(
      id: d.id,
      nombres: d.nombres,
      apellidos: d.apellidos,
      grado: d.grado,
      seccion: d.seccion,
      turno: d.turno,
      activo: d.activo == 1,
      createdAt: d.createdAt,
      updatedAt: d.updatedAt,
    );
  }

  DocenteDrift _toDrift(DocenteModel m) {
    return DocenteDrift(
      id: m.id,
      nombres: m.nombres,
      apellidos: m.apellidos,
      grado: m.grado,
      seccion: m.seccion,
      turno: m.turno,
      activo: m.activo ? 1 : 0,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
      syncedAt: null,
    );
  }
}
