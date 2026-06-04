import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/equipo_model.dart';

class EquipoRemoteDatasource {
  final SupabaseClient _client;
  static const String _table = 'equipos';

  EquipoRemoteDatasource(this._client);

  Future<List<EquipoModel>> getEquipos({String? search, String? estado}) {
    PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
        _client.from(_table).select();

    if (estado != null && estado.isNotEmpty) {
      query = query.eq('estado', estado);
    }

    if (search != null && search.isNotEmpty) {
      query = query.or(
        'codigo_patrimonial.ilike.%$search%,'
        'marca.ilike.%$search%,'
        'modelo.ilike.%$search%',
      );
    }

    return query.order('codigo_patrimonial').then((data) {
      return data.map((e) => EquipoModel.fromJson(e)).toList();
    });
  }

  Future<EquipoModel> getEquipoById(String id) {
    return _client.from(_table).select().eq('id', id).single().then((data) {
      return EquipoModel.fromJson(data);
    });
  }

  Future<EquipoModel> createEquipo(Map<String, dynamic> json) {
    return _client.from(_table).insert(json).select().single().then((data) {
      return EquipoModel.fromJson(data);
    });
  }

  Future<EquipoModel> updateEquipo(String id, Map<String, dynamic> json) {
    return _client.from(_table).update(json).eq('id', id).select().single().then((data) {
      return EquipoModel.fromJson(data);
    });
  }

  Future<void> cambiarEstado(String id, String nuevoEstado) {
    return _client.from(_table).update({'estado': nuevoEstado}).eq('id', id).then((_) {});
  }
}
