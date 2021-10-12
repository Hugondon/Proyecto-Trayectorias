import csv
import os

# from generate_URScript import ConfigurationSpace, Pose
from generate_URScript_module import Pose, ConfigurationSpace


def main():
    os.chdir("C:/Users/hugon/Documents/Git/Proyecto-Trayectorias")

    movements_list = []
    poses_list = []
    configuration_spaces_list = []

    with open(CSV_PATH, "r") as file:
        print("The contents of the above file:")
        next(file)  # Por si es necesario saltarse la primera linea
        csv_rows = csv.reader(file)
        for row in csv_rows:
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
                configuration_spaces_list.append(current_configuration_space)

        print(movements_list)
        for pose in poses_list:
            print(pose)
        for configuration_space in configuration_spaces_list:
            print(configuration_space)


if __name__ == "__main__":
    main()
