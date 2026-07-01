import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/auth/permissions.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/excel_generator.dart';
import '../../../core/services/pdf_generator.dart';
import '../../../domain/entities/reportes/reporte_diario.dart';
import '../../../domain/entities/reportes/reporte_rango_fechas.dart';
import '../../../domain/entities/reportes/reporte_general.dart';
import '../../providers/docente_providers.dart';
import '../../providers/equipo_providers.dart';
import '../../providers/reportes_providers.dart';
import '../../widgets/error_views.dart';
import 'widgets/charts_section.dart';
import 'widgets/reporte_diario_card.dart';
import 'widgets/reporte_general_card.dart';

class ReportesPage extends ConsumerWidget {
  const ReportesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    if (!Permissions.canViewReportes(role)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reportes')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No tienes permisos para acceder a Reportes.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reportes'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Diario'),
              Tab(text: 'Rango'),
              Tab(text: 'Docente'),
              Tab(text: 'Equipo'),
              Tab(text: 'General'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DiarioTab(),
            _RangoTab(),
            _DocenteTab(),
            _EquipoTab(),
            _GeneralTab(),
          ],
        ),
      ),
    );
  }
}

class _DiarioTab extends ConsumerWidget {
  const _DiarioTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diarioAsync = ref.watch(reporteDiarioProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(reporteDiarioProvider),
      child: diarioAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => AppErrorView(
          message: 'No se pudo cargar el reporte diario',
          onRetry: () => ref.invalidate(reporteDiarioProvider),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ReporteDiarioCard(data: data),
            const SizedBox(height: 16),
            _PieChartSection(data: data),
            const SizedBox(height: 16),
            _ExportButtons(
              onPdf: () async {
                final bytes = await PdfGenerator.generateDiario(data);
                await Share.shareXFiles(
                  [XFile.fromData(bytes, mimeType: 'application/pdf')],
                  text: 'reporte_diario.pdf',
                );
              },
              onExcel: () async {
                final file = await ExcelGenerator.generateDiario(data);
                await Share.shareXFiles(
                  [XFile(file.path)],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RangoTab extends ConsumerStatefulWidget {
  const _RangoTab();

  @override
  ConsumerState<_RangoTab> createState() => _RangoTabState();
}

class _RangoTabState extends ConsumerState<_RangoTab> {
  DateTime _inicio = DateTime.now().subtract(const Duration(days: 30));
  DateTime _fin = DateTime.now();

  Future<void> _pickDate(bool isInicio) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isInicio ? _inicio : _fin,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _inicio = picked;
        } else {
          _fin = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rango = DateTimeRange(start: _inicio, end: _fin);
    final rangoAsync = ref.watch(reporteRangoProvider(rango));

    return RefreshIndicator(
      onRefresh: () async =>
          ref.invalidate(reporteRangoProvider(rango)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Fecha inicio',
                  date: _inicio,
                  onTap: () => _pickDate(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: 'Fecha fin',
                  date: _fin,
                  onTap: () => _pickDate(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          rangoAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => AppErrorView(
              message: 'No se pudieron cargar los datos del rango',
              onRetry: () => ref.invalidate(reporteRangoProvider(rango)),
            ),
            data: (data) => Column(
              children: [
                _buildSummary(data),
                if (data.equiposMasUsados.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _BarChartEquipos(data: data),
                ],
                const SizedBox(height: 16),
                _ExportButtons(
                  onPdf: () async {
                    final bytes = await PdfGenerator.generateRango(data);
                    await Share.shareXFiles(
                      [XFile.fromData(bytes, mimeType: 'application/pdf')],
                      text: 'reporte_rango.pdf',
                    );
                  },
                  onExcel: () async {
                    final file = await ExcelGenerator.generateRango(data);
                    await Share.shareXFiles([XFile(file.path)]);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(ReporteRangoFechas data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _RowStat(label: 'Total préstamos', value: '${data.totalPrestamos}'),
            _RowStat(
                label: 'Total devoluciones', value: '${data.totalDevoluciones}'),
            _RowStat(
                label: 'Equipos más usados',
                value: '${data.equiposMasUsados.length}'),
            _RowStat(
                label: 'Docentes',
                value: '${data.docentesConMasPrestamos.length}'),
          ],
        ),
      ),
    );
  }
}

class _DocenteTab extends ConsumerStatefulWidget {
  const _DocenteTab();

  @override
  ConsumerState<_DocenteTab> createState() => _DocenteTabState();
}

class _DocenteTabState extends ConsumerState<_DocenteTab> {
  String? _selectedDocenteId;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Autocomplete<String>(
            optionsBuilder: (textEditingValue) async {
              if (textEditingValue.text.isEmpty) return const [];
              final docentes = await ref.read(docenteListProvider.future);
              return docentes
                  .where((d) => d.nombreCompleto
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()))
                  .map((d) => d.nombreCompleto)
                  .toList();
            },
            onSelected: (selection) async {
              final docentes = await ref.read(docenteListProvider.future);
              final docente = docentes.firstWhere(
                (d) => d.nombreCompleto == selection,
              );
              setState(() => _selectedDocenteId = docente.id);
              _searchController.text = selection;
            },
            fieldViewBuilder: (context, controller, focusNode, onSubmit) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Buscar docente...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => onSubmit(),
              );
            },
          ),
        ),
        if (_selectedDocenteId != null)
          Expanded(
            child: _DocenteDetail(docenteId: _selectedDocenteId!),
          ),
      ],
    );
  }
}

class _DocenteDetail extends ConsumerWidget {
  final String docenteId;
  const _DocenteDetail({required this.docenteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reporteAsync = ref.watch(reporteDocenteProvider(docenteId));

    return RefreshIndicator(
      onRefresh: () async =>
          ref.invalidate(reporteDocenteProvider(docenteId)),
      child: reporteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => AppErrorView(
          message: 'No se pudo cargar el reporte del docente',
          onRetry: () => ref.invalidate(reporteDocenteProvider(docenteId)),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.nombreCompleto,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    _RowStat(
                        label: 'Total préstamos',
                        value: '${data.cantidadPrestamos}'),
                    _RowStat(
                        label: 'Equipos utilizados',
                        value: '${data.equiposUtilizados.length}'),
                  ],
                ),
              ),
            ),
            if (data.equiposUtilizados.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Equipos utilizados',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...data.equiposUtilizados.map((e) => Card(
                    child: ListTile(
                      title: Text(e.nombre),
                      subtitle: Text(e.codigoPatrimonial),
                      trailing: Text('${e.vecesPrestado} veces'),
                    ),
                  )),
            ],
            const SizedBox(height: 16),
            _ExportButtons(
              onPdf: () async {
                final bytes = await PdfGenerator.generateDocente(data);
                await Share.shareXFiles(
                  [XFile.fromData(bytes, mimeType: 'application/pdf')],
                  text: 'reporte_docente.pdf',
                );
              },
              onExcel: () async {
                final file = await ExcelGenerator.generateDocente(data);
                await Share.shareXFiles([XFile(file.path)]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EquipoTab extends ConsumerStatefulWidget {
  const _EquipoTab();

  @override
  ConsumerState<_EquipoTab> createState() => _EquipoTabState();
}

class _EquipoTabState extends ConsumerState<_EquipoTab> {
  String? _selectedEquipoId;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Autocomplete<String>(
            optionsBuilder: (textEditingValue) async {
              if (textEditingValue.text.isEmpty) return const [];
              final equipos = await ref.read(equipoListProvider.future);
              return equipos
                  .where((e) =>
                      e.codigoPatrimonial
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()) ||
                      e.nombre
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()))
                  .map((e) => '${e.codigoPatrimonial} — ${e.nombre}')
                  .toList();
            },
            onSelected: (selection) async {
              final equipos = await ref.read(equipoListProvider.future);
              final equipo = equipos.firstWhere(
                (e) =>
                    '${e.codigoPatrimonial} — ${e.nombre}' == selection,
              );
              setState(() => _selectedEquipoId = equipo.id);
              _searchController.text = selection;
            },
            fieldViewBuilder: (context, controller, focusNode, onSubmit) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Buscar equipo...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => onSubmit(),
              );
            },
          ),
        ),
        if (_selectedEquipoId != null)
          Expanded(
            child: _EquipoDetail(equipoId: _selectedEquipoId!),
          ),
      ],
    );
  }
}

