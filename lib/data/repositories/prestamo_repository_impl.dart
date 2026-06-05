import '../../domain/entities/prestamo.dart';
import '../../domain/repositories/prestamo_repository.dart';
import '../remote/datasources/prestamo_remote_datasource.dart';

class PrestamoRepositoryImpl implements PrestamoRepository {
  final PrestamoRemoteDatasource remote;

  PrestamoRepositoryImpl({required this.remote});

  @override
  Future<List<Prestamo>> getPrestamos({String? estado}) {
    return remote.getPrestamos(estado: estado);
  }

  @override
  Future<Prestamo> getPrestamoById(String id) {
    return remote.getPrestamoById(id);
  }

  @override
  Future<Prestamo> updatePrestamo(String id, Map<String, dynamic> data) {
    return remote.updatePrestamo(id, data);
  }

  @override
  Future<void> addEquipos(String prestamoId, List<String> equipoIds) {
    return remote.addEquipos(prestamoId, equipoIds);
  }

  @override
  Future<void> removeEquipo(String prestamoEquipoId) {
    return remote.removeEquipo(prestamoEquipoId);
  }

  @override
  Future<Prestamo> createPrestamo(
    Map<String, dynamic> prestamoData,
    List<Map<String, dynamic>> equipos,
  ) {
    return remote.createPrestamo(prestamoData, equipos);
  }

  @override
  Future<void> deletePrestamo(String id) {
    // Soft-delete not applicable for prestamos; cascade handles cleans
    throw UnimplementedError('Prestamo deletion not implemented');
  }
}
