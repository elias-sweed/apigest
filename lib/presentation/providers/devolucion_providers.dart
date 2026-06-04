import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../data/remote/datasources/devolucion_remote_datasource.dart';
import '../../data/repositories/devolucion_repository_impl.dart';
import '../../data/services/signature_service.dart';
import '../../domain/repositories/devolucion_repository.dart';

final devolucionRemoteDatasourceProvider =
    Provider<DevolucionRemoteDatasource>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return DevolucionRemoteDatasource(supabase);
});

final devolucionRepositoryProvider = Provider<DevolucionRepository>((ref) {
  final remote = ref.watch(devolucionRemoteDatasourceProvider);
  return DevolucionRepositoryImpl(remote: remote);
});

final signatureServiceProvider = Provider<SignatureService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return SignatureService(supabase);
});
