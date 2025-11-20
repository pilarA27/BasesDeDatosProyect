import mysql.connector

def get_connection():
    cfg = {
        "host": "localhost",
        "port": 3306,
        "user": "root",
        "password": "root",
        "database": "ucu_salas",
        "autocommit": True,
    }
    print("DEBUG CFG EN get_connection():", cfg)
    return mysql.connector.connect(**cfg)
