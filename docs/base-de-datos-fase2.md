# Base de Datos — AIP Gest (Fase 2)

> **Stack**: Supabase (PostgreSQL 15+)
> **Propósito**: Diseño completo de base de datos antes de escribir Flutter
> **Documentos relacionados**: `arquitectura-fase1.md`

---

## 1. Modelo Entidad-Relación (ERD)

```
┌──────────────┐       ┌──────────────────┐       ┌───────────────┐
│   usuarios   │       │    docentes      │       │   equipos     │
│──────────────│       │──────────────────│       │───────────────│
│ PK id        │       │ PK id            │       │ PK id         │
│ nombre       │       │ nombre_completo  │       │ codigo_patr.* │← UNIQUE
│ email        │       │ email            │       │ tipo          │
│ rol          │       │ telefono         │       │ marca         │
│ activo       │       │ departamento     │       │ modelo        │
│              │       │ activo           │       │ numero_serie  │
│              │       │ created_at       │       │ estado        │
│              │       └────────┬─────────┘       │ observaciones │
└──────────────┘                │                 │ created_at    │
                                │ 1               └───────┬───────┘
                                │                         │
                                │ N                       │ N
                    ┌───────────▼─────────────────────────▼──────┐
                    │              prestamos                     │
                    │────────────────────────────────────────────│
                    │ PK id                                      │
                    │ FK docente_id ──────────────────────────────┘
                    │ FK encargado_id ─────────── usuarios ──────┘
                    │ fecha_hora_inicio                           │
                    │ fecha_hora_fin_estimada                     │
                    │ estado                                      │
                    │ observaciones                               │
                    └──────────────┬──────────────────────────────┘
                                   │ 1
                                   │
                          ┌────────▼──────────────────┐
                          │    prestamo_equipos        │
                          │────────────────────────────│
                          │ PK id                      │
                          │ FK prestamo_id             │
                          │ FK equipo_id ──────────────┼── equipos
                          │ fecha_devolucion_real      │
                          │ observaciones_devolucion   │
                          └────────┬───────────────────┘
                                   │ 1
                                   │ N
    ┌──────────────┐     ┌────────▼───────────────────┐
    │  usuarios    │     │     devoluciones            │
    │──────────────│     │─────────────────────────────│
    │ (practicante)│     │ PK id                       │
    └──────┬───────┘     │ FK prestamo_id ─────────────┼── prestamos
           │             │ FK practicante_id           │
           │ 1           │ fecha_hora                  │
           │             │ observaciones               │
           │ N           └────────┬────────────────────┘
           │                      │ 1
           │                      │ N
           │             ┌────────▼────────────────────┐
           │             │   devolucion_equipos         │
           │             │──────────────────────────────│
           │             │ PK id                        │
           │             │ FK devolucion_id             │
           │             │ FK prestamo_equipo_id ────────┼── prestamo_equipos
           │             │ observaciones                │
           │             └──────────────────────────────┘
           │
           │                    ┌──────────────────────────────┐
           │                    │     firmas_digitales          │
           │                    │──────────────────────────────│
           │                    │ PK id                         │
           ├────────────────────┼ FK prestamo_id (nullable)     │
           │                    │ FK devolucion_id (nullable)    │
           │                    │ usuario_id                    │
           │                    │ rol                           │
           │                    │ nombre_completo               │
           │                    │ storage_path                  │
           │                    │ mime_type                     │
           │                    │ created_at                    │
           │                    └──────────────────────────────┘
           │
           │                    ┌──────────────────────────────┐
           │                    │      auditoria                │
           │                    │──────────────────────────────│
           │                    │ PK id                         │
           │                    │ tabla_nombre                  │
           │                    │ registro_id                   │
           │                    │ accion                        │
           │                    │ usuario_id                    │
           │                    │ datos_anteriores (JSONB)      │
           │                    │ datos_nuevos (JSONB)          │
           │                    │ created_at                    │
           │                    └──────────────────────────────┘
```

---

## 2. Catálogo de Tipos y Estados

### 2.1 Tipos de equipo (`equipo_tipo`)

| Valor | Etiqueta | Descripción |
|---|---|---|
| `laptop_dell` | Laptop Dell | Computadora portátil marca Dell |
| `laptop_hp` | Laptop HP | Computadora portátil marca HP |
| `cargador` | Cargador | Cargador de laptop (genérico o específico) |
| `extension` | Extensión | Cable de extensión eléctrica |
| `otro_accesorio` | Otro Accesorio | Cualquier otro accesorio no listado |

### 2.2 Estados de equipo (`equipo_estado`)

| Valor | Descripción |
|---|---|
| `disponible` | Listo para préstamo |
| `prestado` | Actualmente en préstamo (no disponible) |
| `mantenimiento` | En reparación o revisión técnica |
| `dado_de_baja` | Fuera de inventario permanentemente |

### 2.3 Estados de préstamo (`prestamo_estado`)

| Valor | Descripción |
|---|---|
| `activo` | Préstamo vigente (equipos aún no devueltos) |
| `parcial` | Algunos equipos devueltos, otros pendientes |
| `devuelto` | Todos los equipos devueltos |

### 2.4 Roles de usuario (`usuario_rol`)

| Valor | Descripción |
|---|---|
| `encargado_aip` | Encargado del Aula de Innovación Pedagógica |
| `practicante` | Practicante que apoya en la gestión |

---

## 3. Tablas Definitivas

### 3.1 `usuarios`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | `UUID` | `PK DEFAULT gen_random_uuid()` | Identificador único |
| `nombre_completo` | `VARCHAR(200)` | `NOT NULL` | Nombre visible |
| `email` | `VARCHAR(255)` | `NOT NULL UNIQUE` | Email de inicio de sesión |
| `rol` | `usuario_rol` | `NOT NULL` | Rol en el sistema |
| `activo` | `BOOLEAN` | `NOT NULL DEFAULT true` | Si puede operar |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT now()` | Fecha de registro |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT now()` | Última modificación |

### 3.2 `docentes`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | `UUID` | `PK DEFAULT gen_random_uuid()` | Identificador único |
| `nombre_completo` | `VARCHAR(200)` | `NOT NULL` | Nombre completo del docente |
| `email` | `VARCHAR(255)` | `NULL UNIQUE` | Correo institucional |
| `telefono` | `VARCHAR(20)` | `NULL` | Teléfono de contacto |
| `departamento` | `VARCHAR(100)` | `NULL` | Área/departamento al que pertenece |
| `activo` | `BOOLEAN` | `NOT NULL DEFAULT true` | Si está vigente en el sistema |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT now()` | Fecha de registro |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT now()` | Última modificación |

### 3.3 `equipos`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | `UUID` | `PK DEFAULT gen_random_uuid()` | Identificador único |
| `codigo_patrimonial` | `VARCHAR(50)` | `NOT NULL UNIQUE` | Código patrimonial único institucional |
| `tipo` | `equipo_tipo` | `NOT NULL` | Tipo de equipo |
| `marca` | `VARCHAR(100)` | `NULL` | Marca del equipo |
| `modelo` | `VARCHAR(100)` | `NULL` | Modelo del equipo |
| `numero_serie` | `VARCHAR(100)` | `NULL` | Número de serie del fabricante |
| `estado` | `equipo_estado` | `NOT NULL DEFAULT 'disponible'` | Estado actual |
| `observaciones` | `TEXT` | `NULL` | Notas adicionales |
| `imagen_url` | `VARCHAR(500)` | `NULL` | URL de foto del equipo (opcional) |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT now()` | Fecha de registro |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT now()` | Última modificación |

