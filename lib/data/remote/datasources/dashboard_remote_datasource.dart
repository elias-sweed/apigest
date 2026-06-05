import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/activity_item.dart';
import '../../../domain/entities/dashboard_stats.dart';

class DashboardRemoteDatasource {
  final SupabaseClient _client;

  DashboardRemoteDatasource(this._client);

  Future<DashboardStats> getStats() async {
    final prestamosActivos = await _client
        .from('prestamos')
        .select('id')
        .eq('estado', 'activo');

    final equipos = await _client.from('equipos').select('estado');

    int disponibles = 0, prestados = 0, mantenimiento = 0;
    for (final e in (equipos as List)) {
      switch (e['estado'] as String) {
        case 'disponible':
          disponibles++;
        case 'prestado':
          prestados++;
        case 'mantenimiento':
          mantenimiento++;
      }
    }

    final hoy = DateTime.now();
    final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final docentesHoy = await _client
        .from('prestamos')
        .select('docente_id')
        .eq('estado', 'activo')
        .gte('fecha_hora_inicio', inicioHoy.toIso8601String());

    final docentesUnicos =
        (docentesHoy as List).map((d) => d['docente_id'] as String).toSet().length;

    return DashboardStats(
      prestamosActivos: (prestamosActivos as List).length,
      equiposDisponibles: disponibles,
      equiposPrestados: prestados,
      equiposMantenimiento: mantenimiento,
      docentesConPrestamosActivos: docentesUnicos,
    );
  }

  Future<List<ActivityItem>> getRecentActivity() async {
    final prestamos = await _client.from('prestamos').select('''
        id,
        created_at,
        docentes:docente_id(nombre_completo)
      ''').order('created_at', ascending: false).limit(10);

    final devoluciones = await _client.from('devoluciones').select('''
        id,
        created_at,
        prestamos!inner(
          id,
          docentes:docente_id(nombre_completo)
        )
      ''').order('created_at', ascending: false).limit(10);

    final items = <ActivityItem>[];

    for (final p in (prestamos as List)) {
      final docente = p['docentes'] is Map
          ? (p['docentes'] as Map)['nombre_completo'] as String?
          : null;
      items.add(ActivityItem(
        id: p['id'] as String,
        tipo: 'prestamo_creado',
        descripcion: docente != null
            ? 'Préstamo creado — $docente'
            : 'Préstamo creado',
        fecha: DateTime.parse(p['created_at'] as String),
        prestamoId: p['id'] as String,
      ));
    }

    for (final d in (devoluciones as List)) {
      final prestamoData = d['prestamos'];
      final prestamoId = prestamoData is Map
          ? prestamoData['id'] as String
          : null;
      final docente = prestamoData is Map && prestamoData['docentes'] is Map
          ? (prestamoData['docentes'] as Map)['nombre_completo'] as String?
          : null;
      items.add(ActivityItem(
        id: d['id'] as String,
        tipo: 'devolucion_registrada',
        descripcion: docente != null
            ? 'Devolución registrada — $docente'
            : 'Devolución registrada',
        fecha: DateTime.parse(d['created_at'] as String),
        prestamoId: prestamoId,
      ));
    }

    items.sort((a, b) => b.fecha.compareTo(a.fecha));
    return items.take(10).toList();
  }
}
