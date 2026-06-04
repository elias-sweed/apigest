-- ============================================================
-- AIP Gest — Migración 003: Row Level Security (RLS)
-- ============================================================
-- Ejecutar DESPUÉS de 002_functions_and_triggers.sql
-- ============================================================

-- ################################################################
-- 003.1 Habilitar RLS en todas las tablas
-- ################################################################
ALTER TABLE usuarios          ENABLE ROW LEVEL SECURITY;
ALTER TABLE docentes          ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipos           ENABLE ROW LEVEL SECURITY;
ALTER TABLE prestamos         ENABLE ROW LEVEL SECURITY;
ALTER TABLE prestamo_equipos  ENABLE ROW LEVEL SECURITY;
ALTER TABLE devoluciones      ENABLE ROW LEVEL SECURITY;
ALTER TABLE devolucion_equipos ENABLE ROW LEVEL SECURITY;
ALTER TABLE firmas_digitales  ENABLE ROW LEVEL SECURITY;
ALTER TABLE auditoria         ENABLE ROW LEVEL SECURITY;

-- ################################################################
-- 003.2 Políticas — usuarios
-- ################################################################
-- SELECT: todos los autenticados pueden leer
DROP POLICY IF EXISTS "usuarios_select_all" ON usuarios;
CREATE POLICY "usuarios_select_all" ON usuarios
  FOR SELECT TO authenticated
  USING (true);

-- INSERT: solo encargados
DROP POLICY IF EXISTS "usuarios_insert_encargado" ON usuarios;
CREATE POLICY "usuarios_insert_encargado" ON usuarios
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

-- UPDATE: solo encargados
DROP POLICY IF EXISTS "usuarios_update_encargado" ON usuarios;
CREATE POLICY "usuarios_update_encargado" ON usuarios
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

-- DELETE: solo encargados
DROP POLICY IF EXISTS "usuarios_delete_encargado" ON usuarios;
CREATE POLICY "usuarios_delete_encargado" ON usuarios
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

-- ################################################################
-- 003.3 Políticas — docentes
-- ################################################################
DROP POLICY IF EXISTS "docentes_select_all" ON docentes;
CREATE POLICY "docentes_select_all" ON docentes
  FOR SELECT TO authenticated
  USING (true);

-- INSERT: encargados y practicantes activos
DROP POLICY IF EXISTS "docentes_insert_encargado" ON docentes;
DROP POLICY IF EXISTS "docentes_insert_all" ON docentes;
CREATE POLICY "docentes_insert_all" ON docentes
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol IN ('encargado_aip', 'practicante')
        AND activo = true
    )
  );

-- UPDATE: encargados y practicantes activos
DROP POLICY IF EXISTS "docentes_update_encargado" ON docentes;
DROP POLICY IF EXISTS "docentes_update_all" ON docentes;
CREATE POLICY "docentes_update_all" ON docentes
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol IN ('encargado_aip', 'practicante')
        AND activo = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol IN ('encargado_aip', 'practicante')
        AND activo = true
    )
  );

-- DELETE: solo encargados
DROP POLICY IF EXISTS "docentes_delete_encargado" ON docentes;
CREATE POLICY "docentes_delete_encargado" ON docentes
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

-- ################################################################
-- 003.4 Políticas — equipos
-- ################################################################
DROP POLICY IF EXISTS "equipos_select_all" ON equipos;
CREATE POLICY "equipos_select_all" ON equipos
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "equipos_insert_encargado" ON equipos;
CREATE POLICY "equipos_insert_encargado" ON equipos
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

DROP POLICY IF EXISTS "equipos_update_encargado" ON equipos;
CREATE POLICY "equipos_update_encargado" ON equipos
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

DROP POLICY IF EXISTS "equipos_delete_encargado" ON equipos;
CREATE POLICY "equipos_delete_encargado" ON equipos
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

-- ################################################################
-- 003.5 Políticas — préstamos
-- ################################################################
DROP POLICY IF EXISTS "prestamos_select_all" ON prestamos;
CREATE POLICY "prestamos_select_all" ON prestamos
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "prestamos_insert_encargado" ON prestamos;
CREATE POLICY "prestamos_insert_encargado" ON prestamos
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

DROP POLICY IF EXISTS "prestamos_update_encargado" ON prestamos;
CREATE POLICY "prestamos_update_encargado" ON prestamos
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

DROP POLICY IF EXISTS "prestamos_delete_encargado" ON prestamos;
CREATE POLICY "prestamos_delete_encargado" ON prestamos
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

