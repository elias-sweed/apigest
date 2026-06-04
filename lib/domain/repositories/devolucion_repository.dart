abstract class DevolucionRepository {
  Future<void> registrarDevolucion({
    required String prestamoId,
    required String practicanteId,
    required List<String> prestamoEquipoIds,
    String? observaciones,
  });
}
