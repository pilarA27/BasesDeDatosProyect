## Requisitos previos
- Python 3.10+
- Node.js 18+
- MySQL Server 8.0+
- pip para instalar dependencias

## Instalación de dependencias backend
pip install flask mysql-connector-python

Si se usa entorno virtual:
.\.venv\Scripts\Activate.ps1


## Estructura del proyecto
OBLIGATORIO_BD/
└── obligatorio_ucu/
    ├── app/          # Backend
    ├── frontend/     # Frontend


# Datos de prueba 
Antes de iniciar la aplicación cargar la base de datos.
1. Abrir MySQL Workbench o consola.
2. Ejecutar la información de Insert.sql
3. Ejecutar la información en triggers.sql


## Cómo ejecutar el backend
cd OBLIGATORIO_BD
cd obligatorio_ucu
cd app
python app.py

El backend queda disponible en:
http://localhost:5000

## Cómo ejecutar el frontend
cd OBLIGATORIO_BD
cd obligatorio_ucu
cd frontend
npm start

El frontend queda disponible en:
http://localhost:3000




## Fin