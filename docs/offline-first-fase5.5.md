# Arquitectura Offline First — AIP Gest (Fase 5.5)

## 1. Principios

| Principio | Descripción |
|---|---|
| **Local first** | Toda pantalla se renderiza con datos SQLite antes de consultar Supabase |
| **Remote as source of truth** | Supabase es la fuente canónica; SQLite es un caché sincronizable |
| **Optimistic UI** | Crear/editar actualiza SQLite + UI inmediatamente; el envío a Supabase es en background |
| **Sync on demand** | Cada pantalla gatilla su propia sincronización al abrirse |
| **Queue + retry** | Las operaciones que fallan por red se encolan y reintentan automáticamente |

---

## 2. Estructura de carpetas (adiciones)

```
lib/
├── core/
│   └── database/
│       ├── app_database.dart              ← Drift Database, singleton
│       ├── app_database.g.dart            ← generado por drift
│       ├── tables/
│       │   ├── equipos_table.dart
│       │   ├── docentes_table.dart
│       │   ├── prestamos_table.dart       ← futuros
│       │   └── sync_queue_table.dart
│       └── daos/
│           ├── equipo_dao.dart
│           ├── docente_dao.dart
│           └── sync_queue_dao.dart
├── data/
│   ├── local/
│   │   └── datasources/
│   │       ├── equipo_local_datasource.dart
│   │       └── docente_local_datasource.dart
│   ├── remote/                            ← actuales datasources, renombrados
│   │   ├── equipo_remote_datasource.dart
│   │   └── docente_remote_datasource.dart
│   └── sync/
│       ├── sync_service.dart              ← orquestador principal
│       ├── sync_queue_service.dart         ← cola de operaciones pendientes
│       └── connectivity_service.dart       ← wrapper de connectivity_plus
```

---

## 3. Tablas Drift

### 3.1 `equipos`

```dart
@Entity(tableName: 'equipos')
class EquipoDrift {
  @PrimaryKey()
  String id;
  String codigoPatrimonial;
  String tipo;
  String? marca;
  String? modelo;
  String? numeroSerie;
  String estado;
  String? observaciones;
  String? imagenUrl;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? syncedAt;         // ← cuándo se sincronizó por última vez
}
```

### 3.2 `docentes`

```dart
@Entity(tableName: 'docentes')
class DocenteDrift {
  @PrimaryKey()
  String id;
  String nombres;
  String apellidos;
  String? grado;
  String? seccion;
  String? turno;
  bool activo;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? syncedAt;
}
```

### 3.3 `sync_queue`

```dart
@Entity(tableName: 'sync_queue')
class SyncQueueEntry {
  @PrimaryKey(autoGenerate: true)
  int id;
  String entity;        // 'equipos' | 'docentes'
  String entityId;
  String operation;     // 'CREATE' | 'UPDATE' | 'DELETE'
  String payload;       // JSON del registro completo
  DateTime createdAt;
  int retryCount;
  String? lastError;
}
```

---

## 4. Capa de datos — flujo por pantalla

### 4.1 Lectura (abrir pantalla)

```
Pantalla abre
       │
       ▼
┌──────────────────────────────┐
│  Provider inicia             │
│  ref.invalidate(...)         │
└──────────┬───────────────────┘
           │
     ┌─────▼──────┐
     │  ¿Online?  │──── NO ────┐
     └─────┬──────┘            │
           │ SÍ               │
           ▼                   ▼
┌──────────────────┐   ┌──────────────────┐
│ RemoteDatasource │   │ LocalDatasource   │
│ (Supabase)       │   │ (Drift)          │
└────────┬─────────┘   └────────┬─────────┘
         │                      │
         ▼                      ▼
   ┌──────────┐          ┌──────────────┐
   │ ¿Nuevos  │          │ Emitir datos │
   │ datos?   │──SÍ──►   │ locales → UI │
   └────┬─────┘          └──────────────┘
        │ NO
        ▼
   ┌──────────┐
   │ Ignorar  │
   └──────────┘
```

