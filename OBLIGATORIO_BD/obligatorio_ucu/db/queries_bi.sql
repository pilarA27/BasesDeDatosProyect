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