### 3.4 `prestamos`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | `UUID` | `PK DEFAULT gen_random_uuid()` | Identificador único |
| `docente_id` | `UUID` | `FK → docentes(id) NOT NULL` | Docente que recibe el préstamo |
| `encargado_id` | `UUID` | `FK → usuarios(id) NOT NULL` | Usuario encargado que entrega |
| `fecha_hora_inicio` | `TIMESTAMPTZ` | `NOT NULL DEFAULT now()` | Momento del préstamo |
| `fecha_hora_fin_estimada` | `TIMESTAMPTZ` | `NULL` | Fecha estimada de devolución |
| `estado` | `prestamo_estado` | `NOT NULL DEFAULT 'activo'` | Estado del préstamo |
| `observaciones` | `TEXT` | `NULL` | Motivo del préstamo o notas |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT now()` | Fecha de registro |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT now()` | Última modificación |

### 3.5 `prestamo_equipos`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | `UUID` | `PK DEFAULT gen_random_uuid()` | Identificador único |
| `prestamo_id` | `UUID` | `FK → prestamos(id) NOT NULL ON DELETE CASCADE` | Préstamo al que pertenece |
| `equipo_id` | `UUID` | `FK → equipos(id) NOT NULL` | Equipo prestado |
| `fecha_devolucion_real` | `TIMESTAMPTZ` | `NULL` | Cuándo se devolvió este equipo |
| `observaciones_devolucion` | `TEXT` | `NULL` | Estado del equipo al devolverlo |

> **Restricción única**: `UNIQUE(prestamo_id, equipo_id)` — un equipo no puede aparecer dos veces en el mismo préstamo.

### 3.6 `devoluciones`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | `UUID` | `PK DEFAULT gen_random_uuid()` | Identificador único |
| `prestamo_id` | `UUID` | `FK → prestamos(id) NOT NULL` | Préstamo que se devuelve |
| `practicante_id` | `UUID` | `FK → usuarios(id) NOT NULL` | Practicante que recibe la devolución |
| `fecha_hora` | `TIMESTAMPTZ` | `NOT NULL DEFAULT now()` | Momento de la devolución |
| `observaciones` | `TEXT` | `NULL` | Notas sobre la devolución |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT now()` | Fecha de registro |

### 3.7 `devolucion_equipos`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | `UUID` | `PK DEFAULT gen_random_uuid()` | Identificador único |
| `devolucion_id` | `UUID` | `FK → devoluciones(id) NOT NULL ON DELETE CASCADE` | Devolución contenedora |
| `prestamo_equipo_id` | `UUID` | `FK → prestamo_equipos(id) NOT NULL` | Ítem específico del préstamo que se devuelve |
| `observaciones` | `TEXT` | `NULL` | Condición del equipo al devolverlo |

> **Restricción única**: `UNIQUE(devolucion_id, prestamo_equipo_id)` — un ítem no puede devolverse dos veces en la misma devolución.

### 3.8 `firmas_digitales`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | `UUID` | `PK DEFAULT gen_random_uuid()` | Identificador único |
| `prestamo_id` | `UUID` | `NULL FK → prestamos(id)` | Préstamo asociado (si firma al crear préstamo) |
| `devolucion_id` | `UUID` | `NULL FK → devoluciones(id)` | Devolución asociada (si firma al devolver) |
| `usuario_id` | `UUID` | `NULL FK → usuarios(id)` | Usuario del sistema que registró la firma |
| `rol` | `usuario_rol` | `NOT NULL` | Rol de quien firmó |
| `nombre_completo` | `VARCHAR(200)` | `NOT NULL` | Nombre legible de quien firmó |
| `storage_path` | `VARCHAR(500)` | `NOT NULL` | Ruta dentro del bucket `firmas` en Supabase Storage |
| `mime_type` | `VARCHAR(50)` | `NOT NULL DEFAULT 'image/png'` | Tipo MIME del archivo de firma |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT now()` | Fecha de registro de la firma |

> **Restricción CHECK**: `(prestamo_id IS NOT NULL) OR (devolucion_id IS NOT NULL)` — cada firma debe pertenecer a un préstamo o a una devolución.
> **Restricción CHECK**: No puede tener `prestamo_id` y `devolucion_id` no nulos simultáneamente (una firma pertenece a un solo contexto).

### 3.9 `auditoria`

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | `UUID` | `PK DEFAULT gen_random_uuid()` | Identificador único |
| `tabla_nombre` | `VARCHAR(100)` | `NOT NULL` | Nombre de la tabla afectada |
| `registro_id` | `UUID` | `NOT NULL` | ID del registro afectado |
| `accion` | `VARCHAR(10)` | `NOT NULL CHECK (accion IN ('INSERT','UPDATE','DELETE'))` | Operación realizada |
| `usuario_id` | `UUID` | `NULL FK → usuarios(id)` | Usuario que realizó la acción |
| `datos_anteriores` | `JSONB` | `NULL` | Snapshot del registro antes del cambio (solo UPDATE/DELETE) |
| `datos_nuevos` | `JSONB` | `NULL` | Snapshot del registro después del cambio (solo INSERT/UPDATE) |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT now()` | Momento de la acción |

---

## 4. Claves y Relaciones

### 4.1 Relaciones principales

| Relación | Tipo | Desde | Hacia | Descripción |
|---|---|---|---|---|
| Préstamo → Docente | N:1 | `prestamos.docente_id` | `docentes.id` | Un docente puede tener N préstamos |
| Préstamo → Encargado | N:1 | `prestamos.encargado_id` | `usuarios.id` | Un encargado puede gestionar N préstamos |
| Préstamo → Equipos | N:M | `prestamo_equipos` | `prestamos` / `equipos` | Tabla puente muchos a muchos |
| Devolución → Préstamo | N:1 | `devoluciones.prestamo_id` | `prestamos.id` | Un préstamo puede tener N devoluciones (parciales) |
| Devolución → Practicante | N:1 | `devoluciones.practicante_id` | `usuarios.id` | Un practicante recibe N devoluciones |
| Devolución → PrestamoEquipos | N:M | `devolucion_equipos` | `devoluciones` / `prestamo_equipos` | Tabla puente |
| Firma → Préstamo | N:1 | `firmas_digitales.prestamo_id` | `prestamos.id` | Un préstamo tiene 1..N firmas |
| Firma → Devolución | N:1 | `firmas_digitales.devolucion_id` | `devoluciones.id` | Una devolución tiene 1..N firmas |
| Auditoría → Usuario | N:1 | `auditoria.usuario_id` | `usuarios.id` | Registro de quién hizo cada cambio |

### 4.2 Resumen de constraints

```
Tabla                  PK        FKs                        UNIQUE                  CHECK
──────────────────────────────────────────────────────────────────────────────────────────────
usuarios               id        —                           email
docentes               id        —                           email
equipos                id        —                           codigo_patrimonial
prestamos              id        docente_id, encargado_id    —
prestamo_equipos       id        prestamo_id, equipo_id      (prestamo_id, equipo_id)
devoluciones           id        prestamo_id, practicante_id —
devolucion_equipos     id        devolucion_id, prestamo_equipo_id  (devolucion_id, prestamo_equipo_id)
firmas_digitales       id        prestamo_id, devolucion_id, usuario_id  —   (prestamo_id IS NOT NULL) OR (devolucion_id IS NOT NULL)
auditoria              id        usuario_id                  —
```

---

## 5. Índices Recomendados

```sql
── Índices para búsqueda de docentes ──
CREATE INDEX idx_docentes_nombre ON docentes USING gin(to_tsvector('spanish', nombre_completo));
CREATE INDEX idx_docentes_activo ON docentes(activo) WHERE activo = true;