-- ################################################################
-- 003.6 Políticas — prestamo_equipos
-- ################################################################
DROP POLICY IF EXISTS "pe_select_all" ON prestamo_equipos;
CREATE POLICY "pe_select_all" ON prestamo_equipos
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "pe_insert_encargado" ON prestamo_equipos;
CREATE POLICY "pe_insert_encargado" ON prestamo_equipos
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

DROP POLICY IF EXISTS "pe_update_encargado" ON prestamo_equipos;
CREATE POLICY "pe_update_encargado" ON prestamo_equipos
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

DROP POLICY IF EXISTS "pe_delete_encargado" ON prestamo_equipos;
CREATE POLICY "pe_delete_encargado" ON prestamo_equipos
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

-- ################################################################
-- 003.7 Políticas — devoluciones
-- ################################################################
DROP POLICY IF EXISTS "devoluciones_select_all" ON devoluciones;
CREATE POLICY "devoluciones_select_all" ON devoluciones
  FOR SELECT TO authenticated
  USING (true);

-- INSERT: tanto encargados como practicantes pueden registrar devoluciones
DROP POLICY IF EXISTS "devoluciones_insert_all" ON devoluciones;
CREATE POLICY "devoluciones_insert_all" ON devoluciones
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND activo = true
    )
  );

DROP POLICY IF EXISTS "devoluciones_update_encargado" ON devoluciones;
CREATE POLICY "devoluciones_update_encargado" ON devoluciones
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

DROP POLICY IF EXISTS "devoluciones_delete_encargado" ON devoluciones;
CREATE POLICY "devoluciones_delete_encargado" ON devoluciones
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

-- ################################################################
-- 003.8 Políticas — devolucion_equipos
-- ################################################################
DROP POLICY IF EXISTS "de_select_all" ON devolucion_equipos;
CREATE POLICY "de_select_all" ON devolucion_equipos
  FOR SELECT TO authenticated
  USING (true);

-- INSERT: tanto encargados como practicantes
DROP POLICY IF EXISTS "de_insert_all" ON devolucion_equipos;
CREATE POLICY "de_insert_all" ON devolucion_equipos
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND activo = true
    )
  );

DROP POLICY IF EXISTS "de_update_encargado" ON devolucion_equipos;
CREATE POLICY "de_update_encargado" ON devolucion_equipos
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

DROP POLICY IF EXISTS "de_delete_encargado" ON devolucion_equipos;
CREATE POLICY "de_delete_encargado" ON devolucion_equipos
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

-- ################################################################
-- 003.9 Políticas — firmas_digitales
-- ################################################################
DROP POLICY IF EXISTS "firmas_select_all" ON firmas_digitales;
CREATE POLICY "firmas_select_all" ON firmas_digitales
  FOR SELECT TO authenticated
  USING (true);

-- INSERT: cualquier autenticado activo puede firmar
DROP POLICY IF EXISTS "firmas_insert_all" ON firmas_digitales;
CREATE POLICY "firmas_insert_all" ON firmas_digitales
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND activo = true
    )
  );

DROP POLICY IF EXISTS "firmas_update_encargado" ON firmas_digitales;
CREATE POLICY "firmas_update_encargado" ON firmas_digitales
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

DROP POLICY IF EXISTS "firmas_delete_encargado" ON firmas_digitales;
CREATE POLICY "firmas_delete_encargado" ON firmas_digitales
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

-- ################################################################
-- 003.10 Políticas — auditoria
-- ################################################################
-- Solo encargados pueden LEER auditoría
DROP POLICY IF EXISTS "auditoria_select_encargado" ON auditoria;
CREATE POLICY "auditoria_select_encargado" ON auditoria
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

-- Nadie puede escribir directamente en auditoría (solo triggers internos)
DROP POLICY IF EXISTS "auditoria_no_insert" ON auditoria;
CREATE POLICY "auditoria_no_insert" ON auditoria
  FOR INSERT TO authenticated
  WITH CHECK (false);

DROP POLICY IF EXISTS "auditoria_no_update" ON auditoria;
CREATE POLICY "auditoria_no_update" ON auditoria
  FOR UPDATE TO authenticated
  USING (false);

DROP POLICY IF EXISTS "auditoria_no_delete" ON auditoria;
CREATE POLICY "auditoria_no_delete" ON auditoria
  FOR DELETE TO authenticated
  USING (false);

-- ============================================================
-- FIN Migración 003
-- ============================================================
