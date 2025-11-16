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
    return

def agregar_alumno_a_reserva(id_reserva, ci):
    return

def cancelar_reserva(id_reserva):
    return

def listar_reservas():
    return

#ver temas de seguridad por las dudas
def registrar_asistencia(id_reserva, ci):
    sql = """
        UPDATE reserva_alumno
        SET asistencia = 1, checkin_ts = CURRENT_TIMESTAMP
        WHERE id_reserva = %s AND ci_alumno = %s
    """
    return run_query(sql, (id_reserva, ci))

from datetime import datetime, timedelta

def cerrar_reserva(id_reserva):
    #Se verifica si hubo asistencia
    sql_asistencia = """
        SELECT SUM(asistencia) AS total_asistencias
        FROM reserva_alumno
        WHERE id_reserva = %s
    """
    resultado = run_query(sql_asistencia, (id_reserva,), fetch=True)
    asistencias = resultado[0]["total_asistencias"] or 0

    if asistencias > 0:
        nuevo_estado = "finalizada"
    else:
        nuevo_estado = "sin_asistencia"

    sql_update_reserva = """
        UPDATE reserva
        SET estado = %s
        WHERE id_reserva = %s
    """
    run_query(sql_update_reserva, (nuevo_estado, id_reserva))

    #Se genera la sanción si nadie asiste a la reserva
    if asistencias == 0:
        sql_participantes = """
            SELECT ci_alumno
            FROM reserva_alumno
            WHERE id_reserva = %s
        """
        participantes = run_query(sql_participantes, (id_reserva,), fetch=True)

        #2 meses de sanción para los participantes (por letra)
        hoy = datetime.today().date()
        fin_sancion = hoy + timedelta(days=60)

        for p in participantes:
            ci = p["ci_alumno"]
            sql_insert_sancion = """
                INSERT INTO sancion_alumno (ci_alumno, fecha_inicio, fecha_fin, motivo, id_reserva)
                VALUES (%s, %s, %s, %s, %s)
            """
            motivo = "No asiste a una reserva"
            run_query(sql_insert_sancion, (ci, hoy, fin_sancion, motivo, id_reserva))

    return True



#SANCIONES
def listar_sanciones():
    sql = """
        SELECT s.id_sancion, s.ci_alumno, s.fecha_inicio, s.fecha_fin, s.motivo, a.nombre, a.apellido
        FROM sancion_alumno s
        JOIN alumno a ON a.ci = s.ci_alumno
        ORDER BY s.fecha_inicio DESC
    """
    return run_query(sql, fetch=True)

