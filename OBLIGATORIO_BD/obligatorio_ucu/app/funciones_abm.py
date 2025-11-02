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
    return

def listar_salas():
    return

def modificar_sala(id_sala, nombre_sala, id_edificio, capacidad, tipo_sala):
    return

def eliminar_sala(id_sala):
    return

#RESERVA
def crear_reserva(id_sala, fecha, id_turno, creado_por):
    return

def agregar_alumno_a_reserva(id_reserva, ci):
    return

def cancelar_reserva(id_reserva):
    return

def listar_reservas():
    return

def registrar_asistencia(id_reserva, ci):
    return

def cerrar_reserva(id_reserva):
    return

#SANCIONES
def listar_sanciones():
    return
