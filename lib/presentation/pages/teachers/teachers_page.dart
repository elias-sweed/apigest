import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/permissions.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/docente.dart';
import '../../../domain/entities/user_role.dart';
import '../../providers/docente_providers.dart';

class TeachersPage extends ConsumerWidget {
  const TeachersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider).valueOrNull ?? UserRole.practicante;
    final canManage = Permissions.canManageDocentes(role);
    final search = ref.watch(docenteSearchProvider);
    final soloActivos = ref.watch(docenteSoloActivosProvider);
    final docentesAsync = ref.watch(docenteListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Docentes'),
        actions: canManage
            ? [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => context.go(RouteNames.docenteNuevo),
                ),
              ]
            : null,
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
                hintText: 'Buscar docente',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            ref.read(docenteSearchProvider.notifier).state = '',
                      )
                    : null,
              ),
              onChanged: (v) =>
                  ref.read(docenteSearchProvider.notifier).state = v,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Solo activos'),
                  selected: soloActivos,
                  onSelected: (v) =>
                      ref.read(docenteSoloActivosProvider.notifier).state = v,
                ),
              ],
            ),
          ),
          Expanded(
            child: docentesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => _ErrorView(
                onRetry: () => ref.refresh(docenteListProvider.future),
              ),
              data: (docentes) {
                if (docentes.isEmpty) return _EmptyView(canCreate: canManage);
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(docenteListProvider.future),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: docentes.length,
                    itemBuilder: (_, i) => _DocenteCard(docente: docentes[i]),
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

class _DocenteCard extends ConsumerWidget {
  final Docente docente;
  const _DocenteCard({required this.docente});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: docente.activo
              ? AppTheme.successColor.withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.15),
          child: Icon(
            Icons.person,
            color: docente.activo ? AppTheme.successColor : Colors.grey,
          ),
        ),
        title: Text(
          docente.nombreCompleto,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text([
          if (docente.grado != null) 'Grado: ${docente.grado}',
          if (docente.seccion != null) 'Sección: ${docente.seccion}',
          if (docente.turno != null) docente.turno,
        ].join(' · ')),
        trailing: docente.activo
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Activo',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Inactivo',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
        onTap: () => context.go(
          RouteNames.docenteDetalle.replaceFirst(':id', docente.id),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool canCreate;
  const _EmptyView({required this.canCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay docentes registrados',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          if (canCreate) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(RouteNames.docenteNuevo),
              icon: const Icon(Icons.add),
              label: const Text('Registrar primer docente'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback? onRetry;
  const _ErrorView({this.onRetry});

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
              'No se pudieron cargar los docentes.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
