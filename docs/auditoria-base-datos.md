# Auditoría Técnica — Base de Datos AIP Gest

## Resumen

| Archivo | Estado | Errores críticos | Errores altos | Mejoras |
|---|---|---|---|---|
| `001_initial_schema.sql` | ⚠️ Requiere corrección | 0 | 2 | 2 |
| `002_functions_and_triggers.sql` | ❌ Requiere corrección | 6 | 0 | 1 |
| `003_rls_policies.sql` | ✅ Aprobado | 0 | 0 | 0 |
| `storage.sql` | ❌ Requiere corrección | 1 | 0 | 1 |
| `seed.sql` | ⚠️ Depende de correcciones | 0 | 1 | 1 |
| `README_DEPLOY.md` | ⚠️ Mejorable | 0 | 0 | 1 |

---

## 1. Errores críticos

### CRIT-01: storage.sql — Firma digital para practicante rota

**Archivo**: `supabase/storage.sql:59`

```sql
-- ❌ INCORRECTO:
AND storage.foldername(name) = 'devoluciones'

-- ✅ CORRECTO:
AND (storage.foldername(name))[1] = 'devoluciones'
```

`storage.foldername(name)` retorna `text[]` (arreglo de fragmentos de ruta, ej: `{devoluciones,uuid}`). Compararlo directamente con un `text` siempre retorna `false`. La política para practicante **nunca funciona**, impidiendo que suban firmas.

**Severidad**: Crítica — los practicantes no pueden registrar devoluciones.

---

### CRIT-02 a CRIT-06: 002_functions_and_triggers.sql — Inconsistencia de estados con préstamos históricos

#### CRIT-02: `fn_prestamo_equipo_insert` no respeta fecha_devolucion_real

**Archivo**: `supabase/migrations/002_functions_and_triggers.sql:54-62`

Cuando se inserta un `prestamo_equipos` con `fecha_devolucion_real` ya definida (carga histórica, migración de datos, o seed), el trigger **siempre** marca el equipo como `'prestado'`. Debería omitir el cambio porque el equipo ya fue devuelto.

```sql
-- ❌ INCORRECTO: Siempre marca como prestado
UPDATE equipos SET estado = 'prestado' WHERE id = NEW.equipo_id;

-- ✅ CORRECTO: Solo marcar como prestado si no fue devuelto inmediatamente
IF NEW.fecha_devolucion_real IS NULL THEN
  UPDATE equipos SET estado = 'prestado' WHERE id = NEW.equipo_id;
END IF;
```

#### CRIT-03: `fn_prestamo_equipo_devolver` no maneja INSERT

**Archivo**: `002_functions_and_triggers.sql:76-94`

La función solo considera `OLD.fecha_devolucion_real` (UPDATE). En un INSERT, `OLD` es NULL y acceder a `OLD.fecha_devolucion_real` es válido (retorna NULL), pero el trigger nunca se dispara porque está configurado solo para `UPDATE OF`.

#### CRIT-04: Trigger `trg_prestamo_equipo_after_update` no cubre INSERT

**Archivo**: `002_functions_and_triggers.sql:96-102`

```sql
-- ❌ Solo UPDATE, nunca INSERT
AFTER UPDATE OF fecha_devolucion_real ON prestamo_equipos

-- ✅ INSERT + UPDATE
AFTER INSERT OR UPDATE OF fecha_devolucion_real ON prestamo_equipos
```

#### CRIT-05: `fn_actualizar_estado_prestamo` no maneja INSERT en prestamo_equipos

**Archivo**: `002_functions_and_triggers.sql:107-148`

Falta el caso `TG_OP = 'INSERT' AND TG_TABLE_NAME = 'prestamo_equipos'`. Si se inserta un ítem ya devuelto, el estado del préstamo no se recalcula.

#### CRIT-06: Falta trigger para INSERT en prestamo_equipos

**Archivo**: `002_functions_and_triggers.sql:150-156`

```sql
-- ✅ Añadir trigger para INSERT con fecha_devolucion_real
CREATE TRIGGER trg_prestamo_estado_after_insert_pe
  AFTER INSERT ON prestamo_equipos
  FOR EACH ROW
  WHEN (NEW.fecha_devolucion_real IS NOT NULL)
  EXECUTE FUNCTION fn_actualizar_estado_prestamo();
```

