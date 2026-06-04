# Arquitectura — AIP Gest (Control de Préstamos)

> **Documento**: Fase 1 — Arquitectura y diseño técnico
> **Stack**: Flutter + Supabase + Clean Architecture + Riverpod + Go Router

---

## 1. Clean Architecture — Capas

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                    │
│  Pages / Widgets / Providers (Riverpod)                  │
│  Depende de Domain → llama Use Cases                    │
├─────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                        │
│  Entities / Use Cases / Repository Interfaces            │
│  Capa más interna — sin dependencias externas            │
├─────────────────────────────────────────────────────────┤
│                       DATA LAYER                         │
│  Repository Implementations / DataSources (Supabase)     │
│  DTOs / Mappers                                          │
└─────────────────────────────────────────────────────────┘
```

**Regla de dependencia**: las capas externas dependen de las internas. *Nada* en Domain conoce Data ni Presentation.

---

## 2. Estructura de carpetas

```
lib/
├── main.dart
├── app.dart                          # MaterialApp + GoRouter
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── api_constants.dart
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── network/
│   │   └── supabase_client.dart      # Singleton cliente Supabase
│   ├── router/
│   │   ├── app_router.dart           # Definición GoRouter
│   │   └── route_names.dart          # Constantes de ruta
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── date_utils.dart
│       └── validators.dart
│
├── domain/
│   ├── entities/
│   │   ├── docente.dart
│   │   ├── equipo.dart
│   │   ├── equipo_prestamo.dart      # Join Prestamo ↔ Equipo
│   │   ├── prestamo.dart
│   │   ├── devolucion.dart
│   │   ├── firma_digital.dart
│   │   └── usuario.dart
│   │
│   ├── enums/
│   │   ├── equipo_tipo.dart          # laptopDell, laptopHP, cargador, extension, otro
│   │   ├── equipo_estado.dart        # disponible, prestado, mantenimiento
│   │   ├── rol.dart                  # encargadoAIP, practicante
│   │   └── prestamo_estado.dart      # activo, devuelto, parcial
│   │
│   └── repositories/                # Interfaces abstractas
│       ├── i_docente_repository.dart
│       ├── i_equipo_repository.dart
│       ├── i_prestamo_repository.dart
│       ├── i_devolucion_repository.dart
│       ├── i_firma_repository.dart
│       └── i_auth_repository.dart
│
├── domain/
│   └── usecases/                     # Organizados por feature
│       ├── auth/
│       │   ├── login_usecase.dart
│       │   └── logout_usecase.dart
│       ├── docente/
│       │   ├── registrar_docente.dart
│       │   ├── obtener_docentes.dart
│       │   └── buscar_docente.dart
│       ├── equipo/
│       │   ├── registrar_equipo.dart
│       │   ├── obtener_equipos.dart
│       │   ├── obtener_equipos_disponibles.dart
│       │   ├── actualizar_estado_equipo.dart
│       │   └── cambiar_estado_mantenimiento.dart
│       ├── prestamo/
│       │   ├── crear_prestamo.dart
│       │   ├── obtener_prestamos_activos.dart
│       │   ├── obtener_historial_prestamos.dart
│       │   └── obtener_prestamo_por_id.dart
│       ├── devolucion/
│       │   ├── registrar_devolucion.dart
│       │   └── obtener_devoluciones_por_prestamo.dart
│       ├── firma/
│       │   ├── guardar_firma.dart
│       │   └── obtener_firma.dart
│       └── dashboard/
│           ├── obtener_resumen_dashboard.dart
│           └── obtener_equipos_estadisticas.dart
│
├── data/
│   ├── models/                       # DTOs con fromJson/toJson + mapper → Entity
│   │   ├── docente_model.dart
│   │   ├── equipo_model.dart
│   │   ├── equipo_prestamo_model.dart
│   │   ├── prestamo_model.dart
│   │   ├── devolucion_model.dart
│   │   ├── firma_digital_model.dart
│   │   └── usuario_model.dart
│   │
│   ├── datasources/
│   │   ├── remote/
│   │   │   ├── docente_remote_datasource.dart
│   │   │   ├── equipo_remote_datasource.dart
│   │   │   ├── prestamo_remote_datasource.dart
│   │   │   ├── devolucion_remote_datasource.dart
│   │   │   ├── firma_remote_datasource.dart
│   │   │   └── auth_remote_datasource.dart
│   │   └── local/                    # Reservado para caché offline futuro
│   │
│   └── repositories/                # Implementaciones concretas
│       ├── docente_repository_impl.dart
│       ├── equipo_repository_impl.dart
│       ├── prestamo_repository_impl.dart
│       ├── devolucion_repository_impl.dart
│       ├── firma_repository_impl.dart
│       └── auth_repository_impl.dart
│
└── presentation/
    ├── providers/
    │   ├── auth_provider.dart
    │   ├── docente_provider.dart
    │   ├── equipo_provider.dart
    │   ├── prestamo_provider.dart
    │   ├── devolucion_provider.dart
    │   ├── firma_provider.dart
    │   └── dashboard_provider.dart
    │
    ├── pages/
    │   ├── auth/
    │   │   └── login_page.dart
    │   ├── dashboard/
    │   │   └── dashboard_page.dart
    │   ├── prestamo/
    │   │   ├── prestamo_list_page.dart
    │   │   ├── prestamo_create_page.dart
    │   │   └── prestamo_detail_page.dart
    │   ├── devolucion/
    │   │   └── devolucion_create_page.dart
    │   ├── equipo/
    │   │   ├── equipo_list_page.dart
    │   │   └── equipo_form_page.dart
    │   ├── docente/
    │   │   ├── docente_list_page.dart
    │   │   └── docente_form_page.dart
    │   └── historial/
    │       └── historial_page.dart
    │
    └── widgets/
        ├── signature_pad.dart
        ├── equipo_selector.dart
        ├── prestamo_card.dart
        ├── stats_card.dart
        └── common/
            ├── loading_widget.dart
            ├── error_widget.dart
            └── empty_state.dart
