import os
import matlab.engine

""" Documentacion """
# https://la.mathworks.com/help/matlab/apiref/matlab.engine.matlabengine.html


""" Aqui es donde se encuentra para mí"""
# C:\Program Files\MATLAB\R2020b\extern\engines\python

""" Ayuda para instalar"""
# https://la.mathworks.com/help/matlab/matlab_external/install-the-matlab-engine-for-python.html
# https://la.mathworks.com/videos/how-to-call-matlab-from-python-1571136879916.html
""" Hice lo de este foro para que jalara (+ reiniciar la computadora) """
# https://la.mathworks.com/matlabcentral/answers/362824-no-module-named-matlab-engine-matlab-is-not-a-package

MATLAB_SCRIPT_PATH = "MATLAB/create_csv.m"


def main():
    """ Para obtener la direccion inicial. """
    print(os.getcwd())
    os.chdir('C:/Users/hugon/Documents/Git/Proyecto-Trayectorias/MATLAB/')

    eng = matlab.engine.start_matlab()
    """ Correr script que queremos"""
    eng.create_csv(nargout=0)
    eng.quit()


if __name__ == '__main__':
    main()