── Índices para equipos ──
CREATE INDEX idx_equipos_estado ON equipos(estado);
CREATE INDEX idx_equipos_tipo ON equipos(tipo);
CREATE INDEX idx_equipos_codigo ON equipos(codigo_patrimonial);
CREATE INDEX idx_equipos_disponibles ON equipos(estado) WHERE estado = 'disponible';

── Índices para préstamos ──
CREATE INDEX idx_prestamos_estado ON prestamos(estado);
CREATE INDEX idx_prestamos_docente ON prestamos(docente_id);
CREATE INDEX idx_prestamos_encargado ON prestamos(encargado_id);
CREATE INDEX idx_prestamos_fecha ON prestamos(fecha_hora_inicio DESC);
CREATE INDEX idx_prestamos_activos ON prestamos(estado) WHERE estado IN ('activo', 'parcial');

── Índices para prestamo_equipos ──
CREATE INDEX idx_pe_prestamo ON prestamo_equipos(prestamo_id);
CREATE INDEX idx_pe_equipo ON prestamo_equipos(equipo_id);
CREATE INDEX idx_pe_pendientes ON prestamo_equipos(prestamo_id) WHERE fecha_devolucion_real IS NULL;

── Índices para devoluciones ──
CREATE INDEX idx_devoluciones_prestamo ON devoluciones(prestamo_id);
CREATE INDEX idx_devoluciones_fecha ON devoluciones(fecha_hora DESC);

── Índices para firmas ──
CREATE INDEX idx_firmas_prestamo ON firmas_digitales(prestamo_id);
CREATE INDEX idx_firmas_devolucion ON firmas_digitales(devolucion_id);

── Índices para auditoría ──
CREATE INDEX idx_auditoria_tabla ON auditoria(tabla_nombre, created_at DESC);
CREATE INDEX idx_auditoria_registro ON auditoria(registro_id);
```

---

## 6. Restricciones de Integridad

### 6.1 Integridad de dominio (CHECK)

```sql
-- Un equipo no puede estar 'prestado' si su estado no refleja un préstamo activo
-- (se controla desde la lógica de negocio y triggers)

-- Una firma debe pertenecer exclusivamente a un préstamo O una devolución
ALTER TABLE firmas_digitales ADD CONSTRAINT chk_firma_contexto_exclusivo
  CHECK (
    (prestamo_id IS NOT NULL AND devolucion_id IS NULL)
    OR
    (prestamo_id IS NULL AND devolucion_id IS NOT NULL)
  );

-- El rol encargado_aip no puede crear préstamos como practicante (controlado vía RLS)
-- El rol practicante no puede crear préstamos (controlado vía RLS)
```

### 6.2 Integridad referencial

Todas las claves foráneas usan `ON DELETE RESTRICT` excepto:

- `prestamo_equipos.prestamo_id` → `CASCADE` (si se elimina un préstamo, se eliminan sus items)
- `devolucion_equipos.devolucion_id` → `CASCADE` (si se elimina una devolución, se eliminan sus items)

### 6.3 Reglas de negocio (implementadas vía triggers)

```sql
-- TRG-01: Al crear un préstamo, cambiar estado de equipos a 'prestado'
-- TRG-02: Al devolver un equipo (fecha_devolucion_real NOT NULL), cambiar estado a 'disponible'
-- TRG-03: Actualizar prestamo.estado cuando todos los equipos se devuelven
-- TRG-04: Evitar préstamos a docentes inactivos
-- TRG-05: Evitar préstamos de equipos en estado != 'disponible'
-- TRG-06: Auditar INSERT, UPDATE, DELETE en tablas principales
```

---

## 7. Estados de Negocio (Máquina de Estados)

### 7.1 Ciclo de vida de un Equipo

```
                    ┌──────────┐
                    │ NUEVO    │
                    │ (INSERT) │
                    └────┬─────┘
                         │
                         ▼
                 ┌───────────────┐
          ┌──────│  DISPONIBLE   │◄──────────┐
          │      └───────┬───────┘           │
          │              │                   │
          │      ┌───────▼───────┐           │
          │      │   PRESTADO    │───────────┘ (devolución)
          │      └───────────────┘
          │
          │              │
          │              ▼
          │      ┌───────────────┐
          ├──────│ MANTENIMIENTO │
          │      └───────┬───────┘
          │              │
          │              ▼
          │      ┌───────────────┐
          └──────│ DADO DE BAJA  │  (irreversible)
                 └───────────────┘
```

Transiciones válidas:

| Desde | Hacia | ¿Quién? |
|---|---|---|
| `disponible` | `prestado` | Sistema (al crear préstamo) |
| `prestado` | `disponible` | Sistema (al devolver) |
| `disponible` | `mantenimiento` | Encargado AIP |
| `mantenimiento` | `disponible` | Encargado AIP |
| `disponible` | `dado_de_baja` | Encargado AIP |
| `mantenimiento` | `dado_de_baja` | Encargado AIP |
| `prestado` | `mantenimiento` | ⛔ No permitido (forzar devolución) |

### 7.2 Ciclo de vida de un Préstamo

```
  ┌──────────┐
  │  ACTIVO  │
  └────┬─────┘
       │
       ├── (todos devueltos) ────► ┌──────────┐
       │                           │ DEVUELTO │
       │                           └──────────┘
       │
       └── (algunos devueltos) ──► ┌──────────┐
                                  │ PARCIAL  │
                                  └────┬─────┘
                                       │
                                       └── (resto devueltos) ──► ┌──────────┐
                                                                │ DEVUELTO │
                                                                └──────────┘
```

---

## 8. Diseño de Firmas Digitales (Supabase Storage)

### 8.1 Bucket

```
Bucket: 'firmas'
  ├── prestamos/
  │   └── {prestamo_uuid}/
  │       ├── encargado_{timestamp}.png
  │       └── docente_{timestamp}.png
  └── devoluciones/
      └── {devolucion_uuid}/
          └── practicante_{timestamp}.png
```

### 8.2 Convención de nombres

```
{bucket}/{contexto}/{entidad_id}/{rol}_{timestamp_unix}.png

Ejemplo:
  firmas/prestamos/abc-123/encargado_1717200000.png
  firmas/devoluciones/def-456/practicante_1717203600.png
```

### 8.3 Políticas del bucket

```sql
-- Política: Encargado puede leer/escribir en todo el bucket
CREATE POLICY "Encargados full access firmas"
ON storage.objects FOR ALL TO authenticated
USING (
  bucket_id = 'firmas'
  AND EXISTS (
    SELECT 1 FROM usuarios
    WHERE usuarios.id = auth.uid()
    AND usuarios.rol = 'encargado_aip'
    AND usuarios.activo = true
  )
);

-- Política: Practicante solo puede escribir en devoluciones/
-- y leer en todo el bucket
CREATE POLICY "Practicantes insert devoluciones firmas"
ON storage.objects FOR INSERT TO authenticated
USING (
  bucket_id = 'firmas'
  AND (storage.foldername(name))[1] = 'devoluciones'
  AND EXISTS (
    SELECT 1 FROM usuarios
    WHERE usuarios.id = auth.uid()
    AND usuarios.rol = 'practicante'
    AND usuarios.activo = true
  )
);

