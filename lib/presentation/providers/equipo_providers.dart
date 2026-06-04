import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/auth_provider.dart';
import '../../data/local/datasources/equipo_local_datasource.dart';
import '../../data/remote/datasources/equipo_remote_datasource.dart';
import '../../data/repositories/equipo_repository_impl.dart';
import '../../domain/entities/equipo.dart';
import '../../domain/repositories/equipo_repository.dart';

final equipoRemoteDatasourceProvider = Provider<EquipoRemoteDatasource>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return EquipoRemoteDatasource(supabase);
});

final equipoLocalDatasourceProvider = Provider<EquipoLocalDatasource>((ref) {
  final db = ref.watch(databaseProvider);
  return EquipoLocalDatasource(db.equipoDao);
});

final equipoRepositoryProvider = Provider<EquipoRepository>((ref) {
  final local = ref.watch(equipoLocalDatasourceProvider);
  final remote = ref.watch(equipoRemoteDatasourceProvider);
  final syncQueue = ref.watch(syncQueueServiceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return EquipoRepositoryImpl(
    local: local,
    remote: remote,
    syncQueue: syncQueue,
    connectivity: connectivity,
  );
});

final equipoSearchProvider = StateProvider<String>((ref) => '');

final equipoFilterEstadoProvider = StateProvider<String?>((ref) => null);

final equipoListProvider = FutureProvider<List<Equipo>>((ref) {
  final repository = ref.watch(equipoRepositoryProvider);
  final search = ref.watch(equipoSearchProvider);
  final estado = ref.watch(equipoFilterEstadoProvider);
  final sync = ref.watch(syncServiceProvider);
  sync.syncEquipos();
  return repository.getEquipos(
    search: search.isEmpty ? null : search,
    estado: estado,
  );
});

final equipoDetailProvider = FutureProvider.family<Equipo, String>((ref, id) {
  final repository = ref.watch(equipoRepositoryProvider);
  return repository.getEquipoById(id);
});
