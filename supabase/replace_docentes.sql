-- ============================================================
-- Reemplazar todos los docentes con la lista oficial 2026
-- ============================================================
-- Ejecutar en: Supabase SQL Editor (como service_role)
-- 1. Elimina registros dependientes (préstamos, etc.)
-- 2. Elimina todos los docentes existentes
-- 3. Inserta los 44 docentes nuevos
-- ============================================================

BEGIN;

-- ################################################################
-- 1. Eliminar registros que dependen de docentes (FK restrict)
-- Orden inverso de dependencias
-- ################################################################
DELETE FROM firmas_digitales;
DELETE FROM devolucion_equipos;
DELETE FROM devoluciones;
DELETE FROM prestamo_equipos;
DELETE FROM prestamos;
DELETE FROM docentes;

-- ################################################################
-- 2. Insertar nuevos docentes
-- ################################################################

-- 1° Grado — Tarde
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000001', 'COHEN TRIGOZO, Carito',       '{"grado":"1°","seccion":"A","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000002', 'GARCÍA GARCÍA, Dorcas',       '{"grado":"1°","seccion":"B","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000003', 'ISUIZA RUIZ, Delcy',          '{"grado":"1°","seccion":"C","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000004', 'CARDENAS VALLES, Marisol',    '{"grado":"1°","seccion":"D","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000005', 'GARCIA GALAN, Geyner',        '{"grado":"1°","seccion":"E","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000006', 'INUMA GONZALES, Carmen',      '{"grado":"1°","seccion":"F","turno":"Tarde"}', true);

-- 2° Grado — Mañana
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000007', 'CABRERA ARÉVALO, Anita',             '{"grado":"2°","seccion":"A","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000008', 'REATEGUI TELLO, Enith',              '{"grado":"2°","seccion":"B","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000009', 'SHUPINGAHUA MESIA, Sonia I.',        '{"grado":"2°","seccion":"C","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000010', 'REYNA PINEDO, Giovani',              '{"grado":"2°","seccion":"D","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000011', 'PONCE REYNA, Aurora del Carmen',     '{"grado":"2°","seccion":"E","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000012', 'GUIVIN PINEDO DE PAREDES, Nanci',    '{"grado":"2°","seccion":"F","turno":"Mañana"}', true);

-- 3° Grado — Tarde
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000013', 'RENGIFO RAMOS, María Janet',       '{"grado":"3°","seccion":"A","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000014', 'PAREDES ARÉVALO, Zonia',           '{"grado":"3°","seccion":"B","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000015', 'FLORES SALDAÑA, Sonia',            '{"grado":"3°","seccion":"C","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000016', 'CHAVEZ FERNANDEZ, Marina Liceth',  '{"grado":"3°","seccion":"D","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000017', 'ARÉVALO GARCÍA, Elvia',            '{"grado":"3°","seccion":"E","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000018', 'RAMÍREZ TORRES, David M.',         '{"grado":"3°","seccion":"F","turno":"Tarde"}', true);

-- 4° Grado — Mañana
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000019', 'DEL AGUILA PAREDES, Kika',         '{"grado":"4°","seccion":"A","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000020', 'GARCÍA FLORES, Manuel de los',     '{"grado":"4°","seccion":"B","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000021', 'ORDOÑEZ BALDERA, Denis Marilú',    '{"grado":"4°","seccion":"C","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000022', 'SHAPIAMA VÁSQUEZ, Rister',         '{"grado":"4°","seccion":"D","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000023', 'RODRÍGUEZ LÓPEZ, Felipa de J',     '{"grado":"4°","seccion":"E","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000024', 'ALCANTARA VASQUEZ, Juana R',       '{"grado":"4°","seccion":"F","turno":"Mañana"}', true);

-- 5° Grado — Tarde
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000025', 'GARCIA GALÁN, Genan',              '{"grado":"5°","seccion":"A","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000026', 'GONZALEZ RAMAL, Cesar Gustavo',    '{"grado":"5°","seccion":"B","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000027', 'CEOPA BOCANEGRA, Carlos A',        '{"grado":"5°","seccion":"C","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000028', 'ARÉVALO FLORES, Lorena',           '{"grado":"5°","seccion":"D","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000029', 'PÉREZ REATEGUI, Bertha O.',        '{"grado":"5°","seccion":"E","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000030', 'LÓPEZ CHUJUTALLI, Marcial',        '{"grado":"5°","seccion":"F","turno":"Tarde"}', true);

-- 6° Grado — Mañana
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000031', 'RIVADENEIRA RÍOS, Arquímedes',     '{"grado":"6°","seccion":"A","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000032', 'LINARES ACOSTA, Maritza',          '{"grado":"6°","seccion":"B","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000033', 'RODRIGUEZ VALDERRAMA, J',          '{"grado":"6°","seccion":"C","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000034', 'TORRES FLORES, Yboni',             '{"grado":"6°","seccion":"D","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000035', 'QUINTEROS GARCIA, Roberth',        '{"grado":"6°","seccion":"E","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000036', 'AREVALO CORDOVA, Mariluz',         '{"grado":"6°","seccion":"F","turno":"Mañana"}', true);

-- AIP (Aula de Innovación Pedagógica)
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000037', 'VELA VASQUEZ, Manuel Antonio',     '{"grado":"AIP","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000038', 'VILLACORTA PANDURO, Edward T.',    '{"grado":"AIP","turno":"Tarde"}', true);

-- E.F (Educación Física)
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000039', 'GATICA RODRIGUEZ, Alicia',         '{"grado":"E.F","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000040', 'SÁNCHEZ ROMERO, Erlin',            '{"grado":"E.F","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000041', 'GONGORA VASQUEZ, Anthony',         '{"grado":"E.F","turno":"Mañana y Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000042', 'ARMAS PEREZ, Carina',              '{"grado":"E.F","turno":"Tarde"}', true);

-- SEC (Secretaría)
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000043', 'REATEGUI ISLA, Jessica Leonor',    '{"grado":"SEC","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000044', 'ARBILDO RUIZ, Zonia',              '{"grado":"SEC","turno":"Mañana"}', true);

-- ################################################################
-- 3. Verificación
-- ################################################################
SELECT COUNT(*) AS total_docentes FROM docentes;

COMMIT;