class _EquipoDetail extends ConsumerWidget {
  final String equipoId;
  const _EquipoDetail({required this.equipoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reporteAsync = ref.watch(reporteEquipoProvider(equipoId));

    return reporteAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => AppErrorView(
        message: 'No se pudo cargar el reporte del equipo',
        onRetry: () => ref.invalidate(reporteEquipoProvider(equipoId)),
      ),
      data: (data) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${data.codigoPatrimonial} — ${data.nombre}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  _RowStat(label: 'Estado', value: data.estadoActual),
                  _RowStat(
                      label: 'Total préstamos',
                      value: '${data.cantidadPrestamos}'),
                  if (data.tiempoPromedioUso != null)
                    _RowStat(
                        label: 'Tiempo promedio',
                        value:
                            '${data.tiempoPromedioUso!.inHours}h ${data.tiempoPromedioUso!.inMinutes.remainder(60)}m'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ExportButtons(
            onPdf: () async {
              final bytes = await PdfGenerator.generateEquipo(data);
              await Share.shareXFiles(
                [XFile.fromData(bytes, mimeType: 'application/pdf')],
                text: 'reporte_equipo.pdf',
              );
            },
            onExcel: () async {
              final file = await ExcelGenerator.generateEquipo(data);
              await Share.shareXFiles([XFile(file.path)]);
            },
          ),
        ],
      ),
    );
  }
}

