import '../../domain/entities/docente.dart';
import '../../domain/repositories/docente_repository.dart';

class GetDocentesUseCase {
  final DocenteRepository repository;
  GetDocentesUseCase(this.repository);

  Future<List<Docente>> call({String? search, bool? soloActivos}) {
    return repository.getDocentes(search: search, soloActivos: soloActivos);
  }
}

class GetDocenteByIdUseCase {
  final DocenteRepository repository;
  GetDocenteByIdUseCase(this.repository);

  Future<Docente> call(String id) => repository.getDocenteById(id);
}

class CreateDocenteUseCase {
  final DocenteRepository repository;
  CreateDocenteUseCase(this.repository);

  Future<Docente> call(Docente docente) => repository.createDocente(docente);
}

class UpdateDocenteUseCase {
  final DocenteRepository repository;
  UpdateDocenteUseCase(this.repository);

  Future<Docente> call(Docente docente) => repository.updateDocente(docente);
}

class DesactivarDocenteUseCase {
  final DocenteRepository repository;
  DesactivarDocenteUseCase(this.repository);

  Future<void> call(String id) => repository.desactivarDocente(id);
}
