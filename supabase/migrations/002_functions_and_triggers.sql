-- ============================================================
-- AIP Gest — Migración 002: Funciones y Triggers
-- ============================================================
-- Ejecutar DESPUÉS de 001_initial_schema.sql
-- ============================================================

-- ################################################################
-- 002.1 Trigger: actualizar updated_at automáticamente
-- ################################################################
CREATE OR REPLACE FUNCTION fn_actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar a tablas con columna updated_at
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_usuarios_updated_at') THEN
    CREATE TRIGGER trg_usuarios_updated_at
      BEFORE UPDATE ON usuarios
      FOR EACH ROW EXECUTE FUNCTION fn_actualizar_updated_at();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_docentes_updated_at') THEN
    CREATE TRIGGER trg_docentes_updated_at
      BEFORE UPDATE ON docentes
      FOR EACH ROW EXECUTE FUNCTION fn_actualizar_updated_at();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_equipos_updated_at') THEN
    CREATE TRIGGER trg_equipos_updated_at
      BEFORE UPDATE ON equipos
      FOR EACH ROW EXECUTE FUNCTION fn_actualizar_updated_at();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_prestamos_updated_at') THEN
    CREATE TRIGGER trg_prestamos_updated_at
      BEFORE UPDATE ON prestamos
      FOR EACH ROW EXECUTE FUNCTION fn_actualizar_updated_at();
  END IF;
END $$;

-- ################################################################
-- 002.2 Trigger: al insertar en prestamo_equipos → equipo.estado = 'prestado'
-- Solo si fecha_devolucion_real NO está definida (préstamo activo).
-- Si ya tiene fecha de devolución (carga histórica), no toca el estado.
-- ################################################################
CREATE OR REPLACE FUNCTION fn_prestamo_equipo_insert()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.fecha_devolucion_real IS NULL THEN
    UPDATE equipos SET estado = 'prestado' WHERE id = NEW.equipo_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_prestamo_equipo_after_insert') THEN
    CREATE TRIGGER trg_prestamo_equipo_after_insert
      AFTER INSERT ON prestamo_equipos
      FOR EACH ROW EXECUTE FUNCTION fn_prestamo_equipo_insert();
  END IF;
END $$;

-- ################################################################
-- 002.3 Trigger: al devolver equipo → equipo.estado = 'disponible'
-- ################################################################
-- Maneja dos casos:
--   INSERT con fecha_devolucion_real ya definida (carga histórica)
--   UPDATE marcando fecha_devolucion_real (devolución en vivo)
-- Solo cambia a 'disponible' si el equipo no tiene OTRO préstamo activo.
CREATE OR REPLACE FUNCTION fn_prestamo_equipo_devolver()
RETURNS TRIGGER AS $$
BEGIN
  -- Caso INSERT (carga histórica: el ítem se inserta ya devuelto)
  IF TG_OP = 'INSERT' THEN
    IF NEW.fecha_devolucion_real IS NOT NULL THEN
      IF NOT EXISTS (
        SELECT 1 FROM prestamo_equipos pe
        WHERE pe.equipo_id = NEW.equipo_id
          AND pe.fecha_devolucion_real IS NULL
          AND pe.id != NEW.id
      ) THEN
        UPDATE equipos SET estado = 'disponible' WHERE id = NEW.equipo_id;
      END IF;
    END IF;
    RETURN NEW;
  END IF;

  -- Caso UPDATE (devolución en tiempo real)
  IF NEW.fecha_devolucion_real IS NOT NULL
     AND (OLD.fecha_devolucion_real IS NULL OR OLD.fecha_devolucion_real IS DISTINCT FROM NEW.fecha_devolucion_real)
  THEN
    IF NOT EXISTS (
      SELECT 1 FROM prestamo_equipos pe
      WHERE pe.equipo_id = NEW.equipo_id
        AND pe.fecha_devolucion_real IS NULL
        AND pe.id != NEW.id
    ) THEN
      UPDATE equipos SET estado = 'disponible' WHERE id = NEW.equipo_id;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger unificado: se dispara en INSERT y en UPDATE de fecha_devolucion_real
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_prestamo_equipo_after_insert_or_update') THEN
    DROP TRIGGER IF EXISTS trg_prestamo_equipo_after_update ON prestamo_equipos;
    CREATE TRIGGER trg_prestamo_equipo_after_insert_or_update
      AFTER INSERT OR UPDATE OF fecha_devolucion_real ON prestamo_equipos
      FOR EACH ROW EXECUTE FUNCTION fn_prestamo_equipo_devolver();
  END IF;
