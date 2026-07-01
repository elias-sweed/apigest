import '../../domain/entities/docente.dart';
import '../../domain/repositories/docente_repository.dart';
import '../local/datasources/docente_local_datasource.dart';
import '../models/docente_model.dart';
import '../remote/datasources/docente_remote_datasource.dart';
import '../sync/connectivity_service.dart';
import '../sync/sync_queue_service.dart';

class DocenteRepositoryImpl implements DocenteRepository {
  final DocenteLocalDatasource local;
  final DocenteRemoteDatasource remote;
  final SyncQueueService syncQueue;
  final ConnectivityService connectivity;

  DocenteRepositoryImpl({
    required this.local,
    required this.remote,
    required this.syncQueue,
    required this.connectivity,
  });

  @override
  Future<List<Docente>> getDocentes({String? search, bool? soloActivos}) async {
    final cached = await local.getAll();
    if (cached.isNotEmpty) {
      if (connectivity.isOnline) {
        remote.getDocentes(search: search, soloActivos: soloActivos).then((lista) {
          local.upsertAll(lista);
        });
      }
      return cached;
    }
    if (connectivity.isOnline) {
      final lista = await remote.getDocentes(search: search, soloActivos: soloActivos);
      await local.upsertAll(lista);
      return lista;
    }
    return cached;
  }

  @override
  Future<Docente> getDocenteById(String id) async {
    final cached = await local.getById(id);
    if (cached != null) return cached;
    final docente = await remote.getDocenteById(id);
    await local.insert(docente);
    return docente;
  }

  @override
  Future<Docente> createDocente(Docente docente) async {
    final model = docente is DocenteModel ? docente : _toModel(docente);
    await local.insert(model);
    if (connectivity.isOnline) {
      try {
        final created = await remote.createDocente(model.toJson());
        await local.markSynced(created.id);
        return created;
      } catch (e) {
        await syncQueue.enqueue(
          entity: 'docentes',
          entityId: model.id,
          operation: 'CREATE',
          payload: model.toJson(),
        );
        return model;
      }
    } else {
      await syncQueue.enqueue(
        entity: 'docentes',
        entityId: model.id,
        operation: 'CREATE',
        payload: model.toJson(),
      );
      return model;
    }
  }

  @override
  Future<Docente> updateDocente(Docente docente) async {
    final model = docente is DocenteModel ? docente : _toModel(docente);
    await local.update(model);
    if (connectivity.isOnline) {
      try {
        final updated = await remote.updateDocente(docente.id, model.toJson());
        await local.markSynced(updated.id);
        return updated;
      } catch (e) {
        await syncQueue.enqueue(
          entity: 'docentes',
          entityId: model.id,
          operation: 'UPDATE',
          payload: model.toJson(),
        );
        return model;
      }
    } else {
      await syncQueue.enqueue(
        entity: 'docentes',
        entityId: model.id,
        operation: 'UPDATE',
        payload: model.toJson(),
      );
      return model;
    }
  }

  @override
  Future<void> desactivarDocente(String id) async {
    if (connectivity.isOnline) {
      try {
        await remote.desactivarDocente(id);
      } catch (_) {
        await syncQueue.enqueue(
          entity: 'docentes',
          entityId: id,
          operation: 'UPDATE',
          payload: {'id': id, 'activo': false},
        );
      }
    } else {
      await syncQueue.enqueue(
        entity: 'docentes',
        entityId: id,
        operation: 'UPDATE',
        payload: {'id': id, 'activo': false},
      );
    }
  }

  @override
  Future<void> eliminarDocente(String id) async {
    await local.delete(id);
    if (connectivity.isOnline) {
      try {
        await remote.eliminarDocente(id);
      } catch (_) {
        await syncQueue.enqueue(
          entity: 'docentes',
          entityId: id,
          operation: 'DELETE',
          payload: {'id': id},
        );
      }
    } else {
      await syncQueue.enqueue(
        entity: 'docentes',
        entityId: id,
        operation: 'DELETE',
        payload: {'id': id},
      );
    }
  }

  DocenteModel _toModel(Docente entity) {
    return DocenteModel(
      id: entity.id,
      nombres: entity.nombres,
      apellidos: entity.apellidos,
      grado: entity.grado,
      seccion: entity.seccion,
      turno: entity.turno,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
