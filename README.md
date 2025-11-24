# Sistema de Gestión de Salas de Estudio – UCU

## Requisitos previos
- Python 3.10+
- Node.js 18+
- MySQL Server 8.0+
- pip para instalar dependencias

## Instalación de dependencias backend
Desde la carpeta `app`:
pip install flask mysql-connector-python flask-cors


Si se usa entorno virtual:
python -m venv .venv
.\.venv\Scripts\Activate.ps1

## Estructura del proyecto
```text
OBLIGATORIO_BD/
└── obligatorio_ucu/
    ├── app/       
    ├── frontend/ 
    └── db/       
```

## Carga de la base de datos
Antes de iniciar la aplicación, cargar la base de datos en MySQL.
1. Abrir **MySQL Workbench** o consola.
2. Ejecutar `tablas.sql` (crea la base `ucu_salas` y las tablas).
3. Ejecutar `triggers.sql` (crea los triggers).
4. Ejecutar `inserts.sql` (carga datos de prueba).

Nota: si algún `INSERT` de **reserva** da error de foreign key sobre `id_turno`, es porque todavía no existen turnos en la tabla `turno`.  
Los turnos reales se generan automáticamente cuando se ejecuta `app.py` (de la fecha de hoy a una semana hacia adelante).  
En el uso normal, las reservas se crean desde la aplicación usando esos turnos generados por el backend.

## Cómo ejecutar el backend
cd OBLIGATORIO_BD
cd obligatorio_ucu
cd app
python app.py
El backend queda disponible en:
- http://localhost:5000
Al iniciar, el backend genera automáticamente los turnos (tabla `turno`) para todas las salas, desde hoy hasta 7 días hacia adelante, en bloques de 1 hora.

## Cómo ejecutar el frontend
En otra terminal:
cd OBLIGATORIO_BD
cd obligatorio_ucu
cd frontend
npm install   # solo la primera vez
npm start
El frontend queda disponible en:
- http://localhost:3000

## Fin