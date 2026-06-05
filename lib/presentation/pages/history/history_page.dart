import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/historial_filter.dart';
import '../../../domain/entities/prestamo.dart';
import '../../providers/historial_providers.dart';
import '../../widgets/error_views.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilter(HistorialFilter Function(HistorialFilter) updater) {
    ref.read(historialFilterProvider.notifier).update(updater);
    ref.invalidate(historialPrestamosProvider);
  }

  @override
  Widget build(BuildContext context) {
    final prestamosAsync = ref.watch(historialPrestamosProvider);
    final filter = ref.watch(historialFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(historialPrestamosProvider);
        },
        child: Column(
          children: [
            _SearchBar(
              controller: _searchController,
              onSearch: (value) {
                _updateFilter((f) => f.copyWith(search: value));
              },
            ),
            _FilterChips(
              currentEstado: filter.estado,
              onChanged: (estado) {
                _updateFilter((f) => f.copyWith(estado: estado));
              },
            ),
            Expanded(
              child: prestamosAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => AppErrorView(
                  message: 'No se pudo cargar el historial',
                  onRetry: () => ref.invalidate(historialPrestamosProvider),
                ),
                data: (prestamos) {
                  if (prestamos.isEmpty) {
                    return AppEmptyView(
                      message: 'No se encontraron préstamos',
                      actionLabel: 'Limpiar filtros',
                      onAction: () {
                        _searchController.clear();
                        _updateFilter((f) => const HistorialFilter());
                      },
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: prestamos.length,
                    itemBuilder: (context, index) =>
                        _PrestamoTile(prestamo: prestamos[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  const _SearchBar({required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Buscar por docente, código...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onSearch('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onSubmitted: onSearch,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final String? currentEstado;
  final ValueChanged<String?> onChanged;

  const _FilterChips({required this.currentEstado, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = <String?>[
      null,
      'activo',
      'completado',
      'cancelado',
      'parcial',
    ];
    final labels = [
      'Todos',
      'Activos',
      'Completados',
      'Cancelados',
      'Parciales',
    ];
    final colors = [
      Colors.grey,
      AppTheme.primaryColor,
      Colors.green,
      Colors.red,
      Colors.orange,
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (var i = 0; i < options.length; i++)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(labels[i]),
                  selected: currentEstado == options[i],
                  onSelected: (_) => onChanged(options[i]),
                  selectedColor: colors[i].withValues(alpha: 0.2),
                  checkmarkColor: colors[i],
                  labelStyle: TextStyle(
                    color: currentEstado == options[i] ? colors[i] : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PrestamoTile extends StatelessWidget {
  final Prestamo prestamo;
  const _PrestamoTile({required this.prestamo});

  @override
  Widget build(BuildContext context) {
    final estadoColor = switch (prestamo.estado) {
      'activo' => AppTheme.primaryColor,
      'completado' => Colors.green,
      'cancelado' => Colors.red,
      _ => Colors.grey,
    };

    final fechaStr =
        '${prestamo.fechaHoraInicio.day.toString().padLeft(2, '0')}/'
        '${prestamo.fechaHoraInicio.month.toString().padLeft(2, '0')}/'
        '${prestamo.fechaHoraInicio.year}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: estadoColor.withValues(alpha: 0.15),
          child: Icon(Icons.assignment, color: estadoColor, size: 22),
        ),
        title: Text(
          prestamo.docenteNombre,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('$fechaStr · ${prestamo.encargadoNombre}'),
        trailing: Chip(
          label: Text(
            prestamo.estado.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: estadoColor,
            ),
          ),
          backgroundColor: estadoColor.withValues(alpha: 0.1),
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
        ),
        onTap: () => _showDetailSheet(context, prestamo),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, Prestamo prestamo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) {
          return _PrestamoDetailSheet(
            prestamo: prestamo,
            scrollController: scrollController,
          );
        },
      ),
    );
  }
}

class _PrestamoDetailSheet extends StatelessWidget {
  final Prestamo prestamo;
  final ScrollController scrollController;

  const _PrestamoDetailSheet({
    required this.prestamo,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final equipos = prestamo.equipos;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        controller: scrollController,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            prestamo.docenteNombre,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Docente',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.person,
            label: 'Encargado',
            value: prestamo.encargadoNombre,
          ),
          _DetailRow(
            icon: Icons.calendar_today,
            label: 'Inicio',
            value:
                '${prestamo.fechaHoraInicio.day}/${prestamo.fechaHoraInicio.month}/${prestamo.fechaHoraInicio.year} '
                '${prestamo.fechaHoraInicio.hour}:${prestamo.fechaHoraInicio.minute.toString().padLeft(2, '0')}',
          ),
          if (prestamo.fechaHoraFinEstimada != null)
            _DetailRow(
              icon: Icons.event_available,
              label: 'Fin estimado',
              value:
                  '${prestamo.fechaHoraFinEstimada!.day}/${prestamo.fechaHoraFinEstimada!.month}/${prestamo.fechaHoraFinEstimada!.year} '
                  '${prestamo.fechaHoraFinEstimada!.hour}:${prestamo.fechaHoraFinEstimada!.minute.toString().padLeft(2, '0')}',
            ),
          _DetailRow(
            icon: Icons.devices,
            label: 'Equipos (${equipos.length})',
            value: equipos
                .map((e) => '${e.equipoTipo} · ${e.equipoNombre} (${e.equipoCodigo})')
                .join('\n'),
          ),
          if (prestamo.observaciones != null &&
              prestamo.observaciones!.isNotEmpty)
            _DetailRow(
              icon: Icons.notes,
              label: 'Observaciones',
              value: prestamo.observaciones!,
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
