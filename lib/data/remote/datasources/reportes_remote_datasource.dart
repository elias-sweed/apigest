import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/reportes/reporte_diario.dart';
import '../../../domain/entities/reportes/reporte_rango_fechas.dart';
import '../../../domain/entities/reportes/reporte_docente.dart';
import '../../../domain/entities/reportes/reporte_equipo.dart';
import '../../../domain/entities/reportes/reporte_general.dart';

class ReportesRemoteDatasource {
  final SupabaseClient _client;

  ReportesRemoteDatasource(this._client);

  Future<ReporteDiario> getReporteDiario() async {
    final hoy = DateTime.now();
    final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);

    final prestamosHoy = await _client
        .from('prestamos')
        .select()
        .gte('fecha_hora_inicio', inicioHoy.toIso8601String());

    final devolucionesHoy = await _client
        .from('devoluciones')
        .select()
        .gte('created_at', inicioHoy.toIso8601String());

    final pendientes = await _client
        .from('prestamos')
        .select()
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

    return ReporteDiario(
      prestamosCreadosHoy: (prestamosHoy as List).length,
      devolucionesHoy: (devolucionesHoy as List).length,
      prestamosPendientes: (pendientes as List).length,
      equiposDisponibles: disponibles,
      equiposPrestados: prestados,
      equiposMantenimiento: mantenimiento,
    );
  }

  Future<ReporteRangoFechas> getReporteRango(
      DateTime inicio, DateTime fin) async {
    final finDia = DateTime(fin.year, fin.month, fin.day, 23, 59, 59);

    final prestamos = await _client
        .from('prestamos')
        .select()
        .gte('fecha_hora_inicio', inicio.toIso8601String())
        .lte('fecha_hora_inicio', finDia.toIso8601String());

    final devoluciones = await _client
        .from('devoluciones')
        .select()
        .gte('created_at', inicio.toIso8601String())
        .lte('created_at', finDia.toIso8601String());

    final equiposData = await _client.from('prestamo_equipos').select('''
        equipo_id,
        equipos!inner(codigo_patrimonial, nombre),
        count:equipo_id
      ''').gte('prestamos.fecha_hora_inicio', inicio.toIso8601String())
        .lte('prestamos.fecha_hora_inicio', finDia.toIso8601String())
        .order('count', ascending: false)
        .limit(10);

    final docentesData = await _client.from('prestamos').select('''
        docente_id,
        docentes!inner(nombre_completo),
        count:docente_id
      ''').gte('fecha_hora_inicio', inicio.toIso8601String())
        .lte('fecha_hora_inicio', finDia.toIso8601String())
        .order('count', ascending: false)
        .limit(10);

    return ReporteRangoFechas(
      fechaInicio: inicio,
      fechaFin: fin,
      totalPrestamos: (prestamos as List).length,
      totalDevoluciones: (devoluciones as List).length,
      equiposMasUsados: (equiposData as List).map((e) {
        final eq = e['equipos'] as Map;
        return EquipoUso(
          equipoId: e['equipo_id'] as String,
          codigoPatrimonial: eq['codigo_patrimonial'] as String,
          nombre: eq['nombre'] as String,
          cantidadPrestamos: (e['count'] as num).toInt(),
        );
      }).toList(),
      docentesConMasPrestamos: (docentesData as List).map((d) {
        final doc = d['docentes'] as Map;
        return DocentePrestamos(
          docenteId: d['docente_id'] as String,
          nombreCompleto: doc['nombre_completo'] as String,
          cantidadPrestamos: (d['count'] as num).toInt(),
        );
      }).toList(),
    );
  }

  Future<ReporteDocente> getReporteDocente(String docenteId) async {
    final prestamos = await _client.from('prestamos').select('''
        id, fecha_hora_inicio, observaciones,
        prestamo_equipos(
          equipos(id, codigo_patrimonial, nombre)
        )
      ''').eq('docente_id', docenteId).order('fecha_hora_inicio', ascending: false);

    final equiposMap = <String, EquipoUtilizado>{};
    final resumenes = <PrestamoResumen>[];

    for (final p in (prestamos as List)) {
      resumenes.add(PrestamoResumen(
        prestamoId: p['id'] as String,
        fecha: DateTime.parse(p['fecha_hora_inicio'] as String),
        observaciones: p['observaciones'] as String?,
      ));

      final peList = p['prestamo_equipos'] as List? ?? [];
      for (final pe in peList) {
        final eq = pe['equipos'] as Map?;
        if (eq != null) {
          final id = eq['id'] as String;
          equiposMap.putIfAbsent(id, () => EquipoUtilizado(
                equipoId: id,
                codigoPatrimonial: eq['codigo_patrimonial'] as String,
                nombre: eq['nombre'] as String,
                vecesPrestado: 0,
              ));
          equiposMap.update(id, (e) => EquipoUtilizado(
                equipoId: e.equipoId,
                codigoPatrimonial: e.codigoPatrimonial,
                nombre: e.nombre,
                vecesPrestado: e.vecesPrestado + 1,
              ));
        }
      }
    }

    final docenteNombre = prestamos.isNotEmpty
        ? await _client
            .from('docentes')
            .select('nombre_completo')
            .eq('id', docenteId)
            .single()
            .then((d) => d['nombre_completo'] as String)
        : 'Desconocido';

    return ReporteDocente(
      docenteId: docenteId,
      nombreCompleto: docenteNombre,
      cantidadPrestamos: resumenes.length,
      equiposUtilizados: equiposMap.values.toList()
        ..sort((a, b) => b.vecesPrestado.compareTo(a.vecesPrestado)),
      prestamos: resumenes,
    );
  }

  Future<ReporteEquipo> getReporteEquipo(String equipoId) async {
    final equipo = await _client
        .from('equipos')
        .select()
        .eq('id', equipoId)
        .single();

    final usos = await _client.from('prestamo_equipos').select('''
        prestamo_id,
        prestamos!inner(
          fecha_hora_inicio, fecha_hora_fin_estimada,
          docentes!inner(nombre_completo),
          observaciones
        ),
        fecha_devolucion_real
      ''').eq('equipo_id', equipoId).order(
      'prestamos.fecha_hora_inicio',
      ascending: false,
    );

    final historial = <UsoEquipo>[];
    for (final u in (usos as List)) {
      final prestamo = u['prestamos'] as Map;
      final docente = prestamo['docentes'] as Map;
      historial.add(UsoEquipo(
        prestamoId: u['prestamo_id'] as String,
        docenteNombre: docente['nombre_completo'] as String,
        fechaInicio: DateTime.parse(prestamo['fecha_hora_inicio'] as String),
        fechaDevolucion: u['fecha_devolucion_real'] != null
            ? DateTime.parse(u['fecha_devolucion_real'] as String)
            : null,
        observaciones: prestamo['observaciones'] as String?,
      ));
    }

    Duration? promedio;
    if (historial.isNotEmpty) {
      final duraciones = historial
          .where((h) => h.fechaDevolucion != null)
          .map((h) => h.fechaDevolucion!.difference(h.fechaInicio))
          .toList();
      if (duraciones.isNotEmpty) {
        promedio = Duration(
          milliseconds:
              duraciones.fold(0, (a, d) => a + d.inMilliseconds) ~/
                  duraciones.length,
        );
      }
    }

    return ReporteEquipo(
      equipoId: equipoId,
      codigoPatrimonial: equipo['codigo_patrimonial'] as String,
      nombre: equipo['nombre'] as String,
      estadoActual: equipo['estado'] as String,
      cantidadPrestamos: historial.length,
      tiempoPromedioUso: promedio,
      historialUsos: historial,
    );
  }

  Future<ReporteGeneral> getReporteGeneral() async {
    final docentes = await _client.from('docentes').select();

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

    final activos = await _client
        .from('prestamos')
        .select()
        .eq('estado', 'activo');

    final devueltos = await _client
        .from('prestamos')
        .select()
        .eq('estado', 'completado');

    final ahora = DateTime.now();
    final inicioMes = DateTime(ahora.year, ahora.month, 1);

    final prestamosMes = await _client
        .from('prestamos')
        .select()
        .gte('fecha_hora_inicio', inicioMes.toIso8601String());

    final devolucionesMes = await _client
        .from('devoluciones')
        .select()
        .gte('created_at', inicioMes.toIso8601String());

    String? equipoTop;
    try {
      final topEquipo = await _client
          .from('prestamo_equipos')
          .select('equipos!inner(nombre), count:equipo_id')
          .order('count', ascending: false)
          .limit(1)
          .maybeSingle();
      if (topEquipo != null && topEquipo['equipos'] is Map) {
        equipoTop = (topEquipo['equipos'] as Map)['nombre'] as String?;
      }
    } catch (_) {}

    String? docenteTop;
    try {
      final topDocente = await _client
          .from('prestamos')
          .select('docentes!inner(nombre_completo), count:docente_id')
          .order('count', ascending: false)
          .limit(1)
          .maybeSingle();
      if (topDocente != null && topDocente['docentes'] is Map) {
        docenteTop =
            (topDocente['docentes'] as Map)['nombre_completo'] as String?;
      }
    } catch (_) {}

    return ReporteGeneral(
      totalDocentes: (docentes as List).length,
      totalEquipos: equipos.length,
      equiposDisponibles: disponibles,
      equiposPrestados: prestados,
      equiposMantenimiento: mantenimiento,
      prestamosActivos: (activos as List).length,
      prestamosDevueltos: (devueltos as List).length,
      prestamosDelMes: (prestamosMes as List).length,
      devolucionesDelMes: (devolucionesMes as List).length,
      equipoMasUtilizado: equipoTop,
      docenteMayorPrestamos: docenteTop,
    );
  }
}
