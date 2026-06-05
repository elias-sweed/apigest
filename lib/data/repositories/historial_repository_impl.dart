import '../../domain/entities/historial_filter.dart';
import '../../domain/entities/prestamo.dart';
import '../../domain/repositories/historial_repository.dart';
import '../remote/datasources/historial_remote_datasource.dart';

class HistorialRepositoryImpl implements HistorialRepository {
  final HistorialRemoteDatasource remote;

  HistorialRepositoryImpl({required this.remote});

  @override
  Future<List<Prestamo>> getPrestamos(HistorialFilter filter) {
    return remote.getPrestamos(filter);
  }
}
