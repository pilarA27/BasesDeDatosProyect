import { Link } from "react-router-dom";
import '../styles/Home.css';

export default function Home() {
  return (
    <div className="home-container">
      <h1>Login</h1>

      <div className="button-box">
        <Link to="/alumno">
          <button>Acceso Alumnos</button>
        </Link>

        <Link to="/gestion">
          <button>Acceso Administrador</button>
        </Link>
      </div>
    </div>
  );
}
