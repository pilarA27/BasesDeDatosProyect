USE ucu_salas;

-- Turnos 08:00-23:00
DELETE FROM turno;
INSERT INTO turno (id_turno, hora_inicio, hora_fin)
SELECT i, ADDTIME('08:00:00', SEC_TO_TIME((i-1)*3600)), ADDTIME('08:00:00', SEC_TO_TIME((i)*3600))
FROM (SELECT 1 i UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION
             SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15) x;

-- Facultades y programas
INSERT INTO facultad (nombre) VALUES ('Ingeniería y Tecnologías'), ('Ciencias Empresariales');

INSERT INTO programa_academico (nombre_programa, id_facultad, tipo) VALUES
('Ing. Informática', 1, 'grado'),
('MBA', 2, 'posgrado');

-- Alumnos
INSERT INTO alumno (ci, nombre, apellido, email) VALUES
('4.111.111-1', 'Ana', 'Pérez', 'ana@ucu.edu.uy'),
('4.222.222-2', 'Bruno', 'García', 'bruno@ucu.edu.uy'),
('4.333.333-3', 'Carla', 'López', 'carla@ucu.edu.uy'),
('5.444.444-4', 'Diego', 'Suárez', 'diego@ucu.edu.uy'),
('6.555.555-5', 'Elena', 'Ramos', 'elena@ucu.edu.uy'),
('7.666.666-6', 'Laura', 'Docente', 'laura.doc@ucu.edu.uy');

-- Mapear roles
INSERT INTO alumno_programa_academico (ci_alumno, id_programa, rol)
VALUES
('4.111.111-1', 1, 'alumno'),
('4.222.222-2', 1, 'alumno'),
('4.333.333-3', 1, 'alumno');

INSERT INTO alumno_programa_academico (ci_alumno, id_programa, rol)
VALUES
('5.444.444-4', 2, 'alumno'),
('6.555.555-5', 2, 'alumno');

INSERT INTO alumno_programa_academico (ci_alumno, id_programa, rol)
VALUES ('7.666.666-6', 2, 'docente');

-- Edificios
INSERT INTO edificio (nombre_edificio, direccion, departamento) VALUES
('Sede Central', 'Av. 8 de Octubre 2738', 'Montevideo'),
('Punta Carretas', 'José Ellauri 1234', 'Montevideo');

-- Salas
INSERT INTO sala (nombre_sala, id_edificio, capacidad, tipo_sala) VALUES
('Sala 101', 1, 6, 'libre'),
('Sala 102', 1, 6, 'libre'),
('Sala PG 1', 2, 10, 'posgrado'),
('Sala DOC 1', 1, 8, 'docente'),
('Sala 201', 2, 6, 'libre');

-- Logins
INSERT INTO login (correo, contrasena, ci_alumno) VALUES
('ana@ucu.edu.uy', 'pass', '4.111.111-1'),
('bruno@ucu.edu.uy', 'pass', '4.222.222-2'),
('laura.doc@ucu.edu.uy', 'pass', '7.666.666-6');

-- Reservas
SET @hoy := CURRENT_DATE();
INSERT INTO reserva (id_sala, fecha, id_turno, creado_por) VALUES
-- Mañana
((SELECT id_sala FROM sala WHERE nombre_sala='Sala 101' AND id_edificio=1), DATE_ADD(@hoy, INTERVAL 1 DAY), 1, '4.111.111-1'),
((SELECT id_sala FROM sala WHERE nombre_sala='Sala 101' AND id_edificio=1), DATE_ADD(@hoy, INTERVAL 1 DAY), 2, '4.111.111-1'),
-- Posgrado exento
((SELECT id_sala FROM sala WHERE nombre_sala='Sala PG 1'), DATE_ADD(@hoy, INTERVAL 2 DAY), 3, '5.444.444-4'),
-- Docente exento
((SELECT id_sala FROM sala WHERE nombre_sala='Sala DOC 1'), DATE_ADD(@hoy, INTERVAL 2 DAY), 4, '7.666.666-6');

-- alumnos en reservas
INSERT INTO reserva_alumno (id_reserva, ci_alumno) VALUES
(1, '4.111.111-1'), (1, '4.222.222-2'),
(2, '4.111.111-1'),
(3, '5.444.444-4'),
(4, '7.666.666-6');
