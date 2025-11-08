USE ucu_salas;

-- 1. Salas más reservadas
SELECT s.nombre_sala, e.nombre_edificio, COUNT(*) AS total_reservas
FROM reserva r
JOIN sala s ON s.id_sala=r.id_sala
JOIN edificio e ON e.id_edificio=s.id_edificio
GROUP BY s.nombre_sala, e.nombre_edificio
ORDER BY total_reservas DESC;

-- 2. Turnos más demandados
SELECT t.id_turno, t.hora_inicio, t.hora_fin, COUNT(*) AS total
FROM reserva r JOIN turno t ON t.id_turno=r.id_turno
GROUP BY t.id_turno, t.hora_inicio, t.hora_fin
ORDER BY total DESC;

-- 3. Promedio de alumnos por sala
SELECT s.nombre_sala, AVG(cnt) AS promedio_alumnos
FROM (
  SELECT r.id_reserva, COUNT(rp.ci_alumno) AS cnt
  FROM reserva r LEFT JOIN reserva_alumno rp ON rp.id_reserva=r.id_reserva
  GROUP BY r.id_reserva
) x
JOIN reserva r ON r.id_reserva = x.id_reserva
JOIN sala s ON s.id_sala=r.id_sala
GROUP BY s.nombre_sala
ORDER BY promedio_alumnos DESC;

-- 4. Cantidad de reservas por carrera y facultad
SELECT pa.nombre_programa, f.nombre AS facultad, COUNT(*) total
FROM reserva r
JOIN reserva_alumno rp ON rp.id_reserva=r.id_reserva
JOIN alumno_programa_academico ppa ON ppa.ci_alumno=rp.ci_alumno
JOIN programa_academico pa ON pa.id_programa=ppa.id_programa
JOIN facultad f ON f.id_facultad=pa.id_facultad
GROUP BY pa.nombre_programa, f.nombre
ORDER BY total DESC;

-- 5. % de ocupación de salas por edificio
WITH dias AS (
  SELECT e.id_edificio, s.id_sala, r.fecha
  FROM reserva r JOIN sala s ON s.id_sala=r.id_sala JOIN edificio e ON e.id_edificio=s.id_edificio
  GROUP BY e.id_edificio, s.id_sala, r.fecha
),
bloques_posibles AS (
  SELECT id_edificio, COUNT(DISTINCT id_sala)*15 AS bloques_por_dia
  FROM sala
  GROUP BY id_edificio
),
ocupacion AS (
  SELECT e.id_edificio, COUNT(*) AS reservas
  FROM reserva r JOIN sala s ON s.id_sala=r.id_sala JOIN edificio e ON e.id_edificio=s.id_edificio
  GROUP BY e.id_edificio
)
SELECT e.nombre_edificio,
       ROUND(100 * o.reservas / NULLIF((SELECT SUM(b.bloques_por_dia) FROM bloques_posibles b WHERE b.id_edificio=e.id_edificio)
             * (SELECT COUNT(DISTINCT d.fecha) FROM dias d WHERE d.id_edificio=e.id_edificio),0),2) AS porcentaje_ocupacion
FROM edificio e
LEFT JOIN ocupacion o ON o.id_edificio=e.id_edificio
ORDER BY porcentaje_ocupacion DESC;

-- 6. Cantidad de reservas y asistencias por tipo de alumno
SELECT tipo_alumno, COUNT(*) reservas, SUM(asistencias) asistencias
FROM (
  SELECT CASE
           WHEN ppa.rol='docente' THEN 'docente'
           WHEN pa.tipo='posgrado' THEN 'alumno_posgrado'
           ELSE 'alumno_grado'
         END AS tipo_alumno,
         r.id_reserva,
         SUM(rp.asistencia) AS asistencias
  FROM reserva r
  JOIN reserva_alumno rp ON rp.id_reserva=r.id_reserva
  JOIN alumno_programa_academico ppa ON ppa.ci_alumno=rp.ci_alumno
  JOIN programa_academico pa ON pa.id_programa=ppa.id_programa
  GROUP BY tipo_alumno, r.id_reserva
) z
GROUP BY tipo_alumno;