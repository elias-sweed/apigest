import 'package:aipgest/domain/entities/docente.dart';

abstract class DocenteRepository {
  Future<List<Docente>> getDocentes({String? search, bool? soloActivos});
  Future<Docente> getDocenteById(String id);
  Future<Docente> createDocente(Docente docente);
  Future<Docente> updateDocente(Docente docente);
  Future<void> desactivarDocente(String id);
}
