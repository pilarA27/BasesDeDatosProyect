
-- Verifica límites, sanciones y exenciones antes de agregar un alumno a una reserva
DROP FUNCTION IF EXISTS es_exento_por_sala;
DELIMITER $$
CREATE FUNCTION es_exento_por_sala(p_ci VARCHAR(20), p_id_sala INT)
RETURNS TINYINT
DETERMINISTIC
BEGIN
  DECLARE v_tipo ENUM('libre','posgrado','docente');
  DECLARE v_es_docente INT DEFAULT 0;
  DECLARE v_es_posgrado INT DEFAULT 0;

  SELECT s.tipo_sala INTO v_tipo FROM sala s WHERE s.id_sala = p_id_sala;

  -- rol docente en algun programa
  SELECT COUNT(*) INTO v_es_docente
  FROM alumno_programa_academico ppa
  WHERE ppa.ci_alumno = p_ci AND ppa.rol = 'docente';

  -- es alumno de algun  posgrado
  SELECT COUNT(*) INTO v_es_posgrado
  FROM alumno_programa_academico ppa
  JOIN programa_academico pa ON pa.id_programa = ppa.id_programa
  WHERE ppa.ci_alumno = p_ci AND ppa.rol='alumno' AND pa.tipo='posgrado';

  RETURN (v_tipo='docente' AND v_es_docente>0) OR (v_tipo='posgrado' AND v_es_posgrado>0);
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS edificio_de_reserva;
DELIMITER $$
CREATE FUNCTION edificio_de_reserva(p_id_reserva INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE v_id_edificio INT;
  SELECT s.id_edificio INTO v_id_edificio
  FROM reserva r JOIN sala s ON s.id_sala=r.id_sala
  WHERE r.id_reserva=p_id_reserva;
  RETURN v_id_edificio;
END$$
DELIMITER ;

-- tiene sancion activa en una fecha dada
DROP FUNCTION IF EXISTS tiene_sancion_activa_en;
DELIMITER $$
CREATE FUNCTION tiene_sancion_activa_en(p_ci VARCHAR(20), p_fecha DATE)
RETURNS TINYINT
DETERMINISTIC
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM sancion_alumno sp
    WHERE sp.ci_alumno=p_ci
      AND p_fecha BETWEEN sp.fecha_inicio AND sp.fecha_fin
  );
END$$
DELIMITER ;
USE ucu_salas;

DROP FUNCTION IF EXISTS es_exento_por_sala;
DELIMITER $$
CREATE FUNCTION es_exento_por_sala(p_ci VARCHAR(20), p_id_sala INT)
RETURNS TINYINT
DETERMINISTIC
BEGIN
  DECLARE v_tipo ENUM('libre','posgrado','docente');
  DECLARE v_es_docente INT DEFAULT 0;
  DECLARE v_es_posgrado INT DEFAULT 0;

  -- Tipo de sala para ver si aplica excepcion
  SELECT s.tipo_sala INTO v_tipo FROM sala s WHERE s.id_sala = p_id_sala;

  -- Si la persona es docente en algun programa
  SELECT COUNT(*) INTO v_es_docente
  FROM participante_programa_academico ppa
  WHERE ppa.ci_participante = p_ci AND ppa.rol = 'docente';

  -- Si es alumno de posgrado
  SELECT COUNT(*) INTO v_es_posgrado
  FROM participante_programa_academico ppa
  JOIN programa_academico pa ON pa.id_programa = ppa.id_programa
  WHERE ppa.ci_participante = p_ci AND ppa.rol='alumno' AND pa.tipo='posgrado';

  -- Si se cumple la excepcion segun la sala
  RETURN (v_tipo='docente' AND v_es_docente>0) OR (v_tipo='posgrado' AND v_es_posgrado>0);
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS edificio_de_reserva;
DELIMITER $$
CREATE FUNCTION edificio_de_reserva(p_id_reserva INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE v_id_edificio INT;
  SELECT s.id_edificio INTO v_id_edificio
  FROM reserva r JOIN sala s ON s.id_sala=r.id_sala
  WHERE r.id_reserva=p_id_reserva;
  RETURN v_id_edificio;
END$$
DELIMITER ;

-- Se chequea si el tipo tiene sanción en esa fecha
DROP FUNCTION IF EXISTS tiene_sancion_activa_en;
DELIMITER $$
CREATE FUNCTION tiene_sancion_activa_en(p_ci VARCHAR(20), p_fecha DATE)
RETURNS TINYINT
DETERMINISTIC
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM sancion_participante sp
    WHERE sp.ci_participante=p_ci
      AND p_fecha BETWEEN sp.fecha_inicio AND sp.fecha_fin
  );
END$$
DELIMITER ;

-- Participante a reserva validaciones

