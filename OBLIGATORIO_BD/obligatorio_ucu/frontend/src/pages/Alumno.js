import { useEffect, useState } from "react";
import "../styles/Alumno.css";

export default function Alumno() {
  const [salas, setSalas] = useState([]);
  const [turnos, setTurnos] = useState([]);
  const [reservas, setReservas] = useState([]);
  const [errorBackend, setErrorBackend] = useState(false);

  const [modal, setModal] = useState({
    open: false,
    title: "",
    content: null,
    showInput: false,
    inputValue: "",
    onConfirm: null,
  });

  const openModal = (title, content = null, showInput = false, onConfirm = null) => {
    setModal({
      open: true,
      title,
      content,
      showInput,
      inputValue: "",
      onConfirm,
    });
  };

  const closeModal = () => {
    setModal({
      open: false,
      title: "",
      content: null,
      showInput: false,
      inputValue: "",
      onConfirm: null,
    });
  };

  // -------------------------------------------------
  //   CARGA INICIAL
  // -------------------------------------------------
  useEffect(() => {
    fetch("http://localhost:5000/api/salas")
      .then((res) => res.json())
      .then((data) => setSalas(data))
      .catch(() => {
        setErrorBackend(true);
        setSalas([]);
      });

    fetch("http://localhost:5000/api/turnos")
      .then((res) => res.json())
      .then((data) => setTurnos(data))
      .catch(() => setTurnos([]));

    cargarReservas();
  }, []);

  const cargarReservas = () => {
    fetch("http://localhost:5000/api/reservas")
      .then((res) => res.json())
      .then((data) => setReservas(data))
      .catch(() => setReservas([]));
  };

  // -------------------------------------------------
  //   RESERVAR
  // -------------------------------------------------
  const handleReservar = () => {
    openModal(
      "Elegí una sala",
      <ul className="salas-list">
        {salas.map((s) => (
          <li
            key={s.id_sala}
            style={{ cursor: "pointer", padding: "8px 0" }}
            onClick={() => pedirFecha(s.id_sala)}
          >
            <strong>ID {s.id_sala}</strong> — {s.nombre_sala} (cap. {s.capacidad})
          </li>
        ))}
      </ul>
    );
  };

  const pedirFecha = (id_sala) => {
    openModal(
      "Ingresá la fecha (YYYY-MM-DD):",
      null,
      true,
      (fecha) => pedirTurno(id_sala, fecha)
    );
  };

  const pedirTurno = (id_sala, fecha) => {
    const turnosSala = turnos.filter((t) => t.id_sala === id_sala);

    openModal(
      "Turnos disponibles",
      <div className="turnos-scroll">
        <ul className="salas-list">
          {turnosSala.map((t) => (
            <li
              key={t.id_turno}
              style={{ cursor: "pointer", padding: "8px 0" }}
              onClick={() => pedirCI(id_sala, fecha, t.id_turno)}
            >
              <strong>ID {t.id_turno}</strong> — {t.hora_inicio} a {t.hora_fin}
            </li>
          ))}
        </ul>
      </div>
    );
  };

  const pedirCI = (id_sala, fecha, id_turno) => {
    openModal(
      "Ingresá tu CI:",
      null,
      true,
      (ci) => confirmarReserva(id_sala, fecha, id_turno, ci)
    );
  };

  const confirmarReserva = async (id_sala, fecha, id_turno, ci) => {
    try {
      const res = await fetch("http://localhost:5000/api/reservas", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          id_sala,
          fecha,
          id_turno,
          creado_por: ci,
        }),
      });

      if (!res.ok) throw new Error();

      cargarReservas();
      openModal("Reserva creada", <p>La reserva fue creada correctamente.</p>);
    } catch {
      openModal("Error", <p>No se pudo crear la reserva.</p>);
    }
  };

  //cancelar reserva
  const handleCancelar = () => {
    cargarReservas();

    setTimeout(() => {
      openModal(
        "Elegí la reserva a cancelar",
        <ul className="salas-list">
          {reservas.map((r) => (
            <li
              key={r.id_reserva}
              style={{ cursor: "pointer", padding: "8px 0" }}
              onClick={() => confirmarCancelacion(r.id_reserva)}
            >
              <strong>ID {r.id_reserva}</strong> — Sala {r.id_sala}
              <br />
              {r.fecha} — {r.hora_inicio} a {r.hora_fin}
            </li>
          ))}
        </ul>
      );
    }, 150);
  };

  const confirmarCancelacion = async (id_reserva) => {
    try {
      const res = await fetch(
        `http://localhost:5000/api/reservas/${id_reserva}/cancelar`,
        { method: "PUT" }
      );

      if (!res.ok) throw new Error();

      await cargarReservas();

      openModal("Reserva cancelada", <p>Cancelada correctamente.</p>);
    } catch {
      openModal("Error", <p>No se pudo cancelar.</p>);
    }
  };

  //UI
  return (
    <div className="alumno-container">
      <h1>Reserva tu sala</h1>

      {errorBackend && (
        <p style={{ color: "red" }}>Backend caído — usando datos vacíos.</p>
      )}

      <div className="button-box">
        <button onClick={handleReservar}>Reservar sala</button>
        <button onClick={handleCancelar}>Cancelar reserva</button>
        <button
          onClick={() =>
            openModal(
              "Salas disponibles",
              <ul className="salas-list">
                {salas.map((s) => (
                  <li key={s.id_sala}>
                    <strong>ID {s.id_sala}</strong> — {s.nombre_sala} (cap. {s.capacidad})
                  </li>
                ))}
              </ul>
            )
          }
        >
          Salas disponibles
        </button>
      </div>

      <button
        className="back-btn"
        style={{ marginTop: "25px" }}
        onClick={() => window.history.back()}
      >
        Volver
      </button>


      {modal.open && (
        <div className="modal-overlay" onClick={closeModal}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h2>{modal.title}</h2>

            {modal.content}

            {modal.showInput && (
              <>
                <input
                  className="input"
                  value={modal.inputValue}
                  onChange={(e) =>
                    setModal((m) => ({ ...m, inputValue: e.target.value }))
                  }
                />

                <button
                  className="close-btn"
                  style={{ marginTop: "15px" }}
                  onClick={() => {
                    const val = modal.inputValue;
                    closeModal();
                    setTimeout(() => modal.onConfirm(val), 0);
                  }}
                >
                  Aceptar
                </button>
              </>
            )}

            {!modal.showInput && (
              <button className="close-btn" onClick={closeModal}>
                Cerrar
              </button>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