```

---

## 3. Diagrama de módulos

```
 ┌───────────┐    ┌───────────┐    ┌───────────┐    ┌──────────────┐
 │   Auth    │    │  Docente  │    │  Equipo   │    │   Dashboard  │
 │  Módulo   │    │  Módulo   │    │  Módulo   │    │   Módulo     │
 └─────┬─────┘    └─────┬─────┘    └─────┬─────┘    └──────┬───────┘
       │                │                │                 │
       └────────────────┼────────────────┼─────────────────┘
                        │                │
              ┌─────────▼────────────────▼──────────┐
              │          PRÉSTAMO MÓDULO             │
              │  (Núcleo — orquesta los demás)       │
              └────────────────┬─────────────────────┘
                               │
              ┌────────────────▼─────────────────────┐
              │         DEVOLUCIÓN MÓDULO             │
              │  + FIRMA DIGITAL                      │
              └────────────────┬─────────────────────┘
                               │
              ┌────────────────▼─────────────────────┐
              │            HISTORIAL                  │
              │  (Read-only, agrega datos de          │
              │   préstamos + devoluciones)           │
              └──────────────────────────────────────┘
```

**Dependencias entre módulos:**

| Módulo | Depende de |
|---|---|
| Auth | — |
| Docente | — |
| Equipo | — |
| Dashboard | Docente, Equipo, Préstamo |
| **Préstamo** | Docente, Equipo |
| **Devolución** | Préstamo, Firma |
| Firma | — |
| Historial | Préstamo, Devolución |

---

## 4. Entidades del dominio

### Usuario
```
Usuario
├── id: String
├── nombre: String
├── email: String
├── rol: Rol (encargadoAIP | practicante)
└── activo: bool
```

### Docente
```
Docente
├── id: String
├── nombreCompleto: String
├── email: String
├── telefono: String?
├── departamento: String?
└── activo: bool
```

### Equipo
```
Equipo
├── id: String
├── tipo: EquipoTipo (laptopDell | laptopHP | cargador | extension | otro)
├── codigoInventario: String       # Código único institucional
├── marca: String?
├── modelo: String?
├── numeroSerie: String?
├── estado: EquipoEstado (disponible | prestado | mantenimiento)
├── observaciones: String?
└── fechaRegistro: DateTime
```

### Préstamo
```
Préstamo
├── id: String
├── docenteId: String              → Docente
├── encargadoId: String            → Usuario (quien entregó)
├── fechaHoraInicio: DateTime
├── fechaHoraFin: DateTime?
├── estado: PrestamoEstado (activo | devuelto | parcial)
├── observaciones: String?
└── equipos: List<EquipoPrestamo>  # Equipos incluidos
```

### EquipoPrestamo (join)
```
EquipoPrestamo
├── id: String
├── prestamoId: String
├── equipoId: String               → Equipo
├── fechaDevolucion: DateTime?
└── observacionesDevolucion: String?
```

### Devolución
```
Devolución
├── id: String
├── prestamoId: String             → Préstamo
├── practicanteId: String          → Usuario (quien recibió)
├── fechaHora: DateTime
├── observaciones: String?
└── equiposDevueltos: List<String> # IDs de EquipoPrestamo
```

### FirmaDigital
```
FirmaDigital
├── id: String
├── prestamoId: String             → Préstamo (firma al crear)
├── devolucionId: String?          → Devolución (firma al devolver)
├── imagenBase64: String           # PNG codificado
├── rol: Rol                       # Quién firmó
├── nombreCompleto: String         # Nombre legible
└── fechaHora: DateTime
```

### Diagrama de relaciones

```
  Docente ──1:N──> Préstamo ──1:N──> EquipoPrestamo ──N:1── Equipo
                      │                                       │
                      │ 1                                     │
                      ▼                                       │
                 Devolución                                   │
                      │                                       │
                      ▼                                       │
              FirmaDigital (x2)                               │
              ─ prestamoId ───────────────────────────────────┘
              ─ devolucionId
