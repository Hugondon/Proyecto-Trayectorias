
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

### Procesamiento de Imagenes

Este modulo fue hecho especificamente para demostraciones.  
`Proyecto-Trayectorias\Software\MATLAB\Generacion_Trayectoria\Image_processing`: Path relativo al modulo para procesamiento de imagenes.  
En la carpeta `Imagenes` guarda la imagen que quieras procesar.  
Estas son las caracteristicas que mejoran el resultado del procesamiento de imagenes:
- Formato JPEG
- Imagenes caricaturescas
- Alto contraste entre fondo y objeto de interes


Las variables que debes modificar del script son las siguientes:
- `nameImage`: nombre de la imagen en la carpeta `Imagenes` la cual se quiere procesar.
- `physicalSize_m`: longitud del lado más largo del lienzo fisico del dibujo en metros. El programa en automatico expande o comprime la imagen, esto para que la longitud del lado más largo del dibujo digital coincida con la longitud del lado más largo del lienzo fisico.
- `reductionConstant`: numero de reducion de waypoints en la trayectoria. Que el robot no ejecute una trayectoria de más de 3000 waypoints, de preferencia mantente por debajo de 1,800 waypoints. Para reducir el numero de waypoints aumenta esta variable a tu discreción. La relación se expresa con la siguiente formula:  
$length(outputTrajectory) = \lceil {\frac {length(originalTrajectory)} {reductionConstant}}\rceil$

- `numLowPointsThreshold`: los objetos con menos de esta cantidad de waypoints son eliminados. Por lo general se usa para eliminar puntos muy pequeños de la imagen.
- `numHighPointsThreshold`: los objetos con más de esta cantidad de waypoints son eliminados. Por lo general se usa para eliminar el marco de la imagen.
- `eliminatedObject`: el ID de un objeto que se quiere eliminar en especifico.

El resultado es guardado en el archivo `waypoints.mat`.

### Procesamiento de Modelos CAD

### Simulacion del Robot

### Parser

### Ejecutar programa en el Robot
