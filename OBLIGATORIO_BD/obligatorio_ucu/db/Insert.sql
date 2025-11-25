USE ucu_salas;

-- ==========================================
-- LIMPIEZA COMPLETA (RESETEA AUTO_INCREMENT)
-- ==========================================
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE sancion_alumno;
TRUNCATE TABLE reserva_alumno;
TRUNCATE TABLE reserva;
TRUNCATE TABLE turno;
TRUNCATE TABLE sala;
TRUNCATE TABLE edificio;
TRUNCATE TABLE alumno_programa_academico;
TRUNCATE TABLE programa_academico;
TRUNCATE TABLE facultad;
TRUNCATE TABLE login;
TRUNCATE TABLE alumno;

SET FOREIGN_KEY_CHECKS = 1;

-- ALUMNOS (6 personas: 5 estudiantes + 1 docente)
INSERT INTO alumno (ci, nombre, apellido, email) VALUES
('4.111.111-1', 'Juan',   'Pérez',     'juan@ucu.edu.uy'),
('4.222.222-2', 'María',  'Gómez',     'maria@ucu.edu.uy'),
('5.333.333-3', 'Pedro',  'López',     'pedro@ucu.edu.uy'),
('5.444.444-4', 'Lucía',  'Martínez',  'lucia@ucu.edu.uy'),
('7.666.666-6', 'Ana',    'Rodríguez', 'ana@ucu.edu.uy'),
('9.999.999-9', 'Carlos', 'Docente',   'prof@ucu.edu.uy');   -- DOCENTE

-- LOGIN
INSERT INTO login (correo, contrasena, ci_alumno) VALUES
('juan@ucu.edu.uy','123','4.111.111-1'),
('maria@ucu.edu.uy','123','4.222.222-2'),
('pedro@ucu.edu.uy','123','5.333.333-3'),
('lucia@ucu.edu.uy','123','5.444.444-4'),
('ana@ucu.edu.uy','123','7.666.666-6'),
('prof@ucu.edu.uy','123','9.999.999-9');

-- FACULTADES
INSERT INTO facultad (nombre) VALUES
('Ingeniería'),
('Administración'),
('Derecho');

-- PROGRAMAS ACADÉMICOS
INSERT INTO programa_academico (nombre_programa, id_facultad, tipo) VALUES
('Ingeniería en Informática', 1, 'grado'),
('MBA',                        2, 'posgrado'),
('Derecho Penal',              3, 'posgrado');

-- RELACIÓN ALUMNOS – PROGRAMAS
INSERT INTO alumno_programa_academico (ci_alumno, id_programa, rol) VALUES
('4.111.111-1', 1, 'alumno'),  -- Grado
('4.222.222-2', 1, 'alumno'),  -- Grado
('5.333.333-3', 2, 'alumno'),  -- Posgrado
('5.444.444-4', 2, 'alumno'),  -- Posgrado
('7.666.666-6', 3, 'alumno'),  -- Posgrado
('9.999.999-9', 1, 'docente'); -- Docente

-- EDIFICIOS
INSERT INTO edificio (nombre_edificio, direccion, departamento) VALUES
('Edificio Central', 'Av. Principal 123', 'Montevideo'),
('Edificio Norte',   'Calle 456',         'Montevideo');

-- SALAS
INSERT INTO sala (nombre_sala, id_edificio, capacidad, tipo_sala) VALUES
('Sala 101', 1, 30, 'libre'),
('Sala 102', 1, 25, 'libre'),
('Sala PG 1', 1, 10, 'posgrado'),
('Sala DOC 1', 2, 15, 'docente'),
('Sala 201', 2, 35, 'libre');

-- TURNOS BASE PARA QUE FUNCIONE RESERVA + BI
SET @f = CURDATE();

INSERT INTO turno (id_sala, fecha, hora_inicio, hora_fin) VALUES
(1, @f, '08:00:00', '09:00:00'),  -- id_turno = 1
(1, @f, '09:00:00', '10:00:00'),  -- id_turno = 2
(2, @f, '10:00:00', '11:00:00'),  -- id_turno = 3
(3, @f, '11:00:00', '12:00:00'),  -- id_turno = 4
(4, @f, '12:00:00', '13:00:00'),  -- id_turno = 5
(5, @f, '13:00:00', '14:00:00');  -- id_turno = 6

-- RESERVAS DE PRUEBA 
INSERT INTO reserva (id_sala, fecha, id_turno, estado, creado_por) VALUES
(1, @f, 1, 'activa',       '4.111.111-1'), 
(1, @f, 2, 'finalizada',   '4.111.111-1'),
(2, @f, 3, 'finalizada',   '4.222.222-2'),
(3, @f, 4, 'activa',       '5.333.333-3'),  
(4, @f, 5, 'activa',       '9.999.999-9'),  
(5, @f, 6, 'cancelada',    '7.666.666-6');  

-- PARTICIPANTES EN RESERVA
INSERT INTO reserva_alumno (id_reserva, ci_alumno, asistencia) VALUES
(1, '4.111.111-1', 1),
(2, '4.111.111-1', 1),
(2, '4.222.222-2', 1),
(3, '4.222.222-2', 1),
(4, '5.333.333-3', 0),
(5, '9.999.999-9', 1),
(6, '7.666.666-6', 0);

-- SANCIONES 
INSERT INTO sancion_alumno (ci_alumno, fecha_inicio, fecha_fin, motivo, id_reserva) VALUES
('7.666.666-6', DATE_SUB(@f, INTERVAL 3 MONTH), DATE_SUB(@f, INTERVAL 1 MONTH), 'Sancion de prueba', NULL),
('5.333.333-3', DATE_SUB(@f, INTERVAL 4 MONTH), DATE_SUB(@f, INTERVAL 2 MONTH), 'Sancion de prueba', NULL);
