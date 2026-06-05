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

  Future<PrestamoModel> updatePrestamo(
    String id,
    Map<String, dynamic> data,
  ) {
    return _client
        .from(_table)
        .update(data)
        .eq('id', id)
        .select('''
          *,
          docentes:docente_id(nombre_completo),
          usuarios:encargado_id(nombre_completo),
          prestamo_equipos(
            *,
            equipos( codigo_patrimonial, marca, modelo, tipo )
          )
        ''')
        .single()
        .then((data) => PrestamoModel.fromJson(data));
  }

  Future<void> addEquipos(
    String prestamoId,
    List<String> equipoIds,
  ) async {
    if (equipoIds.isEmpty) return;
    final rows = equipoIds.map((id) => {
      'prestamo_id': prestamoId,
      'equipo_id': id,
      'fecha_devolucion_real': null,
    }).toList();
    await _client.from('prestamo_equipos').insert(rows);
  }

  Future<void> removeEquipo(String prestamoEquipoId) async {
    await _client.from('prestamo_equipos').delete().eq('id', prestamoEquipoId);
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
      final equiposConPrestamoId = equiposJson.map((e) => {
        ...e,
        'prestamo_id': prestamo.id,
      }).toList();
      try {
        await _client.from('prestamo_equipos').insert(equiposConPrestamoId);
      } catch (_) {
        await _client.from(_table).delete().eq('id', prestamo.id);
        rethrow;
      }
    }

    return prestamo;
  }
}
