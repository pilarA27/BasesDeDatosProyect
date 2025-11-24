DELIMITER $$

-- TRIGGERS SOBRE reserva_alumno
-- 1) No permitir que un alumno sancionado participe en reservas
CREATE TRIGGER trg_reserva_alumno_no_sancionado
BEFORE INSERT ON reserva_alumno
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM sancion_alumno
        WHERE ci_alumno = NEW.ci_alumno
          AND CURDATE() BETWEEN fecha_inicio AND fecha_fin
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El alumno está sancionado y no puede participar en reservas';
    END IF;
END$$


-- 2) No duplicar el mismo alumno en la misma reserva (mensaje claro)
CREATE TRIGGER trg_reserva_alumno_no_duplicado
BEFORE INSERT ON reserva_alumno
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM reserva_alumno
        WHERE id_reserva = NEW.id_reserva
          AND ci_alumno = NEW.ci_alumno
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El alumno ya está registrado en esta reserva';
    END IF;
END$$


-- 3) Validar capacidad de la sala (no superar cantidad de participantes)
CREATE TRIGGER trg_validar_capacidad_sala
BEFORE INSERT ON reserva_alumno
FOR EACH ROW
BEGIN
    DECLARE capacidad_max INT;
    DECLARE ocupacion_actual INT;

    -- Capacidad máxima de la sala asociada a la reserva
    SELECT s.capacidad
      INTO capacidad_max
    FROM reserva r
    JOIN sala s ON s.id_sala = r.id_sala
    WHERE r.id_reserva = NEW.id_reserva;

    -- Cantidad actual de participantes en la reserva
    SELECT COUNT(*)
      INTO ocupacion_actual
    FROM reserva_alumno
    WHERE id_reserva = NEW.id_reserva;

    IF ocupacion_actual >= capacidad_max THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La sala está llena — capacidad máxima alcanzada';
    END IF;
END$$


-- 4) No permitir que un alumno participe en más de 3 reservas activas 
--    por semana en salas de uso libre
CREATE TRIGGER trg_participante_max_3_semana
BEFORE INSERT ON reserva_alumno
FOR EACH ROW
BEGIN
    DECLARE fecha_reserva DATE;
    DECLARE tipo VARCHAR(20);
    DECLARE cant INT;

    -- Obtenemos fecha y tipo de sala de la reserva a la que se quiere sumar
    SELECT r.fecha, s.tipo_sala
      INTO fecha_reserva, tipo
    FROM reserva r
    JOIN sala s ON s.id_sala = r.id_sala
    WHERE r.id_reserva = NEW.id_reserva;

    -- Solo aplicamos la restricción en salas de uso libre
    IF tipo = 'libre' THEN
        SELECT COUNT(*)
          INTO cant
        FROM reserva_alumno ra
        JOIN reserva r2 ON r2.id_reserva = ra.id_reserva
        JOIN sala s2 ON s2.id_sala = r2.id_sala
        WHERE ra.ci_alumno = NEW.ci_alumno
          AND r2.estado = 'activa'
          AND s2.tipo_sala = 'libre'
          AND YEARWEEK(r2.fecha, 1) = YEARWEEK(fecha_reserva, 1);

        IF cant >= 3 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'No podés participar en más de 3 reservas activas por semana en salas libres';
        END IF;
    END IF;
END$$




 -- TRIGGERS SOBRE reserv
-- 5) No permitir que un alumno con sanción vigente cree reservas
CREATE TRIGGER trg_reserva_creador_no_sancionado
BEFORE INSERT ON reserva
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM sancion_alumno s
        WHERE s.ci_alumno = NEW.creado_por
          AND NEW.fecha BETWEEN s.fecha_inicio AND s.fecha_fin
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No podés crear reservas porque tenés una sanción vigente';
    END IF;
END$$


-- 6) Máximo 2 horas por día en salas de uso libre (por creador)
CREATE TRIGGER trg_reserva_max_2_horas
BEFORE INSERT ON reserva
FOR EACH ROW
BEGIN
    DECLARE tipo VARCHAR(20);
    DECLARE cant INT;

    SELECT tipo_sala INTO tipo
    FROM sala
    WHERE id_sala = NEW.id_sala;

    IF tipo = 'libre' THEN
        SELECT COUNT(*)
          INTO cant
        FROM reserva r
        JOIN sala s ON s.id_sala = r.id_sala
        WHERE r.creado_por = NEW.creado_por
          AND r.fecha      = NEW.fecha
          AND s.tipo_sala  = 'libre';

        IF cant >= 2 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'No podés reservar más de 2 horas por día en salas libres';
        END IF;
    END IF;
