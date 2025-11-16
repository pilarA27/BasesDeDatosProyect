import '../styles/Administrador.css'

export default function Administrador() {
  return (
    <div className="admin-container">
      <h1>Administración</h1>

    <div className="admin-sections">
      <div className="button-box">
        <div>Alumnos</div>
        <button /** alta_alumno */>
          Crear
        </button>

        <button  /** modificar_alumno */>
          Modificar
        </button>

        <button  /** listar_alumnos */>
          Ver todos
        </button>

        <button  /** eliminar_alumno */>
          Eliminar
        </button>
      </div>

      <div className="button-box">
        <div>Salas</div>
        <button  /** alta_sala */>
          Crear
        </button>

        <button /** modificar_sala */>
          Modificar
        </button>

        <button /** listar_salas */>
          Ver todas
        </button>

        <button /** eliminar_sala */>
          Eliminar
        </button>
      </div>

      <div className="button-box">
        <div>Reservas</div>
        <button /** listar_reservas */>
          Ver todas
        </button>

        <button /** registrar_asistencia */>
          Confirmar asistencia
        </button>
      </div>

      <div className="button-box">
        <div>Sanciones</div>
        <button /**  listar_sanciones*/>
          Ver todas
        </button>
      </div>
    </div>
    </div>
  );
}