CREATE POLICY "Practicantes read firmas"
ON storage.objects FOR SELECT TO authenticated
USING (
  bucket_id = 'firmas'
  AND EXISTS (
    SELECT 1 FROM usuarios
    WHERE usuarios.id = auth.uid()
    AND usuarios.activo = true
  )
);
```

### 8.4 Por qué Storage y no Base64

| Aspecto | Storage | Base64 en BD |
|---|---|---|
| Tamaño en BD | Solo metadata (~200 bytes) | Imagen completa (~50-200 KB) |
| Respaldo/export | Separado, más eficiente | Infla backups innecesariamente |
| Caché CDN | Sí (Supabase CDN) | No |
| Carga útil API | Ligera | Pesada |
| Escalabilidad | Storage optimizado | Consultas lentas con blobs |

---

## 9. Auditoría de Acciones

### 9.1 Tablas auditadas

Se auditan todas las tablas del dominio:
- `docentes`, `equipos`, `prestamos`, `prestamo_equipos`, `devoluciones`, `devolucion_equipos`, `firmas_digitales`

### 9.2 Función y trigger genérico de auditoría

Se implementa un trigger por tabla que captura `INSERT`, `UPDATE`, `DELETE` y registra en `auditoria` con el usuario autenticado via `auth.uid()`.

### 9.3 Ejemplo de consulta de auditoría

```sql
-- Historial completo de un préstamo específico
SELECT * FROM auditoria
WHERE registro_id = 'uuid-del-prestamo'
ORDER BY created_at DESC;

-- Actividad reciente de un usuario
SELECT * FROM auditoria
WHERE usuario_id = 'uuid-del-usuario'
  AND created_at >= NOW() - INTERVAL '7 days'
ORDER BY created_at DESC;
```

---

## 10. Políticas RLS

### 10.1 `usuarios`

```sql
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios solo lectura para autenticados"
ON usuarios FOR SELECT TO authenticated
USING (true);

CREATE POLICY "Solo encargados pueden modificar usuarios"
ON usuarios FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);

CREATE POLICY "Solo encargados pueden actualizar usuarios"
ON usuarios FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);

CREATE POLICY "Solo encargados pueden eliminar usuarios"
ON usuarios FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);
```

### 10.2 `docentes`

```sql
ALTER TABLE docentes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos los autenticados pueden leer docentes"
ON docentes FOR SELECT TO authenticated
USING (true);

CREATE POLICY "Solo encargados pueden crear docentes"
ON docentes FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);

CREATE POLICY "Solo encargados pueden actualizar docentes"
ON docentes FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);

CREATE POLICY "Solo encargados pueden eliminar docentes"
ON docentes FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);
```

### 10.3 `equipos`

```sql
ALTER TABLE equipos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos los autenticados pueden leer equipos"
ON equipos FOR SELECT TO authenticated
USING (true);

CREATE POLICY "Solo encargados pueden crear equipos"
ON equipos FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);

CREATE POLICY "Solo encargados pueden actualizar equipos"
ON equipos FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);

CREATE POLICY "Solo encargados pueden eliminar equipos"
ON equipos FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);
```

### 10.4 `prestamos`

```sql
ALTER TABLE prestamos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos los autenticados pueden leer préstamos"
ON prestamos FOR SELECT TO authenticated
USING (true);

CREATE POLICY "Solo encargados pueden crear préstamos"
ON prestamos FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);

CREATE POLICY "Solo encargados pueden actualizar préstamos"
ON prestamos FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);

CREATE POLICY "Solo encargados pueden eliminar préstamos"
ON prestamos FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);
```

### 10.5 `prestamo_equipos`

```sql
ALTER TABLE prestamo_equipos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos los autenticados pueden leer items de préstamo"
ON prestamo_equipos FOR SELECT TO authenticated
USING (true);

CREATE POLICY "Solo encargados pueden modificar items de préstamo"
ON prestamo_equipos FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);

CREATE POLICY "Solo encargados pueden actualizar items"
ON prestamo_equipos FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);

CREATE POLICY "Solo encargados pueden eliminar items"
ON prestamo_equipos FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);
```

### 10.6 `devoluciones`

```sql
ALTER TABLE devoluciones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos los autenticados pueden leer devoluciones"
ON devoluciones FOR SELECT TO authenticated
USING (true);

CREATE POLICY "Encargados y practicantes pueden crear devoluciones"
ON devoluciones FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND activo = true
  )
);

CREATE POLICY "Solo encargados pueden actualizar devoluciones"
ON devoluciones FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);

CREATE POLICY "Solo encargados pueden eliminar devoluciones"
ON devoluciones FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);
```

### 10.7 `devolucion_equipos`

```sql
ALTER TABLE devolucion_equipos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos los autenticados pueden leer"
ON devolucion_equipos FOR SELECT TO authenticated
USING (true);

CREATE POLICY "Autenticados pueden insertar items de devolución"
ON devolucion_equipos FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND activo = true
  )
);

CREATE POLICY "Solo encargados pueden actualizar"
ON devolucion_equipos FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);

CREATE POLICY "Solo encargados pueden eliminar"
ON devolucion_equipos FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);
```

### 10.8 `firmas_digitales`

```sql
ALTER TABLE firmas_digitales ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos los autenticados pueden leer firmas"
ON firmas_digitales FOR SELECT TO authenticated
USING (true);

CREATE POLICY "Autenticados pueden insertar firmas"
ON firmas_digitales FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND activo = true
  )
);

CREATE POLICY "Solo encargados pueden actualizar firmas"
ON firmas_digitales FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);

CREATE POLICY "Solo encargados pueden eliminar firmas"
ON firmas_digitales FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);
```

### 10.9 `auditoria`

```sql
ALTER TABLE auditoria ENABLE ROW LEVEL SECURITY;

-- Solo lectura para encargados; practicantes no tienen acceso
CREATE POLICY "Solo encargados pueden leer auditoría"
ON auditoria FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true
  )
);

-- Nadie puede escribir directamente — solo triggers internos
CREATE POLICY "Bloquear escritura directa en auditoría"
ON auditoria FOR INSERT TO authenticated
WITH CHECK (false);

CREATE POLICY "Bloquear actualización en auditoría"
ON auditoria FOR UPDATE TO authenticated
USING (false);

CREATE POLICY "Bloquear eliminación en auditoría"
ON auditoria FOR DELETE TO authenticated
USING (false);
```

### 10.10 Matriz de accesos por rol

| Tabla | Acción | Encargado AIP | Practicante |
|---|---|---|---|
| `usuarios` | SELECT | ✅ Todos | ✅ Todos |
| `usuarios` | INSERT | ✅ | ❌ |
| `usuarios` | UPDATE | ✅ | ❌ |
| `usuarios` | DELETE | ✅ | ❌ |
| `docentes` | SELECT | ✅ | ✅ |
| `docentes` | INSERT | ✅ | ❌ |
| `docentes` | UPDATE | ✅ | ❌ |
| `docentes` | DELETE | ✅ | ❌ |
| `equipos` | SELECT | ✅ | ✅ |
| `equipos` | INSERT | ✅ | ❌ |
| `equipos` | UPDATE | ✅ | ❌ |
| `equipos` | DELETE | ✅ | ❌ |
| `prestamos` | SELECT | ✅ | ✅ |
| `prestamos` | INSERT | ✅ | ❌ |
| `prestamos` | UPDATE | ✅ | ❌ |
| `prestamos` | DELETE | ✅ | ❌ |
| `prestamo_equipos` | SELECT | ✅ | ✅ |
| `prestamo_equipos` | INSERT/UPDATE/DELETE | ✅ | ❌ |
| `devoluciones` | SELECT | ✅ | ✅ |
| `devoluciones` | INSERT | ✅ | ✅ |
| `devoluciones` | UPDATE | ✅ | ❌ |
| `devoluciones` | DELETE | ✅ | ❌ |
| `devolucion_equipos` | SELECT | ✅ | ✅ |
| `devolucion_equipos` | INSERT | ✅ | ✅ |
| `devolucion_equipos` | UPDATE/DELETE | ✅ | ❌ |
| `firmas_digitales` | SELECT | ✅ | ✅ |
| `firmas_digitales` | INSERT | ✅ | ✅ |
| `firmas_digitales` | UPDATE/DELETE | ✅ | ❌ |
| `auditoria` | SELECT | ✅ | ❌ |
| `auditoria` | INSERT/UPDATE/DELETE | ❌ * | ❌ * |
| Storage `firmas/` | SELECT | ✅ | ✅ |
| Storage `firmas/prestamos/` | INSERT/UPDATE | ✅ | ❌ |
| Storage `firmas/devoluciones/` | INSERT/UPDATE | ✅ | ✅ |

> * Solo los triggers internos escriben en `auditoria`.

---

## 11. Migraciones SQL Completas

```sql
-- =============================================================
-- MIGRACIÓN 001: Extensiones y tipos base
-- =============================================================

