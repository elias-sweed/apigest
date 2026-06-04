import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/database/app_database.dart';
import '../../core/database/daos/equipo_dao.dart';
import '../../core/database/daos/docente_dao.dart';
import '../models/equipo_model.dart';
import '../models/docente_model.dart';
import 'connectivity_service.dart';
import 'sync_queue_service.dart';

class SyncService {
  final SupabaseClient _supabase;
  final EquipoDao _equipoDao;
  final DocenteDao _docenteDao;
  final SyncQueueService _syncQueue;
  final ConnectivityService _connectivity;

  SyncService(
    this._supabase,
    this._equipoDao,
    this._docenteDao,
    this._syncQueue,
    this._connectivity,
  );

  Future<void> syncEquipos() async {
    if (!_connectivity.isOnline) return;
    try {
      final remoteData = await _supabase
          .from('equipos')
          .select()
          .order('updated_at');
      final equipos = (remoteData as List)
          .map((e) => EquipoModel.fromJson(e))
          .toList();
      final driftEquipos = equipos.map((e) => EquipoDrift(
            id: e.id,
            codigoPatrimonial: e.codigoPatrimonial,
            tipo: e.tipo,
            marca: e.marca,
            modelo: e.modelo,
            numeroSerie: e.numeroSerie,
            estado: e.estado,
            observaciones: e.observaciones,
            imagenUrl: e.imagenUrl,
            createdAt: e.createdAt,
            updatedAt: e.updatedAt,
            syncedAt: DateTime.now(),
          )).toList();
      await _equipoDao.upsertAll(driftEquipos);
    } catch (_) {}
  }

  Future<void> syncDocentes() async {
    if (!_connectivity.isOnline) return;
    try {
      final remoteData = await _supabase
          .from('docentes')
          .select()
          .order('updated_at');
      final docentes = (remoteData as List)
          .map((e) => DocenteModel.fromJson(e))
          .toList();
      final driftDocentes = docentes.map((e) => DocenteDrift(
            id: e.id,
            nombres: e.nombres,
            apellidos: e.apellidos,
            grado: e.grado,
            seccion: e.seccion,
            turno: e.turno,
            activo: e.activo ? 1 : 0,
            createdAt: e.createdAt,
            updatedAt: e.updatedAt,
            syncedAt: DateTime.now(),
          )).toList();
      await _docenteDao.upsertAll(driftDocentes);
    } catch (_) {}
  }

  Future<void> processQueue() async {
    if (!_connectivity.isOnline) return;
    final queue = await _syncQueue.getAll();
    for (final entry in queue) {
      if (entry.retryCount >= 5) continue;
      try {
        final payload = jsonDecode(entry.payload) as Map<String, dynamic>;
        final table = _supabase.from(entry.entity);
        switch (entry.operation) {
          case 'CREATE':
            await table.insert(payload);
          case 'UPDATE':
            await table.update(payload).eq('id', entry.entityId);
          case 'DELETE':
            await table.delete().eq('id', entry.entityId);
        }
        await _syncQueue.remove(entry.id);
      } catch (e) {
        await _syncQueue.markRetry(entry.id, e.toString());
      }
    }
  }
}
