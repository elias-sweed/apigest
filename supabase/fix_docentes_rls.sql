-- ============================================================
-- FIX: Docentes RLS — Ejecutar en Supabase SQL Editor
-- ============================================================
-- Este script corrige el error 42501 al crear/editar docentes.
--
-- CAUSA RAÍZ: La política RLS verifica que auth.uid() exista en
-- la tabla 'usuarios' con rol específico. Si el usuario autenticado
-- NO tiene un registro en 'usuarios' que coincida con auth.uid(),
-- la inserción siempre será denegada.
-- ============================================================

-- ################################################################
-- PASO 0: DIAGNÓSTICO — Ejecuta esto primero para ver el estado actual
-- ################################################################
-- Muestra todas las políticas activas en docentes
SELECT '=== Políticas actuales en docentes ===' AS info;
SELECT policyname, cmd, permissive, roles, qual, with_check
FROM pg_policies
WHERE tablename = 'docentes';

-- Muestra el usuario autenticado actual y su registro en usuarios
SELECT '=== Usuario autenticado actual ===' AS info;
SELECT auth.uid() AS auth_user_id;

SELECT '=== Registro en tabla usuarios ===' AS info;
SELECT id, nombre_completo, email, rol, activo
FROM public.usuarios
WHERE id = auth.uid();

-- ################################################################
-- PASO 1: Eliminar TODAS las políticas existentes en docentes
-- (para evitar conflictos con políticas viejas)
-- ################################################################
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN
    SELECT policyname FROM pg_policies WHERE tablename = 'docentes'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON docentes', pol.policyname);
  END LOOP;
END $$;

-- ################################################################
-- PASO 2: Recrear políticas limpias
-- ################################################################

-- SELECT: todos los autenticados pueden leer
CREATE POLICY "docentes_select_all" ON docentes
  FOR SELECT TO authenticated
  USING (true);

-- INSERT: encargados y practicantes activos
CREATE POLICY "docentes_insert_all" ON docentes
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.usuarios
      WHERE id = auth.uid()
        AND rol IN ('encargado_aip', 'practicante')
        AND activo = true
    )
  );

-- UPDATE: encargados y practicantes activos
CREATE POLICY "docentes_update_all" ON docentes
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.usuarios
      WHERE id = auth.uid()
        AND rol IN ('encargado_aip', 'practicante')
        AND activo = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.usuarios
      WHERE id = auth.uid()
        AND rol IN ('encargado_aip', 'practicante')
        AND activo = true
    )
  );

-- DELETE: solo encargados
CREATE POLICY "docentes_delete_encargado" ON docentes
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

-- ################################################################
-- PASO 3: Asegurar que el trigger de auditoría NO bloquee operaciones
-- La función fn_auditar es SECURITY DEFINER, pero por si acaso,
-- verificamos que funcione correctamente.
-- ################################################################

-- Recrear fn_auditar con SECURITY DEFINER + SET search_path
-- Esto asegura que el trigger escriba en auditoria sin ser
-- bloqueado por las políticas RLS de auditoria.
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
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- ################################################################
-- PASO 4: Verificación final
-- ################################################################
SELECT '=== Políticas después de la corrección ===' AS info;
SELECT policyname, cmd, permissive, roles
FROM pg_policies
WHERE tablename = 'docentes'
ORDER BY cmd;

SELECT '=== LISTO ===' AS info;
SELECT 'Si el PASO 0 mostró que NO hay registro en usuarios para auth.uid(),'
       || ' debes crear uno con: INSERT INTO usuarios (id, nombre_completo, email, rol)'
       || ' VALUES (auth.uid(), ''Tu Nombre'', ''tu@email.com'', ''encargado_aip'');'
  AS instruccion_importante;
