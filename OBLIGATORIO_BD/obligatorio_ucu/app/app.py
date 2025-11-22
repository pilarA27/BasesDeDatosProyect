from flask import Flask, jsonify, request
from flask_cors import CORS

from funciones_abm import (
    # ALUMNOS
    listar_alumnos, alta_alumno, eliminar_alumno, modificar_alumno,
    # SALAS
    listar_salas, alta_sala, eliminar_sala, modificar_sala,
    # RESERVAS / ASISTENCIA / SANCIONES
    crear_reserva, agregar_alumno_a_reserva, cancelar_reserva,
    listar_reservas, registrar_asistencia, cerrar_reserva,
    listar_sanciones, listar_turnos,
)

from consultas_bi import ejecutar_bi

app = Flask(__name__)

CORS(app, resources={r"/api/*": {"origins": "*"}})

@app.after_request
def add_cors_headers(response):
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
    return response

# ALUMNOS
@app.get("/api/alumnos")
def api_listar_alumnos():
    alumnos = listar_alumnos()
    return jsonify(alumnos)

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
 
# SALAS
@app.get("/api/salas")
def api_listar_salas():
    salas = listar_salas()
    return jsonify(salas)

@app.post("/api/salas")
def api_alta_sala():
    data = request.json
    alta_sala(
        data["nombre_sala"],
        data["id_edificio"],
        data["capacidad"],
        data["tipo_sala"],
    )
    return {"status": "ok"}, 201

    # TURNOS
@app.get("/api/turnos")
def api_listar_turnos():
    turnos = listar_turnos()
    return jsonify(turnos)


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

# RESERVAS
@app.get("/api/reservas")
def api_listar_reservas():
    reservas = listar_reservas()
    return jsonify(reservas)

@app.post("/api/reservas")
def api_crear_reserva():
    data = request.json

    # 1) Crear reserva
    nuevo_id = crear_reserva(
        data["id_sala"],
        data["fecha"],
        data["id_turno"],
        data["creado_por"],
    )

    # 2) Agregar automáticamente al creador como participante
    agregar_alumno_a_reserva(nuevo_id, data["creado_por"])

    return {"status": "ok", "id_reserva": nuevo_id}, 201


@app.post("/api/reservas/<int:id_reserva>/alumno")
def api_agregar_alumno(id_reserva):
    """
    Espera JSON:
    {
      "ci_alumno": "4.111.111-1"
    }
    """
    data = request.json
    agregar_alumno_a_reserva(id_reserva, data["ci_alumno"])
    return {"status": "ok"}, 201

@app.put("/api/reservas/<int:id_reserva>/cancelar")
def api_cancelar_reserva(id_reserva):
    cancelar_reserva(id_reserva)
    return {"status": "ok"}

@app.post("/api/reservas/<int:id_reserva>/asistencia")
def api_registrar_asistencia(id_reserva):
    """
    Marca asistencia del alumno en la reserva.
    Espera JSON:
    {
      "ci_alumno": "4.111.111-1"
    }
    """
    data = request.json
    registrar_asistencia(id_reserva, data["ci_alumno"])
    return {"status": "ok"}

@app.post("/api/reservas/<int:id_reserva>/cerrar")
def api_cerrar_reserva(id_reserva):
    """
    Cierra la reserva:
    - Si hubo al menos una asistencia -> estado = 'finalizada'
    - Si no hubo asistencia -> estado = 'sin_asistencia' + genera sanciones
    """
    cerrar_reserva(id_reserva)
    return {"status": "ok"}


# SANCIONES
@app.get("/api/sanciones")
def api_listar_sanciones():
    sanciones = listar_sanciones()
    return jsonify(sanciones)

# CONSULTAS BI
@app.get("/api/bi/<int:consulta_id>")
def api_bi(consulta_id: int):
    """
    Ejecuta las consultas BI definidas en consultas_bi.py.
    Por ejemplo:
    - /api/bi/1 -> salas más reservadas
    - /api/bi/2 -> turnos más demandados
    """
    try:
        resultado = ejecutar_bi(consulta_id)
        return jsonify(resultado)
    except ValueError as e:
        return {"error": str(e)}, 400

# MAIN
if __name__ == "__main__":
    app.run(port=5000, debug=True)
