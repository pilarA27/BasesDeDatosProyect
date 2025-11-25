from flask import Flask, jsonify, request
from flask_cors import CORS
from datetime import date, timedelta

from db_config import get_connection

from funciones_abm import (
    listar_alumnos, alta_alumno, eliminar_alumno, modificar_alumno,
    listar_salas, alta_sala, eliminar_sala, modificar_sala,
    crear_reserva, agregar_alumno_a_reserva, cancelar_reserva,
    listar_reservas, registrar_asistencia, cerrar_reserva,
    listar_sanciones, listar_turnos,
)

from queries_bi import ejecutar_bi

app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": "*"}})


# ================================================================
#   GENERAR TURNOS AUTOMÁTICAMENTE
# ================================================================
def generar_turnos_auto():
    cn = get_connection()
    cur = cn.cursor()

    hoy = date.today()

    cur.execute("SELECT id_sala FROM sala")
    salas = [row[0] for row in cur.fetchall()]

    for id_sala in salas:
        for d in range(7):  # 7 días hacia adelante
            fecha = hoy + timedelta(days=d)

            for h in range(15):  # 08:00 -> 23:00 (bloques de 1h)
                cur.execute(
                    """
                    SELECT 1 FROM turno
                    WHERE id_sala=%s AND fecha=%s
                    AND hora_inicio = ADDTIME('08:00:00', SEC_TO_TIME(%s*3600))
                    """,
                    (id_sala, fecha, h)
                )
                if cur.fetchone():
                    continue

                cur.execute(
                    """
                    INSERT INTO turno (id_sala, fecha, hora_inicio, hora_fin, disponible)
                    VALUES (
                        %s, %s,
                        ADDTIME('08:00:00', SEC_TO_TIME(%s*3600)),
                        ADDTIME('09:00:00', SEC_TO_TIME(%s*3600)),
                        1
                    )
                    """,
                    (id_sala, fecha, h, h)
                )

    cn.commit()
    cn.close()
    print("TURNOS → Generados correctamente.")


@app.after_request
def add_cors_headers(response):
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Headers"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "*"
    return response


# ================================================================
#   ALUMNOS
# ================================================================
@app.get("/api/alumnos")
def api_listar_alumnos():
    return jsonify(listar_alumnos())

@app.post("/api/alumnos")
def api_alta_alumno():
    data = request.json
    alta_alumno(data["ci"], data["nombre"], data["apellido"], data["email"])
    return {"status": "ok"}, 201

@app.put("/api/alumnos/<ci>")
def api_modificar_alumno(ci):
    data = request.json
    modificar_alumno(ci, data["nombre"], data["apellido"], data["email"])
    return {"status": "ok"}

@app.delete("/api/alumnos/<ci>")
def api_eliminar_alumno(ci):
    eliminar_alumno(ci)
    return {"status": "ok"}


# ================================================================
#   SALAS
# ================================================================
@app.get("/api/salas")
def api_listar_salas():
    return jsonify(listar_salas())

@app.post("/api/salas")
def api_alta_sala():
    data = request.json
    alta_sala(data["nombre_sala"], data["id_edificio"], data["capacidad"], data["tipo_sala"])
    return {"status": "ok"}, 201

@app.put("/api/salas/<int:id_sala>")
def api_modificar_sala(id_sala):
    data = request.json
    modificar_sala(
        id_sala,
        data["nombre_sala"],
        data["id_edificio"],
        data["capacidad"],
        data["tipo_sala"],
    )
    return {"status": "ok"}

@app.delete("/api/salas/<int:id_sala>")
def api_eliminar_sala(id_sala):
    eliminar_sala(id_sala)
    return {"status": "ok"}


# ================================================================
#   TURNOS
# ================================================================
@app.get("/api/turnos")
def api_listar_turnos():
    return jsonify(listar_turnos())


@app.get("/api/turnos_disponibles")
def api_turnos_disponibles():
    id_sala = request.args.get("id_sala", type=int)
    fecha = request.args.get("fecha")

    sql = """
        SELECT 
            t.id_turno, t.hora_inicio, t.hora_fin,
            DAYNAME(t.fecha) AS dia_en_ing,
            (s.capacidad - COALESCE(oc.total, 0)) AS cupos_disponibles
        FROM turno t
        JOIN sala s ON s.id_sala = t.id_sala
        LEFT JOIN (
            SELECT r.id_turno, COUNT(*) AS total
            FROM reserva_alumno ra
            JOIN reserva r ON r.id_reserva = ra.id_reserva
            WHERE r.estado = 'activa'
            GROUP BY r.id_turno
        ) oc ON oc.id_turno = t.id_turno
        WHERE t.id_sala=%s
          AND t.fecha=%s
          AND t.disponible=1
          AND (s.capacidad - COALESCE(oc.total, 0)) > 0
        ORDER BY t.hora_inicio
    """

    cn = get_connection()
    cur = cn.cursor(dictionary=True)
    cur.execute(sql, (id_sala, fecha))
    rows = cur.fetchall()
    cn.close()

    dias_es = {
        "Monday": "Lunes", "Tuesday": "Martes", "Wednesday": "Miércoles",
        "Thursday": "Jueves", "Friday": "Viernes", "Saturday": "Sábado", "Sunday": "Domingo"
    }

    for r in rows:
        r["hora_inicio"] = str(r["hora_inicio"])
        r["hora_fin"] = str(r["hora_fin"])
        r["cupos_disponibles"] = int(r["cupos_disponibles"])
        r["dia"] = dias_es.get(r["dia_en_ing"], r["dia_en_ing"])
        del r["dia_en_ing"]

    return jsonify(rows)


# ================================================================
#   RESERVAS
# ================================================================
@app.get("/api/reservas")
def api_listar_reservas():
    return jsonify(listar_reservas())

@app.post("/api/reservas")
def api_crear_reserva():
    data = request.json

    nuevo_id = crear_reserva(
        data["id_sala"], data["fecha"], data["id_turno"], data["creado_por"]
    )

    return {"status": "ok", "id_reserva": nuevo_id}, 201

@app.put("/api/reservas/<int:id_reserva>/cancelar")
def api_cancelar_reserva(id_reserva):
    cancelar_reserva(id_reserva)
    return {"status": "ok"}

@app.post("/api/reservas/<int:id_reserva>/asistencia")
def api_asistencia(id_reserva):
    data = request.json
    registrar_asistencia(id_reserva, data["ci_alumno"])
    return {"status": "ok"}

@app.post("/api/reservas/<int:id_reserva>/cerrar")
def api_cerrar_reserva(id_reserva):
    cerrar_reserva(id_reserva)
    return {"status": "ok"}


# ================================================================
#   SANCIONES
# ================================================================
@app.get("/api/sanciones")
def api_sanciones():
    return jsonify(listar_sanciones())


# ================================================================
#   CONSULTAS BI
# ================================================================
@app.get("/api/bi/<int:consulta_id>")
def api_bi(consulta_id):
    try:
        return jsonify(ejecutar_bi(consulta_id))
    except ValueError as e:
        return {"error": str(e)}, 400


# ================================================================
#   MAIN
# ================================================================
if __name__ == "__main__":
    with app.app_context():
        generar_turnos_auto()

    app.run(port=5000, debug=True)