END$$




-- 7) Máximo 3 reservas activas por semana en salas de uso libre (por creador)
CREATE TRIGGER trg_reserva_max_3_semana
BEFORE INSERT ON reserva
FOR EACH ROW
BEGIN
    DECLARE tipo VARCHAR(20);
    DECLARE cant INT;

    SELECT tipo_sala INTO tipo
    FROM sala
    WHERE id_sala = NEW.id_sala;

    IF tipo = 'libre' THEN
        SELECT COUNT(*)
          INTO cant
        FROM reserva r
        JOIN sala s ON s.id_sala = r.id_sala
        WHERE r.creado_por = NEW.creado_por
          AND r.estado     = 'activa'
          AND s.tipo_sala  = 'libre'
          AND YEARWEEK(r.fecha, 1) = YEARWEEK(NEW.fecha, 1);

        IF cant >= 3 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'No podés tener más de 3 reservas activas por semana en salas libres';
        END IF;
    END IF;
END$$



-- 8) Validar que el tipo de sala sea compatible con el rol del creador
--    - Sala'posgrado: solo alumnos de posgrado o docentes
--    - Sala docente: solo docentes
--    - Sala libre: sin restricción de tipo (ya está cubierta por otros triggers)
CREATE TRIGGER trg_validar_tipo_sala
BEFORE INSERT ON reserva
FOR EACH ROW
BEGIN
    DECLARE v_tipo_sala VARCHAR(20);
    DECLARE v_rol       VARCHAR(20);

    -- Tipo de sala
    SELECT tipo_sala
      INTO v_tipo_sala
    FROM sala
    WHERE id_sala = NEW.id_sala;

    -- Rol del creador (alumno / docente) en algún programa
    SELECT rol
      INTO v_rol
    FROM alumno_programa_academico
    WHERE ci_alumno = NEW.creado_por
    LIMIT 1;
    IF v_tipo_sala = 'posgrado'
       AND v_rol = 'alumno'
       AND NEW.creado_por NOT IN (
            SELECT ap.ci_alumno
            FROM alumno_programa_academico ap
            JOIN programa_academico pa ON pa.id_programa = ap.id_programa
            WHERE pa.tipo = 'posgrado'
       )
    THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Solo alumnos de posgrado o docentes pueden usar esta sala de posgrado';
    END IF;

    IF v_tipo_sala = 'docente'
       AND (v_rol IS NULL OR v_rol <> 'docente')
    THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Esta sala es exclusiva de docentes';
    END IF;
END$$




 -- TRIGGER DE SANCIÓN AUTOMÁTICA
-- 9) Sancionar automáticamente si la reserva queda en 'sin_asistencia'
--    y ningún participante registró asistencia
CREATE TRIGGER trg_sancion_auto
AFTER UPDATE ON reserva
FOR EACH ROW
BEGIN
    DECLARE asistentes INT;
    IF NEW.estado = 'sin_asistencia' AND OLD.estado <> 'sin_asistencia' THEN

        -- Cantidad de asistentes marcados (asistencia = 1)
        SELECT COUNT(*)
          INTO asistentes
        FROM reserva_alumno
        WHERE id_reserva = NEW.id_reserva
          AND asistencia = 1;

        -- Si nadie asistió, sancionamos a todos los participantes de la reserva
        IF asistentes = 0 THEN
            INSERT INTO sancion_alumno (ci_alumno, fecha_inicio, fecha_fin, motivo, id_reserva)
            SELECT ra.ci_alumno,
                   CURDATE(),
                   DATE_ADD(CURDATE(), INTERVAL 2 MONTH),
                   'No asistencia a reserva',
                   NEW.id_reserva
            FROM reserva_alumno ra
            WHERE ra.id_reserva = NEW.id_reserva;
        END IF;
    END IF;
END$$

DELIMITER ;
