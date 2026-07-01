import '../../domain/entities/reportes/reporte_diario.dart';
import '../../domain/entities/reportes/reporte_rango_fechas.dart';
import '../../domain/entities/reportes/reporte_docente.dart';
import '../../domain/entities/reportes/reporte_equipo.dart';
import '../../domain/entities/reportes/reporte_general.dart';
import '../../domain/repositories/reportes_repository.dart';
import '../remote/datasources/reportes_remote_datasource.dart';
import '../local/datasources/reportes_local_datasource.dart';
import '../sync/connectivity_service.dart';

class ReportesRepositoryImpl implements ReportesRepository {
  final ReportesRemoteDatasource remote;
  final ReportesLocalDatasource local;
  final ConnectivityService connectivity;

  ReportesRepositoryImpl({
    required this.remote,
    required this.local,
    required this.connectivity,
  });

  @override
  Future<ReporteDiario> getReporteDiario() async {
    if (connectivity.isOnline) {
      try {
        final data = await remote.getReporteDiario();
        await local.cache('diario', {
          'prestamosCreadosHoy': data.prestamosCreadosHoy,
          'devolucionesHoy': data.devolucionesHoy,
          'prestamosPendientes': data.prestamosPendientes,
          'equiposDisponibles': data.equiposDisponibles,
          'equiposPrestados': data.equiposPrestados,
          'equiposMantenimiento': data.equiposMantenimiento,
        });
        return data;
      } catch (_) {}
    }
    final cached = await local.getCached('diario');
    if (cached != null) {
      return ReporteDiario(
        prestamosCreadosHoy: cached['prestamosCreadosHoy'] as int,
        devolucionesHoy: cached['devolucionesHoy'] as int,
        prestamosPendientes: cached['prestamosPendientes'] as int,
        equiposDisponibles: cached['equiposDisponibles'] as int,
        equiposPrestados: cached['equiposPrestados'] as int,
        equiposMantenimiento: cached['equiposMantenimiento'] as int,
      );
    }
    throw Exception('No hay datos disponibles.');
  }

  @override
  Future<ReporteRangoFechas> getReporteRango(
      DateTime inicio, DateTime fin) async {
    final key =
        'rango_${inicio.toIso8601String()}_${fin.toIso8601String()}';
    if (connectivity.isOnline) {
      try {
        final data = await remote.getReporteRango(inicio, fin);
        await local.cache(key, {
          'fechaInicio': inicio.toIso8601String(),
          'fechaFin': fin.toIso8601String(),
          'totalPrestamos': data.totalPrestamos,
          'totalDevoluciones': data.totalDevoluciones,
        });
        return data;
      } catch (_) {}
    }
    final cached = await local.getCached(key);
    if (cached != null) {
      return ReporteRangoFechas(
        fechaInicio: DateTime.parse(cached['fechaInicio'] as String),
        fechaFin: DateTime.parse(cached['fechaFin'] as String),
        totalPrestamos: cached['totalPrestamos'] as int,
        totalDevoluciones: cached['totalDevoluciones'] as int,
        equiposMasUsados: const [],
        docentesConMasPrestamos: const [],
      );
    }
    throw Exception('No hay datos disponibles para este rango.');
  }

  @override
  Future<ReporteDocente> getReporteDocente(String docenteId) async {
    if (connectivity.isOnline) {
      try {
        return await remote.getReporteDocente(docenteId);
      } catch (_) {}
    }
    throw Exception('No hay datos disponibles offline para este reporte.');
  }

  @override
  Future<ReporteEquipo> getReporteEquipo(String equipoId) async {
    if (connectivity.isOnline) {
      try {
        return await remote.getReporteEquipo(equipoId);
      } catch (_) {}
    }
    throw Exception('No hay datos disponibles offline para este reporte.');
  }

  @override
  Future<ReporteGeneral> getReporteGeneral() async {
    if (connectivity.isOnline) {
      try {
        final data = await remote.getReporteGeneral();
        await local.cache('general', {
          'totalDocentes': data.totalDocentes,
          'totalEquipos': data.totalEquipos,
          'equiposDisponibles': data.equiposDisponibles,
          'equiposPrestados': data.equiposPrestados,
          'equiposMantenimiento': data.equiposMantenimiento,
          'prestamosActivos': data.prestamosActivos,
          'prestamosDevueltos': data.prestamosDevueltos,
          'prestamosDelMes': data.prestamosDelMes,
          'devolucionesDelMes': data.devolucionesDelMes,
        });
        return data;
      } catch (_) {}
    }
    final cached = await local.getCached('general');
    if (cached != null) {
      return ReporteGeneral(
        totalDocentes: cached['totalDocentes'] as int,
        totalEquipos: cached['totalEquipos'] as int,
        equiposDisponibles: cached['equiposDisponibles'] as int,
        equiposPrestados: cached['equiposPrestados'] as int,
        equiposMantenimiento: cached['equiposMantenimiento'] as int,
        prestamosActivos: cached['prestamosActivos'] as int,
        prestamosDevueltos: cached['prestamosDevueltos'] as int,
        prestamosDelMes: cached['prestamosDelMes'] as int,
        devolucionesDelMes: cached['devolucionesDelMes'] as int,
      );
    }
    throw Exception('No hay datos disponibles.');
  }
}
