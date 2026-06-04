import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/auth_provider.dart';
import '../../data/local/datasources/docente_local_datasource.dart';
import '../../data/remote/datasources/docente_remote_datasource.dart';
import '../../data/repositories/docente_repository_impl.dart';
import '../../domain/entities/docente.dart';
import '../../domain/repositories/docente_repository.dart';

final docenteRemoteDatasourceProvider = Provider<DocenteRemoteDatasource>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return DocenteRemoteDatasource(supabase);
});

final docenteLocalDatasourceProvider = Provider<DocenteLocalDatasource>((ref) {
  final db = ref.watch(databaseProvider);
  return DocenteLocalDatasource(db.docenteDao);
});

final docenteRepositoryProvider = Provider<DocenteRepository>((ref) {
  final local = ref.watch(docenteLocalDatasourceProvider);
  final remote = ref.watch(docenteRemoteDatasourceProvider);
  final syncQueue = ref.watch(syncQueueServiceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return DocenteRepositoryImpl(
    local: local,
    remote: remote,
    syncQueue: syncQueue,
    connectivity: connectivity,
  );
});

final docenteSearchProvider = StateProvider<String>((ref) => '');

final docenteSoloActivosProvider = StateProvider<bool>((ref) => true);

final docenteListProvider = FutureProvider<List<Docente>>((ref) {
  final repository = ref.watch(docenteRepositoryProvider);
  final search = ref.watch(docenteSearchProvider);
  final soloActivos = ref.watch(docenteSoloActivosProvider);
  final sync = ref.watch(syncServiceProvider);
  sync.syncDocentes();
  return repository.getDocentes(
    search: search.isEmpty ? null : search,
    soloActivos: soloActivos ? true : null,
  );
});

final docenteDetailProvider = FutureProvider.family<Docente, String>((ref, id) {
  final repository = ref.watch(docenteRepositoryProvider);
  return repository.getDocenteById(id);
});
