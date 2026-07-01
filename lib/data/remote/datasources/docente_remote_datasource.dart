import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/docente_model.dart';

class DocenteRemoteDatasource {
  final SupabaseClient _client;
  static const String _table = 'docentes';

  DocenteRemoteDatasource(this._client);

  Future<List<DocenteModel>> getDocentes({String? search, bool? soloActivos}) {
    PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
        _client.from(_table).select();

    if (soloActivos == true) {
      query = query.eq('activo', true);
    }

    if (search != null && search.isNotEmpty) {
      query = query.ilike('nombre_completo', '%$search%');
    }

    return query.order('nombre_completo').then((data) {
      return data.map((e) => DocenteModel.fromJson(e)).toList();
    });
  }

  Future<DocenteModel> getDocenteById(String id) {
    return _client.from(_table).select().eq('id', id).single().then((data) {
      return DocenteModel.fromJson(data);
    });
  }

  Future<DocenteModel> createDocente(Map<String, dynamic> json) {
    return _client.from(_table).insert(json).select().single().then((data) {
      return DocenteModel.fromJson(data);
    });
  }

  Future<DocenteModel> updateDocente(String id, Map<String, dynamic> json) {
    return _client.from(_table).update(json).eq('id', id).select().single().then((data) {
      return DocenteModel.fromJson(data);
    });
  }

  Future<void> desactivarDocente(String id) {
    return _client
        .from(_table)
        .update({'activo': false})
        .eq('id', id)
        .then((_) {});
  }

  Future<void> eliminarDocente(String id) {
    return _client.from(_table).delete().eq('id', id).then((_) {});
  }
}
