import '../entities/prestamo.dart';

abstract class PrestamoRepository {
  Future<List<Prestamo>> getPrestamos({String? estado});
  Future<Prestamo> getPrestamoById(String id);
  Future<Prestamo> createPrestamo(Map<String, dynamic> prestamoData, List<Map<String, dynamic>> equipos);
  Future<void> deletePrestamo(String id);
}