class _GeneralTab extends ConsumerWidget {
  const _GeneralTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generalAsync = ref.watch(reporteGeneralProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(reporteGeneralProvider),
      child: generalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => AppErrorView(
          message: 'No se pudo cargar el reporte general',
          onRetry: () => ref.invalidate(reporteGeneralProvider),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ReporteGeneralCard(data: data),
            const SizedBox(height: 16),
            _PieChartGeneral(data: data),
            const SizedBox(height: 16),
            _ExportButtons(
              onPdf: () async {
                final bytes = await PdfGenerator.generateGeneral(data);
                await Share.shareXFiles(
                  [XFile.fromData(bytes, mimeType: 'application/pdf')],
                  text: 'reporte_general.pdf',
                );
              },
              onExcel: () async {
                final file = await ExcelGenerator.generateGeneral(data);
                await Share.shareXFiles([XFile(file.path)]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}',
        ),
      ),
    );
  }
}

class _RowStat extends StatelessWidget {
  final String label;
  final String value;

  const _RowStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

class _PieChartSection extends StatelessWidget {
  final ReporteDiario data;
  const _PieChartSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Estado de equipos',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ChartsSection.pie({
                'Disponibles': data.equiposDisponibles.toDouble(),
                'Prestados': data.equiposPrestados.toDouble(),
                'Mantenimiento': data.equiposMantenimiento.toDouble(),
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieChartGeneral extends StatelessWidget {
  final ReporteGeneral data;
  const _PieChartGeneral({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Distribución de equipos',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ChartsSection.pie({
                'Disponibles': data.equiposDisponibles.toDouble(),
                'Prestados': data.equiposPrestados.toDouble(),
                'Mantenimiento': data.equiposMantenimiento.toDouble(),
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChartEquipos extends StatelessWidget {
  final ReporteRangoFechas data;
  const _BarChartEquipos({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.equiposMasUsados.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Equipos más utilizados',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ChartsSection.bar(
                data.equiposMasUsados
                    .map((e) => (e.nombre, e.cantidadPrestamos.toDouble()))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportButtons extends StatelessWidget {
  final VoidCallback onPdf;
  final VoidCallback onExcel;

  const _ExportButtons({required this.onPdf, required this.onExcel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onPdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onExcel,
            icon: const Icon(Icons.table_chart),
            label: const Text('Excel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
