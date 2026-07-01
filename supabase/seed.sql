-- ============================================================
-- AIP Gest — Seed: Datos de prueba realistas
-- ============================================================
-- Ejecutar DESPUÉS de 003_rls_policies.sql y storage.sql
-- En Supabase SQL Editor se ejecuta como service_role (bypass RLS)
-- ============================================================

-- ################################################################
-- SEED.001: Usuarios del sistema
-- ################################################################
INSERT INTO usuarios (id, nombre_completo, email, rol, activo) VALUES
  ('a1000000-0000-4000-8000-000000000001', 'Carlos Mendoza López',    'carlos.mendoza@iep.edu.pe', 'encargado_aip', true),
  ('a1000000-0000-4000-8000-000000000002', 'María Fernanda Ríos',     'maria.rios@iep.edu.pe',     'practicante',   true),
  ('a1000000-0000-4000-8000-000000000003', 'José Antonio Huamán',     'jose.huaman@iep.edu.pe',    'practicante',   true),
  ('a1000000-0000-4000-8000-000000000004', 'Elena Patricia Vargas',   'elena.vargas@iep.edu.pe',   'encargado_aip', false)
ON CONFLICT (id) DO NOTHING;

-- ################################################################
-- SEED.002: Docentes
-- ################################################################

-- 1° Grado — Tarde
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000001', 'COHEN TRIGOZO, Carito',       '{"grado":"1°","seccion":"A","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000002', 'GARCÍA GARCÍA, Dorcas',       '{"grado":"1°","seccion":"B","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000003', 'ISUIZA RUIZ, Delcy',          '{"grado":"1°","seccion":"C","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000004', 'CARDENAS VALLES, Marisol',    '{"grado":"1°","seccion":"D","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000005', 'GARCIA GALAN, Geyner',        '{"grado":"1°","seccion":"E","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000006', 'INUMA GONZALES, Carmen',      '{"grado":"1°","seccion":"F","turno":"Tarde"}', true)
ON CONFLICT (id) DO NOTHING;

-- 2° Grado — Mañana
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000007', 'CABRERA ARÉVALO, Anita',             '{"grado":"2°","seccion":"A","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000008', 'REATEGUI TELLO, Enith',              '{"grado":"2°","seccion":"B","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000009', 'SHUPINGAHUA MESIA, Sonia I.',        '{"grado":"2°","seccion":"C","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000010', 'REYNA PINEDO, Giovani',              '{"grado":"2°","seccion":"D","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000011', 'PONCE REYNA, Aurora del Carmen',     '{"grado":"2°","seccion":"E","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000012', 'GUIVIN PINEDO DE PAREDES, Nanci',    '{"grado":"2°","seccion":"F","turno":"Mañana"}', true)
ON CONFLICT (id) DO NOTHING;

-- 3° Grado — Tarde
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000013', 'RENGIFO RAMOS, María Janet',       '{"grado":"3°","seccion":"A","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000014', 'PAREDES ARÉVALO, Zonia',           '{"grado":"3°","seccion":"B","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000015', 'FLORES SALDAÑA, Sonia',            '{"grado":"3°","seccion":"C","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000016', 'CHAVEZ FERNANDEZ, Marina Liceth',  '{"grado":"3°","seccion":"D","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000017', 'ARÉVALO GARCÍA, Elvia',            '{"grado":"3°","seccion":"E","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000018', 'RAMÍREZ TORRES, David M.',         '{"grado":"3°","seccion":"F","turno":"Tarde"}', true)
ON CONFLICT (id) DO NOTHING;

-- 4° Grado — Mañana
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000019', 'DEL AGUILA PAREDES, Kika',         '{"grado":"4°","seccion":"A","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000020', 'GARCÍA FLORES, Manuel de los',     '{"grado":"4°","seccion":"B","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000021', 'ORDOÑEZ BALDERA, Denis Marilú',    '{"grado":"4°","seccion":"C","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000022', 'SHAPIAMA VÁSQUEZ, Rister',         '{"grado":"4°","seccion":"D","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000023', 'RODRÍGUEZ LÓPEZ, Felipa de J',     '{"grado":"4°","seccion":"E","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000024', 'ALCANTARA VASQUEZ, Juana R',       '{"grado":"4°","seccion":"F","turno":"Mañana"}', true)
ON CONFLICT (id) DO NOTHING;

-- 5° Grado — Tarde
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000025', 'GARCIA GALÁN, Genan',              '{"grado":"5°","seccion":"A","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000026', 'GONZALEZ RAMAL, Cesar Gustavo',    '{"grado":"5°","seccion":"B","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000027', 'CEOPA BOCANEGRA, Carlos A',        '{"grado":"5°","seccion":"C","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000028', 'ARÉVALO FLORES, Lorena',           '{"grado":"5°","seccion":"D","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000029', 'PÉREZ REATEGUI, Bertha O.',        '{"grado":"5°","seccion":"E","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000030', 'LÓPEZ CHUJUTALLI, Marcial',        '{"grado":"5°","seccion":"F","turno":"Tarde"}', true)
ON CONFLICT (id) DO NOTHING;

-- 6° Grado — Mañana
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000031', 'RIVADENEIRA RÍOS, Arquímedes',     '{"grado":"6°","seccion":"A","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000032', 'LINARES ACOSTA, Maritza',          '{"grado":"6°","seccion":"B","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000033', 'RODRIGUEZ VALDERRAMA, J',          '{"grado":"6°","seccion":"C","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000034', 'TORRES FLORES, Yboni',             '{"grado":"6°","seccion":"D","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000035', 'QUINTEROS GARCIA, Roberth',        '{"grado":"6°","seccion":"E","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000036', 'AREVALO CORDOVA, Mariluz',         '{"grado":"6°","seccion":"F","turno":"Mañana"}', true)
ON CONFLICT (id) DO NOTHING;

-- AIP (Aula de Innovación Pedagógica)
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000037', 'VELA VASQUEZ, Manuel Antonio',     '{"grado":"AIP","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000038', 'VILLACORTA PANDURO, Edward T.',    '{"grado":"AIP","turno":"Tarde"}', true)
ON CONFLICT (id) DO NOTHING;

-- E.F (Educación Física)
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000039', 'GATICA RODRIGUEZ, Alicia',         '{"grado":"E.F","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000040', 'SÁNCHEZ ROMERO, Erlin',            '{"grado":"E.F","turno":"Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000041', 'GONGORA VASQUEZ, Anthony',         '{"grado":"E.F","turno":"Mañana y Tarde"}', true),
  ('b2000000-0000-4000-8000-000000000042', 'ARMAS PEREZ, Carina',              '{"grado":"E.F","turno":"Tarde"}', true)
ON CONFLICT (id) DO NOTHING;

-- SEC (Secretaría)
INSERT INTO docentes (id, nombre_completo, departamento, activo) VALUES
  ('b2000000-0000-4000-8000-000000000043', 'REATEGUI ISLA, Jessica Leonor',    '{"grado":"SEC","turno":"Mañana"}', true),
  ('b2000000-0000-4000-8000-000000000044', 'ARBILDO RUIZ, Zonia',              '{"grado":"SEC","turno":"Mañana"}', true)
ON CONFLICT (id) DO NOTHING;

-- ################################################################
-- SEED.003: Equipos
-- Todos se insertan como 'disponible'.
-- Los triggers los pasarán a 'prestado' cuando se inserten en
-- prestamo_equipos. Algunos se actualizarán manualmente a
-- 'mantenimiento' y 'dado_de_baja'.
-- ################################################################
INSERT INTO equipos (id, codigo_patrimonial, tipo, marca, modelo, numero_serie, estado, observaciones) VALUES
  -- Laptops Dell
  ('c3000000-0000-4000-8000-000000000001', 'AIP-LDELL-001', 'laptop_dell', 'Dell',       'Latitude 3420',  'SN-DELL-001', 'disponible',   NULL),
  ('c3000000-0000-4000-8000-000000000002', 'AIP-LDELL-002', 'laptop_dell', 'Dell',       'Latitude 3420',  'SN-DELL-002', 'disponible',   NULL),
  ('c3000000-0000-4000-8000-000000000003', 'AIP-LDELL-003', 'laptop_dell', 'Dell',       'Latitude 5430',  'SN-DELL-003', 'disponible',   'Teclado con desgaste — funciona correctamente'),
  -- Laptops HP
  ('c3000000-0000-4000-8000-000000000004', 'AIP-LHP-001',   'laptop_hp',   'HP',         'ProBook 450 G9', 'SN-HP-001',   'disponible',   NULL),
  ('c3000000-0000-4000-8000-000000000005', 'AIP-LHP-002',   'laptop_hp',   'HP',         'ProBook 450 G9', 'SN-HP-002',   'disponible',   NULL),
  ('c3000000-0000-4000-8000-000000000006', 'AIP-LHP-003',   'laptop_hp',   'HP',         'Pavilion x360',  'SN-HP-003',   'disponible',   'Pantalla con leve rayón'),
  -- Cargadores
  ('c3000000-0000-4000-8000-000000000007', 'AIP-CARG-001',  'cargador',    'Dell',       '65W USB-C',       'SN-CARG-001', 'disponible',   'Cargador para Latitude'),
  ('c3000000-0000-4000-8000-000000000008', 'AIP-CARG-002',  'cargador',    'HP',         '65W USB-C',       'SN-CARG-002', 'disponible',   'Cargador para ProBook'),
  -- Extensiones
  ('c3000000-0000-4000-8000-000000000009', 'AIP-EXT-001',   'extension',   'Koblenz',    'REG-6T',          NULL,          'disponible',   'Regleta 6 tomas + 2 USB'),
  ('c3000000-0000-4000-8000-000000000010', 'AIP-EXT-002',   'extension',   'Koblenz',    'REG-4T',          NULL,          'disponible',   'Regleta 4 tomas'),
  -- Otros accesorios
  ('c3000000-0000-4000-8000-000000000011', 'AIP-OTRO-001',  'otro_accesorio', 'Logitech', 'C920 HD Pro',    'SN-WEBCAM-01', 'disponible',  'Cámara web para videoconferencias'),
  ('c3000000-0000-4000-8000-000000000012', 'AIP-OTRO-002',  'otro_accesorio', 'Epson',     'EB-X51',         'SN-PROY-001',  'disponible',  'Proyector multimedia — incluye cable HDMI')
ON CONFLICT (id) DO NOTHING;

-- ################################################################
-- SEED.004: Préstamos
-- Préstamo 1: activo — Lucía Fernández recibió laptop HP + cargador + extensión
-- Préstamo 2: activo — Ricardo Gutiérrez recibió laptop Dell
-- Préstamo 3: completado (devuelto) — Hugo Sánchez recibió laptop HP + extensión
-- ################################################################
INSERT INTO prestamos (id, docente_id, encargado_id, fecha_hora_inicio, fecha_hora_fin_estimada, estado, observaciones) VALUES
  ('d4000000-0000-4000-8000-000000000001',
   'b2000000-0000-4000-8000-000000000002',   -- GARCÍA GARCÍA, Dorcas
   'a1000000-0000-4000-8000-000000000001',   -- Carlos Mendoza
   '2026-05-28 09:15:00-05', '2026-05-28 16:00:00-05',
   'activo', '1° "B" — Lectura y escritura con herramientas digitales'),
  ('d4000000-0000-4000-8000-000000000002',
   'b2000000-0000-4000-8000-000000000001',   -- COHEN TRIGOZO, Carito
   'a1000000-0000-4000-8000-000000000001',   -- Carlos Mendoza
   '2026-05-29 08:00:00-05', '2026-05-29 12:00:00-05',
   'activo', '1° "A" — Uso de GeoGebra y proyector'),
  ('d4000000-0000-4000-8000-000000000003',
   'b2000000-0000-4000-8000-000000000003',   -- ISUIZA RUIZ, Delcy
   'a1000000-0000-4000-8000-000000000001',   -- Carlos Mendoza
   '2026-05-26 10:00:00-05', '2026-05-26 15:00:00-05',
   'devuelto', '1° "C" — Presentación interactiva con estudiantes')
ON CONFLICT (id) DO NOTHING;

-- ################################################################
-- SEED.005: Prestamo-Equipos (detalle de cada ítem prestado)
-- Al insertar, el trigger fn_prestamo_equipo_insert cambia
-- equipo.estado a 'prestado' automáticamente (solo si
-- fecha_devolucion_real IS NULL).
-- ################################################################
INSERT INTO prestamo_equipos (id, prestamo_id, equipo_id, fecha_devolucion_real, observaciones_devolucion) VALUES
  -- Préstamo 1: Laptop HP + Cargador HP + Extensión (AÚN NO DEVUELTOS)
  ('e5000000-0000-4000-8000-000000000001',
   'd4000000-0000-4000-8000-000000000001',
   'c3000000-0000-4000-8000-000000000005',   -- HP ProBook 450 G9
   NULL, NULL),
  ('e5000000-0000-4000-8000-000000000002',
   'd4000000-0000-4000-8000-000000000001',
   'c3000000-0000-4000-8000-000000000008',   -- Cargador HP
   NULL, NULL),
  ('e5000000-0000-4000-8000-000000000003',
   'd4000000-0000-4000-8000-000000000001',
   'c3000000-0000-4000-8000-000000000009',   -- Extensión REG-6T
   NULL, NULL),
  -- Préstamo 2: Laptop Dell + Cargador Dell (AÚN NO DEVUELTOS)
  ('e5000000-0000-4000-8000-000000000004',
   'd4000000-0000-4000-8000-000000000002',
   'c3000000-0000-4000-8000-000000000002',   -- Dell Latitude 3420
   NULL, NULL),
  ('e5000000-0000-4000-8000-000000000005',
   'd4000000-0000-4000-8000-000000000002',
   'c3000000-0000-4000-8000-000000000007',   -- Cargador Dell
   NULL, NULL),
  -- Préstamo 3: Laptop HP + Extensión (YA DEVUELTOS)
  ('e5000000-0000-4000-8000-000000000006',
   'd4000000-0000-4000-8000-000000000003',
   'c3000000-0000-4000-8000-000000000006',   -- HP Pavilion x360
   '2026-05-26 14:45:00-05', 'Equipo devuelto en buen estado'),
  ('e5000000-0000-4000-8000-000000000007',
   'd4000000-0000-4000-8000-000000000003',
   'c3000000-0000-4000-8000-000000000010',   -- Extensión REG-4T
   '2026-05-26 14:45:00-05', 'Devuelto sin observaciones')
ON CONFLICT (id) DO NOTHING;

-- ################################################################
-- SEED.006: Actualizar estados manuales
-- Equipos que NO están en préstamo y deben tener otro estado
-- ################################################################
UPDATE equipos SET estado = 'mantenimiento',
  observaciones = 'Mantenimiento preventivo: limpieza de ventilador y cambio de pasta térmica'
WHERE id = 'c3000000-0000-4000-8000-000000000003';   -- Dell Latitude 5430

UPDATE equipos SET estado = 'dado_de_baja',
  observaciones = 'Pantalla rota sin repuesto disponible. Dado de baja el 15/05/2026.'
WHERE id = 'c3000000-0000-4000-8000-000000000006';   -- HP Pavilion x360
-- NOTA: este equipo se marcó como dado_de_baja DESPUÉS de ser devuelto del préstamo 3.
-- El trigger fn_prestamo_equipo_devolver ya lo había puesto en 'disponible'.
-- Ahora se actualiza manualmente a 'dado_de_baja'.

-- ################################################################
-- SEED.007: Devoluciones (solo para el préstamo completado)
-- ################################################################
INSERT INTO devoluciones (id, prestamo_id, practicante_id, fecha_hora, observaciones) VALUES
  ('f6000000-0000-4000-8000-000000000001',
   'd4000000-0000-4000-8000-000000000003',   -- Préstamo 3
   'a1000000-0000-4000-8000-000000000002',   -- María Fernanda Ríos (practicante)
   '2026-05-26 14:50:00-05', 'Devolución total: laptop y extensión en buen estado.')
ON CONFLICT (id) DO NOTHING;

INSERT INTO devolucion_equipos (id, devolucion_id, prestamo_equipo_id, observaciones) VALUES
  ('a7000000-0000-4000-8000-000000000001',
   'f6000000-0000-4000-8000-000000000001',
   'e5000000-0000-4000-8000-000000000006',   -- HP Pavilion x360
   'Laptop funciona correctamente. Se notó leve desgaste en bisagras.'),
  ('a7000000-0000-4000-8000-000000000002',
   'f6000000-0000-4000-8000-000000000001',
   'e5000000-0000-4000-8000-000000000007',   -- Extensión REG-4T
   'Sin observaciones.')
ON CONFLICT (id) DO NOTHING;

-- ################################################################
-- SEED.008: Firmas Digitales (metadata — archivos en Storage)
-- Las rutas storage_path apuntan al bucket 'firmas'.
-- Los archivos PNG se subirán desde la app Flutter.
-- ################################################################
INSERT INTO firmas_digitales (id, prestamo_id, devolucion_id, usuario_id, rol, nombre_completo, storage_path) VALUES
  -- Firma 1: Encargado firma al entregar préstamo 1
  ('a8000000-0000-4000-8000-000000000001',
   'd4000000-0000-4000-8000-000000000001', NULL,
   'a1000000-0000-4000-8000-000000000001',
   'encargado_aip', 'Carlos Mendoza López',
   'firmas/prestamos/d4000000-0000-4000-8000-000000000001/encargado_1716916500.png'),
  -- Firma 2: Docente firma al recibir préstamo 1
  ('a8000000-0000-4000-8000-000000000002',
   'd4000000-0000-4000-8000-000000000001', NULL,
   NULL,
   'encargado_aip', 'GARCÍA GARCÍA, Dorcas',
   'firmas/prestamos/d4000000-0000-4000-8000-000000000001/docente_1716916500.png'),
  -- Firma 3: Encargado firma al entregar préstamo 2
  ('a8000000-0000-4000-8000-000000000003',
   'd4000000-0000-4000-8000-000000000002', NULL,
   'a1000000-0000-4000-8000-000000000001',
   'encargado_aip', 'Carlos Mendoza López',
   'firmas/prestamos/d4000000-0000-4000-8000-000000000002/encargado_1717002900.png'),
  -- Firma 4: Docente firma al recibir préstamo 2
  ('a8000000-0000-4000-8000-000000000004',
   'd4000000-0000-4000-8000-000000000002', NULL,
   NULL,
   'encargado_aip', 'COHEN TRIGOZO, Carito',
   'firmas/prestamos/d4000000-0000-4000-8000-000000000002/docente_1717002900.png'),
  -- Firma 5: Practicante firma al recibir devolución del préstamo 3
  ('a8000000-0000-4000-8000-000000000005',
   NULL, 'f6000000-0000-4000-8000-000000000001',
   'a1000000-0000-4000-8000-000000000002',
   'practicante', 'María Fernanda Ríos',
   'firmas/devoluciones/f6000000-0000-4000-8000-000000000001/practicante_1716839400.png'),
  -- Firma 6: Docente firma al devolver préstamo 3
  ('a8000000-0000-4000-8000-000000000006',
   NULL, 'f6000000-0000-4000-8000-000000000001',
   NULL,
   'encargado_aip', 'ISUIZA RUIZ, Delcy',
   'firmas/devoluciones/f6000000-0000-4000-8000-000000000001/docente_1716839400.png')
ON CONFLICT (id) DO NOTHING;

-- ################################################################
-- SEED.009: Verificación de consistencia
-- ################################################################
-- Mostrar resumen de datos insertados
SELECT 'Seed ejecutado correctamente' AS mensaje;

SELECT 'usuarios' AS tabla, COUNT(*) AS registros FROM usuarios
UNION ALL
SELECT 'docentes', COUNT(*) FROM docentes
UNION ALL
SELECT 'equipos', COUNT(*) FROM equipos
UNION ALL
SELECT 'prestamos', COUNT(*) FROM prestamos
UNION ALL
SELECT 'prestamo_equipos', COUNT(*) FROM prestamo_equipos
UNION ALL
SELECT 'devoluciones', COUNT(*) FROM devoluciones
UNION ALL
SELECT 'devolucion_equipos', COUNT(*) FROM devolucion_equipos
UNION ALL
SELECT 'firmas_digitales', COUNT(*) FROM firmas_digitales
ORDER BY tabla;

SELECT 'Estados de equipos:' AS mensaje;
SELECT estado, COUNT(*) AS cantidad FROM equipos GROUP BY estado ORDER BY estado;

SELECT 'Estados de préstamos:' AS mensaje;
SELECT estado, COUNT(*) AS cantidad FROM prestamos GROUP BY estado ORDER BY estado;

-- ============================================================
-- FIN Seed
-- ============================================================
