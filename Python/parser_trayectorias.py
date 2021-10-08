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
        next(file)            # Por si es necesario saltarse la primera linea
        csv_rows = csv.reader(file)
        for row in csv_rows:
            if row[0] == '':
                break
            movement_type = int(row[0])
            current_pose = Pose(
                x=float(row[1]), y=float(row[2]), z=float(row[3]), rx=float(row[4]), ry=float(row[5]), rz=float(row[6]))

            movements_list.append(movement_type)
            poses_list.append(current_pose)

            if(movement_type == MOVEJ_MOVEMENT):

                current_configuration_space = ConfigurationSpace(
                    base_angle_rad=float(row[7]),
                    shoulder_angle_rad=float(row[8]),
                    elbow_angle_rad=float(row[9]),
                    wrist_1_angle_rad=float(row[10]),
                    wrist_2_angle_rad=float(row[11]),
                    wrist_3_angle_rad=float(row[12])
                )
                configuration_spaces_list.append(current_configuration_space)

        print(movements_list)
        for pose in poses_list:
            print(pose)
        for configuration_space in configuration_spaces_list:
            print(configuration_space)

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
    pose_2 = poses_list[1]
    pose_3 = poses_list[2]
    pose_4 = poses_list[3]
    pose_5 = poses_list[4]

    # Inicializaciones en Script.

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

    # Cambiar a directorio destino

    # print(os.getcwd())
    os.chdir(rf"{URSCRIPT_FILE_PATH}")
    # print(os.getcwd())

    with open(FILENAME, "w") as file:
        # func = function_structure("hola_mundo", popup_function("Nemo es buena peli"))
        func = function_structure("initialization", initialization_content)
        func += function_structure("main", main_content)

        file.write(func)


if __name__ == '__main__':
    main()
