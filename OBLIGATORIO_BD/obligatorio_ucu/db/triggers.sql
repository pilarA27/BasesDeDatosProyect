USE ucu_salas;

-- excento por sala
DROP FUNCTION IF EXISTS es_exento_por_sala;
DELIMITER $$ 
CREATE FUNCTION es_exento_por_sala(p_ci VARCHAR(20), p_id_sala INT)
RETURNS TINYINT
DETERMINISTIC
BEGIN
  DECLARE v_tipo ENUM('libre','posgrado','docente');
  DECLARE v_es_docente INT DEFAULT 0;
  DECLARE v_es_posgrado INT DEFAULT 0;

  -- Tipo de sala
  SELECT s.tipo_sala INTO v_tipo
  FROM sala s WHERE s.id_sala = p_id_sala;

  -- ¿Es docente?
  SELECT COUNT(*) INTO v_es_docente
  FROM alumno_programa_academico ppa
  WHERE ppa.ci_alumno = p_ci AND ppa.rol = 'docente';

  -- ¿Es alumno de posgrado?
  SELECT COUNT(*) INTO v_es_posgrado
  FROM alumno_programa_academico ppa
  JOIN programa_academico pa ON pa.id_programa = ppa.id_programa
  WHERE ppa.ci_alumno = p_ci AND ppa.rol='alumno' AND pa.tipo='posgrado';

  RETURN (v_tipo='docente' AND v_es_docente>0)
      OR (v_tipo='posgrado' AND v_es_posgrado>0);
END$$
DELIMITER ;


-- sancion activa?
DROP FUNCTION IF EXISTS tiene_sancion_activa_en;
DELIMITER $$
CREATE FUNCTION tiene_sancion_activa_en(p_ci VARCHAR(20), p_fecha DATE)
RETURNS TINYINT
DETERMINISTIC
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM sancion_alumno sa
    WHERE sa.ci_alumno = p_ci
      AND p_fecha BETWEEN sa.fecha_inicio AND sa.fecha_fin
  );
END$$
DELIMITER ;


-- edificio resreva
DROP FUNCTION IF EXISTS edificio_de_reserva;
DELIMITER $$
CREATE FUNCTION edificio_de_reserva(p_id_reserva INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE v_id_edificio INT;

  SELECT s.id_edificio
    INTO v_id_edificio
  FROM reserva r 
  JOIN sala s ON s.id_sala = r.id_sala
  WHERE r.id_reserva = p_id_reserva;

  RETURN v_id_edificio;
END$$
DELIMITER ;


-- reserva alumnno
DROP TRIGGER IF EXISTS bi_reserva_alumno;
DELIMITER $$
CREATE TRIGGER bi_reserva_alumno
BEFORE INSERT ON reserva_alumno
FOR EACH ROW
BEGIN
  DECLARE v_estado ENUM('activa','cancelada','sin_asistencia','finalizada');
  DECLARE v_fecha DATE;
  DECLARE v_id_sala INT;
  DECLARE v_id_edificio INT;
  DECLARE v_capacidad INT;
  DECLARE v_es_exento TINYINT;
  DECLARE v_turnos_dia INT DEFAULT 0;
  DECLARE v_semana INT DEFAULT 0;

  -- Datos de la reserva
  SELECT r.estado, r.fecha, r.id_sala
    INTO v_estado, v_fecha, v_id_sala
  FROM reserva r
  WHERE r.id_reserva = NEW.id_reserva;

  IF v_estado IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT='La reserva no existe';
  END IF;

  IF v_estado <> 'activa' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT='Solo se pueden agregar alumnos a reservas activas';
  END IF;

  -- Sanciones
  IF tiene_sancion_activa_en(NEW.ci_alumno, v_fecha) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT='El alumno tiene una sanción activa';
  END IF;

  -- Datos sala
  SELECT s.capacidad, s.id_edificio, s.tipo_sala
    INTO v_capacidad, v_id_edificio, v_tipo
  FROM sala s
  WHERE s.id_sala = v_id_sala;

  -- Capacidad
  IF (SELECT COUNT(*) FROM reserva_alumno ra 
      WHERE ra.id_reserva = NEW.id_reserva) >= v_capacidad THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT='La sala ya está al máximo de capacidad';
  END IF;

  -- Exención según tipo de sala
  SET v_es_exento = es_exento_por_sala(NEW.ci_alumno, v_id_sala);

  -- Límites semanales/diarios (solo si NO es exento)
  IF v_es_exento = 0 THEN

    -- Máximo 3 reservas activas semanales
    SELECT COUNT(DISTINCT r2.id_reserva)
      INTO v_semana
    FROM reserva r2
    JOIN reserva_alumno ra2 ON ra2.id_reserva = r2.id_reserva 
                           AND ra2.ci_alumno = NEW.ci_alumno
    WHERE r2.estado='activa'
      AND YEARWEEK(r2.fecha, 3) = YEARWEEK(v_fecha, 3);

    IF v_semana >= 3 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='El alumno ya tiene 3 reservas activas esta semana';
    END IF;

    -- Máximo 2 turnos por día en el mismo edificio
    SELECT COUNT(DISTINCT r3.id_turno)
      INTO v_turnos_dia
    FROM reserva r3
    JOIN sala s3 ON s3.id_sala = r3.id_sala
    JOIN reserva_alumno ra3 ON ra3.id_reserva = r3.id_reserva
                           AND ra3.ci_alumno = NEW.ci_alumno
    WHERE r3.estado='activa'
      AND r3.fecha = v_fecha
      AND s3.id_edificio = v_id_edificio
      AND es_exento_por_sala(NEW.ci_alumno, s3.id_sala)=0;

    IF v_turnos_dia >= 2 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='El alumno ya tiene 2 horas en este edificio hoy';
    END IF;

  END IF;

END$$
DELIMITER ;


-- registrar asistencia
DROP PROCEDURE IF EXISTS registrar_asistencia;
DELIMITER $$
CREATE PROCEDURE registrar_asistencia(IN p_id_reserva INT, IN p_ci VARCHAR(20))
BEGIN
  UPDATE reserva_alumno
     SET asistencia = 1,
         checkin_ts = NOW()
   WHERE id_reserva = p_id_reserva
     AND ci_alumno = p_ci;
END$$
DELIMITER ;


-- cerrar reserva
DROP PROCEDURE IF EXISTS cerrar_reserva;
DELIMITER $$
CREATE PROCEDURE cerrar_reserva(IN p_id_reserva INT)
BEGIN
  DECLARE v_asistentes INT DEFAULT 0;
  DECLARE v_total INT DEFAULT 0;

  SELECT COALESCE(SUM(ra.asistencia),0), COUNT(*)
    INTO v_asistentes, v_total
  FROM reserva_alumno ra
  WHERE ra.id_reserva = p_id_reserva;

  IF v_total = 0 THEN
    UPDATE reserva SET estado='cancelada'
    WHERE id_reserva = p_id_reserva;

  ELSEIF v_asistentes > 0 THEN
    UPDATE reserva SET estado='finalizada'
    WHERE id_reserva = p_id_reserva;

  ELSE
    UPDATE reserva SET estado='sin_asistencia'
    WHERE id_reserva = p_id_reserva;

    INSERT INTO sancion_alumno (ci_alumno, fecha_inicio, fecha_fin, motivo, id_reserva)
    SELECT ra.ci_alumno, CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL 60 DAY),
           'No-show: reserva sin asistencia', p_id_reserva
    FROM reserva_alumno ra
    WHERE ra.id_reserva = p_id_reserva;

  END IF;
END$$
DELIMITER ;
