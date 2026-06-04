import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/docente.dart';
import '../../providers/docente_providers.dart';

class DocenteDetailPage extends ConsumerWidget {
  const DocenteDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docenteId = GoRouterState.of(context).pathParameters['id'] ?? '';
    final docenteAsync = ref.watch(docenteDetailProvider(docenteId));

    return docenteAsync.when(
      loading: () => const Scaffold(
        appBar: _DetailAppBar(),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: const _DetailAppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error al cargar docente',
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
      data: (docente) => Scaffold(
        appBar: AppBar(
          title: Text(docente.nombreCompleto),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.go(
                RouteNames.docenteNuevo,
                extra: docente,
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeaderCard(docente: docente),
            const SizedBox(height: 24),
            _InfoSection(docente: docente),
            if (docente.activo) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDesactivar(context, ref, docente),
                  icon: const Icon(Icons.person_off),
                  label: const Text('Desactivar docente'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDesactivar(
      BuildContext context, WidgetRef ref, Docente docente) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Desactivar docente'),
        content: Text(
          '¿Estás seguro de desactivar a ${docente.nombreCompleto}? '
          'No podrá aparecer en nuevos préstamos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(docenteRepositoryProvider)
                    .desactivarDocente(docente.id);
                ref.invalidate(docenteDetailProvider(docente.id));
                ref.invalidate(docenteListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Docente desactivado')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Desactivar'),
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
    return AppBar(title: const Text('Docente'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HeaderCard extends StatelessWidget {
  final Docente docente;
  const _HeaderCard({required this.docente});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: docente.activo
                  ? AppTheme.successColor.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.15),
              child: Icon(
                Icons.person,
                size: 32,
                color: docente.activo ? AppTheme.successColor : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    docente.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: docente.activo
                    ? AppTheme.successColor.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                docente.activo ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  color:
                      docente.activo ? AppTheme.successColor : Colors.grey[600],
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
  final Docente docente;
  const _InfoSection({required this.docente});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información del docente',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const Divider(),
            _InfoRow(label: 'Nombres', value: docente.nombres),
            _InfoRow(label: 'Apellidos', value: docente.apellidos),
            _InfoRow(label: 'Grado', value: docente.grado ?? '—'),
            _InfoRow(label: 'Sección', value: docente.seccion ?? '—'),
            _InfoRow(
              label: 'Turno',
              value: docente.turno != null
                  ? (docente.turno == 'mañana' ? 'Mañana' : 'Tarde')
                  : '—',
            ),
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
