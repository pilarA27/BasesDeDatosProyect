import { useState } from "react";
import "../styles/Administrador.css";

const API = "http://localhost:5000/api";

export default function Administrador() {
  // ============================
  // ESTADO GENERAL
  // ============================
  const [pantallaBI, setPantallaBI] = useState(false);
  const [resultado, setResultado] = useState(null);
  const [consultaActiva, setConsultaActiva] = useState(null);

  // Datos para listas
  const [alumnos, setAlumnos] = useState([]);
  const [salas, setSalas] = useState([]);
  const [reservas, setReservas] = useState([]);

  // Formularios
  const [formAlumno, setFormAlumno] = useState({
    ci: "",
    nombre: "",
    apellido: "",
    email: "",
  });

  const [formSala, setFormSala] = useState({
    id_sala: null,
    nombre_sala: "",
    id_edificio: "",
    capacidad: "",
    tipo_sala: "",
  });

  const [formAsistencia, setFormAsistencia] = useState({
    id_reserva: "",
    ci_alumno: "",
  });

  // Modal genérico Admin
  const [modalOpen, setModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState(null);
  const [modalTitle, setModalTitle] = useState("");

  const openModal = (mode, title) => {
    setModalMode(mode);
    setModalTitle(title);
    setModalOpen(true);
  };

  const closeModal = () => {
    setModalOpen(false);
    setModalMode(null);
  };

  // ============================
  // HELPERS FETCH
  // ============================
  async function cargarAlumnos() {
    const res = await fetch(`${API}/alumnos`);
    const data = await res.json();
    setAlumnos(data);
  }

  async function cargarSalas() {
    const res = await fetch(`${API}/salas`);
    const data = await res.json();
    setSalas(data);
  }

  async function cargarReservas() {
    const res = await fetch(`${API}/reservas`);
    const data = await res.json();
    setReservas(data);
  }

  // ============================
  // ALUMNOS – ABM
  // ============================

  // Crear
  const handleCrearAlumno = () => {
    setFormAlumno({ ci: "", nombre: "", apellido: "", email: "" });
    openModal("crearAlumno", "Crear alumno");
  };

  const submitCrearAlumno = async () => {
    try {
      await fetch(`${API}/alumnos`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formAlumno),
      });
      alert("Alumno creado");
      closeModal();
      await cargarAlumnos();
    } catch {
      alert("Error al crear alumno");
    }
  };

  // Listar
  const handleListarAlumnos = async () => {
    await cargarAlumnos();
    openModal("listarAlumnos", "Listado de alumnos");
  };

  // Modificar (elegir de lista)
  const handleModificarAlumno = async () => {
    await cargarAlumnos();
    openModal("modificarAlumnoElegir", "Elegí un alumno para modificar");
  };

  const startEditarAlumno = (alumno) => {
    setFormAlumno({
      ci: alumno.ci,
      nombre: alumno.nombre,
      apellido: alumno.apellido,
      email: alumno.email,
    });
    openModal("modificarAlumnoForm", "Modificar alumno");
  };

  const submitModificarAlumno = async () => {
    try {
      await fetch(`${API}/alumnos/${formAlumno.ci}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          nombre: formAlumno.nombre,
          apellido: formAlumno.apellido,
          email: formAlumno.email,
        }),
      });
      alert("Alumno modificado");
      closeModal();
      await cargarAlumnos();
    } catch {
      alert("Error al modificar alumno");
    }
  };

  // Eliminar (elegir de lista)
  const handleEliminarAlumno = async () => {
    await cargarAlumnos();
    openModal("eliminarAlumnoElegir", "Elegí un alumno para eliminar");
  };

  const eliminarAlumnoSeleccion = async (ci) => {
    const ok = window.confirm(`¿Eliminar alumno ${ci}?`);
    if (!ok) return;
    try {
      await fetch(`${API}/alumnos/${ci}`, { method: "DELETE" });
      alert("Alumno eliminado");
      await cargarAlumnos();
    } catch {
      alert("Error al eliminar alumno");
    }
  };

  // ============================
  // SALAS – ABM
  // ============================

  // Crear
  const handleCrearSala = () => {
    setFormSala({
      id_sala: null,
      nombre_sala: "",
      id_edificio: "",
      capacidad: "",
      tipo_sala: "",
    });
    openModal("crearSala", "Crear sala");
  };

  const submitCrearSala = async () => {
    try {
      await fetch(`${API}/salas`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          nombre_sala: formSala.nombre_sala,
          id_edificio: formSala.id_edificio,
          capacidad: formSala.capacidad,
          tipo_sala: formSala.tipo_sala,
        }),
      });
      alert("Sala creada");
      closeModal();
      await cargarSalas();
    } catch {
      alert("Error al crear sala");
    }
  };

  // Listar
  const handleListarSalas = async () => {
    await cargarSalas();
    openModal("listarSalas", "Listado de salas");
  };

  // Modificar (elegir de lista)
  const handleModificarSala = async () => {
    await cargarSalas();
    openModal("modificarSalaElegir", "Elegí una sala para modificar");
  };

  const startEditarSala = (s) => {
    setFormSala({
      id_sala: s.id_sala,
      nombre_sala: s.nombre_sala,
      id_edificio: s.id_edificio,
      capacidad: s.capacidad,
      tipo_sala: s.tipo_sala,
    });
    openModal("modificarSalaForm", "Modificar sala");
  };

  const submitModificarSala = async () => {
    try {
      await fetch(`${API}/salas/${formSala.id_sala}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          nombre_sala: formSala.nombre_sala,
          id_edificio: formSala.id_edificio,
          capacidad: formSala.capacidad,
          tipo_sala: formSala.tipo_sala,
        }),
      });
      alert("Sala modificada");
      closeModal();
      await cargarSalas();
    } catch {
      alert("Error al modificar sala");
    }
  };

  // Eliminar (elegir de lista)
  const handleEliminarSala = async () => {
    await cargarSalas();
    openModal("eliminarSalaElegir", "Elegí una sala para eliminar");
  };

  const eliminarSalaSeleccion = async (id_sala) => {
    const ok = window.confirm(`¿Eliminar sala ${id_sala}?`);
    if (!ok) return;
    try {
      await fetch(`${API}/salas/${id_sala}`, { method: "DELETE" });
      alert("Sala eliminada");
      await cargarSalas();
    } catch {
      alert("Error al eliminar sala");
    }
  };

  // ============================
  // RESERVAS / ASISTENCIA / SANCIONES
  // ============================

  const handleListarReservas = async () => {
    await cargarReservas();
    openModal("listarReservas", "Listado de reservas");
  };

  const handleAsistencia = () => {
    setFormAsistencia({ id_reserva: "", ci_alumno: "" });
    openModal("asistenciaForm", "Registrar asistencia");
  };

  const submitAsistencia = async () => {
    try {
      await fetch(`${API}/reservas/${formAsistencia.id_reserva}/asistencia`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ ci_alumno: formAsistencia.ci_alumno }),
      });
      alert("Asistencia registrada");
      closeModal();
    } catch {
      alert("Error al registrar asistencia");
    }
  };

  const handleListarSanciones = async () => {
    const res = await fetch(`${API}/sanciones`);
    const data = await res.json();
    setReservas(data); // usamos el mismo state como listado genérico
    openModal("listarSanciones", "Listado de sanciones");
  };

  // ============================
  // CONSULTAS BI
  // ============================
  const consultas = [
    "1 Salas más reservadas",
    "2 Turnos más demandados",
    "3 Promedio de participantes por sala",
    "4 Cantidad de reservas por carrera y facultad",
    "5 Porcentaje de ocupación de salas por edificio",
    "6 Cantidad de reservas y asistencias de profesores y alumnos (grado y posgrado)",
    "7 Cantidad de sanciones para profesores y alumnos (grado y posgrado)",
    "8 Porcentaje de reservas efectivamente utilizadas vs. canceladas/no asistidas",
    "9 Ranking alumnos más activos",
    "10 Ranking de tipo de edificios más utilizados",
    "11 Reservas por sala por día de la semana",
  ];

  async function ejecutarConsulta(id, setResultado, setConsultaActiva) {
    const res = await fetch(`${API}/bi/${id}`);
    const data = await res.json();
    setConsultaActiva(id);
    setResultado(data);
  }

  // ============================
  // RENDER PANTALLA BI
  // ============================
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
                onClick={() =>
                  ejecutarConsulta(i + 1, setResultado, setConsultaActiva)
                }
              >
                {t}
              </button>
            ))}
          </div>

          {resultado && resultado.length > 0 && (
            consultaActiva === 8 ? (
              <table className="result-table">
                <thead>
                  <tr>
                    <th>Categoría</th>
                    <th>Total</th>
                    <th>% sobre el total</th>
                  </tr>
                </thead>
                <tbody>
                  {resultado.map((row, i) => (
                    <tr key={i}>
                      <td>{row.categoria}</td>
                      <td>{row.total}</td>
                      <td>{row.porcentaje}%</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            ) : (
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
            )
          )}

          {resultado && resultado.length === 0 && (
            <p>No hay datos para esta consulta.</p>
          )}

          <button
            className="close-consultas-btn"
            onClick={() => {
              setPantallaBI(false);
              setResultado(null);
              setConsultaActiva(null);
            }}
          >
            Cerrar
          </button>
        </div>
      </div>
    );
  }

  // ============================
  // RENDER PRINCIPAL ADMIN
  // ============================
  return (
    <div className="admin-container">
      <h1>Administración</h1>

      <div className="admin-row">
        {/* ALUMNOS */}
        <div className="button-box">
          <div>Alumnos</div>
          <button onClick={handleCrearAlumno}>Crear</button>
          <button onClick={handleModificarAlumno}>Modificar</button>
          <button onClick={handleListarAlumnos}>Ver todos</button>
          <button onClick={handleEliminarAlumno}>Eliminar</button>
        </div>

        {/* SALAS */}
        <div className="button-box">
          <div>Salas</div>
          <button onClick={handleCrearSala}>Crear</button>
          <button onClick={handleModificarSala}>Modificar</button>
          <button onClick={handleListarSalas}>Ver todas</button>
          <button onClick={handleEliminarSala}>Eliminar</button>
        </div>

        {/* RESERVAS */}
        <div className="button-box">
          <div>Reservas</div>
          <button onClick={handleListarReservas}>Ver todas</button>
          <button onClick={handleAsistencia}>Confirmar asistencia</button>
        </div>

        {/* SANCIONES */}
        <div className="button-box">
          <div>Sanciones</div>
          <button onClick={handleListarSanciones}>Ver todas</button>
        </div>

        {/* CONSULTAS BI */}
        <div className="button-box">
          <div>Consultas BI</div>
          <button onClick={() => setPantallaBI(true)}>Mostrar consultas</button>
        </div>

        {/* VOLVER */}
        <div className="button-box">
          <div>Volver</div>
          <button className="back-btn" onClick={() => window.history.back()}>
            Atrás
          </button>
        </div>
      </div>

      {/* MODAL ADMIN */}
      {modalOpen && (
        <div className="modal-overlay" onClick={closeModal}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h2>{modalTitle}</h2>

            {/* Crear / editar alumno */}
            {modalMode === "crearAlumno" && (
              <>
                <div className="form-box">
                  <input
                    placeholder="CI"
                    value={formAlumno.ci}
                    onChange={(e) =>
                      setFormAlumno((f) => ({ ...f, ci: e.target.value }))
                    }
                  />
                  <input
                    placeholder="Nombre"
                    value={formAlumno.nombre}
                    onChange={(e) =>
                      setFormAlumno((f) => ({ ...f, nombre: e.target.value }))
                    }
                  />
                  <input
                    placeholder="Apellido"
                    value={formAlumno.apellido}
                    onChange={(e) =>
                      setFormAlumno((f) => ({ ...f, apellido: e.target.value }))
                    }
                  />
                  <input
                    placeholder="Email"
                    value={formAlumno.email}
                    onChange={(e) =>
                      setFormAlumno((f) => ({ ...f, email: e.target.value }))
                    }
                  />
                </div>
                <button className="confirm-btn" onClick={submitCrearAlumno}>
                  Guardar
                </button>
                <button className="close-btn" onClick={closeModal}>
                  Cancelar
                </button>
              </>
            )}

            {modalMode === "listarAlumnos" && (
              <div className="list-scroll">
                {alumnos.map((a) => (
                  <div key={a.ci} className="list-item">
                    <strong>{a.ci}</strong> — {a.nombre} {a.apellido} (
                    {a.email})
                  </div>
                ))}
              </div>
            )}

            {modalMode === "modificarAlumnoElegir" && (
              <div className="list-scroll">
                {alumnos.map((a) => (
                  <div
                    key={a.ci}
                    className="list-item"
                    onClick={() => startEditarAlumno(a)}
                  >
                    <strong>{a.ci}</strong> — {a.nombre} {a.apellido} (
                    {a.email})
                  </div>
                ))}
              </div>
            )}

            {modalMode === "modificarAlumnoForm" && (
              <>
                <div className="form-box">
                  <input value={formAlumno.ci} disabled />
                  <input
                    placeholder="Nombre"
                    value={formAlumno.nombre}
                    onChange={(e) =>
                      setFormAlumno((f) => ({ ...f, nombre: e.target.value }))
                    }
                  />
                  <input
                    placeholder="Apellido"
                    value={formAlumno.apellido}
                    onChange={(e) =>
                      setFormAlumno((f) => ({ ...f, apellido: e.target.value }))
                    }
                  />
                  <input
                    placeholder="Email"
                    value={formAlumno.email}
                    onChange={(e) =>
                      setFormAlumno((f) => ({ ...f, email: e.target.value }))
                    }
                  />
                </div>
                <button className="confirm-btn" onClick={submitModificarAlumno}>
                  Guardar cambios
                </button>
                <button className="close-btn" onClick={closeModal}>
                  Cancelar
                </button>
              </>
            )}

            {modalMode === "eliminarAlumnoElegir" && (
              <div className="list-scroll">
                {alumnos.map((a) => (
                  <div
                    key={a.ci}
                    className="list-item"
                    onClick={() => eliminarAlumnoSeleccion(a.ci)}
                  >
                    <strong>{a.ci}</strong> — {a.nombre} {a.apellido} (
                    {a.email})
                  </div>
                ))}
              </div>
            )}

            {/* Crear / editar sala */}
            {modalMode === "crearSala" && (
              <>
                <div className="form-box">
                  <input
                    placeholder="Nombre sala"
                    value={formSala.nombre_sala}
                    onChange={(e) =>
                      setFormSala((f) => ({
                        ...f,
                        nombre_sala: e.target.value,
                      }))
                    }
                  />
                  <input
                    placeholder="ID edificio"
                    value={formSala.id_edificio}
                    onChange={(e) =>
                      setFormSala((f) => ({
                        ...f,
                        id_edificio: e.target.value,
                      }))
                    }
                  />
                  <input
                    placeholder="Capacidad"
                    value={formSala.capacidad}
                    onChange={(e) =>
                      setFormSala((f) => ({
                        ...f,
                        capacidad: e.target.value,
                      }))
                    }
                  />
                  <input
                    placeholder="Tipo (libre/docente/posgrado)"
                    value={formSala.tipo_sala}
                    onChange={(e) =>
                      setFormSala((f) => ({
                        ...f,
                        tipo_sala: e.target.value,
                      }))
                    }
                  />
                </div>
                <button className="confirm-btn" onClick={submitCrearSala}>
                  Guardar
                </button>
                <button className="close-btn" onClick={closeModal}>
                  Cancelar
                </button>
              </>
            )}

            {modalMode === "listarSalas" && (
              <div className="list-scroll">
                {salas.map((s) => (
                  <div key={s.id_sala} className="list-item">
                    <strong>ID {s.id_sala}</strong> — {s.nombre_sala} (Edif.{" "}
                    {s.id_edificio}, cap. {s.capacidad}, {s.tipo_sala})
                  </div>
                ))}
              </div>
            )}

            {modalMode === "modificarSalaElegir" && (
              <div className="list-scroll">
                {salas.map((s) => (
                  <div
                    key={s.id_sala}
                    className="list-item"
                    onClick={() => startEditarSala(s)}
                  >
                    <strong>ID {s.id_sala}</strong> — {s.nombre_sala} (Edif.{" "}
                    {s.id_edificio}, cap. {s.capacidad}, {s.tipo_sala})
                  </div>
                ))}
              </div>
            )}

            {modalMode === "modificarSalaForm" && (
              <>
                <div className="form-box">
                  <input value={formSala.id_sala ?? ""} disabled />
                  <input
                    placeholder="Nombre sala"
                    value={formSala.nombre_sala}
                    onChange={(e) =>
                      setFormSala((f) => ({
                        ...f,
                        nombre_sala: e.target.value,
                      }))
                    }
                  />
                  <input
                    placeholder="ID edificio"
                    value={formSala.id_edificio}
                    onChange={(e) =>
                      setFormSala((f) => ({
                        ...f,
                        id_edificio: e.target.value,
                      }))
                    }
                  />
                  <input
                    placeholder="Capacidad"
                    value={formSala.capacidad}
                    onChange={(e) =>
                      setFormSala((f) => ({
                        ...f,
                        capacidad: e.target.value,
                      }))
                    }
                  />
                  <input
                    placeholder="Tipo (libre/docente/posgrado)"
                    value={formSala.tipo_sala}
                    onChange={(e) =>
                      setFormSala((f) => ({
                        ...f,
                        tipo_sala: e.target.value,
                      }))
                    }
                  />
                </div>
                <button className="confirm-btn" onClick={submitModificarSala}>
                  Guardar cambios
                </button>
                <button className="close-btn" onClick={closeModal}>
                  Cancelar
                </button>
              </>
            )}

            {modalMode === "eliminarSalaElegir" && (
              <div className="list-scroll">
                {salas.map((s) => (
                  <div
                    key={s.id_sala}
                    className="list-item"
                    onClick={() => eliminarSalaSeleccion(s.id_sala)}
                  >
                    <strong>ID {s.id_sala}</strong> — {s.nombre_sala} (Edif.{" "}
                    {s.id_edificio}, cap. {s.capacidad}, {s.tipo_sala})
                  </div>
                ))}
              </div>
            )}

            {/* Reservas */}
            {modalMode === "listarReservas" && (
              <div className="list-scroll">
                {reservas.map((r) => (
                  <div key={r.id_reserva} className="list-item">
                    <strong>ID {r.id_reserva}</strong> — Sala {r.id_sala} —{" "}
                    {r.fecha} {r.hora_inicio} a {r.hora_fin} — Estado:{" "}
                    {r.estado}
                  </div>
                ))}
              </div>
            )}

            {/* Asistencia */}
            {modalMode === "asistenciaForm" && (
              <>
                <div className="form-box">
                  <input
                    placeholder="ID reserva"
                    value={formAsistencia.id_reserva}
                    onChange={(e) =>
                      setFormAsistencia((f) => ({
                        ...f,
                        id_reserva: e.target.value,
                      }))
                    }
                  />
                  <input
                    placeholder="CI alumno"
                    value={formAsistencia.ci_alumno}
                    onChange={(e) =>
                      setFormAsistencia((f) => ({
                        ...f,
                        ci_alumno: e.target.value,
                      }))
                    }
                  />
                </div>
                <button className="confirm-btn" onClick={submitAsistencia}>
                  Registrar asistencia
                </button>
                <button className="close-btn" onClick={closeModal}>
                  Cancelar
                </button>
              </>
            )}

            {/* Sanciones */}
            {modalMode === "listarSanciones" && (
              <div className="list-scroll">
                {reservas.map((s) => (
                  <div key={s.id_sancion} className="list-item">
                    <strong>CI {s.ci_alumno}</strong> — {s.motivo} —{" "}
                    {s.fecha_inicio} a {s.fecha_fin}
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