-- Extensiones
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ENUMs
CREATE TYPE usuario_rol AS ENUM ('encargado_aip', 'practicante');
CREATE TYPE equipo_tipo AS ENUM ('laptop_dell', 'laptop_hp', 'cargador', 'extension', 'otro_accesorio');
CREATE TYPE equipo_estado AS ENUM ('disponible', 'prestado', 'mantenimiento', 'dado_de_baja');
CREATE TYPE prestamo_estado AS ENUM ('activo', 'parcial', 'devuelto');


-- =============================================================
-- MIGRACIÓN 002: Tablas
-- =============================================================

-- 002.1 Usuarios
CREATE TABLE usuarios (
  id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre_completo VARCHAR(200)  NOT NULL,
  email           VARCHAR(255)  NOT NULL UNIQUE,
  rol             usuario_rol   NOT NULL,
  activo          BOOLEAN       NOT NULL DEFAULT true,
  created_at      TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- 002.2 Docentes
CREATE TABLE docentes (
  id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre_completo VARCHAR(200)  NOT NULL,
  email           VARCHAR(255)  UNIQUE,
  telefono        VARCHAR(20),
  departamento    VARCHAR(100),
  activo          BOOLEAN       NOT NULL DEFAULT true,
  created_at      TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- 002.3 Equipos
CREATE TABLE equipos (
  id                UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo_patrimonial VARCHAR(50)  NOT NULL UNIQUE,
  tipo              equipo_tipo   NOT NULL,
  marca             VARCHAR(100),
  modelo            VARCHAR(100),
  numero_serie      VARCHAR(100),
  estado            equipo_estado NOT NULL DEFAULT 'disponible',
  observaciones     TEXT,
  imagen_url        VARCHAR(500),
  created_at        TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- 002.4 Préstamos
CREATE TABLE prestamos (
  id                      UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
  docente_id              UUID            NOT NULL REFERENCES docentes(id) ON DELETE RESTRICT,
  encargado_id            UUID            NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
  fecha_hora_inicio       TIMESTAMPTZ     NOT NULL DEFAULT now(),
  fecha_hora_fin_estimada TIMESTAMPTZ,
  estado                  prestamo_estado NOT NULL DEFAULT 'activo',
  observaciones           TEXT,
  created_at              TIMESTAMPTZ     NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ     NOT NULL DEFAULT now()
);

-- 002.5 Prestamo-Equipos (join)
CREATE TABLE prestamo_equipos (
  id                        UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  prestamo_id               UUID        NOT NULL REFERENCES prestamos(id) ON DELETE CASCADE,
  equipo_id                 UUID        NOT NULL REFERENCES equipos(id) ON DELETE RESTRICT,
  fecha_devolucion_real     TIMESTAMPTZ,
  observaciones_devolucion  TEXT,
  UNIQUE(prestamo_id, equipo_id)
);

-- 002.6 Devoluciones
CREATE TABLE devoluciones (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  prestamo_id     UUID        NOT NULL REFERENCES prestamos(id) ON DELETE RESTRICT,
  practicante_id  UUID        NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
  fecha_hora      TIMESTAMPTZ NOT NULL DEFAULT now(),
  observaciones   TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 002.7 Devolucion-Equipos (join)
CREATE TABLE devolucion_equipos (
  id                  UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  devolucion_id       UUID    NOT NULL REFERENCES devoluciones(id) ON DELETE CASCADE,
  prestamo_equipo_id  UUID    NOT NULL REFERENCES prestamo_equipos(id) ON DELETE RESTRICT,
  observaciones       TEXT,
  UNIQUE(devolucion_id, prestamo_equipo_id)
);

-- 002.8 Firmas Digitales
CREATE TABLE firmas_digitales (
  id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  prestamo_id     UUID          REFERENCES prestamos(id) ON DELETE RESTRICT,
  devolucion_id   UUID          REFERENCES devoluciones(id) ON DELETE RESTRICT,
  usuario_id      UUID          REFERENCES usuarios(id) ON DELETE SET NULL,
  rol             usuario_rol   NOT NULL,
  nombre_completo VARCHAR(200)  NOT NULL,
  storage_path    VARCHAR(500)  NOT NULL,
  mime_type       VARCHAR(50)   NOT NULL DEFAULT 'image/png',
  created_at      TIMESTAMPTZ   NOT NULL DEFAULT now(),
  CONSTRAINT chk_firma_contexto_exclusivo CHECK (
    (prestamo_id IS NOT NULL AND devolucion_id IS NULL)
    OR
    (prestamo_id IS NULL AND devolucion_id IS NOT NULL)
  )
);

-- 002.9 Auditoría
CREATE TABLE auditoria (
  id                UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  tabla_nombre      VARCHAR(100)  NOT NULL,
  registro_id       UUID          NOT NULL,
  accion            VARCHAR(10)   NOT NULL CHECK (accion IN ('INSERT', 'UPDATE', 'DELETE')),
  usuario_id        UUID          REFERENCES usuarios(id) ON DELETE SET NULL,
  datos_anteriores  JSONB,
  datos_nuevos      JSONB,
  created_at        TIMESTAMPTZ   NOT NULL DEFAULT now()
);


-- =============================================================
-- MIGRACIÓN 003: Índices
-- =============================================================

CREATE INDEX idx_docentes_nombre ON docentes USING gin(to_tsvector('spanish', nombre_completo));
CREATE INDEX idx_docentes_activo ON docentes(activo) WHERE activo = true;

CREATE INDEX idx_equipos_estado ON equipos(estado);
CREATE INDEX idx_equipos_tipo ON equipos(tipo);
CREATE INDEX idx_equipos_codigo ON equipos(codigo_patrimonial);
CREATE INDEX idx_equipos_disponibles ON equipos(estado) WHERE estado = 'disponible';

CREATE INDEX idx_prestamos_estado ON prestamos(estado);
CREATE INDEX idx_prestamos_docente ON prestamos(docente_id);
CREATE INDEX idx_prestamos_encargado ON prestamos(encargado_id);
CREATE INDEX idx_prestamos_fecha ON prestamos(fecha_hora_inicio DESC);
CREATE INDEX idx_prestamos_activos ON prestamos(estado) WHERE estado IN ('activo', 'parcial');

CREATE INDEX idx_pe_prestamo ON prestamo_equipos(prestamo_id);
CREATE INDEX idx_pe_equipo ON prestamo_equipos(equipo_id);
CREATE INDEX idx_pe_pendientes ON prestamo_equipos(prestamo_id) WHERE fecha_devolucion_real IS NULL;

CREATE INDEX idx_devoluciones_prestamo ON devoluciones(prestamo_id);
CREATE INDEX idx_devoluciones_fecha ON devoluciones(fecha_hora DESC);

CREATE INDEX idx_firmas_prestamo ON firmas_digitales(prestamo_id);
CREATE INDEX idx_firmas_devolucion ON firmas_digitales(devolucion_id);

CREATE INDEX idx_auditoria_tabla ON auditoria(tabla_nombre, created_at DESC);
CREATE INDEX idx_auditoria_registro ON auditoria(registro_id);


-- =============================================================
-- MIGRACIÓN 004: Funciones y Triggers
-- =============================================================

-- 004.1 Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION fn_actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_usuarios_updated_at
  BEFORE UPDATE ON usuarios
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_updated_at();

CREATE TRIGGER trg_docentes_updated_at
  BEFORE UPDATE ON docentes
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_updated_at();

CREATE TRIGGER trg_equipos_updated_at
  BEFORE UPDATE ON equipos
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_updated_at();

CREATE TRIGGER trg_prestamos_updated_at
  BEFORE UPDATE ON prestamos
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_updated_at();

-- 004.2 Trigger: Al insertar en prestamo_equipos → equipo.estado = 'prestado'
CREATE OR REPLACE FUNCTION fn_prestamo_equipo_insert()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE equipos SET estado = 'prestado' WHERE id = NEW.equipo_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prestamo_equipo_after_insert
  AFTER INSERT ON prestamo_equipos
  FOR EACH ROW EXECUTE FUNCTION fn_prestamo_equipo_insert();

-- 004.3 Trigger: Al devolver equipo → equipo.estado = 'disponible'
CREATE OR REPLACE FUNCTION fn_prestamo_equipo_devolver()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.fecha_devolucion_real IS NOT NULL AND OLD.fecha_devolucion_real IS NULL THEN
    UPDATE equipos SET estado = 'disponible'
    WHERE id = NEW.equipo_id
      AND NOT EXISTS (
        SELECT 1 FROM prestamo_equipos
        WHERE equipo_id = NEW.equipo_id
          AND fecha_devolucion_real IS NULL
          AND id != NEW.id
      );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prestamo_equipo_after_update
  AFTER UPDATE OF fecha_devolucion_real ON prestamo_equipos
  FOR EACH ROW EXECUTE FUNCTION fn_prestamo_equipo_devolver();

-- 004.4 Trigger: Actualizar estado del préstamo al devolver equipos
CREATE OR REPLACE FUNCTION fn_actualizar_estado_prestamo()
RETURNS TRIGGER AS $$
DECLARE
  v_total_items   INT;
  v_devueltos     INT;
  v_prestamo_id   UUID;
BEGIN
  -- Determinar prestamo_id según contexto (UPDATE prestamo_equipos vs INSERT devolucion)
  IF TG_OP = 'UPDATE' AND TG_TABLE_NAME = 'prestamo_equipos' THEN
    v_prestamo_id := NEW.prestamo_id;
  ELSIF TG_OP = 'INSERT' AND TG_TABLE_NAME = 'devolucion_equipos' THEN
    SELECT pe.prestamo_id INTO v_prestamo_id
    FROM prestamo_equipos pe
    WHERE pe.id = NEW.prestamo_equipo_id;
  ELSE
    RETURN NEW;
  END IF;

  SELECT COUNT(*), COUNT(*) FILTER (WHERE fecha_devolucion_real IS NOT NULL)
  INTO v_total_items, v_devueltos
  FROM prestamo_equipos
  WHERE prestamo_id = v_prestamo_id;

  IF v_devueltos = 0 THEN
    UPDATE prestamos SET estado = 'activo' WHERE id = v_prestamo_id;
  ELSIF v_devueltos >= v_total_items THEN
    UPDATE prestamos SET estado = 'devuelto' WHERE id = v_prestamo_id;
  ELSE
    UPDATE prestamos SET estado = 'parcial' WHERE id = v_prestamo_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prestamo_estado_after_update_pe
  AFTER UPDATE OF fecha_devolucion_real ON prestamo_equipos
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_estado_prestamo();

CREATE TRIGGER trg_prestamo_estado_after_insert_de
  AFTER INSERT ON devolucion_equipos
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_estado_prestamo();

-- 004.5 Trigger: Validar que el equipo esté disponible al prestar
CREATE OR REPLACE FUNCTION fn_validar_equipo_disponible()
RETURNS TRIGGER AS $$
DECLARE
  v_estado equipo_estado;
BEGIN
  SELECT estado INTO v_estado FROM equipos WHERE id = NEW.equipo_id;
  IF v_estado != 'disponible' THEN
    RAISE EXCEPTION 'El equipo % no está disponible (estado: %)', NEW.equipo_id, v_estado
      USING HINT = 'Solo equipos en estado "disponible" pueden ser prestados.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_equipo_disponible_before_insert
  BEFORE INSERT ON prestamo_equipos
  FOR EACH ROW EXECUTE FUNCTION fn_validar_equipo_disponible();

-- 004.6 Trigger: Validar que el docente esté activo
CREATE OR REPLACE FUNCTION fn_validar_docente_activo()
RETURNS TRIGGER AS $$
DECLARE
  v_activo BOOLEAN;
BEGIN
  SELECT activo INTO v_activo FROM docentes WHERE id = NEW.docente_id;
  IF NOT v_activo THEN
    RAISE EXCEPTION 'El docente no está activo'
      USING HINT = 'No se puede crear un préstamo para un docente inactivo.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_docente_activo_before_insert
  BEFORE INSERT ON prestamos
  FOR EACH ROW EXECUTE FUNCTION fn_validar_docente_activo();

-- 004.7 Trigger: Auditoría genérica
CREATE OR REPLACE FUNCTION fn_auditar()
RETURNS TRIGGER AS $$
DECLARE
  v_old_data JSONB;
  v_new_data JSONB;
  v_user_id  UUID;
BEGIN
  v_user_id := auth.uid();

  IF TG_OP = 'INSERT' THEN
    v_new_data := to_jsonb(NEW);
    INSERT INTO auditoria (tabla_nombre, registro_id, accion, usuario_id, datos_nuevos)
    VALUES (TG_TABLE_NAME, NEW.id, 'INSERT', v_user_id, v_new_data);
    RETURN NEW;

  ELSIF TG_OP = 'UPDATE' THEN
    v_old_data := to_jsonb(OLD);
    v_new_data := to_jsonb(NEW);
    INSERT INTO auditoria (tabla_nombre, registro_id, accion, usuario_id, datos_anteriores, datos_nuevos)
    VALUES (TG_TABLE_NAME, NEW.id, 'UPDATE', v_user_id, v_old_data, v_new_data);
    RETURN NEW;

  ELSIF TG_OP = 'DELETE' THEN
    v_old_data := to_jsonb(OLD);
    INSERT INTO auditoria (tabla_nombre, registro_id, accion, usuario_id, datos_anteriores)
    VALUES (TG_TABLE_NAME, OLD.id, 'DELETE', v_user_id, v_old_data);
    RETURN OLD;
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar trigger de auditoría a tablas del dominio
CREATE TRIGGER trg_auditar_docentes
  AFTER INSERT OR UPDATE OR DELETE ON docentes
  FOR EACH ROW EXECUTE FUNCTION fn_auditar();

CREATE TRIGGER trg_auditar_equipos
  AFTER INSERT OR UPDATE OR DELETE ON equipos
  FOR EACH ROW EXECUTE FUNCTION fn_auditar();

CREATE TRIGGER trg_auditar_prestamos
  AFTER INSERT OR UPDATE OR DELETE ON prestamos
  FOR EACH ROW EXECUTE FUNCTION fn_auditar();

CREATE TRIGGER trg_auditar_prestamo_equipos
  AFTER INSERT OR UPDATE OR DELETE ON prestamo_equipos
  FOR EACH ROW EXECUTE FUNCTION fn_auditar();

CREATE TRIGGER trg_auditar_devoluciones
  AFTER INSERT OR UPDATE OR DELETE ON devoluciones
  FOR EACH ROW EXECUTE FUNCTION fn_auditar();

CREATE TRIGGER trg_auditar_devolucion_equipos
  AFTER INSERT OR UPDATE OR DELETE ON devolucion_equipos
  FOR EACH ROW EXECUTE FUNCTION fn_auditar();

CREATE TRIGGER trg_auditar_firmas_digitales
  AFTER INSERT OR UPDATE OR DELETE ON firmas_digitales
  FOR EACH ROW EXECUTE FUNCTION fn_auditar();


-- =============================================================
-- MIGRACIÓN 005: Row Level Security (RLS)
-- =============================================================

-- 005.1 Habilitar RLS en todas las tablas
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE docentes ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipos ENABLE ROW LEVEL SECURITY;
ALTER TABLE prestamos ENABLE ROW LEVEL SECURITY;
ALTER TABLE prestamo_equipos ENABLE ROW LEVEL SECURITY;
ALTER TABLE devoluciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE devolucion_equipos ENABLE ROW LEVEL SECURITY;
ALTER TABLE firmas_digitales ENABLE ROW LEVEL SECURITY;
ALTER TABLE auditoria ENABLE ROW LEVEL SECURITY;

-- 005.2 Políticas — usuarios
CREATE POLICY "usuarios_select_all" ON usuarios FOR SELECT TO authenticated USING (true);
CREATE POLICY "usuarios_insert_encargado" ON usuarios FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));
CREATE POLICY "usuarios_update_encargado" ON usuarios FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));
CREATE POLICY "usuarios_delete_encargado" ON usuarios FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));

