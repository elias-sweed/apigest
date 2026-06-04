import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/equipo.dart';
import '../../providers/equipo_providers.dart';

class EquipmentPage extends ConsumerWidget {
  const EquipmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(equipoSearchProvider);
    final filter = ref.watch(equipoFilterEstadoProvider);
    final equiposAsync = ref.watch(equipoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go(RouteNames.equipoNuevo),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: TextEditingController.fromValue(
                TextEditingValue(text: search),
              ),
              decoration: InputDecoration(
                hintText: 'Buscar por código o nombre',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            ref.read(equipoSearchProvider.notifier).state = '',
                      )
                    : null,
              ),
              onChanged: (v) =>
                  ref.read(equipoSearchProvider.notifier).state = v,
            ),
          ),
          _FilterChips(
            current: filter,
            onChanged: (f) =>
                ref.read(equipoFilterEstadoProvider.notifier).state = f,
          ),
          Expanded(
            child: equiposAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorView(
                message: error.toString(),
                onRetry: () => ref.refresh(equipoListProvider.future),
              ),
              data: (equipos) {
                if (equipos.isEmpty) return _EmptyView();
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(equipoListProvider.future),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: equipos.length,
                    itemBuilder: (_, i) => _EquipoCard(equipo: equipos[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final String? current;
  final void Function(String?) onChanged;

  const _FilterChips({required this.current, required this.onChanged});

  static const _filters = <String?>[
    null,
    'disponible',
    'prestado',
    'mantenimiento',
    'dado_de_baja',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _filters.map((f) {
          final selected = current == f;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(_label(f)),
              selected: selected,
              onSelected: (_) => onChanged(f),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(String? f) {
    if (f == null) return 'Todos';
    return Equipo.estadoLabels[f] ?? f;
  }
}

class _EquipoCard extends ConsumerWidget {
  final Equipo equipo;
  const _EquipoCard({required this.equipo});

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'disponible':
        return AppTheme.successColor;
      case 'prestado':
        return AppTheme.primaryColor;
      case 'mantenimiento':
        return AppTheme.warningColor;
      case 'dado_de_baja':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _estadoColor(equipo.estado).withValues(alpha: 0.15),
          child: Icon(
            Icons.devices,
            color: _estadoColor(equipo.estado),
          ),
        ),
        title: Text(
          equipo.codigoPatrimonial,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(equipo.nombre),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _estadoColor(equipo.estado).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            equipo.estadoLabel,
            style: TextStyle(
              fontSize: 12,
              color: _estadoColor(equipo.estado),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () => context.go(
          RouteNames.equipoDetalle.replaceFirst(':id', equipo.id),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay equipos registrados',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go(RouteNames.equipoNuevo),
            icon: const Icon(Icons.add),
            label: const Text('Registrar primer equipo'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorView({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'No se pudieron cargar los equipos.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
