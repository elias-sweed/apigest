import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/historial_filter.dart';
import '../../models/prestamo_model.dart';

class HistorialRemoteDatasource {
  final SupabaseClient _client;
  static const String _table = 'prestamos';

  HistorialRemoteDatasource(this._client);

  Future<List<PrestamoModel>> getPrestamos(HistorialFilter filter) async {
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

    if (filter.estado != null && filter.estado!.isNotEmpty) {
      query = query.eq('estado', filter.estado!);
    }

    if (filter.fechaInicio != null) {
      query = query.gte('fecha_hora_inicio', filter.fechaInicio!.toIso8601String());
    }

    if (filter.fechaFin != null) {
      query = query.lte('fecha_hora_inicio', filter.fechaFin!.toIso8601String());
    }

    if (filter.search != null && filter.search!.isNotEmpty) {
      query = query.or(
        'docentes.nombre_completo.ilike.%${filter.search}%,'
        'prestamo_equipos.equipos.codigo_patrimonial.ilike.%${filter.search}%,'
        'observaciones.ilike.%${filter.search}%',
      );
    }

    return query.order('fecha_hora_inicio', ascending: false).then((data) {
      return data.map((e) => PrestamoModel.fromJson(e)).toList();
    });
  }
}
