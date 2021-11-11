
<h1 align="center">Proyecto Trayectorias</h1>
<h2 align="center">Parser para transformar trayectorias 2D en programas de URScript</h2>

## Herramientas Utilizadas

- MATLAB R2021b
- Python 3.8.10
- Polyscope

## Manual de Usuario
### Instalación Polyscope en Ubuntu

Seguir tutorial en [este repositorio](https://github.com/arunavanag591/ursim) con las siguientes modificaciones:

1. Instalar Java con [este tutorial](https://tecadmin.net/install-oracle-java-8-ubuntu-via-ppa/)
2. Hacer cambio de curl en archivo `install.sh`:

  `commonDependencies='libcurl4 openjdk-8-jre libjava3d-* ttf-dejavu* fonts-ipafont fonts-baekmuk fonts-nanum fonts-arphic-uming fonts-arphic-ukai'`

Ejemplo de `install.sh` en carpeta Polyscope.
### Instalación MATLAB.engine

1. Se debe localizar la carpeta con el instalador a través del comando `matlabroot` en la consola de MATLAB. 
2. Una vez encontrada la carpeta, se deberá llegar a la subcarpeta `matlabroot/extern/engines/python`
3. Para instalar la librería se debe correr el comando `python setup.py install` dentro de esta carpeta.

### Uso general

Para el uso general del código después de instalaciones previas se deben ajustar las siguientes constantes:

`FILENAME`: nombre del archivo script que contendrá el código para llevar a cabo la trayectoria.

`URSCRIPT_FILE_PATH`: path en el cual se generará el archivo script.