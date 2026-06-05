import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../data/remote/datasources/historial_remote_datasource.dart';
import '../../data/repositories/historial_repository_impl.dart';
import '../../domain/entities/historial_filter.dart';
import '../../domain/entities/prestamo.dart';
import '../../domain/repositories/historial_repository.dart';

final historialRemoteDatasourceProvider = Provider<HistorialRemoteDatasource>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return HistorialRemoteDatasource(supabase);
});

final historialRepositoryProvider = Provider<HistorialRepository>((ref) {
  final remote = ref.watch(historialRemoteDatasourceProvider);
  return HistorialRepositoryImpl(remote: remote);
});

final historialFilterProvider = StateProvider<HistorialFilter>((ref) {
  return const HistorialFilter();
});

final historialPrestamosProvider = FutureProvider<List<Prestamo>>((ref) {
  final repository = ref.watch(historialRepositoryProvider);
  final filter = ref.watch(historialFilterProvider);
  return repository.getPrestamos(filter);
});
