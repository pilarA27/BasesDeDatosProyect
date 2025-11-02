import sys
from funciones_abm import (
    alta_alumno, listar_alumnos, modificar_alumno, eliminar_alumno,
    alta_sala, listar_salas, modificar_sala, eliminar_sala,
    crear_reserva, agregar_alumno_a_reserva, cancelar_reserva, listar_reservas,
    registrar_asistencia, cerrar_reserva, listar_sanciones
)
from consultas_bi import ejecutar_bi

def input_nonempty(prompt):
    val = input(prompt).strip()
    if not val:
        raise ValueError("Valor requerido.")
    return val

def menu_alumnos():
    while True:
        print("\nalumnoS")
        print("1. Alta")
        print("2. Listar")
        print("3. Modificar")
        print("4. Eliminar")
        print("0. Volver")
        op = input("Opción: ").strip()
        if op == "1":
            ci = input_nonempty("CI: ")
            nombre = input_nonempty("Nombre: ")
            apellido = input_nonempty("Apellido: ")
            email = input("Email: ").strip() or None
            try:
                alta_alumno(ci, nombre, apellido, email)
                print("alumno creado.")
            except Exception as e:
                print("ERROR:", e)
        elif op == "2":
            rows = listar_alumnos()
            for r in rows:
                print(r)
        elif op == "3":
            ci = input_nonempty("CI: ")
            nombre = input_nonempty("Nuevo nombre: ")
            apellido = input_nonempty("Nuevo apellido: ")
            email = input("Nuevo email: ").strip() or None
            try:
                modificar_alumno(ci, nombre, apellido, email)
                print("alumno modificado.")
            except Exception as e:
                print("ERROR:", e)
        elif op == "4":
            ci = input_nonempty("CI: ")
            try:
                eliminar_alumno(ci)
                print("alumno eliminado.")
            except Exception as e:
                print("ERROR:", e)
        elif op == "0":
            return
        else:
            print("Opción inválida.")

def menu_salas():
    while True:
        print("\nSALAS")
        print("1. Alta")
        print("2. Listar")
        print("3. Modificar")
        print("4. Eliminar")
        print("0. Volver")
        op = input("Opción: ").strip()
        if op == "1":
            nombre = input_nonempty("Nombre sala: ")
            id_edificio = input_nonempty("ID edificio: ")
            capacidad = input_nonempty("Capacidad (int): ")
            tipo = input_nonempty("Tipo (libre/posgrado/docente): ")
            try:
                alta_sala(nombre, int(id_edificio), int(capacidad), tipo)
                print("OK: sala creada.")
            except Exception as e:
                print("ERROR:", e)
        elif op == "2":
            rows = listar_salas()
            for r in rows:
                print(r)
        elif op == "3":
            id_sala = int(input_nonempty("ID sala: "))
            nombre = input_nonempty("Nuevo nombre sala: ")
            id_edificio = int(input_nonempty("Nuevo ID edificio: "))
            capacidad = int(input_nonempty("Nueva capacidad: "))
            tipo = input_nonempty("Nuevo tipo (libre/posgrado/docente): ")
            try:
                modificar_sala(id_sala, nombre, id_edificio, capacidad, tipo)
                print("Sala modificada.")
            except Exception as e:
                print("ERROR:", e)
        elif op == "4":
            id_sala = int(input_nonempty("ID sala: "))
            try:
                eliminar_sala(id_sala)
                print("Sala eliminada.")
            except Exception as e:
                print("ERROR:", e)
        elif op == "0":
            return
        else:
            print("Opción inválida.")

def menu_reservas():
    while True:
        print("\nRESERVAS")
        print("1. Crear reserva")
        print("2. Agregar alumno a reserva")
        print("3. Listar reservas")
        print("4. Cancelar reserva")
        print("5. Registrar asistencia")
        print("6. Cerrar reserva")
        print("0. Volver")
        op = input("Opción: ").strip()
        try:
            if op == "1":
                id_sala = int(input_nonempty("ID sala: "))
                fecha = input_nonempty("Fecha (YYYY-MM-DD): ")
                id_turno = int(input_nonempty("ID turno (1..15): "))
                creador = input_nonempty("CI creador: ")
                crear_reserva(id_sala, fecha, id_turno, creador)
                print("Reserva creada.")
            elif op == "2":
                id_reserva = int(input_nonempty("ID reserva: "))
                ci = input_nonempty("CI: ")
                agregar_alumno_a_reserva(id_reserva, ci)
                print("alumno agregado.")
            elif op == "3":
                for r in listar_reservas():
                    print(r)
            elif op == "4":
                id_reserva = int(input_nonempty("ID reserva: "))
                cancelar_reserva(id_reserva)
                print("Reserva cancelada.")
            elif op == "5":
                id_reserva = int(input_nonempty("ID reserva: "))
                ci = input_nonempty("CI: ")
                registrar_asistencia(id_reserva, ci)
                print("Asistencia registrada.")
            elif op == "6":
                id_reserva = int(input_nonempty("ID reserva: "))
                cerrar_reserva(id_reserva)
                print("Reserva cerrada.")
            elif op == "0":
                return
            else:
                print("Opción inválida.")
        except Exception as e:
            print("ERROR:", e)

def menu_bi():
    while True:
        print("\nREPORTES BI")
        print("1. Salas más reservadas")
        print("2. Turnos más demandados")
        print("3. Promedio de alumnos por sala")
        print("4. Reservas por carrera y facultad")
        print("5. % ocupación por edificio")
        print("6. Reservas y asistencias por tipo alumno")
        print("7. Sanciones por tipo alumno")
        print("8. Tasa de uso efectivo por semana")
        print("9. Top 5 alumnos más activos")
        print("10. Promedio horas por edificio y semana")
        print("0. Volver")
        op = input("Opción: ").strip()
        if op == "0":
            return
        try:
            data = ejecutar_bi(int(op))
            for row in data:
                print(row)
        except Exception as e:
            print("ERROR:", e)

def main():
    while True:
        print("\nGESTIÓN DE SALAS DE ESTUDIO")
        print("1. alumnos")
        print("2. Salas")
        print("3. Reservas")
        print("4. Sanciones (listar)")
        print("5. Reportes BI")
        print("0. Salir")
        op = input("Opción: ").strip()
        if op == "1":
            menu_alumnos()
        elif op == "2":
            menu_salas()
        elif op == "3":
            menu_reservas()
        elif op == "4":
            for s in listar_sanciones():
                print(s)
        elif op == "5":
            menu_bi()
        elif op == "0":
            print("Chau!")
            sys.exit(0)
        else:
            print("Opción inválida.")

if __name__ == "__main__":
    main()
