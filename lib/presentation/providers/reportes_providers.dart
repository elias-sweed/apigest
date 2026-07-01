import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/auth_provider.dart';
import '../../data/local/datasources/reportes_local_datasource.dart';
import '../../data/remote/datasources/reportes_remote_datasource.dart';
import '../../data/repositories/reportes_repository_impl.dart';
import '../../domain/entities/reportes/reporte_diario.dart';
import '../../domain/entities/reportes/reporte_rango_fechas.dart';
import '../../domain/entities/reportes/reporte_docente.dart';
import '../../domain/entities/reportes/reporte_equipo.dart';
import '../../domain/entities/reportes/reporte_general.dart';
import '../../domain/repositories/reportes_repository.dart';

final reportesRemoteDatasourceProvider = Provider<ReportesRemoteDatasource>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ReportesRemoteDatasource(supabase);
});

final reportesLocalDatasourceProvider = Provider<ReportesLocalDatasource>((ref) {
  final db = ref.watch(databaseProvider);
  return ReportesLocalDatasource(db.reportCacheDao);
});

final reportesRepositoryProvider = Provider<ReportesRepository>((ref) {
  final remote = ref.watch(reportesRemoteDatasourceProvider);
  final local = ref.watch(reportesLocalDatasourceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return ReportesRepositoryImpl(
    remote: remote,
    local: local,
    connectivity: connectivity,
  );
});

final reporteDiarioProvider = FutureProvider<ReporteDiario>((ref) {
  final repo = ref.watch(reportesRepositoryProvider);
  return repo.getReporteDiario();
});

final reporteRangoProvider =
    FutureProvider.family<ReporteRangoFechas, DateTimeRange>((ref, rango) {
  final repo = ref.watch(reportesRepositoryProvider);
  return repo.getReporteRango(rango.start, rango.end);
});

final reporteDocenteProvider =
    FutureProvider.family<ReporteDocente, String>((ref, docenteId) {
  final repo = ref.watch(reportesRepositoryProvider);
  return repo.getReporteDocente(docenteId);
});

final reporteEquipoProvider =
    FutureProvider.family<ReporteEquipo, String>((ref, equipoId) {
  final repo = ref.watch(reportesRepositoryProvider);
  return repo.getReporteEquipo(equipoId);
});

final reporteGeneralProvider = FutureProvider<ReporteGeneral>((ref) {
  final repo = ref.watch(reportesRepositoryProvider);
  return repo.getReporteGeneral();
});
