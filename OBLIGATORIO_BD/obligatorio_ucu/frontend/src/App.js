import { useEffect, useState } from "react";
import { BrowserRouter as Router, Routes, Route} from "react-router-dom";
import Alumno from "./pages/Alumno";
import Gestion from "./pages/Administrador";
import Home from "./pages/Home";



const USE_MOCK = false; //true: Docker desactivado, false: Docker activado

const salasMock = [
  { id_sala: 1, nombre_sala: "Sala Roja", capacidad: 100 },
  { id_sala: 2, nombre_sala: "Sala Azul", capacidad: 150 },
];

function App() {
  const [salas, setSalas] = useState([]);

  useEffect(() => {
    if (USE_MOCK) {
      setSalas(salasMock);
      return;
    }

    fetch("http://localhost:5000/api/salas")
      .then((res) => res.json())
      .then((data) => setSalas(data))
      .catch((err) => {
        console.error("Error al conectar al backend:", err);
      });
  }, []);

 return (
    <Router>
      <Routes>
        {/* Página principal con botones */}
        <Route path="/" element={<Home />} />

        {/* Páginas internas */}
        <Route path="/alumno" element={<Alumno />} />
        <Route path="/gestion" element={<Gestion />} />
      </Routes>
    </Router>
  );
}

export default App;
