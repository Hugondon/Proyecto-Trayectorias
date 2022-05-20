import os

complete_path = os.path.realpath(__file__)  # .../Proyecto-Trayectorias/Python/file.py
print(complete_path)

# Si está en carpeta de Python
parent_directory_name = os.path.dirname(
    complete_path
)  # .../Proyecto-Trayectorias/Python/file.py
CSV_PATH = os.path.join(parent_directory_name, "trajectory.csv")
print(CSV_PATH)


# Si está en carpeta de MATLAB
parent_directory_name = os.path.dirname(parent_directory_name)
CSV_PATH = os.path.join(parent_directory_name, "MATLAB")
CSV_PATH = os.path.join(CSV_PATH, "Generacion_Trayectoria")
CSV_PATH = os.path.join(CSV_PATH, "trajectory.csv")
print(CSV_PATH)
