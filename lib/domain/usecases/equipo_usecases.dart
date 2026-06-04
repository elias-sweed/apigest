import '../../domain/entities/equipo.dart';
import '../../domain/repositories/equipo_repository.dart';

class GetEquiposUseCase {
  final EquipoRepository repository;
  GetEquiposUseCase(this.repository);

  Future<List<Equipo>> call({String? search, String? estado}) {
    return repository.getEquipos(search: search, estado: estado);
  }
}

class GetEquipoByIdUseCase {
  final EquipoRepository repository;
  GetEquipoByIdUseCase(this.repository);

  Future<Equipo> call(String id) => repository.getEquipoById(id);
}

class CreateEquipoUseCase {
  final EquipoRepository repository;
  CreateEquipoUseCase(this.repository);

  Future<Equipo> call(Equipo equipo) => repository.createEquipo(equipo);
}

class UpdateEquipoUseCase {
  final EquipoRepository repository;
  UpdateEquipoUseCase(this.repository);

  Future<Equipo> call(Equipo equipo) => repository.updateEquipo(equipo);
}

class CambiarEstadoEquipoUseCase {
  final EquipoRepository repository;
  CambiarEstadoEquipoUseCase(this.repository);

  Future<void> call(String id, String nuevoEstado) {
    return repository.cambiarEstado(id, nuevoEstado);
  }
}
