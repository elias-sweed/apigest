import '../entities/prestamo.dart';
import '../repositories/prestamo_repository.dart';

class GetPrestamos {
  final PrestamoRepository repository;
  GetPrestamos(this.repository);
  Future<List<Prestamo>> call({String? estado}) =>
      repository.getPrestamos(estado: estado);
}

class GetPrestamoById {
  final PrestamoRepository repository;
  GetPrestamoById(this.repository);
  Future<Prestamo> call(String id) => repository.getPrestamoById(id);
}

class CreatePrestamo {
  final PrestamoRepository repository;
  CreatePrestamo(this.repository);
  Future<Prestamo> call(
    Map<String, dynamic> prestamoData,
    List<Map<String, dynamic>> equipos,
  ) => repository.createPrestamo(prestamoData, equipos);
}