**En código (provider)**:
```dart
final equipoListProvider = FutureProvider<List<Equipo>>((ref) async {
  final local = ref.read(equipoLocalDatasourceProvider);
  final remote = ref.read(equipoRemoteDatasourceProvider);
  final sync = ref.read(syncServiceProvider);

  // 1. Devolver locales inmediatamente
  final cached = await local.getAll();
  if (cached.isNotEmpty) {
    // 2. Lanzar sync en background sin await
    sync.syncEquipos();
    return cached;  // ← UI se pinta al toque
  }

  // 3. Si no hay caché, esperar sync
  return remote.getEquipos().then((lista) {
    local.upsertAll(lista);
    return lista;
  });
});
```

### 4.2 Escritura (crear/editar)

```
Usuario guarda
       │
       ▼
┌──────────────────────────────┐
│ Repository.createEquipo()    │
└──────────┬───────────────────┘
           │
     ┌─────▼──────┐
     │ 1. Guardar │──── en SQLite (Drift) ──► UI se actualiza
     │  local     │        (optimistic)
     └─────┬──────┘
           │
     ┌─────▼──────────┐
     │ 2. ¿Online?    │──── NO ────► encolar en sync_queue
     └─────┬──────────┘             y mostrar snackbar "cambios
           │ SÍ                      guardados localmente"
           ▼
     ┌──────────────────┐
     │ 3. Supabase       │── SÍ ──► marcar syncedAt
     │    .insert()      │
     └────────┬─────────┘
              │ NO (error)
              ▼
       ┌──────────────┐
       │ 4. Encolar + │
       │   reintentar  │
       └──────────────┘
```

**En código (repository)**:
```dart
@override
Future<Equipo> createEquipo(Equipo equipo) async {
  final local = ref.read(equipoLocalDatasourceProvider);
  final remote = ref.read(equipoRemoteDatasourceProvider);
  final syncQueue = ref.read(syncQueueServiceProvider);

  // 1. Guardar local
  await local.insert(equipo);

  // 2. Intentar Supabase
  try {
    final created = await remote.createEquipo(equipo);
    await local.markSynced(created.id);
    return created;
  } catch (e) {
    // 3. Si falla, encolar
    await syncQueue.enqueue(
      entity: 'equipos',
      entityId: equipo.id,
      operation: 'CREATE',
      payload: equipo,
    );
    return equipo;  // ← UI ya tiene el dato
  }
}
```

---

## 5. SyncService

### 5.1 Responsabilidades

| Responsabilidad | Clase |
|---|---|
| Orquestar sync al abrir pantalla | `SyncService` |
| Reintentar operaciones fallidas | `SyncQueueService` |
| Monitorear conectividad | `ConnectivityService` |

### 5.2 Flujo de sincronización

```
┌─────────────────────────────────────────────────────────┐
│  SyncService.syncEquipos()                               │
│                                                          │
│  1. Obtener última sync (MAX syncedAt)                   │
│  2. GET desde Supabase:                                  │
│     /equipos?updated_at=gt.{ultimaSync}.order('updated') │
│  3. Para cada registro:                                  │
│     ● Si remote.updatedAt > local.updatedAt → UPSERT    │
│     ● Si remote.updatedAt < local.updatedAt → PUSH     │
│     ● Si remote deleted (soft) → marcar en local        │
│  4. Actualizar syncedAt                                  │
└─────────────────────────────────────────────────────────┘
```

### 5.3 Estrategia de resolución de conflictos

| Escenario | Regla |
|---|---|
| Misma entidad editada local y remotamente | **Last-write-wins**: el `updated_at` más reciente gana |
| Registro eliminado en Supabase pero no en local | Local marca `activo = false` para docentes/equipos |
| Operación en cola que falla por violación de unicidad | Reintentar con `upsert` (ON CONFLICT DO UPDATE) |
| Conflicto por edición concurrente | El `updated_at` más nuevo sobrescribe; se notifica al usuario con un snackbar |

### 5.4 SyncQueueService

```dart
class SyncQueueService {
  Future<void> enqueue({required String entity, required String entityId,
                        required String operation, required dynamic payload});

  Future<void> processQueue();  // llamado al reconectar

  Future<int> pendingCount();   // badge en UI, ej. "3 pendientes"
}
```

**Reintentos**:
- Máximo 5 reintentos por operación
- Intervalo exponencial: 1s → 2s → 4s → 8s → 16s
- Después del 5º, se notifica al usuario y se mantiene en cola para reintento manual

### 5.5 ConnectivityService

