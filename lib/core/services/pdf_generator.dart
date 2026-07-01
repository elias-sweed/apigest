import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/entities/reportes/reporte_diario.dart';
import '../../domain/entities/reportes/reporte_rango_fechas.dart';
import '../../domain/entities/reportes/reporte_docente.dart';
import '../../domain/entities/reportes/reporte_equipo.dart';
import '../../domain/entities/reportes/reporte_general.dart';

class PdfGenerator {
  static Future<Uint8List> generateGeneral(ReporteGeneral data) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(context),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildTitle('Reporte General del Sistema'),
          pw.SizedBox(height: 16),
          _buildSection('Docentes'),
          _buildStatRow('Total docentes', '${data.totalDocentes}'),
          pw.SizedBox(height: 12),
          _buildSection('Equipos'),
          _buildStatRow('Total equipos', '${data.totalEquipos}'),
          _buildStatRow('Disponibles', '${data.equiposDisponibles}'),
          _buildStatRow('Prestados', '${data.equiposPrestados}'),
          _buildStatRow('En mantenimiento', '${data.equiposMantenimiento}'),
          pw.SizedBox(height: 12),
          _buildSection('Préstamos'),
          _buildStatRow('Activos', '${data.prestamosActivos}'),
          _buildStatRow('Devueltos', '${data.prestamosDevueltos}'),
          _buildStatRow('Del mes', '${data.prestamosDelMes}'),
          _buildStatRow('Devoluciones del mes', '${data.devolucionesDelMes}'),
          pw.SizedBox(height: 12),
          if (data.equipoMasUtilizado != null)
            _buildStatRow('Equipo más utilizado', data.equipoMasUtilizado!),
          if (data.docenteMayorPrestamos != null)
            _buildStatRow('Docente con más préstamos',
                data.docenteMayorPrestamos!),
        ],
      ),
    );

    return doc.save();
  }

  static Future<Uint8List> generateDiario(ReporteDiario data) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(context),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildTitle('Reporte Diario'),
          pw.SizedBox(height: 16),
          _buildSection('Resumen del día'),
          _buildStatRow('Préstamos creados hoy', '${data.prestamosCreadosHoy}'),
          _buildStatRow('Devoluciones hoy', '${data.devolucionesHoy}'),
          _buildStatRow('Préstamos pendientes', '${data.prestamosPendientes}'),
          pw.SizedBox(height: 12),
          _buildSection('Estado de equipos'),
          _buildStatRow('Disponibles', '${data.equiposDisponibles}'),
          _buildStatRow('Prestados', '${data.equiposPrestados}'),
          _buildStatRow('En mantenimiento', '${data.equiposMantenimiento}'),
        ],
      ),
    );

    return doc.save();
  }

  static Future<Uint8List> generateRango(
      ReporteRangoFechas data) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(context),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildTitle('Reporte por Rango de Fechas'),
          pw.SizedBox(height: 8),
          pw.Paragraph(
            text:
                'Del ${_fmtDate(data.fechaInicio)} al ${_fmtDate(data.fechaFin)}',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 16),
          _buildStatRow('Total préstamos', '${data.totalPrestamos}'),
          _buildStatRow('Total devoluciones', '${data.totalDevoluciones}'),
          if (data.equiposMasUsados.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _buildSection('Equipos más utilizados'),
            _buildTable(
              headers: ['Código', 'Nombre', 'Veces'],
              rows: data.equiposMasUsados
                  .map((e) => [e.codigoPatrimonial, e.nombre, '${e.cantidadPrestamos}'])
                  .toList(),
            ),
          ],
          if (data.docentesConMasPrestamos.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _buildSection('Docentes con más préstamos'),
            _buildTable(
              headers: ['Docente', 'Préstamos'],
              rows: data.docentesConMasPrestamos
                  .map((d) => [d.nombreCompleto, '${d.cantidadPrestamos}'])
                  .toList(),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static Future<Uint8List> generateDocente(ReporteDocente data) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(context),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildTitle('Reporte por Docente'),
          pw.SizedBox(height: 8),
          pw.Paragraph(
            text: 'Docente: ${data.nombreCompleto}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          _buildStatRow('Total préstamos', '${data.cantidadPrestamos}'),
          if (data.equiposUtilizados.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _buildSection('Equipos utilizados'),
            _buildTable(
              headers: ['Código', 'Nombre', 'Veces'],
              rows: data.equiposUtilizados
                  .map((e) => [e.codigoPatrimonial, e.nombre, '${e.vecesPrestado}'])
                  .toList(),
            ),
          ],
          if (data.prestamos.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _buildSection('Historial de préstamos'),
            _buildTable(
              headers: ['Fecha', 'Observaciones'],
              rows: data.prestamos.map((p) => [
                _fmtDate(p.fecha),
                p.observaciones ?? '-',
              ]).toList(),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static Future<Uint8List> generateEquipo(ReporteEquipo data) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(context),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildTitle('Reporte por Equipo'),
          pw.SizedBox(height: 8),
          pw.Paragraph(
            text: '${data.codigoPatrimonial} — ${data.nombre}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          _buildStatRow('Estado actual', data.estadoActual),
          _buildStatRow('Total préstamos', '${data.cantidadPrestamos}'),
          if (data.tiempoPromedioUso != null)
            _buildStatRow('Tiempo promedio de uso',
                '${data.tiempoPromedioUso!.inHours}h ${data.tiempoPromedioUso!.inMinutes.remainder(60)}m'),
          if (data.historialUsos.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _buildSection('Historial de usos'),
            _buildTable(
              headers: ['Docente', 'Inicio', 'Devolución', 'Observaciones'],
              rows: data.historialUsos.map((u) => [
                u.docenteNombre,
                _fmtDate(u.fechaInicio),
                u.fechaDevolucion != null ? _fmtDate(u.fechaDevolucion!) : '-',
                u.observaciones ?? '-',
              ]).toList(),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildHeader(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('AIP Gest',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text('Control de Préstamos — Aula de Innovación Pedagógica',
                    style: pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey700)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Divider(),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generado: ${_fmtDate(DateTime.now())}',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
            pw.Text(
              'Página ${context.pageNumber}',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTitle(String text) {
    return pw.Paragraph(
      text: text,
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue800,
      ),
    );
  }

  static pw.Widget _buildSection(String title) {
    return pw.Paragraph(
      text: title,
      style: pw.TextStyle(
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue700,
      ),
    );
  }

  static pw.Widget _buildStatRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 11)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 11, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _buildTable(
      {required List<String> headers, required List<List<String>> rows}) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 0.5,
      ),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.blue50,
      ),
      cellAlignments: {
        for (var i = 0; i < headers.length; i++) i: pw.Alignment.centerLeft,
      },
      columnWidths: {
        for (var i = 0; i < headers.length; i++)
          i: const pw.FixedColumnWidth(100),
      },
    );
  }

  static String _fmtDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }
}
