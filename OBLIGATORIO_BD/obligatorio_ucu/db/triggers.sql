DELIMITER $$

CREATE TRIGGER trg_reserva_alumno_no_sancionado
BEFORE INSERT ON reserva_alumno
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM sancion_alumno
        WHERE ci_alumno = NEW.ci_alumno
        AND CURDATE() BETWEEN fecha_inicio AND fecha_fin
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El alumno está sancionado y no puede participar en reservas';
    END IF;
END$$


CREATE TRIGGER trg_reserva_alumno_no_duplicado
BEFORE INSERT ON reserva_alumno
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM reserva_alumno
        WHERE id_reserva = NEW.id_reserva
        AND ci_alumno = NEW.ci_alumno
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El alumno ya está registrado en esta reserva';
    END IF;
END$$


CREATE TRIGGER trg_validar_capacidad_sala
BEFORE INSERT ON reserva_alumno
FOR EACH ROW
BEGIN
    DECLARE capacidad_max INT;
    DECLARE ocupacion_actual INT;

    SELECT s.capacidad INTO capacidad_max
    FROM reserva r
    JOIN sala s ON s.id_sala = r.id_sala
    WHERE r.id_reserva = NEW.id_reserva;

    SELECT COUNT(*) INTO ocupacion_actual
    FROM reserva_alumno
    WHERE id_reserva = NEW.id_reserva;

    IF ocupacion_actual >= capacidad_max THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La sala está llena — capacidad máxima alcanzada';
    END IF;
END$$


CREATE TRIGGER trg_reserva_max_2_horas
BEFORE INSERT ON reserva
FOR EACH ROW
BEGIN
    DECLARE tipo VARCHAR(20);
    DECLARE cant INT;

    SELECT tipo_sala INTO tipo
    FROM sala WHERE id_sala = NEW.id_sala;

    IF tipo = 'libre' THEN
        SELECT COUNT(*) INTO cant
        FROM reserva 
        WHERE creado_por = NEW.creado_por
        AND fecha = NEW.fecha;

        IF cant >= 2 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No podés reservar más de 2 horas por día en salas libres';
        END IF;
    END IF;
END$$


CREATE TRIGGER trg_reserva_max_3_semana
BEFORE INSERT ON reserva
FOR EACH ROW
BEGIN
    DECLARE tipo VARCHAR(20);
    DECLARE cant INT;

    SELECT tipo_sala INTO tipo
    FROM sala WHERE id_sala = NEW.id_sala;

    IF tipo = 'libre' THEN
        SELECT COUNT(*) INTO cant
        FROM reserva 
        WHERE creado_por = NEW.creado_por
        AND estado = 'activa'
        AND YEARWEEK(fecha,1) = YEARWEEK(NEW.fecha,1);

        IF cant >= 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No podés tener más de 3 reservas activas por semana';
        END IF;
    END IF;
END$$


CREATE TRIGGER trg_validar_tipo_sala
BEFORE INSERT ON reserva
FOR EACH ROW
BEGIN
    DECLARE tipo_sala VARCHAR(20);
    DECLARE rol VARCHAR(20);

    SELECT tipo_sala INTO tipo_sala
    FROM sala WHERE id_sala = NEW.id_sala;

    SELECT rol INTO rol
    FROM alumno_programa_academico
    WHERE ci_alumno = NEW.creado_por
    LIMIT 1;

    IF tipo_sala = 'posgrado' AND rol = 'alumno' AND NEW.creado_por NOT IN (
        SELECT ci_alumno FROM alumno_programa_academico ap
        JOIN programa_academico pa ON pa.id_programa = ap.id_programa
        WHERE pa.tipo='posgrado'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Solo alumnos de posgrado o docentes pueden usar esta sala';
    END IF;

    IF tipo_sala = 'docente' AND rol <> 'docente' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Esta sala es exclusiva de docentes';
    END IF;
END$$


CREATE TRIGGER trg_sancion_auto
AFTER UPDATE ON reserva
FOR EACH ROW
BEGIN
    DECLARE asistentes INT;

    IF NEW.estado = 'sin_asistencia' THEN

        SELECT COUNT(*)
        INTO asistentes
        FROM reserva_alumno
        WHERE id_reserva = NEW.id_reserva
        AND asistencia = 1;

        IF asistentes = 0 THEN
            INSERT INTO sancion_alumno(ci_alumno, fecha_inicio, fecha_fin, motivo, id_reserva)
            SELECT ci_alumno, CURDATE(),
                   DATE_ADD(CURDATE(), INTERVAL 2 MONTH),
                   'No asistencia a reserva', NEW.id_reserva
            FROM reserva_alumno
            WHERE id_reserva = NEW.id_reserva;
        END IF;
    END IF;
END$$

DELIMITER ;