DROP TRIGGER IF EXISTS bi_reserva_participante;
DELIMITER $$
CREATE TRIGGER bi_reserva_participante
BEFORE INSERT ON reserva_participante
FOR EACH ROW
BEGIN
  DECLARE v_estado ENUM('activa','cancelada','sin_asistencia','finalizada');
  DECLARE v_fecha DATE;
  DECLARE v_id_sala INT;
  DECLARE v_id_edificio INT;
  DECLARE v_cap INT;
  DECLARE v_es_exento TINYINT;
  DECLARE v_turnos_dia_edif INT DEFAULT 0;
  DECLARE v_count_semana INT DEFAULT 0;
  DECLARE v_tipo_sala ENUM('libre','posgrado','docente');

  -- Buscar los datos básicos de la reserva para validar
  SELECT r.estado, r.fecha, r.id_sala INTO v_estado, v_fecha, v_id_sala
  FROM reserva r WHERE r.id_reserva = NEW.id_reserva;

  IF v_estado IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Reserva inexistente';
  END IF;

  -- Que no se permita cuando no está activa
  IF v_estado <> 'activa' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Solo se pueden agregar participantes a reservas activas';
  END IF;

  -- Chequear sanciones para esa fecha
  IF tiene_sancion_activa_en(NEW.ci_participante, v_fecha) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Participante con sanción activa para la fecha de la reserva';
  END IF;

  -- Me fijo capacidad, edificio y tipo de sala
  SELECT s.capacidad, s.id_edificio, s.tipo_sala INTO v_cap, v_id_edificio, v_tipo_sala
  FROM sala s WHERE s.id_sala = v_id_sala;

  -- No dejar si ya está al maximo
  IF (SELECT COUNT(*) FROM reserva_participante rp WHERE rp.id_reserva = NEW.id_reserva) >= v_cap THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Capacidad de la sala alcanzada';
  END IF;

  -- Me fijo si le corresponde entrar
  SET v_es_exento = es_exento_por_sala(NEW.ci_participante, v_id_sala);

  IF v_es_exento = 0 THEN
    -- Contar reservas activas en esa semana
    SELECT COUNT(DISTINCT r2.id_reserva) INTO v_count_semana
    FROM reserva r2
    JOIN reserva_participante rp2 ON rp2.id_reserva = r2.id_reserva AND rp2.ci_participante = NEW.ci_participante
    WHERE r2.estado='activa'
      AND YEARWEEK(r2.fecha, 3) = YEARWEEK(v_fecha, 3);

    IF v_count_semana >= 3 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El participante ya tiene 3 reservas activas esta semana';
    END IF;

    -- Contar horas diarias en ese edificio
    SELECT COUNT(DISTINCT r3.id_turno) INTO v_turnos_dia_edif
    FROM reserva r3
    JOIN sala s3 ON s3.id_sala=r3.id_sala
    JOIN reserva_participante rp3 ON rp3.id_reserva=r3.id_reserva AND rp3.ci_participante=NEW.ci_participante
    WHERE r3.estado='activa'
      AND r3.fecha=v_fecha
      AND s3.id_edificio=v_id_edificio
      AND es_exento_por_sala(NEW.ci_participante, s3.id_sala)=0;

    IF v_turnos_dia_edif >= 2 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El participante ya alcanzó 2 horas diarias en este edificio';
    END IF;
  END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS registrar_asistencia;
DELIMITER $$
CREATE PROCEDURE registrar_asistencia(IN p_id_reserva INT, IN p_ci VARCHAR(20))
BEGIN
  UPDATE reserva_participante
     SET asistencia=1, checkin_ts=NOW()
   WHERE id_reserva=p_id_reserva AND ci_participante=p_ci;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS cerrar_reserva;
DELIMITER $$
CREATE PROCEDURE cerrar_reserva(IN p_id_reserva INT)
BEGIN
  DECLARE v_asistentes INT DEFAULT 0;
  DECLARE v_total INT DEFAULT 0;

  SELECT COALESCE(SUM(rp.asistencia),0), COUNT(*) INTO v_asistentes, v_total
  FROM reserva_participante rp WHERE rp.id_reserva=p_id_reserva;

  IF v_total=0 THEN
    UPDATE reserva SET estado='cancelada' WHERE id_reserva=p_id_reserva;
  ELSEIF v_asistentes>0 THEN
    UPDATE reserva SET estado='finalizada' WHERE id_reserva=p_id_reserva;
  ELSE
    UPDATE reserva SET estado='sin_asistencia' WHERE id_reserva=p_id_reserva;

    INSERT INTO sancion_participante (ci_participante, fecha_inicio, fecha_fin, motivo, id_reserva)
    SELECT rp.ci_participante, CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL 2 MONTH),
           'No-show: reserva sin asistencia', p_id_reserva
    FROM reserva_participante rp
    WHERE rp.id_reserva=p_id_reserva;
  END IF;
END$$
DELIMITER ;

DROP VIEW IF EXISTS vw_disponibilidad_bloques;
CREATE VIEW vw_disponibilidad_bloques AS
SELECT s.id_sala, s.nombre_sala, s.id_edificio, r.fecha, t.id_turno,
  CASE WHEN r2.id_reserva IS NULL THEN 1 ELSE 0 END AS bloque_libre
FROM sala s
JOIN (SELECT DISTINCT fecha FROM reserva) r ON 1=1
JOIN turno t ON 1=1
LEFT JOIN reserva r2 ON r2.id_sala=s.id_sala AND r2.fecha=r.fecha AND r2.id_turno=t.id_turno;