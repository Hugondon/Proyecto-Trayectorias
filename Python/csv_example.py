import csv
import os

""" Uso de virtual environment """
# https://www.infoworld.com/article/3239675/virtualenv-and-venv-python-virtual-environments-explained.html

# https://www.youtube.com/watch?v=N5vscPTWKOk
# .\venv\Scripts\activate.ps1
# deactivate


""" Documentacion librerias  """
# https://docs.python.org/3/library/csv.html
# https://stackoverflow.com/questions/62139040/python-csv-module-vs-pandas

# CSV_PATH = "Python/addresses.csv"
CSV_PATH = "Python/coordinates.csv"
CSV_PATH = "MATLAB/coordinates.csv"


def main():
    """ Para obtener la direccion inicial. """
    # print(os.getcwd())
    # os.chdir('C:/Users/hugon/Documents/Git/Proyecto-Trayectorias/Python/')

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


if __name__ == '__main__':
    main()
