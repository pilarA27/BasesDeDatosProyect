from db_config import get_connection

def run(sql):
    cn = get_connection()
    try:
        cur = cn.cursor(dictionary=True)
        cur.execute(sql)
        return cur.fetchall()
    finally:
        cn.close()


def ejecutar_bi(consulta_id: int):

    consultas = {

        # 1) Salas más reservadas
        1: """
            SELECT 
                s.nombre_sala,
                e.nombre_edificio,
                COUNT(*) AS total_reservas
            FROM reserva r
            JOIN sala s ON s.id_sala = r.id_sala
            JOIN edificio e ON e.id_edificio = s.id_edificio
            GROUP BY s.nombre_sala, e.nombre_edificio
            ORDER BY total_reservas DESC
        """,

        # 2) Turnos más demandados (día + hora formateada)
        2: """
            SELECT 
                DATE_FORMAT(t.fecha, '%d/%m/%Y') AS fecha,
                CASE
                    WHEN DAYOFWEEK(t.fecha)=1 THEN 'Domingo'
                    WHEN DAYOFWEEK(t.fecha)=2 THEN 'Lunes'
                    WHEN DAYOFWEEK(t.fecha)=3 THEN 'Martes'
                    WHEN DAYOFWEEK(t.fecha)=4 THEN 'Miércoles'
                    WHEN DAYOFWEEK(t.fecha)=5 THEN 'Jueves'
                    WHEN DAYOFWEEK(t.fecha)=6 THEN 'Viernes'
                    WHEN DAYOFWEEK(t.fecha)=7 THEN 'Sábado'
                END AS dia,
                TIME_FORMAT(t.hora_inicio, '%H:%i') AS hora_inicio,
                TIME_FORMAT(t.hora_fin, '%H:%i') AS hora_fin,
                COUNT(r.id_reserva) AS total_reservas
            FROM turno t
            LEFT JOIN reserva r ON r.id_turno = t.id_turno
            GROUP BY fecha, dia, hora_inicio, hora_fin
            ORDER BY total_reservas DESC
        """,

        # 3) Promedio de participantes por sala
       3: """
    SELECT s.nombre_sala,
           ROUND(AVG(cnt),2) AS promedio_participantes
    FROM (
        SELECT r.id_reserva,
               COUNT(rp.ci_alumno) AS cnt
        FROM reserva r
        LEFT JOIN reserva_alumno rp ON rp.id_reserva = r.id_reserva
        GROUP BY r.id_reserva
    ) x
    JOIN reserva r ON r.id_reserva = x.id_reserva
    JOIN sala s ON s.id_sala = r.id_sala
    WHERE r.estado IN ('activa','finalizada')
    GROUP BY s.nombre_sala
    ORDER BY promedio_participantes DESC
""",



        # 4) Reservas por carrera y facultad
        4: """
            SELECT 
                pa.nombre_programa AS programa,
                f.nombre AS facultad,
                COUNT(*) AS total_reservas
            FROM reserva r
            JOIN reserva_alumno rp ON rp.id_reserva = r.id_reserva
            JOIN alumno_programa_academico ppa ON ppa.ci_alumno = rp.ci_alumno
            JOIN programa_academico pa ON pa.id_programa = ppa.id_programa
            JOIN facultad f ON f.id_facultad = pa.id_facultad
            GROUP BY programa, facultad
            ORDER BY total_reservas DESC
        """,

        # 5) % Ocupación por edificio
        5: """
            SELECT 
                e.nombre_edificio,
                ROUND(
                    (COUNT(r.id_reserva) / 
                     NULLIF(COUNT(DISTINCT r.fecha) * COUNT(DISTINCT s.id_sala),0)
                    ) * 100,
                2) AS porcentaje_ocupacion
            FROM reserva r
            JOIN sala s ON s.id_sala = r.id_sala
            JOIN edificio e ON e.id_edificio = s.id_edificio
            GROUP BY e.nombre_edificio
            ORDER BY porcentaje_ocupacion DESC
        """,

        # 6) Reservas y asistencias por tipo alumno
        6: """
            SELECT 
                tipo_alumno,
                COUNT(*) AS total_reservas,
                SUM(asistencia) AS total_asistencias
            FROM (
                SELECT 
                    CASE WHEN pa.tipo='posgrado' THEN 'alumno_posgrado'
                         ELSE 'alumno_grado' END AS tipo_alumno,
                    rp.asistencia
                FROM reserva r
                JOIN reserva_alumno rp ON rp.id_reserva = r.id_reserva
                JOIN alumno_programa_academico ppa ON ppa.ci_alumno = rp.ci_alumno
                JOIN programa_academico pa ON pa.id_programa = ppa.id_programa
            ) x
            GROUP BY tipo_alumno
        """,

        # 7) Sanciones por tipo alumno
        7: """
            SELECT 
                CASE WHEN pa.tipo='posgrado' THEN 'alumno_posgrado'
                     ELSE 'alumno_grado' END AS tipo_alumno,
                COUNT(*) AS total_sanciones
            FROM sancion_alumno s
            JOIN alumno_programa_academico ppa ON ppa.ci_alumno = s.ci_alumno
            JOIN programa_academico pa ON pa.id_programa = ppa.id_programa
            GROUP BY tipo_alumno
            ORDER BY total_sanciones DESC
        """,

        # 8) Reservas utilizadas vs canceladas
        8: """
            SELECT estado, COUNT(*) AS total
            FROM reserva
            GROUP BY estado
            ORDER BY total DESC
        """,

        # 9) Ranking de alumnos con más reservas
        9: """
            SELECT 
                a.ci,
                a.nombre,
                a.apellido,
                COUNT(*) AS total_reservas
            FROM reserva r
            JOIN reserva_alumno rp ON rp.id_reserva = r.id_reserva
            JOIN alumno a ON a.ci = rp.ci_alumno
            GROUP BY a.ci
            ORDER BY total_reservas DESC
        """,

        # 10) Edificios más utilizados
        10: """
            SELECT 
                e.nombre_edificio,
                COUNT(*) AS total_reservas
            FROM reserva r
            JOIN sala s ON s.id_sala = r.id_sala
            JOIN edificio e ON e.id_edificio = s.id_edificio
            GROUP BY e.nombre_edificio
            ORDER BY total_reservas DESC
        """,

        # 11) Salas más utilizadas por día de semana (en español)
        11: """
            SELECT 
                s.nombre_sala,
                CASE
                    WHEN DAYOFWEEK(r.fecha)=1 THEN 'Domingo'
                    WHEN DAYOFWEEK(r.fecha)=2 THEN 'Lunes'
                    WHEN DAYOFWEEK(r.fecha)=3 THEN 'Martes'
                    WHEN DAYOFWEEK(r.fecha)=4 THEN 'Miércoles'
                    WHEN DAYOFWEEK(r.fecha)=5 THEN 'Jueves'
                    WHEN DAYOFWEEK(r.fecha)=6 THEN 'Viernes'
                    WHEN DAYOFWEEK(r.fecha)=7 THEN 'Sábado'
                END AS dia_semana,
                DATE_FORMAT(r.fecha, '%d/%m/%Y') AS fecha,
                COUNT(*) AS total
            FROM reserva r
            JOIN sala s ON s.id_sala = r.id_sala
            GROUP BY s.nombre_sala, dia_semana, fecha
            ORDER BY total DESC
        """,
    }

    sql = consultas.get(consulta_id)
    if not sql:
        raise ValueError("Consulta BI no válida")
    return run(sql)
