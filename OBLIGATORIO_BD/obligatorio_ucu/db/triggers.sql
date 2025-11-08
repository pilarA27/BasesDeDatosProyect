
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