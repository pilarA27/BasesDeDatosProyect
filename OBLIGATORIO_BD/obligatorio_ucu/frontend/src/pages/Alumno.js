import { useEffect, useState } from "react";
import "../styles/Alumno.css";

export default function Alumno() {
  const [modalOpen, setModalOpen] = useState(false);
  const [salas, setSalas] = useState([]);
  const [errorBackend, setErrorBackend] = useState(false);

  const salasMock = [
    { id_sala: 1, nombre_sala: "Sala Roja", capacidad: 100 },
    { id_sala: 2, nombre_sala: "Sala Azul", capacidad: 150 },
    { id_sala: 3, nombre_sala: "Sala Verde", capacidad: 80 },
  ];

  //
  // Cargar salas desde backend
  //
    useEffect(() => {
    fetch("http://localhost:5000/api/salas")
      .then(res => {
        console.log("RES /api/salas status:", res.status);
        if (!res.ok) {
          return res.text().then(txt => {
            console.error("Respuesta NO OK del backend:", txt);
            throw new Error("Backend sin respuesta");
          });
        }
        return res.json();
      })
      .then(data => {
        console.log("Datos de salas desde backend:", data);
        setSalas(data);
        setErrorBackend(false);
      })
      .catch(err => {
        console.warn("Error al conectar con backend, usando mock:", err);
        setSalas(salasMock);
        setErrorBackend(true);
      });
  }, []);

  //
  // RESERVAR SALA
  //
  const handleReservar = async () => {
    const id_sala = prompt("ID de la sala:");
    if (!id_sala) return;

    const fecha = prompt("Fecha (YYYY-MM-DD):");
    if (!fecha) return;

    const id_turno = prompt("ID del turno (1,2,3…):");
    if (!id_turno) return;

    const creado_por = prompt("Tu CI (creador de la reserva):");
    if (!creado_por) return;

    try {
      const res = await fetch("http://localhost:5000/api/reservas", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          id_sala: Number(id_sala),
          fecha,
          id_turno: Number(id_turno),
          creado_por,
        }),
      });

      if (!res.ok) throw new Error("Error al crear reserva");
      alert("✅ Reserva creada correctamente");
    } catch (err) {
      console.error(err);
      alert("No se pudo crear la reserva");
    }
  };

  //
  // CANCELAR RESERVA
  //
  const handleCancelar = async () => {
    const id_reserva = prompt("ID de la reserva a cancelar:");
    if (!id_reserva) return;

    try {
      const res = await fetch(
        `http://localhost:5000/api/reservas/${Number(id_reserva)}/cancelar`,
        {
          method: "PUT",
        }
      );

      if (!res.ok) throw new Error("Error al cancelar reserva");
      alert("Reserva cancelada correctamente");
    } catch (err) {
      console.error(err);
      alert("No se pudo cancelar la reserva");
    }
  };

  //
  // UI
  //
  return (
    <div className="alumno-container">
      <h1>Reserva tu sala</h1>

      {errorBackend && (
        <p style={{ color: "red" }}>
          No se pudo conectar al servidor — mostrando datos de prueba.
        </p>
      )}

      <div className="button-box">
        <button onClick={handleReservar}>
          Reservar sala
        </button>

        <button onClick={handleCancelar}>
          Cancelar reserva
        </button>

        <button onClick={() => setModalOpen(true)}>
          Salas disponibles
        </button>
      </div>

      {/* Salas Disponibles */}
      {modalOpen && (
        <div className="modal-overlay" onClick={() => setModalOpen(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h2>Salas disponibles</h2>

            <ul className="salas-list">
              {salas.map((s) => (
                <li key={s.id_sala}>
                  <strong>{s.nombre_sala}</strong> — capacidad {s.capacidad}
                </li>
              ))}
            </ul>

            <button className="close-btn" onClick={() => setModalOpen(false)}>
              Cerrar
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
