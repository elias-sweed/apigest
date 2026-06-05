import '../entities/historial_filter.dart';
import '../entities/prestamo.dart';

abstract class HistorialRepository {
  Future<List<Prestamo>> getPrestamos(HistorialFilter filter);
}
