import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/errors/app_messages.dart';
import '../../../core/errors/error_helpers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/prestamo.dart';
import '../../providers/equipo_providers.dart';
import '../../providers/prestamo_providers.dart';

class LoanDetailPage extends ConsumerWidget {
  const LoanDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prestamoId = GoRouterState.of(context).pathParameters['id'] ?? '';
    final prestamoAsync = ref.watch(prestamoDetailProvider(prestamoId));

    return prestamoAsync.when(
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
              const Text('No se pudo cargar el préstamo.',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
      data: (prestamo) => Scaffold(
        appBar: AppBar(
          title: const Text('Préstamo'),
          actions: [
            if (prestamo.estado == 'activo')
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditObservaciones(context, ref, prestamo),
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _InfoCard(prestamo: prestamo),
            const SizedBox(height: 16),
            _ObservacionesCard(prestamo: prestamo),
            const SizedBox(height: 16),
            _EquiposCard(prestamo: prestamo),
            if (prestamo.estado == 'activo') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child:               FilledButton.icon(
                  onPressed: () async {
                    await context.pushNamed<dynamic>(
                      'prestamoDevolucion',
                      pathParameters: {'id': prestamo.id},
                    );
                    ref.invalidate(prestamoDetailProvider(prestamo.id));
                  },
                  icon: const Icon(Icons.assignment_return),
                  label: const Text('REGISTRAR DEVOLUCIÓN'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showEditObservaciones(
      BuildContext context, WidgetRef ref, Prestamo prestamo) {
    final controller = TextEditingController(text: prestamo.observaciones ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar observaciones'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Observaciones del préstamo',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(prestamoRepositoryProvider).updatePrestamo(
                      prestamo.id,
                      {'observaciones': controller.text},
                    );
                ref.invalidate(prestamoDetailProvider(prestamo.id));
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) showError(ctx, e);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DetailAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Préstamo'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _InfoCard extends StatelessWidget {
  final Prestamo prestamo;
  const _InfoCard({required this.prestamo});

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'activo':
        return AppTheme.primaryColor;
      case 'parcial':
        return AppTheme.warningColor;
      case 'devuelto':
        return AppTheme.successColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 8),
                Text('Información general',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _estadoColor(prestamo.estado).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    prestamo.estadoLabel,
                    style: TextStyle(
                      color: _estadoColor(prestamo.estado),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            _InfoRow(
                label: 'Docente', value: prestamo.docenteNombre),
            _InfoRow(
                label: 'Encargado', value: prestamo.encargadoNombre),
            _InfoRow(
                label: 'Inicio',
                value:
                    '${prestamo.fechaHoraInicio.day.toString().padLeft(2, '0')}/'
                    '${prestamo.fechaHoraInicio.month.toString().padLeft(2, '0')}/'
                    '${prestamo.fechaHoraInicio.year} '
                    '${prestamo.fechaHoraInicio.hour.toString().padLeft(2, '0')}:'
                    '${prestamo.fechaHoraInicio.minute.toString().padLeft(2, '0')}'),
            _InfoRow(
                label: 'Equipos',
                value:
                    '${prestamo.equiposDevueltos}/${prestamo.cantidadEquipos} devueltos'),
          ],
        ),
      ),
    );
  }
}

class _ObservacionesCard extends StatelessWidget {
  final Prestamo prestamo;
  const _ObservacionesCard({required this.prestamo});

  @override
  Widget build(BuildContext context) {
    if (prestamo.observaciones == null || prestamo.observaciones!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notes, size: 20),
                const SizedBox(width: 8),
                Text('Observaciones',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
              ],
            ),
            const Divider(),
            Text(prestamo.observaciones!),
          ],
        ),
      ),
    );
  }
}

