import { useState } from "react";
import "../styles/Administrador.css";

const API = "http://localhost:5000/api";

//crud alumnos
async function crearAlumno() {
  const ci = prompt("CI:");
  const nombre = prompt("Nombre:");
  const apellido = prompt("Apellido:");
  const email = prompt("Email:");
  if (!ci || !nombre || !apellido || !email) return;

  await fetch(`${API}/alumnos`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ ci, nombre, apellido, email }),
  });

  alert("Alumno creado");
}

async function modificarAlumno() {
  const ci = prompt("CI del alumno a modificar:");
  if (!ci) return;
  const nombre = prompt("Nuevo nombre:");
  const apellido = prompt("Nuevo apellido:");
  const email = prompt("Nuevo email:");

  await fetch(`${API}/alumnos/${ci}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ nombre, apellido, email }),
  });

  alert("Alumno modificado");
}

async function eliminarAlumno() {
  const ci = prompt("CI a eliminar:");
  if (!ci) return;

  await fetch(`${API}/alumnos/${ci}`, { method: "DELETE" });
  alert("Alumno eliminado");
}

async function listarAlumnos() {
  const res = await fetch(`${API}/alumnos`);
  const data = await res.json();
  console.log("ALUMNOS:", data);
  alert("Revisá la consola → alumnos listados");
}

//crud salas
async function crearSala() {
  const nombre_sala = prompt("Nombre sala:");
  const id_edificio = prompt("ID edificio:");
  const capacidad = prompt("Capacidad:");
  const tipo_sala = prompt("Tipo (libre/docente/posgrado):");

  await fetch(`${API}/salas`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ nombre_sala, id_edificio, capacidad, tipo_sala }),
  });

  alert("Sala creada");
}

async function modificarSala() {
  const id_sala = prompt("ID sala a modificar:");
  if (!id_sala) return;

  const nombre_sala = prompt("Nuevo nombre:");
  const id_edificio = prompt("Nuevo edificio:");
  const capacidad = prompt("Nueva capacidad:");
  const tipo_sala = prompt("Nuevo tipo:");

  await fetch(`${API}/salas/${id_sala}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ nombre_sala, id_edificio, capacidad, tipo_sala }),
  });

  alert("Sala modificada");
}

async function eliminarSala() {
  const id_sala = prompt("ID sala a eliminar:");
  if (!id_sala) return;

  await fetch(`${API}/salas/${id_sala}`, { method: "DELETE" });
  alert("Sala eliminada");
}

async function listarSalas() {
  const res = await fetch(`${API}/salas`);
  const data = await res.json();
  console.log("SALAS:", data);
  alert("Revisá consola → salas listadas");
}

//listar reservas
async function listarReservas() {
  const res = await fetch(`${API}/reservas`);
  const data = await res.json();
  console.log("RESERVAS:", data);
  alert("Revisá consola → reservas listadas");
}

async function confirmarAsistencia() {
  const id_reserva = prompt("ID de la reserva:");
  const ci_alumno = prompt("CI del alumno:");

  await fetch(`${API}/reservas/${id_reserva}/asistencia`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ ci_alumno }),
  });

  alert("Asistencia registrada");
}

//listar sanciones
async function listarSanciones() {
  const res = await fetch(`${API}/sanciones`);
  const data = await res.json();
  console.log("SANCIONES:", data);
  alert("Revisá consola → sanciones listadas");
}

//consultas bi
async function ejecutarConsulta(id, setResultado) {
  const res = await fetch(`${API}/bi/${id}`);
  const data = await res.json();
  setResultado(data);
}

//menu
export default function Administrador() {
  const [pantallaBI, setPantallaBI] = useState(false);
  const [resultado, setResultado] = useState(null);

  const consultas = [
    "Salas más reservadas",
    "Turnos más demandados",
    "Promedio de participantes por sala",
    "Cantidad de reservas por carrera y facultad",
    "Porcentaje de ocupación de salas por edificio",
    "Cantidad de reservas y asistencias de profesores y alumnos (grado y posgrado)",
    "Cantidad de sanciones para profesores y alumnos (grado y posgrado)",
    "Porcentaje de reservas efectivamente utilizadas vs. canceladas/no asistidas",
    "Ranking alumnos más activos",
    "Ranking de tipo de edificios más utilizados",
    "Reservas por sala por dia de la seman",
    "FALTA",
  ];

//pantalla bi
  if (pantallaBI) {
    return (
      <div className="consultas-overlay">
        <div className="consultas-panel">

          <h2>Consultas BI</h2>

          <div className="consultas-list">
            {consultas.map((t, i) => (
              <button
                key={i}
                className="consulta-btn"
                onClick={() => ejecutarConsulta(i + 1, setResultado)}
              >
                {t}
              </button>
            ))}
          </div>

          {resultado && (
            <table className="result-table">
              <thead>
                <tr>
                  {Object.keys(resultado[0] || {}).map((col) => (
                    <th key={col}>{col}</th>
                  ))}
                </tr>
              </thead>

              <tbody>
                {resultado.map((fila, i) => (
                  <tr key={i}>
                    {Object.values(fila).map((val, j) => (
                      <td key={j}>{val}</td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          )}

          <button
            className="close-consultas-btn"
            onClick={() => {
              setPantallaBI(false);
              setResultado(null);
            }}
          >
            Cerrar
          </button>
        </div>
      </div>
    );
  }

  /*
  MENÚ PRINCIPAL*/
  return (
    <div className="admin-container">
      <h1>Administración</h1>

      <div className="admin-row">

        <div className="button-box">
          <div>Alumnos</div>
          <button onClick={crearAlumno}>Crear</button>
          <button onClick={modificarAlumno}>Modificar</button>
          <button onClick={listarAlumnos}>Ver todos</button>
          <button onClick={eliminarAlumno}>Eliminar</button>
        </div>

        <div className="button-box">
          <div>Salas</div>
          <button onClick={crearSala}>Crear</button>
          <button onClick={modificarSala}>Modificar</button>
          <button onClick={listarSalas}>Ver todas</button>
          <button onClick={eliminarSala}>Eliminar</button>
        </div>

        <div className="button-box">
          <div>Reservas</div>
          <button onClick={listarReservas}>Ver todas</button>
          <button onClick={confirmarAsistencia}>Confirmar asistencia</button>
        </div>

        <div className="button-box">
          <div>Sanciones</div>
          <button onClick={listarSanciones}>Ver todas</button>
        </div>

        <div className="button-box">
          <div>Consultas BI</div>
          <button onClick={() => setPantallaBI(true)}>
            Mostrar consultas
          </button>
        </div>

        <div className="button-box">
          <div>Volver</div>
          <button className="back-btn" onClick={() => window.history.back()}>
            Atrás
          </button>
        </div>

      </div>
    </div>
  );
}
