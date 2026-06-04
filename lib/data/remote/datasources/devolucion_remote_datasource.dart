import 'package:supabase_flutter/supabase_flutter.dart';

class DevolucionRemoteDatasource {
  final SupabaseClient _client;

  DevolucionRemoteDatasource(this._client);

  Future<void> registrarDevolucion({
    required String prestamoId,
    required String practicanteId,
    required List<String> prestamoEquipoIds,
    String? observaciones,
  }) async {
    final devolucion = await _client
        .from('devoluciones')
        .insert({
          'prestamo_id': prestamoId,
          'practicante_id': practicanteId,
          'observaciones': observaciones,
        })
        .select('id')
        .single();

    final devolucionId = devolucion['id'] as String;

    if (prestamoEquipoIds.isNotEmpty) {
      await _client.from('devolucion_equipos').insert(
            prestamoEquipoIds.map((peId) => {
              'devolucion_id': devolucionId,
              'prestamo_equipo_id': peId,
            }).toList(),
          );

      await _client
          .from('prestamo_equipos')
          .update({'fecha_devolucion_real': DateTime.now().toIso8601String()})
          .inFilter('id', prestamoEquipoIds);
    }

    final pendientes = await _client
        .from('prestamo_equipos')
        .select('id')
        .eq('prestamo_id', prestamoId)
        .isFilter('fecha_devolucion_real', null);

    if (pendientes.isEmpty) {
      await _client
          .from('prestamos')
          .update({'estado': 'devuelto'})
          .eq('id', prestamoId);
    } else {
      await _client
          .from('prestamos')
          .update({'estado': 'parcial'})
          .eq('id', prestamoId);
    }
  }
}
