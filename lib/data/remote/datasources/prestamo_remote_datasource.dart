import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/prestamo_model.dart';

class PrestamoRemoteDatasource {
  final SupabaseClient _client;
  static const String _table = 'prestamos';

  PrestamoRemoteDatasource(this._client);

  Future<List<PrestamoModel>> getPrestamos({String? estado}) {
    PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
        _client.from(_table).select('''
          *,
          docentes:docente_id(nombre_completo),
          usuarios:encargado_id(nombre_completo),
          prestamo_equipos(
            *,
            equipos( codigo_patrimonial, marca, modelo, tipo )
          )
        ''');

    if (estado != null && estado.isNotEmpty) {
      query = query.eq('estado', estado);
    }

    return query.order('fecha_hora_inicio', ascending: false).then((data) {
      return data.map((e) => PrestamoModel.fromJson(e)).toList();
    });
  }

  Future<PrestamoModel> getPrestamoById(String id) {
    return _client
        .from(_table)
        .select('''
          *,
          docentes:docente_id(nombre_completo),
          usuarios:encargado_id(nombre_completo),
          prestamo_equipos(
            *,
            equipos( codigo_patrimonial, marca, modelo, tipo )
          )
        ''')
        .eq('id', id)
        .single()
        .then((data) => PrestamoModel.fromJson(data));
  }

  Future<PrestamoModel> createPrestamo(
    Map<String, dynamic> prestamoJson,
    List<Map<String, dynamic>> equiposJson,
  ) async {
    final prestamo = await _client
        .from(_table)
        .insert(prestamoJson)
        .select('''
          *,
          docentes:docente_id(nombre_completo),
          usuarios:encargado_id(nombre_completo)
        ''')
        .single()
        .then((data) => PrestamoModel.fromJson(data));

    if (equiposJson.isNotEmpty) {
      await _client.from('prestamo_equipos').insert(equiposJson);
    }

    return prestamo;
  }
}