-- 005.3 Políticas — docentes
CREATE POLICY "docentes_select_all" ON docentes FOR SELECT TO authenticated USING (true);
CREATE POLICY "docentes_insert_encargado" ON docentes FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));
CREATE POLICY "docentes_update_encargado" ON docentes FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));
CREATE POLICY "docentes_delete_encargado" ON docentes FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));

-- 005.4 Políticas — equipos
CREATE POLICY "equipos_select_all" ON equipos FOR SELECT TO authenticated USING (true);
CREATE POLICY "equipos_insert_encargado" ON equipos FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));
CREATE POLICY "equipos_update_encargado" ON equipos FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));
CREATE POLICY "equipos_delete_encargado" ON equipos FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));

-- 005.5 Políticas — prestamos
CREATE POLICY "prestamos_select_all" ON prestamos FOR SELECT TO authenticated USING (true);
CREATE POLICY "prestamos_insert_encargado" ON prestamos FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));
CREATE POLICY "prestamos_update_encargado" ON prestamos FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));
CREATE POLICY "prestamos_delete_encargado" ON prestamos FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));

-- 005.6 Políticas — prestamo_equipos
CREATE POLICY "pe_select_all" ON prestamo_equipos FOR SELECT TO authenticated USING (true);
CREATE POLICY "pe_insert_encargado" ON prestamo_equipos FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));
CREATE POLICY "pe_update_encargado" ON prestamo_equipos FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));
CREATE POLICY "pe_delete_encargado" ON prestamo_equipos FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));

