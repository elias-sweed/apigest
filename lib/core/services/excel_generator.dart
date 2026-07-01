import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/reportes/reporte_diario.dart';
import '../../domain/entities/reportes/reporte_rango_fechas.dart';
import '../../domain/entities/reportes/reporte_docente.dart';
import '../../domain/entities/reportes/reporte_equipo.dart';
import '../../domain/entities/reportes/reporte_general.dart';

class ExcelGenerator {
  static Future<File> generateGeneral(ReporteGeneral data) async {
    final excel = Excel.createExcel();
    final sheet = excel['Reporte General'];

    _addHeaderRow(sheet, ['Métrica', 'Valor']);
    _addDataRow(sheet, ['Total docentes', '${data.totalDocentes}']);
    _addDataRow(sheet, ['Total equipos', '${data.totalEquipos}']);
    _addDataRow(sheet, ['Equipos disponibles', '${data.equiposDisponibles}']);
    _addDataRow(sheet, ['Equipos prestados', '${data.equiposPrestados}']);
    _addDataRow(
        sheet, ['Equipos en mantenimiento', '${data.equiposMantenimiento}']);
    _addDataRow(sheet, ['Préstamos activos', '${data.prestamosActivos}']);
    _addDataRow(sheet, ['Préstamos devueltos', '${data.prestamosDevueltos}']);
    _addDataRow(sheet, ['Préstamos del mes', '${data.prestamosDelMes}']);
    _addDataRow(
        sheet, ['Devoluciones del mes', '${data.devolucionesDelMes}']);
    if (data.equipoMasUtilizado != null) {
      _addDataRow(
          sheet, ['Equipo más utilizado', data.equipoMasUtilizado!]);
    }
    if (data.docenteMayorPrestamos != null) {
      _addDataRow(
          sheet, ['Docente con más préstamos', data.docenteMayorPrestamos!]);
    }

    return _save(excel, 'reporte_general');
  }

  static Future<File> generateDiario(ReporteDiario data) async {
    final excel = Excel.createExcel();
    final sheet = excel['Reporte Diario'];

    _addHeaderRow(sheet, ['Métrica', 'Valor']);
    _addDataRow(
        sheet, ['Préstamos creados hoy', '${data.prestamosCreadosHoy}']);
    _addDataRow(sheet, ['Devoluciones hoy', '${data.devolucionesHoy}']);
    _addDataRow(
        sheet, ['Préstamos pendientes', '${data.prestamosPendientes}']);
    _addDataRow(sheet, ['Equipos disponibles', '${data.equiposDisponibles}']);
    _addDataRow(sheet, ['Equipos prestados', '${data.equiposPrestados}']);
    _addDataRow(
        sheet, ['Equipos mantenimiento', '${data.equiposMantenimiento}']);

    return _save(excel, 'reporte_diario');
  }

  static Future<File> generateRango(ReporteRangoFechas data) async {
    final excel = Excel.createExcel();
    final sheet = excel['Reporte Rango'];

    _addHeaderRow(sheet, ['Métrica', 'Valor']);
    _addDataRow(sheet, ['Total préstamos', '${data.totalPrestamos}']);
    _addDataRow(sheet, ['Total devoluciones', '${data.totalDevoluciones}']);

    if (data.equiposMasUsados.isNotEmpty) {
      sheet.appendRow([null, null]);
      _addHeaderRow(sheet, ['Código', 'Nombre', 'Veces']);
      for (final e in data.equiposMasUsados) {
        _addDataRow(
            sheet, [e.codigoPatrimonial, e.nombre, '${e.cantidadPrestamos}']);
      }
    }

    if (data.docentesConMasPrestamos.isNotEmpty) {
      sheet.appendRow([null, null]);
      _addHeaderRow(sheet, ['Docente', 'Préstamos']);
      for (final d in data.docentesConMasPrestamos) {
        _addDataRow(sheet, [d.nombreCompleto, '${d.cantidadPrestamos}']);
      }
    }

    return _save(excel, 'reporte_rango');
  }

  static Future<File> generateDocente(ReporteDocente data) async {
    final excel = Excel.createExcel();
    final sheet = excel['Reporte Docente'];

    _addHeaderRow(sheet, ['Métrica', 'Valor']);
    _addDataRow(sheet, ['Docente', data.nombreCompleto]);
    _addDataRow(sheet, ['Total préstamos', '${data.cantidadPrestamos}']);

    if (data.equiposUtilizados.isNotEmpty) {
      sheet.appendRow([null, null]);
      _addHeaderRow(sheet, ['Código', 'Nombre', 'Veces']);
      for (final e in data.equiposUtilizados) {
        _addDataRow(sheet,
            [e.codigoPatrimonial, e.nombre, '${e.vecesPrestado}']);
      }
    }

    if (data.prestamos.isNotEmpty) {
      sheet.appendRow([null, null]);
      _addHeaderRow(sheet, ['Fecha', 'Observaciones']);
      for (final p in data.prestamos) {
        _addDataRow(sheet, [
          '${p.fecha.day}/${p.fecha.month}/${p.fecha.year}',
          p.observaciones ?? '-'
        ]);
      }
    }

    return _save(excel, 'reporte_docente');
  }

  static Future<File> generateEquipo(ReporteEquipo data) async {
    final excel = Excel.createExcel();
    final sheet = excel['Reporte Equipo'];

    _addHeaderRow(sheet, ['Métrica', 'Valor']);
    _addDataRow(sheet, ['Equipo', '${data.codigoPatrimonial} — ${data.nombre}']);
    _addDataRow(sheet, ['Estado actual', data.estadoActual]);
    _addDataRow(sheet, ['Total préstamos', '${data.cantidadPrestamos}']);

    if (data.historialUsos.isNotEmpty) {
      sheet.appendRow([null, null]);
      _addHeaderRow(sheet, ['Docente', 'Inicio', 'Devolución', 'Obs.']);
      for (final u in data.historialUsos) {
        _addDataRow(sheet, [
          u.docenteNombre,
          '${u.fechaInicio.day}/${u.fechaInicio.month}/${u.fechaInicio.year}',
          u.fechaDevolucion != null
              ? '${u.fechaDevolucion!.day}/${u.fechaDevolucion!.month}/${u.fechaDevolucion!.year}'
              : '-',
          u.observaciones ?? '-',
        ]);
      }
    }

    return _save(excel, 'reporte_equipo');
  }

  static void _addHeaderRow(Sheet sheet, List<String> headers) {
    final headerValues = headers.map((h) => TextCellValue(h)).toList();
    sheet.appendRow(headerValues);
    final rowIndex = sheet.maxRows - 1;
    for (var col = 0; col < headerValues.length; col++) {
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex),
        headerValues[col],
        cellStyle: CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.indigo900,
          fontColorHex: ExcelColor.white,
        ),
      );
    }
  }

  static void _addDataRow(Sheet sheet, List<String> values) {
    sheet.appendRow(values.map((v) => TextCellValue(v)).toList());
  }

  static Future<File> _save(Excel excel, String name) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name.xlsx');
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
    return file;
  }
}
