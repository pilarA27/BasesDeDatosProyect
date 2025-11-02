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
        1: "SELECT s.nombre_sala, e.nombre_edificio, COUNT(*) AS total_reservas FROM reserva r JOIN sala s ON s.id_sala=r.id_sala JOIN edificio e ON e.id_edificio=s.id_edificio GROUP BY s.nombre_sala, e.nombre_edificio ORDER BY total_reservas DESC",
        2: "SELECT t.id_turno, t.hora_inicio, t.hora_fin, COUNT(*) AS total FROM reserva r JOIN turno t ON t.id_turno=r.id_turno GROUP BY t.id_turno, t.hora_inicio, t.hora_fin ORDER BY total DESC",
    }
    sql = consultas.get(consulta_id)
    if not sql:
        raise ValueError("Consulta BI no válida")
    return run(sql)
