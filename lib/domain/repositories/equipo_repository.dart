import 'package:aipgest/domain/entities/equipo.dart';

abstract class EquipoRepository {
  Future<List<Equipo>> getEquipos({String? search, String? estado});
  Future<Equipo> getEquipoById(String id);
  Future<Equipo> createEquipo(Equipo equipo);
  Future<Equipo> updateEquipo(Equipo equipo);
  Future<void> cambiarEstado(String id, String nuevoEstado);
}
