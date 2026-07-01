-- ============================================================
-- Sincronizar rol de usuarios → auth.users.raw_user_meta_data
-- ============================================================
-- 1. Actualiza usuarios existentes que no tienen el rol en metadata
-- 2. Crea trigger para mantener sincronizado en adelante
-- ============================================================

-- 1. One-time update for existing users
UPDATE auth.users au
SET raw_user_meta_data = 
  COALESCE(raw_user_meta_data, '{}'::jsonb) || 
  jsonb_build_object('rol', u.rol::text)
FROM public.usuarios u
WHERE u.email = au.email
  AND (raw_user_meta_data->>'rol' IS NULL OR raw_user_meta_data->>'rol' != u.rol::text);

-- 2. Trigger function: sync usuarios.rol → auth.users.raw_user_meta_data
CREATE OR REPLACE FUNCTION public.sync_usuario_rol_to_auth()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE auth.users
  SET raw_user_meta_data = 
    COALESCE(raw_user_meta_data, '{}'::jsonb) || 
    jsonb_build_object('rol', NEW.rol::text)
  WHERE email = NEW.email;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Apply trigger on INSERT and UPDATE of usuarios.rol
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_sync_usuario_rol_to_auth') THEN
    CREATE TRIGGER trg_sync_usuario_rol_to_auth
      AFTER INSERT OR UPDATE OF rol ON public.usuarios
      FOR EACH ROW
      EXECUTE FUNCTION public.sync_usuario_rol_to_auth();
  END IF;
END $$;
