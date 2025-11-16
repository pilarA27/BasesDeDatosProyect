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
  useEffect(() => {
    fetch("http://localhost:5000/api/salas")
      .then(res => {
        if (!res.ok) throw new Error("Backend sin respuesta");
        return res.json();
      })
      .then(data => {
        setSalas(data);
        setErrorBackend(false);
      })
      .catch(err => {
        console.warn("Error al conectar con backend, usando mock:", err);
        setSalas(salasMock);
        setErrorBackend(true);
      });
  }, []);

  return (
    <div className="alumno-container">
      <h1>Reserva tu sala</h1>

      {errorBackend && (
        <p style={{ color: "red" }}>
          No se pudo conectar al servidor — mostrando datos de prueba.
        </p>
      )}

      <div className="button-box">
        <button /** crear_reserva */>
          Reservar sala
        </button>

         <button /** cancelar_reserva */>
          Cancelar reserva
        </button>

        <button onClick={() => setModalOpen(true)} /** listar_salas */>
          Salas disponibles
        </button>
      </div>

      {/*Salas Disponibles*/}
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
