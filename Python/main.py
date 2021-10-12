import csv

# import matlab.engine
import os

from generate_URScript_module import *


"""
Consideraciones importantes en programa:
    1. Primer fila después del nombre de las columnas en el  csv deberá ser la de configuración inicial
    2. Por ahora, únicamente MoveJ tiene ConfigurationSpace asociado a él.
    3. Queda pendeiente arreglar identación dentro de while :( (debería hacerse con algún tipo de recursividad?)

"""

""" Constantes relacionadas a lectura de CSV"""
complete_path = os.path.realpath(__file__)  # .../Proyecto-Trayectorias/Python/file.py

# Si está en carpeta de Python
parent_directory_name = os.path.dirname(complete_path)
CSV_PATH = os.path.join(parent_directory_name, "trajectory.csv")

# Si está en carpeta de MATLAB
# parent_directory_name = os.path.dirname(parent_directory_name)
# CSV_PATH = os.path.join(parent_directory_name, "MATLAB")
# CSV_PATH = os.path.join(CSV_PATH, "Generacion_Trayectoria")
# CSV_PATH = os.path.join(CSV_PATH, "trajectory.csv")

MOVEJ_MOVEMENT = 0
MOVEL_MOVEMENT = 1

""" Constantes relacionadas a escritura de Script"""
FILENAME = "trajectory.script"
URSCRIPT_FILE_PATH = "/home/hugo/URSim-5.10.2/programs/Proyecto/Trayectorias"
# URSCRIPT_FILE_PATH = "C:/Users/hugon/Documents/Git/Proyecto-Trayectorias/Python"
# URSCRIPT_FILE_PATH = "/home/damiau/ursim-5.9.4.1031232/programs"


def main():
    """Correr script de MATLAB."""
    # os.chdir('C:/Users/hugon/Documents/Git/Proyecto-Trayectorias/MATLAB/')
    # eng = matlab.engine.start_matlab()
    # eng.create_csv(nargout=0)
    # eng.quit()

    """Obtener datos de archivo csv(generado en MATLAB)."""
    # os.chdir('C:/Users/hugon/Documents/Git/Proyecto-Trayectorias/')
    movements_list = []
    poses_list = []
    configuration_spaces_list = []

    with open(CSV_PATH, "r") as file:
        next(file)  # Por si es necesario saltarse la primera linea
        csv_rows = csv.reader(file)
        for row in csv_rows:
            if row[0] == "":
                break
            movement_type = int(row[0])
            current_pose = Pose(
                x=float(row[1]),
                y=float(row[2]),
                z=float(row[3]),
                rx=float(row[4]),
                ry=float(row[5]),
                rz=float(row[6]),
            )

            movements_list.append(movement_type)
            poses_list.append(current_pose)
            if movement_type == MOVEJ_MOVEMENT:
                current_configuration_space = ConfigurationSpace(
                    base_angle_rad=float(row[7]),
                    shoulder_angle_rad=float(row[8]),
                    elbow_angle_rad=float(row[9]),
                    wrist_1_angle_rad=float(row[10]),
                    wrist_2_angle_rad=float(row[11]),
                    wrist_3_angle_rad=float(row[12]),
                )
            else:
                # Ponemos lugar string vacío para indicar que no hubo configuration space en esa row
                current_configuration_space = ""
            configuration_spaces_list.append(current_configuration_space)

        print("MOVEMENT\tPOSE\t\t\t\t\tCONFIGURATION SPACE")
        for index, pose in enumerate(poses_list):
            print(
                f"{movements_list[index]}\t\t{pose}\t{configuration_spaces_list[index]}"
            )

    """Generacion de Script."""

    initial_configuration_space = ConfigurationSpace(
        BASE_ANGLE_RAD,
        SHOULDER_ANGLE_RAD,
        ELBOW_ANGLE_RAD,
        WRIST_1_ANGLE_RAD,
        WRIST_2_ANGLE_RAD,
        WRIST_3_ANGLE_RAD,
    )

    pose_1 = poses_list[0]

    # Inicializaciones en Script.

    initialization_content = "\t" + "global program_counter = 1\n"
    # initialization_content = request_integer_from_primary_client_function(
    #     "program_counter", "Inserte cantidad de repeticiones:"
    # )

    initialization_content += movej_function(
        get_inverse_kin_function(pose_1, initial_configuration_space)
    )

    #  main en Script.

    main_initialization = f"\tcounter = 0\n"
    main_content = ""

    # Empezamos desde el segundo elemento debido a que el primero siempre será el de inicialización
    for index, pose in enumerate(poses_list[1:], 1):
        if movements_list[index] == MOVEJ_MOVEMENT:
            main_content += movej_function(
                get_inverse_kin_function(pose, configuration_spaces_list[index])
            )
        else:
            main_content += movel_function(pose)

    main_content = while_structure("counter", "program_counter", main_content)
    main_content = main_initialization + main_content

    # Generación de archivo

    # Cambiar a directorio destino

    # print(os.getcwd())
    os.chdir(rf"{URSCRIPT_FILE_PATH}")
    # print(os.getcwd())

    with open(FILENAME, "w") as file:
        # func = function_structure("hola_mundo", popup_function("Nemo es buena peli"))
        func = function_structure("initialization", initialization_content)
        func += function_structure("main", main_content)

        file.write(func)


if __name__ == "__main__":
    main()