```

---

## 5. Casos de uso

### Módulo Auth
| CU | Nombre | Descripción |
|---|---|---|
| CU-01 | Login | Autenticar con email/contraseña vía Supabase Auth |
| CU-02 | Logout | Cerrar sesión |
| CU-03 | Obtener sesión actual | Recuperar usuario logueado |

### Módulo Docente
| CU | Nombre | Descripción |
|---|---|---|
| CU-04 | Registrar docente | Crear nuevo docente en el sistema |
| CU-05 | Obtener docentes | Listar todos los docentes activos |
| CU-06 | Buscar docente | Buscar por nombre, email o departamento |
| CU-07 | Actualizar docente | Editar datos de un docente |
| CU-08 | Desactivar docente | Marcar como inactivo (no se elimina) |

### Módulo Equipo
| CU | Nombre | Descripción |
|---|---|---|
| CU-09 | Registrar equipo | Ingresar nuevo equipo al inventario |
| CU-10 | Obtener equipos | Listar todos los equipos |
| CU-11 | Obtener disponibles | Filtrar equipos con estado = disponible |
| CU-12 | Actualizar equipo | Editar datos del equipo |
| CU-13 | Cambiar a mantenimiento | Marcar equipo como no disponible |
| CU-14 | Cambiar a disponible | Reactivar equipo |

### Módulo Préstamo (Core)
| CU | Nombre | Descripción |
|---|---|---|
| CU-15 | Crear préstamo | Seleccionar docente + equipos + firma digital. Cambia estado equipos a "prestado" |
| CU-16 | Obtener préstamos activos | Listar préstamos no devueltos |
| CU-17 | Obtener historial | Todos los préstamos con filtros por fecha/docente |
| CU-18 | Obtener detalle | Préstamo individual con equipos y devolución asociada |

### Módulo Devolución
| CU | Nombre | Descripción |
|---|---|---|
| CU-19 | Registrar devolución | Seleccionar equipos devueltos + firma digital. Cambia estado equipos a "disponible" |
| CU-20 | Obtener devoluciones | Listar devoluciones de un préstamo |

### Módulo Firma Digital
| CU | Nombre | Descripción |
|---|---|---|
| CU-21 | Guardar firma | Almacenar imagen base64 asociada a un préstamo o devolución |
| CU-22 | Obtener firma | Recuperar imagen por ID |

### Módulo Dashboard
| CU | Nombre | Descripción |
|---|---|---|
| CU-23 | Resumen dashboard | Préstamos activos, equipos disponibles, prestados, en mantenimiento, total docentes hoy |
| CU-24 | Estadísticas equipos | Conteo por tipo de equipo y estado |

---

## 6. Flujo de navegación (Go Router)

### Árbol de rutas

```
/login                                          → LoginPage
/dashboard                                      → DashboardPage         (shell route)
  /dashboard/prestamos                          → PrestamoListPage
  /dashboard/prestamos/nuevo                    → PrestamoCreatePage
  /dashboard/prestamos/:id                      → PrestamoDetailPage
  /dashboard/devoluciones/nuevo?prestamoId=:id  → DevolucionCreatePage
  /dashboard/equipos                            → EquipoListPage
  /dashboard/equipos/nuevo                      → EquipoFormPage
  /dashboard/equipos/:id/editar                 → EquipoFormPage
  /dashboard/docentes                           → DocenteListPage
  /dashboard/docentes/nuevo                     → DocenteFormPage
  /dashboard/docentes/:id/editar                → DocenteFormPage
  /dashboard/historial                          → HistorialPage
