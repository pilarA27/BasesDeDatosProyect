USE ucu_salas;

-- Facultades
INSERT INTO facultad (nombre) VALUES 
('Ingeniería y Tecnologías'), 
('Ciencias Empresariales');

-- Programas académicos
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

-- alumno-programa
INSERT INTO alumno_programa_academico (ci_alumno, id_programa, rol) VALUES
('4.111.111-1', 1, 'alumno'),
('4.222.222-2', 1, 'alumno'),
('4.333.333-3', 1, 'alumno'),
('5.444.444-4', 2, 'alumno'),
('6.555.555-5', 2, 'alumno'),
('7.666.666-6', 2, 'docente');

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


--Logins
INSERT INTO login (correo, contrasena, ci_alumno) VALUES
('ana@ucu.edu.uy', 'pass', '4.111.111-1'),
('bruno@ucu.edu.uy', 'pass', '4.222.222-2'),
('laura.doc@ucu.edu.uy', 'pass', '7.666.666-6');

-- GENERAR TURNOS 
DELETE FROM turno;

SET @fecha1 = CURDATE();
SET @fecha2 = DATE_ADD(@fecha1, INTERVAL 1 DAY);

INSERT INTO turno (id_sala, fecha, hora_inicio, hora_fin, disponible)
SELECT 
    s.id_sala,
    f.fecha,
    SEC_TO_TIME(TIME_TO_SEC('08:00:00') + h.id_hora * 3600),

    1
FROM sala s
CROSS JOIN (SELECT @fecha1 AS fecha UNION SELECT @fecha2) f
CROSS JOIN (
    SELECT 0 AS id_hora UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION
    SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION
    SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14
) h;

-- Reservas iniciales
SET @hoy := CURDATE();

INSERT INTO reserva (id_sala, fecha, id_turno, creado_por) VALUES
(1, DATE_ADD(@hoy, INTERVAL 1 DAY), 1, '4.111.111-1'),
(1, DATE_ADD(@hoy, INTERVAL 1 DAY), 2, '4.111.111-1'),
(3, DATE_ADD(@hoy, INTERVAL 2 DAY), 3, '5.444.444-4'),
(4, DATE_ADD(@hoy, INTERVAL 2 DAY), 4, '7.666.666-6');

-- Alumnos en reservas
INSERT INTO reserva_alumno (id_reserva, ci_alumno) VALUES
(1, '4.111.111-1'),
(1, '4.222.222-2'),
(2, '4.111.111-1'),
(3, '5.444.444-4'),
(4, '7.666.666-6');