END $$;

-- ################################################################
-- 002.4 Trigger: actualizar estado del préstamo según devoluciones
-- ################################################################
CREATE OR REPLACE FUNCTION fn_actualizar_estado_prestamo()
RETURNS TRIGGER AS $$
DECLARE
  v_total_items   INT;
  v_devueltos     INT;
  v_prestamo_id   UUID;
BEGIN
  -- Determinar el prestamo_id según qué operación invocó el trigger
  IF TG_OP = 'INSERT' AND TG_TABLE_NAME = 'prestamo_equipos' THEN
    v_prestamo_id := NEW.prestamo_id;
  ELSIF TG_OP = 'UPDATE' AND TG_TABLE_NAME = 'prestamo_equipos' THEN
    v_prestamo_id := NEW.prestamo_id;
  ELSIF TG_OP = 'INSERT' AND TG_TABLE_NAME = 'devolucion_equipos' THEN
    SELECT pe.prestamo_id INTO v_prestamo_id
    FROM prestamo_equipos pe
    WHERE pe.id = NEW.prestamo_equipo_id;
  ELSE
    RETURN NEW;
  END IF;

  IF v_prestamo_id IS NULL THEN
    RETURN NEW;
  END IF;

  -- Contar total de ítems y cuántos tienen devolución
  SELECT
    COUNT(*),
    COUNT(*) FILTER (WHERE fecha_devolucion_real IS NOT NULL)
  INTO v_total_items, v_devueltos
  FROM prestamo_equipos
  WHERE prestamo_id = v_prestamo_id;

  -- Actualizar estado del préstamo
  IF v_devueltos >= v_total_items THEN
    UPDATE prestamos SET estado = 'devuelto' WHERE id = v_prestamo_id;
  ELSIF v_devueltos > 0 THEN
    UPDATE prestamos SET estado = 'parcial' WHERE id = v_prestamo_id;
  ELSE
    UPDATE prestamos SET estado = 'activo' WHERE id = v_prestamo_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para INSERT en prestamo_equipos con fecha_devolucion_real definida (carga histórica)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_prestamo_estado_after_insert_pe') THEN
    CREATE TRIGGER trg_prestamo_estado_after_insert_pe
      AFTER INSERT ON prestamo_equipos
      FOR EACH ROW
      WHEN (NEW.fecha_devolucion_real IS NOT NULL)
      EXECUTE FUNCTION fn_actualizar_estado_prestamo();
  END IF;
END $$;

-- Trigger para UPDATE de fecha_devolucion_real en prestamo_equipos (devolución en vivo)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_prestamo_estado_after_update_pe') THEN
    DROP TRIGGER IF EXISTS trg_prestamo_estado_after_update_pe ON prestamo_equipos;
    CREATE TRIGGER trg_prestamo_estado_after_update_pe
      AFTER UPDATE OF fecha_devolucion_real ON prestamo_equipos
      FOR EACH ROW
      WHEN (NEW.fecha_devolucion_real IS NOT NULL)
      EXECUTE FUNCTION fn_actualizar_estado_prestamo();
  END IF;
END $$;

-- Trigger para INSERT en devolucion_equipos (registro de devolución)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_prestamo_estado_after_insert_de') THEN
    CREATE TRIGGER trg_prestamo_estado_after_insert_de
      AFTER INSERT ON devolucion_equipos
      FOR EACH ROW EXECUTE FUNCTION fn_actualizar_estado_prestamo();
  END IF;
END $$;

-- ################################################################
-- 002.5 Trigger: validar equipo disponible al prestar (BEFORE INSERT)
-- ################################################################
CREATE OR REPLACE FUNCTION fn_validar_equipo_disponible()
RETURNS TRIGGER AS $$
DECLARE
  v_estado equipo_estado;
