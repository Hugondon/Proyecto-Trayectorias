import csv
import os
import matlab.engine

CSV_PATH = "MATLAB/coordinates.csv"


def main():

    # Correr script de MATLAB
    os.chdir('C:/Users/hugon/Documents/Git/Proyecto-Trayectorias/MATLAB/')
    eng = matlab.engine.start_matlab()
    eng.create_csv(nargout=0)
    eng.quit()

    # Obtener datos de archivo csv (generado en MATLAB)
    os.chdir('C:/Users/hugon/Documents/Git/Proyecto-Trayectorias/')
    x_coordinates_list_m = []
    y_coordinates_list_m = []
    z_coordinates_list_m = []
    angles_list_radians = []

    with open(CSV_PATH, 'r') as file:
        print("The contents of the above file:")
        next(file)            # Por si es necesario saltarse la primera linea
        csv_rows = csv.reader(file)
        for row in csv_rows:
            x_coordinates_list_m.append(float(row[0]))
            y_coordinates_list_m.append(float(row[1]))
            z_coordinates_list_m.append(float(row[2]))
            angles_list_radians.append(float(row[3]))
            # print(row)
            # print(int(row[5]))
            # print(float(row[6]) + 0.7)

        print(x_coordinates_list_m)
        print(y_coordinates_list_m)
        print(z_coordinates_list_m)
        print(angles_list_radians)

    # Inicio de interpretacion con base en puntos


if __name__ == '__main__':
    main()