-- 005.7 Políticas — devoluciones
CREATE POLICY "devoluciones_select_all" ON devoluciones FOR SELECT TO authenticated USING (true);
CREATE POLICY "devoluciones_insert_all" ON devoluciones FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND activo = true));
CREATE POLICY "devoluciones_update_encargado" ON devoluciones FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));
CREATE POLICY "devoluciones_delete_encargado" ON devoluciones FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));

-- 005.8 Políticas — devolucion_equipos
CREATE POLICY "de_select_all" ON devolucion_equipos FOR SELECT TO authenticated USING (true);
CREATE POLICY "de_insert_all" ON devolucion_equipos FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND activo = true));
CREATE POLICY "de_update_encargado" ON devolucion_equipos FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));
CREATE POLICY "de_delete_encargado" ON devolucion_equipos FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));

-- 005.9 Políticas — firmas_digitales
CREATE POLICY "firmas_select_all" ON firmas_digitales FOR SELECT TO authenticated USING (true);
CREATE POLICY "firmas_insert_all" ON firmas_digitales FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND activo = true));
CREATE POLICY "firmas_update_encargado" ON firmas_digitales FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));
CREATE POLICY "firmas_delete_encargado" ON firmas_digitales FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));

-- 005.10 Políticas — auditoria
CREATE POLICY "auditoria_select_encargado" ON auditoria FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'encargado_aip' AND activo = true));
CREATE POLICY "auditoria_no_insert" ON auditoria FOR INSERT TO authenticated WITH CHECK (false);
CREATE POLICY "auditoria_no_update" ON auditoria FOR UPDATE TO authenticated USING (false);
CREATE POLICY "auditoria_no_delete" ON auditoria FOR DELETE TO authenticated USING (false);
```

---

## 12. Datos Semilla (seed.sql)

```sql
-- =============================================================
-- SEED: Datos de prueba realistas para AIP Gest
-- =============================================================

-- 12.1 Usuarios del sistema
INSERT INTO usuarios (id, nombre_completo, email, rol, activo) VALUES
  ('a1000000-0000-4000-8000-000000000001', 'Carlos Mendoza López',    'carlos.mendoza@iep.edu.pe', 'encargado_aip', true),
  ('a1000000-0000-4000-8000-000000000002', 'María Fernanda Ríos',     'maria.rios@iep.edu.pe',     'practicante',   true),
  ('a1000000-0000-4000-8000-000000000003', 'José Antonio Huamán',     'jose.huaman@iep.edu.pe',    'practicante',   true),
  ('a1000000-0000-4000-8000-000000000004', 'Elena Patricia Vargas',   'elena.vargas@iep.edu.pe',   'encargado_aip', false);

