import '../entities/prestamo.dart';

abstract class PrestamoRepository {
  Future<List<Prestamo>> getPrestamos({String? estado});
  Future<Prestamo> getPrestamoById(String id);
  Future<Prestamo> createPrestamo(Map<String, dynamic> prestamoData, List<Map<String, dynamic>> equipos);
  Future<Prestamo> updatePrestamo(String id, Map<String, dynamic> data);
  Future<void> addEquipos(String prestamoId, List<String> equipoIds);
  Future<void> removeEquipo(String prestamoEquipoId);
  Future<void> deletePrestamo(String id);
}
