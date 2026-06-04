-- ============================================================
-- AIP Gest — Migración 001: Schema inicial
-- ============================================================
-- Ejecutar en: Supabase SQL Editor > New Query
-- Diseñado para ejecución ÚNICA. Las constraints se envuelven
-- en DO blocks con EXCEPTION para permitir re-ejecución.
-- ============================================================

-- ################################################################
-- 001.1 Extensiones
-- ################################################################
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ################################################################
-- 001.2 ENUMs
-- ################################################################
DO $$ BEGIN
  CREATE TYPE usuario_rol AS ENUM ('encargado_aip', 'practicante');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE equipo_tipo AS ENUM ('laptop_dell', 'laptop_hp', 'cargador', 'extension', 'otro_accesorio');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE equipo_estado AS ENUM ('disponible', 'prestado', 'mantenimiento', 'dado_de_baja');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE prestamo_estado AS ENUM ('activo', 'parcial', 'devuelto');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ################################################################
-- 001.3 Tablas
-- ################################################################

-- 001.3.1 Usuarios del sistema
CREATE TABLE IF NOT EXISTS usuarios (
  id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre_completo VARCHAR(200)  NOT NULL,
  email           VARCHAR(255)  NOT NULL,
  rol             usuario_rol   NOT NULL,
  activo          BOOLEAN       NOT NULL DEFAULT true,
  created_at      TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- 001.3.2 Docentes (profesores — NO tienen usuario en el sistema)
CREATE TABLE IF NOT EXISTS docentes (
  id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre_completo VARCHAR(200)  NOT NULL,
  email           VARCHAR(255),
  telefono        VARCHAR(20),
  departamento    VARCHAR(100),
  activo          BOOLEAN       NOT NULL DEFAULT true,
  created_at      TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- 001.3.3 Equipos (inventario)
CREATE TABLE IF NOT EXISTS equipos (
  id                 UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo_patrimonial VARCHAR(50)   NOT NULL,
  tipo               equipo_tipo   NOT NULL,
  marca              VARCHAR(100),
  modelo             VARCHAR(100),
  numero_serie       VARCHAR(100),
  estado             equipo_estado NOT NULL DEFAULT 'disponible',
  observaciones      TEXT,
  imagen_url         VARCHAR(500),
  created_at         TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- 001.3.4 Préstamos
CREATE TABLE IF NOT EXISTS prestamos (
  id                      UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
  docente_id              UUID            NOT NULL,
  encargado_id            UUID            NOT NULL,
  fecha_hora_inicio       TIMESTAMPTZ     NOT NULL DEFAULT now(),
  fecha_hora_fin_estimada TIMESTAMPTZ,
  estado                  prestamo_estado NOT NULL DEFAULT 'activo',
  observaciones           TEXT,
  created_at              TIMESTAMPTZ     NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ     NOT NULL DEFAULT now()
);

-- 001.3.5 Prestamo-Equipos (tabla puente N:M con metadata individual)
CREATE TABLE IF NOT EXISTS prestamo_equipos (
  id                        UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  prestamo_id               UUID        NOT NULL,
  equipo_id                 UUID        NOT NULL,
  fecha_devolucion_real     TIMESTAMPTZ,
  observaciones_devolucion  TEXT
);

-- 001.3.6 Devoluciones (evento de devolución)
CREATE TABLE IF NOT EXISTS devoluciones (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  prestamo_id     UUID        NOT NULL,
  practicante_id  UUID        NOT NULL,
  fecha_hora      TIMESTAMPTZ NOT NULL DEFAULT now(),
  observaciones   TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 001.3.7 Devolucion-Equipos (tabla puente: qué ítems se devuelven en cada evento)
CREATE TABLE IF NOT EXISTS devolucion_equipos (
  id                  UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  devolucion_id       UUID    NOT NULL,
  prestamo_equipo_id  UUID    NOT NULL,
  observaciones       TEXT
);

-- 001.3.8 Firmas Digitales (metadata — archivos en Supabase Storage)
CREATE TABLE IF NOT EXISTS firmas_digitales (
  id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  prestamo_id     UUID,
  devolucion_id   UUID,
  usuario_id      UUID,
  rol             usuario_rol   NOT NULL,
  nombre_completo VARCHAR(200)  NOT NULL,
  storage_path    VARCHAR(500)  NOT NULL,
  mime_type       VARCHAR(50)   NOT NULL DEFAULT 'image/png',
  created_at      TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- 001.3.9 Auditoría (solo escritura vía triggers)
CREATE TABLE IF NOT EXISTS auditoria (
  id                UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  tabla_nombre      VARCHAR(100)  NOT NULL,
  registro_id       UUID          NOT NULL,
  accion            VARCHAR(10)   NOT NULL,
  usuario_id        UUID,
  datos_anteriores  JSONB,
  datos_nuevos      JSONB,
  created_at        TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- ################################################################
-- 001.4 Constraints faltantes (CHECK, UNIQUE, FK que requieren tablas existan)
-- ################################################################

-- --- UNIQUE ---
DO $$ BEGIN ALTER TABLE usuarios      ADD CONSTRAINT uq_usuarios_email      UNIQUE (email);           EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE docentes      ADD CONSTRAINT uq_docentes_email      UNIQUE (email);           EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE equipos       ADD CONSTRAINT uq_equipos_codigo      UNIQUE (codigo_patrimonial); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE prestamo_equipos ADD CONSTRAINT uq_prestamo_equipo  UNIQUE (prestamo_id, equipo_id); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE devolucion_equipos ADD CONSTRAINT uq_devolucion_equipo UNIQUE (devolucion_id, prestamo_equipo_id); EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- --- CHECK ---
DO $$ BEGIN
  ALTER TABLE auditoria ADD CONSTRAINT chk_auditoria_accion
    CHECK (accion IN ('INSERT', 'UPDATE', 'DELETE'));
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  ALTER TABLE firmas_digitales ADD CONSTRAINT chk_firma_contexto_exclusivo
    CHECK (
      (prestamo_id IS NOT NULL AND devolucion_id IS NULL)
      OR
      (prestamo_id IS NULL AND devolucion_id IS NOT NULL)
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- --- FOREIGN KEYS ---
DO $$ BEGIN ALTER TABLE prestamos          ADD CONSTRAINT fk_prestamos_docente    FOREIGN KEY (docente_id)    REFERENCES docentes(id)   ON DELETE RESTRICT; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE prestamos          ADD CONSTRAINT fk_prestamos_encargado FOREIGN KEY (encargado_id)  REFERENCES usuarios(id)  ON DELETE RESTRICT; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE prestamo_equipos   ADD CONSTRAINT fk_pe_prestamo         FOREIGN KEY (prestamo_id)   REFERENCES prestamos(id) ON DELETE CASCADE; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE prestamo_equipos   ADD CONSTRAINT fk_pe_equipo           FOREIGN KEY (equipo_id)     REFERENCES equipos(id)   ON DELETE RESTRICT; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE devoluciones       ADD CONSTRAINT fk_devoluciones_prestamo    FOREIGN KEY (prestamo_id)    REFERENCES prestamos(id) ON DELETE RESTRICT; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE devoluciones       ADD CONSTRAINT fk_devoluciones_practicante FOREIGN KEY (practicante_id) REFERENCES usuarios(id) ON DELETE RESTRICT; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE devolucion_equipos ADD CONSTRAINT fk_de_prestamo_equipo  FOREIGN KEY (prestamo_equipo_id) REFERENCES prestamo_equipos(id) ON DELETE RESTRICT; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE devolucion_equipos ADD CONSTRAINT fk_de_devolucion       FOREIGN KEY (devolucion_id)      REFERENCES devoluciones(id)     ON DELETE CASCADE; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE firmas_digitales   ADD CONSTRAINT fk_firmas_prestamo     FOREIGN KEY (prestamo_id)   REFERENCES prestamos(id)   ON DELETE RESTRICT; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE firmas_digitales   ADD CONSTRAINT fk_firmas_devolucion   FOREIGN KEY (devolucion_id) REFERENCES devoluciones(id) ON DELETE RESTRICT; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE firmas_digitales   ADD CONSTRAINT fk_firmas_usuario      FOREIGN KEY (usuario_id)    REFERENCES usuarios(id)    ON DELETE SET NULL; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN ALTER TABLE auditoria          ADD CONSTRAINT fk_auditoria_usuario   FOREIGN KEY (usuario_id)    REFERENCES usuarios(id)    ON DELETE SET NULL; EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ################################################################
-- 001.5 Índices
-- ################################################################

-- Docentes
CREATE INDEX IF NOT EXISTS idx_docentes_nombre
  ON docentes USING gin(to_tsvector('spanish', nombre_completo));
CREATE INDEX IF NOT EXISTS idx_docentes_activo
  ON docentes(activo) WHERE activo = true;

-- Equipos
CREATE INDEX IF NOT EXISTS idx_equipos_estado    ON equipos(estado);
CREATE INDEX IF NOT EXISTS idx_equipos_tipo      ON equipos(tipo);
CREATE INDEX IF NOT EXISTS idx_equipos_disponibles
  ON equipos(estado) WHERE estado = 'disponible';

-- Préstamos
CREATE INDEX IF NOT EXISTS idx_prestamos_estado    ON prestamos(estado);
CREATE INDEX IF NOT EXISTS idx_prestamos_docente   ON prestamos(docente_id);
CREATE INDEX IF NOT EXISTS idx_prestamos_encargado ON prestamos(encargado_id);
CREATE INDEX IF NOT EXISTS idx_prestamos_fecha
  ON prestamos(fecha_hora_inicio DESC);
CREATE INDEX IF NOT EXISTS idx_prestamos_activos
  ON prestamos(estado) WHERE estado IN ('activo', 'parcial');

-- Prestamo-Equipos
CREATE INDEX IF NOT EXISTS idx_pe_prestamo   ON prestamo_equipos(prestamo_id);
CREATE INDEX IF NOT EXISTS idx_pe_equipo     ON prestamo_equipos(equipo_id);
CREATE INDEX IF NOT EXISTS idx_pe_pendientes
  ON prestamo_equipos(prestamo_id) WHERE fecha_devolucion_real IS NULL;

-- Devoluciones
CREATE INDEX IF NOT EXISTS idx_devoluciones_prestamo ON devoluciones(prestamo_id);
CREATE INDEX IF NOT EXISTS idx_devoluciones_fecha    ON devoluciones(fecha_hora DESC);

-- Firmas
CREATE INDEX IF NOT EXISTS idx_firmas_prestamo   ON firmas_digitales(prestamo_id);
CREATE INDEX IF NOT EXISTS idx_firmas_devolucion ON firmas_digitales(devolucion_id);

-- Auditoría
CREATE INDEX IF NOT EXISTS idx_auditoria_tabla     ON auditoria(tabla_nombre, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_auditoria_registro  ON auditoria(registro_id);

-- ################################################################
-- 001.6 Índice de integridad: evitar doble préstamo del mismo equipo
-- ################################################################
-- Garantiza que un equipo no esté en dos préstamos activos simultáneamente.
-- Previene race conditions que los triggers no pueden cubrir solos.
CREATE UNIQUE INDEX IF NOT EXISTS uq_equipo_prestamo_activo
  ON prestamo_equipos(equipo_id) WHERE fecha_devolucion_real IS NULL;

-- ============================================================
-- FIN Migración 001
-- ============================================================