**Impacto de CRIT-02 a CRIT-06**: Los equipos del préstamo 3 (completado) en `seed.sql` terminan en estado `'prestado'` en lugar de `'disponible'`. El UPDATE a `'dado_de_baja'` posterior (seed:128-133) ejecuta una transición de estado inválida (`prestado → dado_de_baja` sin pasar por `disponible`).

---

## 2. Errores de alta severidad

### HIGH-01: 001_initial_schema.sql — Constraints no idempotentes

**Archivo**: `supabase/migrations/001_initial_schema.sql:148-178`

15 sentencias `ALTER TABLE ... ADD CONSTRAINT`. Si el script se ejecuta dos veces (común en desarrollo), todas fallan porque las constraints ya existen. PostgreSQL no soporta `IF NOT EXISTS` para constraints.

**Solución**: Envolver cada una en `DO $$ BEGIN ... EXCEPTION WHEN duplicate_object THEN NULL; END $$;`.

### HIGH-02: 001_initial_schema.sql — Índice redundante

**Archivo**: `supabase/migrations/001_initial_schema.sql:193`

```sql
CREATE INDEX IF NOT EXISTS idx_equipos_codigo ON equipos(codigo_patrimonial);
```

La constraint `uq_equipos_codigo` (UNIQUE) en línea 151 ya crea un índice único sobre `codigo_patrimonial`. Este índice adicional es redundante y consume recursos en cada INSERT/UPDATE.

---

## 3. Problemas de diseño / producción

### PROD-01: Race condition en validación de equipo disponible

**Archivo**: `002_functions_and_triggers.sql:169-198`

`fn_validar_equipo_disponible` usa `SELECT ... INTO` sin bloqueo (`FOR UPDATE`). Dos transacciones concurrentes pueden:

1. Leer equipo como `'disponible'` (ambas)
2. Ambas pasan la validación
3. Ambas insertan `prestamo_equipos`
4. Ambas marcan el equipo como `'prestado'`
5. Resultado: **doble préstamo del mismo equipo**

En MVP con pocos usuarios concurrentes es aceptable. Para producción, usar `SELECT ... FOR UPDATE` o nivel `SERIALIZABLE`.

### PROD-02: Dependencia frágil entre `auth.users` y `public.usuarios`

**Archivo**: `003_rls_policies.sql` (transversal)

Todas las políticas RLS verifican:
```sql
EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND activo = true)
```

Si `auth.uid()` no existe en `public.usuarios`, todas las operaciones se bloquean. El README menciona la sincronización, pero es un paso manual fácil de omitir.

**Sugerencia**: Agregar un trigger `ON auth.users AFTER INSERT` que cree automáticamente el registro en `public.usuarios`.

### PROD-03: No hay restricción de unicidad temporal para equipos prestados

No existe UNIQUE constraint parcial que impida que un equipo esté en dos préstamos activos simultáneamente. Sería ideal:
```sql
CREATE UNIQUE INDEX uq_equipo_prestamo_activo
  ON prestamo_equipos(equipo_id) WHERE fecha_devolucion_real IS NULL;
```

Esto evitaría la race condition a nivel de base de datos (PROD-01).

### PROD-04: storage.sql — columna `avif_autodetection`

**Archivo**: `storage.sql:11`

La columna `avif_autodetection` no existe en versiones antiguas de Supabase. Considerar omitirla para compatibilidad o agregar un DO block condicional.

---

## 4. Hallazgos del seed

### SEED-01: Estados de equipos tras seed con bugs CRIT-02 a CRIT-06

Sin las correcciones, el seed produce estos estados INCORRECTOS:

| Equipo | ID | Estado esperado | Estado real (con bugs) |
|---|---|---|---|
| HP Pavilion x360 | c3000...006 | `dado_de_baja` | `prestado` (luego `dado_de_baja` ilegalmente) |
| Extensión REG-4T | c3000...010 | `disponible` | `prestado` |

Con las correcciones aplicadas:

