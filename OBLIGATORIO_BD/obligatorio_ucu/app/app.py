from flask import Flask, jsonify, request
from flask_cors import CORS
from funciones_abm import (
    listar_alumnos, alta_alumno, eliminar_alumno,
    listar_salas, alta_sala, eliminar_sala
)

app = Flask(__name__)
CORS(app)

# ---- ALUMNOS ----
@app.get("/api/alumnos")
def api_listar_alumnos():
    return jsonify(listar_alumnos())

@app.post("/api/alumnos")
def api_alta_alumno():
    data = request.json
    alta_alumno(data["ci"], data["nombre"], data["apellido"], data["email"])
    return {"status": "ok"}

@app.delete("/api/alumnos/<ci>")
def api_eliminar_alumno(ci):
    eliminar_alumno(ci)
    return {"status": "ok"}

# ---- SALAS ----
@app.get("/api/salas")
def api_listar_salas():
    return jsonify(listar_salas())

@app.post("/api/salas")
def api_alta_sala():
    data = request.json
    alta_sala(data["nombre_sala"], data["id_edificio"], data["capacidad"], data["tipo_sala"])
    return {"status": "ok"}

@app.delete("/api/salas/<id_sala>")
def api_eliminar_sala(id_sala):
    eliminar_sala(id_sala)
    return {"status": "ok"}


if __name__ == "__main__":
    app.run(port=5000, debug=True)