class _EquiposCard extends ConsumerWidget {
  final Prestamo prestamo;
  const _EquiposCard({required this.prestamo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.devices, size: 20),
                const SizedBox(width: 8),
                Text('Equipos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
              ],
            ),
            const Divider(),
            ...prestamo.equipos.map((pe) => _EquipoTile(
                  pe: pe,
                  canRemove: prestamo.estado == 'activo' && !pe.devuelto,
                  onRemove: () =>
                      _confirmRemoveEquipo(context, ref, prestamo.id, pe.id),
                )),
            if (prestamo.estado == 'activo') ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showAddEquipos(context, ref, prestamo),
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir equipos'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmRemoveEquipo(
      BuildContext context, WidgetRef ref, String prestamoId, String peId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitar equipo'),
        content:
            const Text('¿Está seguro de que desea quitar este equipo del préstamo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(prestamoRepositoryProvider).removeEquipo(peId);
                ref.invalidate(prestamoDetailProvider(prestamoId));
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) showError(ctx, e);
              }
            },
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
  }

  void _showAddEquipos(
      BuildContext context, WidgetRef ref, Prestamo prestamo) {
    final prestamoEquipoIds = prestamo.equipos.map((e) => e.equipoId).toSet();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddEquiposSheet(
        prestamoId: prestamo.id,
        prestamoEquipoIds: prestamoEquipoIds,
      ),
    );
  }
}

class _EquipoTile extends StatelessWidget {
  final EquipoPrestamoInfo pe;
  final bool canRemove;
  final VoidCallback onRemove;

  const _EquipoTile({
    required this.pe,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.devices),
      title: Text(pe.equipoNombre),
      subtitle: Text('${pe.equipoCodigo} • ${pe.equipoTipo}'),
      trailing: pe.devuelto
          ? Chip(
              label: Text(
                'Devuelto',
                style: TextStyle(
                    fontSize: 11, color: AppTheme.successColor),
              ),
              backgroundColor: AppTheme.successColor.withValues(alpha: 0.1),
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
            )
          : canRemove
              ? IconButton(
                  icon: Icon(Icons.remove_circle_outline,
                      color: Colors.red[400]),
                  onPressed: onRemove,
                )
              : null,
    );
  }
}

class _AddEquiposSheet extends ConsumerWidget {
  final String prestamoId;
  final Set<String> prestamoEquipoIds;

  const _AddEquiposSheet({
    required this.prestamoId,
    required this.prestamoEquipoIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equiposAsync = ref.watch(equipoListProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, scrollController) {
        final selected = <String>{};

        return equiposAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              const Center(child: Text(AppMessages.errorCargaEquipos)),
          data: (equipos) {
            final disponibles = equipos
                .where((e) =>
                    e.estado == 'disponible' &&
                    !prestamoEquipoIds.contains(e.id))
                .toList();

            return StatefulBuilder(
              builder: (ctx, setSheetState) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Seleccionar equipos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Expanded(
                    child: disponibles.isEmpty
                        ? const Center(
                            child: Text('No hay equipos disponibles'))
                        : ListView(
                            controller: scrollController,
                            children: disponibles.map((e) {
                              return CheckboxListTile(
                                title: Text(e.nombre),
                                subtitle: Text(e.codigoPatrimonial),
                                secondary: const Icon(Icons.devices),
                                value: selected.contains(e.id),
                                onChanged: (checked) {
                                  setSheetState(() {
                                    if (checked == true) {
                                      selected.add(e.id);
                                    } else {
                                      selected.remove(e.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: selected.isEmpty
                            ? null
                            : () async {
                                try {
                                  await ref
                                      .read(prestamoRepositoryProvider)
                                      .addEquipos(
                                          prestamoId, selected.toList());
                                  ref.invalidate(
                                      prestamoDetailProvider(prestamoId));
                                  if (ctx.mounted) Navigator.pop(ctx);
                                } catch (e) {
                                  if (ctx.mounted) showError(ctx, e);
                                }
                              },
                        child: Text(
                            'Agregar (${selected.length})'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
