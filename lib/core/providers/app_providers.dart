import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../../data/sync/connectivity_service.dart';
import '../../data/sync/sync_queue_service.dart';
import '../../data/sync/sync_service.dart';
import 'auth_provider.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncQueueService(db.syncQueueDao);
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final db = ref.watch(databaseProvider);
  final syncQueue = ref.watch(syncQueueServiceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return SyncService(
    supabase,
    db.equipoDao,
    db.docenteDao,
    syncQueue,
    connectivity,
  );
});
