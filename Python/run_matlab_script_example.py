import os
import matlab.engine

# https://la.mathworks.com/help/matlab/matlab_external/install-the-matlab-engine-for-python.html
# https://la.mathworks.com/videos/how-to-call-matlab-from-python-1571136879916.html

MATLAB_SCRIPT_PATH = "MATLAB/create_csv.m"


def main():
    """ Para obtener la direccion inicial. """
    print(os.getcwd())
    os.chdir('C:/Users/hugon/Documents/Git/Proyecto-Trayectorias/MATLAB/')
    print(os.getcwd())


if __name__ == '__main__':
    main()