BEGIN
  SELECT estado INTO v_estado FROM equipos WHERE id = NEW.equipo_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'El equipo con ID % no existe', NEW.equipo_id;
  END IF;

  IF v_estado != 'disponible' THEN
    RAISE EXCEPTION
      'El equipo código % no está disponible (estado actual: %)',
      (SELECT codigo_patrimonial FROM equipos WHERE id = NEW.equipo_id),
      v_estado
      USING HINT = 'Solo equipos en estado "disponible" pueden ser prestados.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_validar_equipo_disponible_before_insert') THEN
    CREATE TRIGGER trg_validar_equipo_disponible_before_insert
      BEFORE INSERT ON prestamo_equipos
      FOR EACH ROW EXECUTE FUNCTION fn_validar_equipo_disponible();
  END IF;
END $$;

-- ################################################################
-- 002.6 Trigger: validar docente activo al crear préstamo (BEFORE INSERT)
-- ################################################################
CREATE OR REPLACE FUNCTION fn_validar_docente_activo()
RETURNS TRIGGER AS $$
DECLARE
  v_activo BOOLEAN;
BEGIN
  SELECT activo INTO v_activo FROM docentes WHERE id = NEW.docente_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'El docente con ID % no existe', NEW.docente_id;
  END IF;

  IF NOT v_activo THEN
    RAISE EXCEPTION 'El docente seleccionado no está activo en el sistema'
      USING HINT = 'No se puede crear un préstamo para un docente inactivo.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_validar_docente_activo_before_insert') THEN
    CREATE TRIGGER trg_validar_docente_activo_before_insert
      BEFORE INSERT ON prestamos
      FOR EACH ROW EXECUTE FUNCTION fn_validar_docente_activo();
  END IF;
END $$;

-- ################################################################
-- 002.7 Trigger: auditoría genérica (INSERT / UPDATE / DELETE)
-- ################################################################
CREATE OR REPLACE FUNCTION fn_auditar()
RETURNS TRIGGER AS $$
DECLARE
  v_old_data JSONB;
  v_new_data JSONB;
  v_user_id  UUID;
BEGIN
  -- Obtener usuario autenticado (puede ser NULL en operaciones internas)
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

-- Aplicar trigger de auditoría a tablas del dominio (solo si no existe)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_auditar_docentes') THEN
    CREATE TRIGGER trg_auditar_docentes
      AFTER INSERT OR UPDATE OR DELETE ON docentes
      FOR EACH ROW EXECUTE FUNCTION fn_auditar();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_auditar_equipos') THEN
    CREATE TRIGGER trg_auditar_equipos
      AFTER INSERT OR UPDATE OR DELETE ON equipos
      FOR EACH ROW EXECUTE FUNCTION fn_auditar();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_auditar_prestamos') THEN
    CREATE TRIGGER trg_auditar_prestamos
      AFTER INSERT OR UPDATE OR DELETE ON prestamos
      FOR EACH ROW EXECUTE FUNCTION fn_auditar();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_auditar_prestamo_equipos') THEN
    CREATE TRIGGER trg_auditar_prestamo_equipos
      AFTER INSERT OR UPDATE OR DELETE ON prestamo_equipos
      FOR EACH ROW EXECUTE FUNCTION fn_auditar();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_auditar_devoluciones') THEN
    CREATE TRIGGER trg_auditar_devoluciones
      AFTER INSERT OR UPDATE OR DELETE ON devoluciones
      FOR EACH ROW EXECUTE FUNCTION fn_auditar();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_auditar_devolucion_equipos') THEN
    CREATE TRIGGER trg_auditar_devolucion_equipos
      AFTER INSERT OR UPDATE OR DELETE ON devolucion_equipos
      FOR EACH ROW EXECUTE FUNCTION fn_auditar();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_auditar_firmas_digitales') THEN
    CREATE TRIGGER trg_auditar_firmas_digitales
      AFTER INSERT OR UPDATE OR DELETE ON firmas_digitales
      FOR EACH ROW EXECUTE FUNCTION fn_auditar();
  END IF;
END $$;

-- ============================================================
-- FIN Migración 002
-- ============================================================
