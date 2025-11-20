from db_config import get_connection
from datetime import datetime, timedelta

# HELPER GENERAL (revisar esto)
def run_query(sql, params=None, fetch=False):
    cn = get_connection()
    try:
        cur = cn.cursor(dictionary=True)
        cur.execute(sql, params or ())
        if fetch:
            return cur.fetchall()
        else:
            cn.commit()
            return cur.rowcount
    finally:
        cn.close()
# ALUMNOS
def alta_alumno(ci, nombre, apellido, email):
    sql = "INSERT INTO alumno (ci, nombre, apellido, email) VALUES (%s, %s, %s, %s)"
    return run_query(sql, (ci, nombre, apellido, email))

def listar_alumnos():
    sql = "SELECT * FROM alumno ORDER BY apellido, nombre"
    return run_query(sql, fetch=True)

def modificar_alumno(ci, nombre, apellido, email):
    sql = "UPDATE alumno SET nombre=%s, apellido=%s, email=%s WHERE ci=%s"
    return run_query(sql, (nombre, apellido, email, ci))

def eliminar_alumno(ci):
    sql = "DELETE FROM alumno WHERE ci=%s"
    return run_query(sql, (ci,))

# SALAS
def alta_sala(nombre_sala, id_edificio, capacidad, tipo_sala):
    sql = """
        INSERT INTO sala (nombre_sala, id_edificio, capacidad, tipo_sala)
        VALUES (%s, %s, %s, %s)
    """
    return run_query(sql, (nombre_sala, id_edificio, capacidad, tipo_sala))

def listar_salas():
    sql = """
        SELECT 
            s.id_sala, s.nombre_sala, s.capacidad, s.tipo_sala,
            e.nombre_edificio AS edificio
        FROM sala s
        JOIN edificio e ON s.id_edificio = e.id_edificio
        ORDER BY e.nombre_edificio, s.nombre_sala
    """
    return run_query(sql, fetch=True)

def modificar_sala(id_sala, nombre_sala, id_edificio, capacidad, tipo_sala):
    sql = """
        UPDATE sala
        SET nombre_sala=%s, id_edificio=%s, capacidad=%s, tipo_sala=%s
        WHERE id_sala=%s
    """
    return run_query(sql, (nombre_sala, id_edificio, capacidad, tipo_sala, id_sala))

def eliminar_sala(id_sala):
    sql = "DELETE FROM sala WHERE id_sala=%s"
    return run_query(sql, (id_sala,))

# RESERVAS
def crear_reserva(id_sala, fecha, id_turno, creado_por):
    sql = """
        INSERT INTO reserva (id_sala, fecha, id_turno, creado_por)
        VALUES (%s, %s, %s, %s)
    """
    return run_query(sql, (id_sala, fecha, id_turno, creado_por))

def agregar_alumno_a_reserva(id_reserva, ci):
    sql = """
        INSERT INTO reserva_alumno (id_reserva, ci_alumno)
        VALUES (%s, %s)
    """
    return run_query(sql, (id_reserva, ci))

def cancelar_reserva(id_reserva):
    sql = "UPDATE reserva SET estado='cancelada' WHERE id_reserva=%s"
    return run_query(sql, (id_reserva,))

def listar_reservas():
    sql = """
        SELECT 
            r.id_reserva,
            r.id_sala,
            r.fecha,
            r.id_turno,
            r.creado_por,
            t.hora_inicio,
            t.hora_fin
        FROM reserva r
        JOIN turno t ON r.id_turno = t.id_turno
        ORDER BY r.id_reserva DESC
    """
    
    rows = run_query(sql, fetch=True)

    reservas = []
    for r in rows:
        reservas.append({
            "id_reserva": r["id_reserva"],
            "id_sala": r["id_sala"],
            "fecha": str(r["fecha"]),            # FIX DATE
            "id_turno": r["id_turno"],
            "creado_por": r["creado_por"],
            "hora_inicio": str(r["hora_inicio"]), # FIX TIME
            "hora_fin": str(r["hora_fin"])        # FIX TIME
        })
    return reservas

# ASISTENCIA
def registrar_asistencia(id_reserva, ci):
    sql = """
        UPDATE reserva_alumno
        SET asistencia = 1, checkin_ts = CURRENT_TIMESTAMP
        WHERE id_reserva=%s AND ci_alumno=%s
    """
    return run_query(sql, (id_reserva, ci))

def cerrar_reserva(id_reserva):
    # 1) Verificar asistencia
    sql_asistencia = """
        SELECT SUM(asistencia) AS total_asistencias
        FROM reserva_alumno
        WHERE id_reserva=%s
    """
    result = run_query(sql_asistencia, (id_reserva,), fetch=True)
    asistencias = result[0]["total_asistencias"] or 0

    nuevo_estado = "finalizada" if asistencias > 0 else "sin_asistencia"

    sql_update = "UPDATE reserva SET estado=%s WHERE id_reserva=%s"
    run_query(sql_update, (nuevo_estado, id_reserva))

    # 2) Generar sanción si nadie fue
    if asistencias == 0:
        sql_participantes = """
            SELECT ci_alumno
            FROM reserva_alumno
            WHERE id_reserva=%s
        """
        participantes = run_query(sql_participantes, (id_reserva,), fetch=True)

        hoy = datetime.today().date()
        fin_sancion = hoy + timedelta(days=60)

        for p in participantes:
            sql_sancion = """
                INSERT INTO sancion_alumno (ci_alumno, fecha_inicio, fecha_fin, motivo, id_reserva)
                VALUES (%s, %s, %s, %s, %s)
            """
            run_query(sql_sancion, (
                p["ci_alumno"],
                hoy,
                fin_sancion,
                "No asiste a una reserva",
                id_reserva
            ))

    return True
# SANCIONES
def listar_sanciones():
    sql = """
        SELECT 
            s.id_sancion, s.ci_alumno, s.fecha_inicio, s.fecha_fin,
            s.motivo, a.nombre, a.apellido
        FROM sancion_alumno s
        JOIN alumno a ON a.ci = s.ci_alumno
        ORDER BY s.fecha_inicio DESC
    """
    rows = run_query(sql, fetch=True)

    # cast fechas a string 
    for r in rows:
        r["fecha_inicio"] = str(r["fecha_inicio"])
        r["fecha_fin"] = str(r["fecha_fin"])

    return rows
