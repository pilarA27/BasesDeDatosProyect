from db_config import get_connection

def run_query(sql, params=None, fetch=False):
    cn = get_connection()
    try:
        cur = cn.cursor(dictionary=True)
        cur.execute(sql, params or ())
        if fetch:
            rows = cur.fetchall()
            return rows
        else:
            cn.commit()
            return cur.rowcount
    finally:
        cn.close()

#alumno
def alta_alumno(ci, nombre, apellido, email):
    sql = "INSERT INTO alumno (ci, nombre, apellido, email) VALUES (%s, %s, %s, %s)"
    return run_query(sql, (ci, nombre, apellido, email))

def listar_alumnos():
    return run_query("SELECT * FROM alumno ORDER BY apellido, nombre", fetch=True)

def modificar_alumno(ci, nombre, apellido, email):
    sql = "UPDATE alumno SET nombre=%s, apellido=%s, email=%s WHERE ci=%s"
    return run_query(sql, (nombre, apellido, email, ci))

def eliminar_alumno(ci):
    return run_query("DELETE FROM alumno WHERE ci=%s", (ci,))

#SALA
def alta_sala(nombre_sala, id_edificio, capacidad, tipo_sala):
    sql = """INSERT INTO sala (nombre_sala, id_edificio, capacidad, tipo_sala)
        VALUES (%s, %s, %s, %s)"""
    return run_query(sql, (nombre_sala, id_edificio, capacidad, tipo_sala))

def listar_salas():
    sql = """SELECT s.id_sala, s.nombre_sala, s.capacidad, s.tipo_sala, e.nombre_edificio AS edificio
        FROM sala s
        JOIN edificio e ON s.id_edificio = e.id_edificio
        ORDER BY e.nombre_edificio, s.nombre_sala"""
    return run_query(sql, fetch=True)

def modificar_sala(id_sala, nombre_sala, id_edificio, capacidad, tipo_sala):
    sql = """UPDATE sala 
        SET nombre_sala = %s, id_edificio = %s, capacidad = %s, tipo_sala = %s
        WHERE id_sala = %s"""
    return run_query(sql, (nombre_sala, id_edificio, capacidad, tipo_sala, id_sala))

def eliminar_sala(id_sala):
    sql = "DELETE FROM sala WHERE id_sala = %s"
    return run_query(sql, (id_sala,))

#RESERVA
def crear_reserva(id_sala, fecha, id_turno, creado_por):
    sql = """INSERT INTO reserva (id_sala, fecha, id_turno, creado_por)
            VALUES (%s, %s, %s, %s)"""
    return run_query(sql, (id_sala, fecha, id_turno, creado_por))

def agregar_alumno_a_reserva(id_reserva, ci):
    sql = """INSERT INTO reserva_alumno (id_reserva, ci_alumno)
            VALUES (%s, %s)"""
    return run_query(sql, (id_reserva, ci))

def cancelar_reserva(id_reserva):
    sql = """UPDATE reserva SET estado='cancelada'
            WHERE id_reserva=%s"""
    return run_query(sql, (id_reserva,))

def listar_reservas():
    sql = """SELECT r.id_reserva, r.fecha, r.estado, t.hora_inicio, t.hora_fin, s.nombre_sala, e.nombre_edificio
            FROM reserva r
            JOIN turno t ON t.id_turno=r.id_turno
            JOIN sala s ON s.id_sala=r.id_sala
            JOIN edificio e ON e.id_edificio=s.id_edificio
            ORDER BY r.fecha DESC, t.hora_inicio"""
    return run_query(sql, fetch=True)

def registrar_asistencia(id_reserva, ci):
    return

def cerrar_reserva(id_reserva):
    return

#SANCIONES
def listar_sanciones():
    return
