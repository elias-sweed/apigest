import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/prestamo_providers.dart';
import '../../../domain/entities/prestamo.dart';

class LoansPage extends ConsumerWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prestamos = ref.watch(prestamoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Préstamos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/dashboard/prestamos/nuevo'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/dashboard/prestamos/nuevo'),
        child: const Icon(Icons.add),
      ),
      body: prestamos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(prestamoListProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (lista) {
          if (lista.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No hay préstamos activos',
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('Todos los equipos están disponibles.'),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push('/dashboard/prestamos/nuevo'),
                    icon: const Icon(Icons.add),
                    label: const Text('CREAR PRÉSTAMO'),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final p = lista[index];
              return _PrestamoCard(prestamo: p);
            },
          );
        },
      ),
    );
  }
}

class _PrestamoCard extends StatelessWidget {
  final Prestamo prestamo;
  const _PrestamoCard({required this.prestamo});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: prestamo.estado == 'activo'
              ? Colors.blue.shade100
              : Colors.orange.shade100,
          child: Text('${prestamo.cantidadEquipos}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: prestamo.estado == 'activo'
                      ? Colors.blue.shade700
                      : Colors.orange.shade700)),
        ),
        title: Text(prestamo.docenteNombre,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${prestamo.cantidadEquipos} equipos · ${_formatTime(prestamo.fechaHoraInicio)}',
        ),
        trailing: Chip(
          label: Text(prestamo.estadoLabel,
              style: const TextStyle(fontSize: 12)),
          backgroundColor: prestamo.estado == 'activo'
              ? Colors.blue.shade50
              : Colors.orange.shade50,
        ),
        onTap: () => context.push('/dashboard/prestamos/${prestamo.id}'),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
