USE ucu_salas;

-- FACULTADES
INSERT INTO facultad (nombre) VALUES
('Ingeniería'),
('Administración'),
('Derecho');

-- PROGRAMAS ACADÉMICOS
INSERT INTO programa_academico (nombre_programa, id_facultad, tipo) VALUES
('Ingeniería en Informática', 1, 'grado'),
('Ingeniería Industrial',      1, 'grado'),
('MBA',                        2, 'posgrado'),
('Contador Público',           2, 'grado'),
('Derecho Penal',              3, 'posgrado');

-- ALUMNOS
INSERT INTO alumno (ci, nombre, apellido, email) VALUES
('4.111.111-1', 'Juan', 'Pérez', 'juan@ucu.edu.uy'),
('4.222.222-2', 'María', 'Gómez', 'maria@ucu.edu.uy'),
('5.333.333-3', 'Pedro', 'López', 'pedro@ucu.edu.uy'),
('5.444.444-4', 'Lucía', 'Martínez', 'lucia@ucu.edu.uy'),
('7.666.666-6', 'Ana', 'Rodríguez', 'ana@ucu.edu.uy');

-- RELACIÓN ALUMNO–PROGRAMA
INSERT INTO alumno_programa_academico (ci_alumno, id_programa, rol) VALUES
('4.111.111-1', 1, 'alumno'),
('4.222.222-2', 1, 'alumno'),
('5.333.333-3', 3, 'alumno'),
('5.444.444-4', 4, 'alumno'),
('7.666.666-6', 5, 'alumno');

-- EDIFICIOS
INSERT INTO edificio (nombre_edificio, direccion, departamento) VALUES
('Edificio Central', 'Av. Principal 123', 'Montevideo'),
('Edificio Norte', 'Calle 456', 'Montevideo');

-- SALAS
INSERT INTO sala (nombre_sala, id_edificio, capacidad, tipo_sala) VALUES
('Sala 101', 1, 30, 'libre'),
('Sala 102', 1, 25, 'libre'),
('Sala PG 1', 1, 20, 'posgrado'),
('Sala DOC 1', 2, 15, 'docente'),
('Sala 201', 2, 35, 'libre');


/* ======================================================
   TURNOS AUTOMÁTICOS POR 7 DÍAS, INCLUYENDO FINES
   08:00 → 23:00 EN BLOQUES DE 1 HORA
   ====================================================== */

DELETE FROM turno;

SET @dias_hacia_adelante = 7;
SET @hora_inicio = 8;
SET @hora_fin = 23;

WITH RECURSIVE fechas AS (
    SELECT CURDATE() AS fecha
    UNION ALL
    SELECT fecha + INTERVAL 1 DAY
    FROM fechas
    WHERE fecha < CURDATE() + INTERVAL @dias_hacia_adelante DAY
),
horas AS (
    SELECT @hora_inicio AS h
    UNION ALL
    SELECT h + 1 FROM horas WHERE h < @hora_fin - 1
)
INSERT INTO turno (id_sala, fecha, hora_inicio, hora_fin, disponible)
SELECT 
    s.id_sala,
    f.fecha,
    MAKETIME(h.h,   0, 0),
    MAKETIME(h.h+1, 0, 0),
    1
FROM sala s
CROSS JOIN fechas f
CROSS JOIN horas h;




-- RESERVAS DE PRUEBA (día viejo original)
SET @fecha = '2025-11-25';

INSERT INTO reserva (id_sala, fecha, id_turno, estado, creado_por) VALUES
(1, @fecha, 1, 'activa', '4.111.111-1'),
(1, @fecha, 2, 'finalizada', '4.111.111-1'),
(2, @fecha, 3, 'finalizada', '4.222.222-2'),
(3, @fecha, 4, 'sin_asistencia', '5.333.333-3'),
(4, @fecha, 5, 'activa', '7.666.666-6'),
(5, @fecha, 6, 'cancelada', '5.444.444-4');

-- RESERVA_ALUMNO
INSERT INTO reserva_alumno (id_reserva, ci_alumno, asistencia) VALUES
(1, '4.111.111-1', 1),
(2, '4.111.111-1', 1),
(2, '4.222.222-2', 1),
(3, '4.222.222-2', 1),
(4, '5.333.333-3', 0),
(5, '7.666.666-6', 0),
(6, '5.444.444-4', 0);

-- SANCIONES
INSERT INTO sancion_alumno (ci_alumno, fecha_inicio, fecha_fin, motivo, id_reserva) VALUES
('5.333.333-3', '2025-11-20', '2026-01-20', 'Inasistencia', 4),
('7.666.666-6', '2025-11-21', '2026-01-21', 'Inasistencia', 5);
