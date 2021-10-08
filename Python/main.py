import csv
import matlab.engine
import os

from generate_URScript_module import *
from read_csv_module import *


def main():
    """Correr script de MATLAB."""
    # os.chdir('C:/Users/hugon/Documents/Git/Proyecto-Trayectorias/MATLAB/')
    # eng = matlab.engine.start_matlab()
    # eng.create_csv(nargout=0)
    # eng.quit()

    """Obtener datos de archivo csv(generado en MATLAB)."""
    os.chdir('C:/Users/hugon/Documents/Git/Proyecto-Trayectorias/')
    movements_list = []
    poses_list = []
    configuration_spaces_list = []

    with open(CSV_PATH, 'r') as file:
        next(file)              # Por si es necesario saltarse la primera linea
        csv_rows = csv.reader(file)
        for row in csv_rows:
            if row[0] == '':    # Por si al csv se le seca el cerebro y añade valores vacios
                break
            movement_type = int(row[0])
            current_pose = Pose(
                x=float(row[1]), y=float(row[2]), z=float(row[3]), rx=float(row[4]), ry=float(row[5]), rz=float(row[6]))

            movements_list.append(movement_type)
            poses_list.append(current_pose)

            if(movement_type == MOVEJ_MOVEMENT):    # Solamente los movej necesitan ConfigurationSpace

                current_configuration_space = ConfigurationSpace(
                    base_angle_rad=float(row[7]),
                    shoulder_angle_rad=float(row[8]),
                    elbow_angle_rad=float(row[9]),
                    wrist_1_angle_rad=float(row[10]),
                    wrist_2_angle_rad=float(row[11]),
                    wrist_3_angle_rad=float(row[12])
                )
                configuration_spaces_list.append(current_configuration_space)

        # print(movements_list)
        # for pose in poses_list:
        #     print(pose)
        # for configuration_space in configuration_spaces_list:
        #     print(configuration_space)

    """Generacion de Script."""

    # Inicializaciones en Script.

    initial_configuration_space = configuration_spaces_list[0]

    pose_1 = poses_list[0]
    pose_2 = poses_list[1]
    pose_3 = poses_list[2]
    pose_4 = poses_list[3]
    pose_5 = poses_list[4]

    # initialization_content = "\t" + "counter = 0\n"
    initialization_content = request_integer_from_primary_client_function(
        "counter", "Inserte cantidad de repeticiones:"
    )

    initialization_content += movej_function(
        get_inverse_kin_function(pose_1, initial_configuration_space)
    )

    #  main en Script.

    main_content = movel_function(pose_2)
    main_content += movel_function(pose_3)
    main_content += movel_function(pose_4)
    main_content += movel_function(pose_5)
    main_content += movel_function(pose_1)

    # Generación de archivo

    # Cambiar a directorio destino del archivo Script
    # print(os.getcwd())
    os.chdir(rf"{URSCRIPT_FILE_PATH}")
    # print(os.getcwd())

    with open(FILENAME, "w") as file:   # Generacion de funciones de Script
        # func = function_structure("hola_mundo", popup_function("Nemo es buena peli"))
        func = function_structure("initialization", initialization_content)
        func += function_structure("main", main_content)

        file.write(func)


if __name__ == '__main__':
    main()
