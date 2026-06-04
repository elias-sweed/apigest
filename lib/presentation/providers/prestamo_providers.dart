import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../data/remote/datasources/prestamo_remote_datasource.dart';
import '../../data/repositories/prestamo_repository_impl.dart';
import '../../domain/entities/prestamo.dart';
import '../../domain/repositories/prestamo_repository.dart';

final prestamoRemoteDatasourceProvider = Provider<PrestamoRemoteDatasource>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return PrestamoRemoteDatasource(supabase);
});

final prestamoRepositoryProvider = Provider<PrestamoRepository>((ref) {
  final remote = ref.watch(prestamoRemoteDatasourceProvider);
  return PrestamoRepositoryImpl(remote: remote);
});

final prestamoListProvider = FutureProvider<List<Prestamo>>((ref) {
  final repository = ref.watch(prestamoRepositoryProvider);
  return repository.getPrestamos(estado: 'activo');
});

final prestamoDetailProvider = FutureProvider.family<Prestamo, String>((ref, id) {
  final repository = ref.watch(prestamoRepositoryProvider);
  return repository.getPrestamoById(id);
});