-- 12.2 Docentes
INSERT INTO docentes (id, nombre_completo, email, telefono, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000001', 'Dr. Ricardo Gutiérrez Paredes',  'rgutierrez@iep.edu.pe',  '987654321', 'Matemáticas',   true),
  ('b2000000-0000-4000-8000-000000000002', 'Mg. Lucía Fernández Campos',    'lfernandez@iep.edu.pe', '987654322', 'Comunicación',  true),
  ('b2000000-0000-4000-8000-000000000003', 'Prof. Hugo Sánchez Quispe',     'hsanchez@iep.edu.pe',   '987654323', 'Ciencias',      true),
  ('b2000000-0000-4000-8000-000000000004', 'Dra. Mónica Velasco Torres',    'mvelasco@iep.edu.pe',   '987654324', 'Historia',      true),
  ('b2000000-0000-4000-8000-000000000005', 'Mg. Fernando Rojas Delgado',    'frojas@iep.edu.pe',     '987654325', 'Inglés',        true),
  ('b2000000-0000-4000-8000-000000000006', 'Prof. Silvia Pinedo Marín',     NULL,                     NULL,        'Arte',          false);

-- 12.3 Equipos
INSERT INTO equipos (id, codigo_patrimonial, tipo, marca, modelo, numero_serie, estado, observaciones) VALUES
  -- Laptops Dell
  ('c3000000-0000-4000-8000-000000000001', 'AIP-LDELL-001', 'laptop_dell', 'Dell',        'Latitude 3420',  'SN-DELL-001', 'disponible',   NULL),
  ('c3000000-0000-4000-8000-000000000002', 'AIP-LDELL-002', 'laptop_dell', 'Dell',        'Latitude 3420',  'SN-DELL-002', 'prestado',     NULL),
  ('c3000000-0000-4000-8000-000000000003', 'AIP-LDELL-003', 'laptop_dell', 'Dell',        'Latitude 5430',  'SN-DELL-003', 'mantenimiento', 'Teclado dañado — en reparación'),
  -- Laptops HP
  ('c3000000-0000-4000-8000-000000000004', 'AIP-LHP-001',   'laptop_hp',   'HP',          'ProBook 450 G9', 'SN-HP-001',   'disponible',   NULL),
  ('c3000000-0000-4000-8000-000000000005', 'AIP-LHP-002',   'laptop_hp',   'HP',           'ProBook 450 G9', 'SN-HP-002',   'prestado',     NULL),
  ('c3000000-0000-4000-8000-000000000006', 'AIP-LHP-003',   'laptop_hp',   'HP',           'Pavilion x360', 'SN-HP-003',   'dado_de_baja',  'Pantalla rota — sin repuestos'),
  -- Cargadores
  ('c3000000-0000-4000-8000-000000000007', 'AIP-CARG-001',  'cargador',    'Dell',        '65W USB-C',      'SN-CARG-001',  'disponible',   'Cargador Dell Latitude'),
  ('c3000000-0000-4000-8000-000000000008', 'AIP-CARG-002',  'cargador',    'HP',          '65W USB-C',      'SN-CARG-002',  'prestado',     'Cargador HP ProBook'),
  -- Extensiones
  ('c3000000-0000-4000-8000-000000000009', 'AIP-EXT-001',   'extension',   'Koblenz',     'REG-6T',         NULL,           'disponible',   'Regleta 6 tomas + USB'),
  ('c3000000-0000-4000-8000-000000000010', 'AIP-EXT-002',   'extension',   'Koblenz',     'REG-4T',         NULL,           'disponible',   'Regleta 4 tomas'),
  -- Otros accesorios
  ('c3000000-0000-4000-8000-000000000011', 'AIP-OTRO-001',  'otro_accesorio', 'Logitech', 'C920 HD Pro',   'SN-WEBCAM-01', 'disponible',   'Cámara web para videoconferencias'),
  ('c3000000-0000-4000-8000-000000000012', 'AIP-OTRO-002',  'otro_accesorio', 'Epson',     'EB-X51',        'SN-PROY-001',  'disponible',   'Proyector multimedia');

-- 12.4 Préstamos
INSERT INTO prestamos (id, docente_id, encargado_id, fecha_hora_inicio, fecha_hora_fin_estimada, estado, observaciones) VALUES
  ('d4000000-0000-4000-8000-000000000001',
   'b2000000-0000-4000-8000-000000000002',   -- Lucía Fernández
   'a1000000-0000-4000-8000-000000000001',   -- Carlos Mendoza
   '2026-05-26 09:15:00-05', '2026-05-26 16:00:00-05',
   'activo', 'Préstamo para sesión de taller de comunicación con diapositivas'),
  ('d4000000-0000-4000-8000-000000000002',
   'b2000000-0000-4000-8000-000000000001',   -- Ricardo Gutiérrez
   'a1000000-0000-4000-8000-000000000001',   -- Carlos Mendoza
   '2026-05-27 08:00:00-05', '2026-05-27 12:00:00-05',
   'activo', 'Clase de matemáticas — uso de GeoGebra');

-- 12.5 Equipos por préstamo
INSERT INTO prestamo_equipos (id, prestamo_id, equipo_id, fecha_devolucion_real, observaciones_devolucion) VALUES
  -- Préstamo 1: laptop HP + cargador + extensión
  ('e5000000-0000-4000-8000-000000000001',
   'd4000000-0000-4000-8000-000000000001',
   'c3000000-0000-4000-8000-000000000005',   -- HP ProBook (prestado)
   NULL, NULL),
  ('e5000000-0000-4000-8000-000000000002',
   'd4000000-0000-4000-8000-000000000001',
   'c3000000-0000-4000-8000-000000000008',   -- Cargador HP (prestado)
   NULL, NULL),
  ('e5000000-0000-4000-8000-000000000003',
   'd4000000-0000-4000-8000-000000000001',
   'c3000000-0000-4000-8000-000000000009',   -- Extensión Koblenz
   NULL, NULL),
  -- Préstamo 2: laptop Dell + cargador
  ('e5000000-0000-4000-8000-000000000004',
   'd4000000-0000-4000-8000-000000000002',
   'c3000000-0000-4000-8000-000000000002',   -- Dell Latitude (prestado)
   NULL, NULL);

-- 12.6 Firmas digitales (registro metadata — archivos en Storage)
INSERT INTO firmas_digitales (id, prestamo_id, devolucion_id, usuario_id, rol, nombre_completo, storage_path) VALUES
  ('f6000000-0000-4000-8000-000000000001',
   'd4000000-0000-4000-8000-000000000001', NULL,
   'a1000000-0000-4000-8000-000000000001',
   'encargado_aip', 'Carlos Mendoza López',
   'firmas/prestamos/d4000000-0000-4000-8000-000000000001/encargado_1716768900.png'),
  ('f6000000-0000-4000-8000-000000000002',
   'd4000000-0000-4000-8000-000000000001', NULL,
   NULL,
   'encargado_aip', 'Lucía Fernández Campos',
   'firmas/prestamos/d4000000-0000-4000-8000-000000000001/docente_1716768900.png'),
  ('f6000000-0000-4000-8000-000000000003',
   'd4000000-0000-4000-8000-000000000002', NULL,
   'a1000000-0000-4000-8000-000000000001',
   'encargado_aip', 'Carlos Mendoza López',
   'firmas/prestamos/d4000000-0000-4000-8000-000000000002/encargado_1716854400.png');
```

---

## Resumen de Fase 2

| Elemento | Estado |
|---|---|
| Modelo entidad-relación (ERD) | ✅ Diagrama de texto con 9 tablas |
| Tablas definitivas con columnas, tipos y constraints | ✅ 9 tablas |
| Catálogo de tipos (ENUMs) | ✅ 4 ENUMs (usuario_rol, equipo_tipo, equipo_estado, prestamo_estado) |
| Claves primarias y foráneas | ✅ PKs UUID + FKs con ON DELETE RESTRICT/CASCADE |
| Índices recomendados | ✅ 18 índices (búsqueda, filtros, joins) |
| Restricciones de integridad | ✅ CHECK constraints + triggers de validación |
| Estados de negocio | ✅ Máquina de estados para Equipo y Préstamo |
| Firmas digitales | ✅ Supabase Storage (bucket `firmas/`) con paths jerárquicos |
| Auditoría de acciones | ✅ Tabla `auditoria` + triggers automáticos SECURITY DEFINER |
| Políticas RLS | ✅ 9 tablas + Storage con matriz Encargado/Practicante |
| Migraciones SQL | ✅ 5 migraciones (extensions, tablas, índices, triggers, RLS) |
| Datos semilla | ✅ 4 usuarios, 6 docentes, 12 equipos, 2 préstamos, 3 firmas |
| Código Flutter generado | ❌ (Fase 3) |

> **Siguiente paso**: Fase 3 — Implementación de entidades Dart, datasources, repositorios y providers en Flutter.
