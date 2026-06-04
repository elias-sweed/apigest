# AIP Gest — Deploy en Supabase

Guía paso a paso para ejecutar toda la configuración de base de datos en Supabase.

---

## Requisitos previos

- Proyecto creado en [Supabase Dashboard](https://supabase.com)
- Conexión a Internet

---

## Paso 1: Obtener credenciales del proyecto

1. Ir a [Supabase Dashboard](https://supabase.com/dashboard/projects)
2. Crear o seleccionar tu proyecto
3. Ir a **Project Settings > API**
4. Anotar:
   - **Project URL** (ej: `https://xxxxx.supabase.co`)
   - **anon public key**
   - **service_role key** (solo para administración)

---

## Paso 2: Ejecutar migraciones (SQL Editor)

Ir a **SQL Editor > New Query** y ejecutar en **ESTE ORDEN**:

### 2.1 Schema inicial

```
1. Copiar contenido de supabase/migrations/001_initial_schema.sql
2. Pegar en SQL Editor
3. Ejecutar (Ctrl+Enter)
```

Crea:
- Extensiones (`uuid-ossp`, `pg_trgm`)
- ENUMs (`usuario_rol`, `equipo_tipo`, `equipo_estado`, `prestamo_estado`)
- 9 tablas con constraints (PKs, FKs, UNIQUE, CHECK)
- 18 índices de rendimiento

### 2.2 Funciones y triggers

```
1. Copiar contenido de supabase/migrations/002_functions_and_triggers.sql
2. Pegar en SQL Editor
3. Ejecutar
```

Crea:
- `fn_actualizar_updated_at` — actualiza `updated_at` automáticamente
- `fn_prestamo_equipo_insert` — cambia equipo a `prestado` al insertar
- `fn_prestamo_equipo_devolver` — cambia equipo a `disponible` al devolver
- `fn_actualizar_estado_prestamo` — actualiza estado del préstamo (activo/parcial/devuelto)
- `fn_validar_equipo_disponible` — evita prestar equipos no disponibles
- `fn_validar_docente_activo` — evita préstamos a docentes inactivos
- `fn_auditar` — auditoría automática de todas las operaciones

### 2.3 Políticas RLS

```
1. Copiar contenido de supabase/migrations/003_rls_policies.sql
2. Pegar en SQL Editor
3. Ejecutar
```

Crea:
- RLS habilitado en 9 tablas
- Políticas SELECT para todos los autenticados
- Políticas INSERT/UPDATE/DELETE restringidas por rol
- Auditoría de solo lectura para encargados

### 2.4 Storage (bucket firmas)

```
1. Copiar contenido de supabase/storage.sql
2. Pegar en SQL Editor
3. Ejecutar
```

Configura:
- Bucket `firmas` (privado, no público)
- Límite: 2 MB por archivo
- Tipos permitidos: PNG, JPEG, WebP
- Políticas de acceso por rol

### 2.5 Datos semilla

```
1. Copiar contenido de supabase/seed.sql
2. Pegar en SQL Editor
3. Ejecutar
```

Inserta:
- 4 usuarios (2 encargados, 2 practicantes, 1 inactivo)
- 6 docentes (5 activos, 1 inactivo)
- 12 equipos de 5 tipos y 4 estados
- 3 préstamos (2 activos, 1 devuelto)
- 7 registros en prestamo_equipos
- 1 devolución con 2 equipos
- 6 firmas digitales (metadata)

---

## Paso 3: Configurar Autenticación (Supabase Auth)

### 3.1 Habilitar email/password

1. Ir a **Authentication > Providers**
2. Asegurar que **Email** está habilitado
3. Confirmar que **Confirm email** está desactivado (para pruebas)

### 3.2 Crear usuarios de prueba

```
1. Ir a Authentication > Users > Invite user
2. Crear:
   - carlos.mendoza@iep.edu.pe  → (rol: encargado_aip)
   - maria.rios@iep.edu.pe       → (rol: practicante)
   - jose.huaman@iep.edu.pe      → (rol: practicante)
```

> **Importante**: El `id` generado en `auth.users` debe coincidir con el `id` de `public.usuarios`.
> Para automatizar esta sincronización, ejecuta este trigger UNA SOLA VEZ:

```sql
-- Trigger: cada vez que se crea un usuario en auth.users,
-- se sincroniza automáticamente con public.usuarios
CREATE OR REPLACE FUNCTION fn_sync_auth_user()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.usuarios
  SET id = NEW.id
  WHERE email = NEW.email;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER trg_sync_auth_user AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION fn_sync_auth_user();
```

Esto asegura que cuando invites un usuario desde Authentication > Users, su UUID se refleje automáticamente en `public.usuarios`. Sin este paso, ninguna política RLS funcionará porque `auth.uid()` no encontrará el ID en `public.usuarios`.

---

## Paso 4: Verificar instalación

### 4.1 Consultas de prueba

```sql
-- Resumen del dashboard
SELECT
  (SELECT COUNT(*) FROM equipos WHERE estado = 'disponible') AS equipos_disponibles,
  (SELECT COUNT(*) FROM equipos WHERE estado = 'prestado')   AS equipos_prestados,
  (SELECT COUNT(*) FROM equipos WHERE estado = 'mantenimiento') AS en_mantenimiento,
  (SELECT COUNT(*) FROM prestamos WHERE estado IN ('activo', 'parcial')) AS prestamos_activos;

-- Préstamos activos con datos del docente
SELECT
  p.id,
  d.nombre_completo AS docente,
  u.nombre_completo AS entregado_por,
  p.fecha_hora_inicio,
  p.estado
FROM prestamos p
JOIN docentes d ON d.id = p.docente_id
JOIN usuarios u ON u.id = p.encargado_id
WHERE p.estado IN ('activo', 'parcial')
ORDER BY p.fecha_hora_inicio DESC;

-- Historial completo de un préstamo
SELECT
  pe.id,
  eq.codigo_patrimonial,
  eq.tipo,
  eq.marca,
  pe.fecha_devolucion_real,
  pe.observaciones_devolucion
FROM prestamo_equipos pe
JOIN equipos eq ON eq.id = pe.equipo_id
WHERE pe.prestamo_id = 'd4000000-0000-4000-8000-000000000001';
```

### 4.2 Probar RLS

```sql
-- Esta consulta debe fallar si se ejecuta con anon key (desde la app)
-- y el usuario no es encargado:
INSERT INTO equipos (codigo_patrimonial, tipo) VALUES ('TEST-001', 'laptop_dell');
```

---

## Paso 5: Configurar Flutter

En `lib/core/network/supabase_client.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://TU_PROYECTO.supabase.co',
    anonKey: 'TU_ANON_KEY',
  );
}
```

---

## Estructura de archivos

```
supabase/
├── migrations/
│   ├── 001_initial_schema.sql       ← ENUMs, tablas, constraints, índices
│   ├── 002_functions_and_triggers.sql ← funciones, triggers, auditoría
│   └── 003_rls_policies.sql         ← RLS y políticas
├── storage.sql                      ← Bucket y políticas de Storage
├── seed.sql                         ← Datos de prueba
└── README_DEPLOY.md                 ← Este archivo
```

---

## Orden de ejecución (resumen)

| Paso | Archivo | Tiempo estimado |
|---|---|---|
| 1 | `001_initial_schema.sql` | ~2 seg |
| 2 | `002_functions_and_triggers.sql` | ~2 seg |
| 3 | `003_rls_policies.sql` | ~2 seg |
| 4 | `storage.sql` | ~1 seg |
| 5 | `seed.sql` | ~1 seg |
| 6 | Crear usuarios en Auth | ~5 min |
| 7 | Sincronizar IDs auth ↔ public | ~1 min |

**Tiempo total**: ~10 minutos

---

## Solución de problemas

| Problema | Causa | Solución |
|---|---|---|
| `relation "xxx" does not exist` | Migraciones en orden incorrecto | Ejecutar 001 → 002 → 003 en secuencia |
| `policy already exists` | RLS ya aplicado | Usar `DROP POLICY IF EXISTS` (ya incluido) |
| `type "xxx" already exists` | ENUM ya creado | Usar bloque `DO $$ ... EXCEPTION` (ya incluido) |
| `new row violates row-level security` | RLS bloquea la operación | Verificar que el usuario tiene el rol correcto |
| `auth.uid()` returns NULL | Operación desde SQL Editor sin contexto de usuario | Normal para seed data; en producción se usa desde la API |

---

## Siguientes pasos

Una vez ejecutado todo:

1. ✅ Base de datos lista con migraciones
2. ✅ RLS configurado por rol
3. ✅ Storage listo para firmas digitales
4. ✅ Datos de prueba insertados
5. ⬜ Conectar desde Flutter (Fase 3)
6. ⬜ Implementar lógica de negocio en la app
7. ⬜ Crear pantallas de usuario

---

## Referencias

- [Supabase SQL Editor](https://supabase.com/dashboard/project/_/sql/new)
- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [Supabase Storage](https://supabase.com/docs/guides/storage)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
