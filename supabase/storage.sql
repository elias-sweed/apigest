-- ============================================================
-- AIP Gest — Storage: Bucket y políticas para firmas digitales
-- ============================================================
-- Ejecutar en: Supabase SQL Editor (después de migraciones)
-- También se puede crear desde Supabase Dashboard > Storage
-- ============================================================

-- ################################################################
-- STORAGE.001: Crear bucket 'firmas'
-- ################################################################
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'firmas',
  'firmas',
  false,                                            -- No público (solo autenticados)
  2097152,                                          -- 2 MB límite por archivo
  ARRAY['image/png', 'image/jpeg', 'image/webp']    -- Solo imágenes
)
ON CONFLICT (id) DO NOTHING;

-- ################################################################
-- STORAGE.002: Políticas del bucket 'firmas'
-- ################################################################

-- 002.1 SELECT: cualquier usuario autenticado activo puede leer firmas
DROP POLICY IF EXISTS "firmas_select_authenticated" ON storage.objects;
CREATE POLICY "firmas_select_authenticated" ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'firmas'
    AND EXISTS (
      SELECT 1 FROM public.usuarios
      WHERE id = auth.uid()
        AND activo = true
    )
  );

-- 002.2 INSERT (general) — solo encargados pueden subir en cualquier ruta
DROP POLICY IF EXISTS "firmas_insert_encargado" ON storage.objects;
CREATE POLICY "firmas_insert_encargado" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'firmas'
    AND EXISTS (
      SELECT 1 FROM public.usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

-- 002.3 INSERT (practicante) — solo en carpeta devoluciones/
DROP POLICY IF EXISTS "firmas_insert_practicante_devoluciones" ON storage.objects;
CREATE POLICY "firmas_insert_practicante_devoluciones" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'firmas'
    AND (storage.foldername(name))[1] = 'devoluciones'
    AND EXISTS (
      SELECT 1 FROM public.usuarios
      WHERE id = auth.uid()
        AND rol = 'practicante'
        AND activo = true
    )
  );

-- 002.4 UPDATE: solo encargados
DROP POLICY IF EXISTS "firmas_update_encargado" ON storage.objects;
CREATE POLICY "firmas_update_encargado" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'firmas'
    AND EXISTS (
      SELECT 1 FROM public.usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

-- 002.5 DELETE: solo encargados
DROP POLICY IF EXISTS "firmas_delete_encargado" ON storage.objects;
CREATE POLICY "firmas_delete_encargado" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'firmas'
    AND EXISTS (
      SELECT 1 FROM public.usuarios
      WHERE id = auth.uid()
        AND rol = 'encargado_aip'
        AND activo = true
    )
  );

-- ============================================================
-- FIN Storage
-- ============================================================
