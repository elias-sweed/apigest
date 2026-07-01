import '../entities/reportes/reporte_diario.dart';
import '../entities/reportes/reporte_rango_fechas.dart';
import '../entities/reportes/reporte_docente.dart';
import '../entities/reportes/reporte_equipo.dart';
import '../entities/reportes/reporte_general.dart';

abstract class ReportesRepository {
  Future<ReporteDiario> getReporteDiario();
  Future<ReporteRangoFechas> getReporteRango(DateTime inicio, DateTime fin);
  Future<ReporteDocente> getReporteDocente(String docenteId);
  Future<ReporteEquipo> getReporteEquipo(String equipoId);
  Future<ReporteGeneral> getReporteGeneral();
}