```dart
class ConnectivityService {
  Stream<bool> get onConnectivityChanged;
  bool get isOnline;
}
```

Usa `connectivity_plus` para escuchar cambios de red. Cuando detecta reconexión:
1. Procesa `sync_queue` (operaciones pendientes)
2. Gatilla sync de cada módulo abierto
3. Muestra snackbar "Conexión restablecida — datos sincronizados"

---

## 6. Cambios en módulos existentes

### 6.1 Repositorios

Cada repositorio actual `*RepositoryImpl` se refactoriza para inyectar ambos datasources (local + remote) más `SyncQueueService`:

```
ANTES:
EquipoRepositoryImpl(EquipoSupabaseDatasource)

DESPUÉS:
EquipoRepositoryImpl({
  EquipoLocalDatasource,
  EquipoRemoteDatasource,     ← renombrado
  SyncQueueService,
  ConnectivityService,
})
```

### 6.2 Providers

Se agregan providers para cada nuevo servicio:

```dart
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final equipoLocalDatasourceProvider = Provider((ref) {
  return EquipoLocalDatasource(ref.watch(databaseProvider));
});

final equipoRemoteDatasourceProvider = Provider((ref) {
  return EquipoRemoteDatasource(ref.watch(supabaseProvider));
});

final connectivityServiceProvider = Provider((ref) => ConnectivityService());

final syncQueueServiceProvider = Provider((ref) {
  return SyncQueueService(ref.watch(databaseProvider));
});

final syncServiceProvider = Provider((ref) {
  return SyncService(
    ref.watch(supabaseProvider),
    ref.watch(databaseProvider),
    ref.watch(connectivityServiceProvider),
  );
});
```

### 6.3 Riverpod — invalidación post-sync

```dart
// Auto-invalidar providers cuando cambia la conectividad
ref.listen(connectivityServiceProvider.select((c) => c.isOnline), (_, online) {
  if (online) {
    ref.invalidate(equipoListProvider);
    ref.invalidate(docenteListProvider);
  }
});
```

---

## 7. Dependencias (pubspec.yaml)

```yaml
dependencies:
  drift: ^2.23.0
  sqlite3_flutter_libs: ^0.5.0          # SQLite nativo
  path_provider: ^2.1.0
  path: ^1.9.0
  connectivity_plus: ^6.1.0
  rxdart: ^0.28.0                       # streams adicionales

dev_dependencies:
  drift_dev: ^2.23.0                    # generador de código
  build_runner: ^2.4.0
```

---

## 8. Consideraciones adicionales

| Aspecto | Decisión |
|---|---|
| **Primera carga** | Si SQLite está vacío, mostrar shimmer + esperar sync inicial |
| **Refresh manual (pull-to-refresh)** | Forzar sync completo, no incremental |
| **Tamaño de BD** | Estimar < 5 MB para miles de registros; sin preocupación de límite |
| **Seguridad** | Drift usa SQLite local en el sandbox de la app; los datos son del usuario autenticado |
| **Migraciones Drift** | Usar `MigrationStrategy` de Drift con versión de esquema |
| **Préstamos/devoluciones offline** | Los préstamos requieren firma; offline se permite crear borrador local pero la firma requiere subir a Storage → necesitará conexión eventual |

---

## 9. Orden de implementación sugerido

| Paso | Qué |
|---|---|
| 1 | Agregar dependencias Drift + connectivity_plus a pubspec.yaml |
| 2 | Definir tablas Drift (`equipos`, `docentes`, `sync_queue`) |
| 3 | Generar código con `dart run build_runner build` |
| 4 | Crear `ConnectivityService` |
| 5 | Migrar `EquipoSupabaseDatasource` → `EquipoRemoteDatasource` (solo renombrar) |
| 6 | Crear `EquipoLocalDatasource` con Drift |
| 7 | Refactorizar `EquipoRepositoryImpl` para usar local + remote + sync |
| 8 | Crear `SyncQueueService` con tabla `sync_queue` |
| 9 | Crear `SyncService` con sync incremental |
| 10 | Repetir pasos 5-9 para el módulo Docentes |
| 11 | Probar: avión mode → crear equipo → reopen → ver datos locales |
| 12 | Probar: avión mode → crear → online → ver sync automático |