```

### Estructura de navegación

```
Login ──(auth ok)──> Dashboard (ShellRoute con BottomNavigation)
                        │
                        ├── Préstamos (tab)
                        │    ├── Lista (default)
                        │    ├── Nuevo Préstamo
                        │    └── Detalle → Devolución
                        │
                        ├── Equipos (tab)
                        │    ├── Lista (default)
                        │    └── Formulario (nuevo/editar)
                        │
                        ├── Docentes (tab)
                        │    ├── Lista (default)
                        │    └── Formulario (nuevo/editar)
                        │
                        └── Historial (tab)
                             └── (filtros en página)
```

### Redirects

| Condición | Destino |
|---|---|
| No autenticado | → `/login` |
| Autenticado + ruta raíz `/` | → `/dashboard/prestamos` |
| Autenticado + ruta inexistente | → `/dashboard/prestamos` |

### Go Router decisión técnica

- `ShellRoute` para el layout persistente con BottomNavigationBar.
- `StatefulShellRoute.indexedStack` para mantener el estado de cada tab.
- `redirect` en el router para control de autenticación.
- `pathParameters` para IDs (`:id`).
- `queryParameters` para datos opcionales (`?prestamoId=`).

---

## 7. Convenciones de código

### Nomenclatura

| Elemento | Convención | Ejemplo |
|---|---|---|
| Archivos Dart | `snake_case` | `prestamo_create_page.dart` |
| Clases/Enums | `PascalCase` | `CrearPrestamo`, `EquipoTipo` |
| Métodos/funciones | `camelCase` | `obtenerEquiposDisponibles()` |
| Variables/parámetros | `camelCase` | `prestamoActivo` |
| Constantes | `camelCase` | `appName` |
| Providers | `camelCase` + sufijo `Provider` | `prestamoProvider` |
| Use Cases | `PascalCase` verbo infinitivo + sustantivo | `CrearPrestamo` |
| Interfaces repositorio | `PascalCase` prefijo `I` | `IPrestamoRepository` |
| Implementaciones | `PascalCase` sufijo `Impl` | `PrestamoRepositoryImpl` |
| Modelos (DTOs) | `PascalCase` sufijo `Model` | `PrestamoModel` |
| Widgets | `PascalCase` sufijo descriptivo | `EquipoSelector`, `StatsCard` |

### Organización de imports

```
1. dart:*
2. flutter:*
3. Paquetes externos (riverpod, go_router, supabase)
4. (blank line)
5. Proyecto (package:aipgest/...)
```

### Riverpod — Providers

- Usar `NotifierProvider` o `AsyncNotifierProvider` para lógica de estado.
- Usar `FutureProvider` para consultas simples (lista de docentes).
- Providers definidos en archivos separados por feature dentro de `presentation/providers/`.
- Inyección de dependencias: pasar repositorios/usecases como argumentos del provider.

### Manejo de errores

- `Failures` (domain) para errores de negocio mapeados desde `Exceptions` (data).
- Todo use case retorna `Either<Failure, T>` o lanza excepción controlada.
- Providers capturan failures y exponen estado `AsyncValue<T>`.

### Estructura de un Use Case

```dart
// 1 archivo = 1 clase invocable con call()
class ObtenerEquiposDisponibles {
  final IEquipoRepository _repository;

  ObtenerEquiposDisponibles(this._repository);

  Future<List<Equipo>> call() async {
    return _repository.obtenerPorEstado(EquipoEstado.disponible);
  }
}
```

### Testing

| Capa | Test | Framework |
|---|---|---|
| Domain | Unit tests de entidades y use cases | `flutter_test` + `mocktail` |
| Data | Unit tests de repositorios y mappers | `flutter_test` + `mocktail` |
| Presentation | Widget tests de páginas y providers | `flutter_test` + `riverpod_test` |
| Integración | Integration tests de flujo completo | `integration_test` |

### Estilo

- Sin `dynamic` — tipado explícito siempre.
- Sin `late` sin inicialización segura; preferir `?` nullable o constructor.
- Sin `print()` — usar `dart:developer` log o logger dedicado.
- `const` constructor siempre que sea posible.
- Archivos < 400 líneas; funciones < 40 líneas.

---

## Resumen de la Fase 1

| Elemento | Estado |
|---|---|
| Arquitectura Clean Architecture definida | ✅ |
| Estructura de carpetas creada | ✅ |
| Diagrama de módulos | ✅ |
| Entidades del dominio modeladas | ✅ |
| Casos de uso identificados (24) | ✅ |
| Flujo de navegación con Go Router | ✅ |
| Convenciones de código | ✅ |
| Código generado | ❌ (Fase 2) |
| Pantallas UI | ❌ (Fase 2) |
| Base de datos / migraciones | ❌ (Fase 3) |

> **Siguiente paso**: Fase 2 — Implementación de entidades, use cases, datasources y providers base.
