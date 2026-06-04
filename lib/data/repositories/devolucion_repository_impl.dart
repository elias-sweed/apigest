import '../../domain/repositories/devolucion_repository.dart';
import '../remote/datasources/devolucion_remote_datasource.dart';

class DevolucionRepositoryImpl implements DevolucionRepository {
  final DevolucionRemoteDatasource remote;

  DevolucionRepositoryImpl({required this.remote});

  @override
  Future<void> registrarDevolucion({
    required String prestamoId,
    required String practicanteId,
    required List<String> prestamoEquipoIds,
    String? observaciones,
  }) {
    return remote.registrarDevolucion(
      prestamoId: prestamoId,
      practicanteId: practicanteId,
      prestamoEquipoIds: prestamoEquipoIds,
      observaciones: observaciones,
    );
  }
}
