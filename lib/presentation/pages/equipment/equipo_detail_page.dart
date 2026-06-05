import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/errors/error_helpers.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/equipo.dart';
import '../../providers/equipo_providers.dart';

class EquipoDetailPage extends ConsumerWidget {
  const EquipoDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipoId = GoRouterState.of(context).pathParameters['id'] ?? '';
    final equipoAsync = ref.watch(equipoDetailProvider(equipoId));

    return equipoAsync.when(
      loading: () => const Scaffold(
        appBar: _DetailAppBar(),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: const _DetailAppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text('No se pudo cargar el equipo.',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
      data: (equipo) => Scaffold(
        appBar: AppBar(
          title: Text(equipo.codigoPatrimonial),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push(
                RouteNames.equipoNuevo,
                extra: equipo,
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _EstadoHeader(equipo: equipo),
            const SizedBox(height: 24),
            _InfoSection(equipo: equipo),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCambiarEstado(context, ref, equipo),
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Cambiar estado'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCambiarEstado(BuildContext context, WidgetRef ref, Equipo equipo) {
    final estados = ['disponible', 'prestado', 'mantenimiento', 'dado_de_baja'];
    final disponibles = estados.where((e) => e != equipo.estado).toList();

    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Cambiar estado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...disponibles.map((estado) {
            return ListTile(
              leading: Icon(_estadoIcon(estado), color: _estadoColor(estado)),
              title: Text(Equipo.estadoLabels[estado] ?? estado),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await ref
                      .read(equipoRepositoryProvider)
                      .cambiarEstado(equipo.id, estado);
                  ref.invalidate(equipoDetailProvider(equipo.id));
                  ref.invalidate(equipoListProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Estado cambiado a ${Equipo.estadoLabels[estado] ?? estado}'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) showError(context, e);
                }
              },
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  IconData _estadoIcon(String estado) {
    switch (estado) {
      case 'disponible':
        return Icons.check_circle;
      case 'prestado':
        return Icons.assignment;
      case 'mantenimiento':
        return Icons.build;
      case 'dado_de_baja':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

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
}

class _DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DetailAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Equipo'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _EstadoHeader extends StatelessWidget {
  final Equipo equipo;
  const _EstadoHeader({required this.equipo});

  Color _color(String estado) {
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
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: _color(equipo.estado).withValues(alpha: 0.15),
              child: Icon(Icons.devices,
                  size: 32, color: _color(equipo.estado)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipo.codigoPatrimonial,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    equipo.nombre,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _color(equipo.estado).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                equipo.estadoLabel,
                style: TextStyle(
                  color: _color(equipo.estado),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final Equipo equipo;
  const _InfoSection({required this.equipo});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información del equipo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const Divider(),
            _InfoRow(label: 'Tipo', value: equipo.tipoLabel),
            _InfoRow(label: 'Marca', value: equipo.marca ?? '—'),
            _InfoRow(label: 'Modelo', value: equipo.modelo ?? '—'),
            _InfoRow(label: 'Número de serie', value: equipo.numeroSerie ?? '—'),
            if (equipo.observaciones != null) ...[
              const SizedBox(height: 8),
              Text('Observaciones',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  )),
              const SizedBox(height: 4),
              Text(equipo.observaciones!),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
