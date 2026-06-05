import '../../domain/entities/equipo.dart';
import '../../domain/repositories/equipo_repository.dart';
import '../local/datasources/equipo_local_datasource.dart';
import '../models/equipo_model.dart';
import '../remote/datasources/equipo_remote_datasource.dart';
import '../sync/connectivity_service.dart';
import '../sync/sync_queue_service.dart';

class EquipoRepositoryImpl implements EquipoRepository {
  final EquipoLocalDatasource local;
  final EquipoRemoteDatasource remote;
  final SyncQueueService syncQueue;
  final ConnectivityService connectivity;

  EquipoRepositoryImpl({
    required this.local,
    required this.remote,
    required this.syncQueue,
    required this.connectivity,
  });

  @override
  Future<List<Equipo>> getEquipos({String? search, String? estado}) async {
    if (connectivity.isOnline) {
      try {
        final lista = await remote.getEquipos(search: search, estado: estado);
        await local.upsertAll(lista);
        return lista;
      } catch (_) {
        return local.getAll();
      }
    }
    return local.getAll();
  }

  @override
  Future<Equipo> getEquipoById(String id) async {
    final cached = await local.getById(id);
    if (cached != null) return cached;
    final equipo = await remote.getEquipoById(id);
    await local.insert(equipo);
    return equipo;
  }

  @override
  Future<Equipo> createEquipo(Equipo equipo) async {
    final model = equipo is EquipoModel ? equipo : _toModel(equipo);
    await local.insert(model);
    if (connectivity.isOnline) {
      try {
        final created = await remote.createEquipo(model.toJson());
        await local.markSynced(created.id);
        return created;
      } catch (e) {
        await syncQueue.enqueue(
          entity: 'equipos',
          entityId: model.id,
          operation: 'CREATE',
          payload: model.toJson(),
        );
        return model;
      }
    } else {
      await syncQueue.enqueue(
        entity: 'equipos',
        entityId: model.id,
        operation: 'CREATE',
        payload: model.toJson(),
      );
      return model;
    }
  }

  @override
  Future<Equipo> updateEquipo(Equipo equipo) async {
    final model = equipo is EquipoModel ? equipo : _toModel(equipo);
    await local.update(model);
    if (connectivity.isOnline) {
      try {
        final updated = await remote.updateEquipo(equipo.id, model.toJson());
        await local.markSynced(updated.id);
        return updated;
      } catch (e) {
        await syncQueue.enqueue(
          entity: 'equipos',
          entityId: model.id,
          operation: 'UPDATE',
          payload: model.toJson(),
        );
        return model;
      }
    } else {
      await syncQueue.enqueue(
        entity: 'equipos',
        entityId: model.id,
        operation: 'UPDATE',
        payload: model.toJson(),
      );
      return model;
    }
  }

  @override
  Future<void> cambiarEstado(String id, String nuevoEstado) async {
    if (connectivity.isOnline) {
      try {
        await remote.cambiarEstado(id, nuevoEstado);
      } catch (_) {
        await syncQueue.enqueue(
          entity: 'equipos',
          entityId: id,
          operation: 'UPDATE',
          payload: {'id': id, 'estado': nuevoEstado},
        );
      }
    } else {
      await syncQueue.enqueue(
        entity: 'equipos',
        entityId: id,
        operation: 'UPDATE',
        payload: {'id': id, 'estado': nuevoEstado},
      );
    }
  }

  EquipoModel _toModel(Equipo entity) {
    return EquipoModel(
      id: entity.id,
      codigoPatrimonial: entity.codigoPatrimonial,
      tipo: entity.tipo,
      marca: entity.marca,
      modelo: entity.modelo,
      numeroSerie: entity.numeroSerie,
      estado: entity.estado,
      observaciones: entity.observaciones,
      imagenUrl: entity.imagenUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