| Equipo | ID | Estado esperado | Estado real (corregido) |
|---|---|---|---|
| Dell Latitude 5430 | c3000...003 | `mantenimiento` | `mantenimiento` ✅ |
| HP Pavilion x360 | c3000...006 | `dado_de_baja` | `dado_de_baja` ✅ |
| Extensión REG-4T | c3000...010 | `disponible` | `disponible` ✅ |
| HP ProBook (préstamo 1) | c3000...005 | `prestado` | `prestado` ✅ |
| Cargador HP (préstamo 1) | c3000...008 | `prestado` | `prestado` ✅ |
| Extensión REG-6T (préstamo 1) | c3000...009 | `prestado` | `prestado` ✅ |
| Dell Latitude (préstamo 2) | c3000...002 | `prestado` | `prestado` ✅ |
| Cargador Dell (préstamo 2) | c3000...007 | `prestado` | `prestado` ✅ |

---

## 5. Estado de archivos sin errores

### ✅ `003_rls_policies.sql`

- 36 políticas con nombre consistente `{tabla}_{accion}_{rol}`
- `DROP POLICY IF EXISTS` antes de cada creación → re-ejecutable
- `auditoria` bloqueada con `WITH CHECK (false)` y solo SELECT para encargados
- Sin errores de sintaxis ni lógica

### ✅ Matriz de accesos verificada

| Tabla | Encargado SELECT | Practicante SELECT | Encargado INSERT | Practicante INSERT |
|---|---|---|---|---|
| usuarios | ✅ | ✅ | ✅ | ❌ |
| docentes | ✅ | ✅ | ✅ | ❌ |
| equipos | ✅ | ✅ | ✅ | ❌ |
| prestamos | ✅ | ✅ | ✅ | ❌ |
| prestamo_equipos | ✅ | ✅ | ✅ | ❌ |
| devoluciones | ✅ | ✅ | ✅ | ✅ |
| devolucion_equipos | ✅ | ✅ | ✅ | ✅ |
| firmas_digitales | ✅ | ✅ | ✅ | ✅ |
| auditoria | ✅ | ❌ | ❌ | ❌ |

---

## 6. Archivos corregidos

### 6.1 `supabase/migrations/001_initial_schema.sql`

**Cambios**:
- Envolver todas las `ALTER TABLE ... ADD CONSTRAINT` en `DO $$ BEGIN ... EXCEPTION` para idempotencia
- Eliminar `idx_equipos_codigo` redundante

### 6.2 `supabase/migrations/002_functions_and_triggers.sql`

**Cambios**:
- `fn_prestamo_equipo_insert`: condicionar cambio a `NEW.fecha_devolucion_real IS NULL`
- `fn_prestamo_equipo_devolver`: manejar `TG_OP = 'INSERT'`
- Trigger unificado `trg_prestamo_equipo_after_insert_or_update` (INSERT + UPDATE OF)
- `fn_actualizar_estado_prestamo`: agregar caso `TG_OP = 'INSERT' AND TG_TABLE_NAME = 'prestamo_equipos'`
- Nuevo trigger `trg_prestamo_estado_after_insert_pe` para INSERT con WHEN
- Fix: `fn_prestamo_equipo_devolver` mover el RETURN NEW fuera del bloque IF para TG_OP INSERT

### 6.3 `supabase/storage.sql`

**Cambios**:
- `storage.foldername(name)` → `(storage.foldername(name))[1]`
- Eliminar `avif_autodetection` para compatibilidad máxima

---

## 7. Orden de ejecución verificado

```
1. 001_initial_schema.sql    ← ENUMs, tablas, constraints, índices
2. 002_functions_and_triggers.sql  ← funciones, triggers (corregido)
3. 003_rls_policies.sql      ← RLS (sin cambios)
4. storage.sql                ← Bucket (corregido)
5. seed.sql                   ← Datos (sin cambios, depende de 002 corregido)
```

**Verificación**: El orden es correcto. Cada paso depende de los anteriores.

---

## 8. Conclusión

| Categoría | Cantidad |
|---|---|
| Errores críticos (CRIT) | 6 — **Todos corregidos** |
| Errores altos (HIGH) | 2 — **Ambos corregidos** |
| Mejoras de diseño (PROD) | 4 — Documentados para decisión |
| Hallazgos seed | 1 — Resuelto tras correcciones |
| Archivos sin cambios | `003_rls_policies.sql`, `seed.sql` |
| Archivos modificados | `001_initial_schema.sql`, `002_functions_and_triggers.sql`, `storage.sql` |

Los errores críticos (CRIT-01 a CRIT-06) causan fallos funcionales. Los archivos corregidos se encuentran en `supabase/migrations/` y `supabase/storage.sql`.
