<h1 align="center">Proyecto de Ingeniería</h1>
<h2 align="center">Generación y Monitoreo de Trayectorias 3D sobre superficies regulares para Cobots UR</h2>

![diagrama-bloques](https://user-images.githubusercontent.com/47252665/184560856-a072e741-1f7a-4cfc-a49e-b2a6df0c913e.png)

<!-- <h2>Herramientas Utilizadas</h2>

1. [MATLAB R2021b](#matlab)
2. [Python 3.8.10](#python)
3. [Polyscope](#polyscope)
4. [ESP-IDF](#esp-idf)

--- -->

<h2>Herramientas Utilizadas</h2>

<details>
<summary id="matlab">MATLAB R2021b</summary>
<h4>Procesamiento de Imagenes</h4>

Este modulo fue hecho especificamente para demostraciones.  
`Proyecto-Trayectorias\Software\MATLAB\Generacion_Trayectoria\Image_processing`: Path relativo al modulo para procesamiento de imagenes.  
En la carpeta `Imagenes` guarda la imagen que quieras procesar.  
Estas son las caracteristicas que mejoran el resultado del procesamiento de imagenes:

- Formato JPEG
- Imagenes caricaturescas
- Alto contraste entre fondo y objeto de interes

En el path `Proyecto-Trayectorias\Software\MATLAB\Generacion_Trayectoria\Image_processing` abre el script `prueba_imagen.m` es donde atraves de procesamiento de imagenes algoritmos de deteccion de bordes el objeto de una imagen se convierte en una trayectoria. Las variables que debes modificar de este script son las siguientes:

- `nameImage`: nombre de la imagen en la carpeta `Imagenes` la cual se quiere procesar.
- `physicalSize_m`: longitud del lado más largo del lienzo fisico del dibujo en metros. El programa en automatico expande o comprime la imagen, esto para que la longitud del lado más largo del dibujo digital coincida con la longitud del lado más largo del lienzo fisico.
- `reductionConstant`: numero de reducion de waypoints en la trayectoria. Que el robot no ejecute una trayectoria de más de 3000 waypoints, de preferencia mantente por debajo de 1,800 waypoints. Para reducir el numero de waypoints aumenta esta variable a tu discreción. La relación se expresa con la siguiente formula:  
  $length(outputTrajectory) = \lceil {\frac {length(originalTrajectory)} {reductionConstant}}\rceil$

- `numLowPointsThreshold`: los objetos con menos de esta cantidad de waypoints son eliminados. Por lo general se usa para eliminar puntos muy pequeños de la imagen.
- `numHighPointsThreshold`: los objetos con más de esta cantidad de waypoints son eliminados. Por lo general se usa para eliminar el marco de la imagen.
- `eliminatedObject`: el ID de un objeto que se quiere eliminar en especifico.

El resultado es guardado en el archivo `waypoints.mat`.

En el path `Proyecto-Trayectorias\Software\MATLAB\Generacion_Trayectoria` abre el script `imagePlacement.m` para que puedas apreciar el tamaño del dibujo con respecto al robot. Debido a que las poses son relativas con el primer waypoint de la trayectoria no importa la posicion u orientacion. Las poses son guardadas en `trajectoryPoses.mat` para posteriormente ser simulados con el robot.

<h4>Procesamiento de Modelos CAD</h4>

En el path `Proyecto-Trayectorias\Software\MATLAB\Generacion_Trayectoria\CAD_procesing` abre el script `cad_interactive_node_selector.m` es un selector interactivo de los nodos del modelo CAD.  
En la carpeta `Parts` guarda las piezas CAD en formato CSV.  
En la linea `gm=importGeometry(msd,'Part\botella.STL')` esta el Path para exportar el modelo CAD.  
En el apartado `Generate Mesh`:

- `edgeLenght.Hmax`: maxima longitud de una arista de la malla.
- `edgeLenght.Hmin`: minima longitud de una arista de la malla.  
  Modifica `edgeLenght.Hmax` y `edgeLenght.Hmin` a tu conveniencia, aristas muy pequeñas haran el programa muy lento, aristas muy grandes haran que se pierda resolución del modelo.  
  El modelo CAD y sus parametros es guardado en `CADparameters.mat` y las poses en latrayectoria del modelo CAD junto con el modelo CAD son guardados en `processedCAD.mat`.

En el path `Proyecto-Trayectorias\Software\MATLAB\Generacion_Trayectoria` esta el script `CADplacement.m` sirve para vizualizar el robot, el modelo CAD y la trayectoria sobre la superficie del modelo CAD. Además puedes modificar la pose del modelo CAD.  
En el apartado `Modifing Processed CAD` tienes las siguientes variables para modificar la pose del modelo CAD y la trayectoria en la superficie del modelo CAD:

- `displacementVector` : representa la posicion del modelo CAD y la trayectoria.
- `rotationVector` : representa la orientacion del modelo CAD y la trayectoria.  
  Importante: la posicion y orientacion del modelo CAD y la trayectoria sobre su superficie estan ligadas modificar `displacementVector` y `rotationVector` afectara a ambas.  
  El modelo CAD y la trayectoria en su superficie son guardados en `transformedCAD.mat`, para posteriormente ser simulados con el robot.

<h4>Simulacion del Robot</h4>

En el path `Proyecto-Trayectorias\Software\MATLAB\Generacion_Trayectoria` abre el script `main.m` Toma la trayectoria deseada, calcula la cinematica inversa, grafica la trayectoria y simula el robot. Ve a la subseccion `Get Waypoints` ahi podras definir de donde quieres que se obtenga la trayectoria. El numero en la variable `typeTrajectory` define cual trayectoria es utilizada.

| Número | Tipo de Trayectoria |
| ------ | ------------------- |
| 0      | Test Trajectory     |
| 1      | CAD Trajectory      |
| 2      | Image Trajectory    |

La funcion `simulateRobot` unicamente simula el movimiento del robot. Si es comentada esa linea no afecta el resultado.

El tipo de movimiento, las poses y las configuraciones del robot en la trayectoria son guardadas en el CSV `trajectory.csv` .

</details>

<details open>
<summary id="python">Python</summary>
<h4> Parser </h4>

<p>

Este módulo se diseñó para llevar a cabo la conversión de la información contenida en el archivo `trajectory.csv` .

</p>

<p>

De forma general, el algoritmo para llevar a cabo esta tarea consiste en la iteración sobre las filas del archivo CSV para la extracción información de la pose y espacio de configuración y la generación del código .script a partir de esta.

</p>

<p>

Aprovechando que el lenguaje es orientado a objetos, se utilizó esto para encapsular información de los datos relevantes. La definición de estos se encuentra [aquí](https://github.com/Hugondon/Proyecto-Trayectorias/blob/main/Software/Python/utils/UR.py).

La información contenida en cada una de las filas del CSV se almacena en forma de listas de objetos (una para el Tipo de Movimiento y otra para las Poses). Al terminar de extraer toda la información, comienza el proceso de generación del código `.script` que será enviado al Robot. Esto se hace a través de la concatenación de strings conteniendo la información. Para ver directamente el funcionamiento de esto, ver la función `parse_csv` de [este](https://github.com/Hugondon/Proyecto-Trayectorias/blob/main/Software/Python/app.py) archivo.

</p>
<p>

Para la generación del código `.script` es importante mencionar que este se dividirá en dos partes:

`initialization`. Se utiliza para la inicialización de configuraciones en general (por el momento utilizado solamente para un contador global para llevar a cabo la trayectoria por una o más veces).

`main`. Aquí se encuentra en primer lugar la inicialización para llevar a cabo los movimientos de forma relativa al lugar en el que se encuentra actualmente el TCP y para llevar a cabo la información de la trayectoria

</p>

<p>

Todo esto se lleva a cabo como un programa debajo de una GUI, la cual se ejecuta con el siguiente comando:
`python .\Software\Python\app.py`
Es importante mencionar que este puede variar de acuerdo al Path desde el cual se ejecuta la aplicación, esto es considerando que se encuentra en el folder de `Proyecto-Trayectorias`)

El uso general de la GUI consiste en dos pasos:

1. Seleccionar el archivo CSV con el que se desea generar el `.script` a través de la ventana que se abre cuando se presiona el botón `Load CSV File`
   ![image](https://user-images.githubusercontent.com/47252665/184567620-f309f8d7-fa87-4ab4-8f90-65d967862bf9.png)

2) Seleccionar el path en el cual se desea crear este archivo a través del uso del botón `Save to specific folder`
   ![image](https://user-images.githubusercontent.com/47252665/184567498-ff3761d8-6326-443b-908a-6c6b4940ff8b.png)

Como comentario adicional, el botón de `Save URScript File` es útil para guardar directamente el archivo después de una modificación en el path (el nombre del archivo, por ejemplo) sin tener que seleccionar el folder de nuevo desde la ventana.

Finalmente, en el [folder correspondiente a este módulo](https://github.com/Hugondon/Proyecto-Trayectorias/tree/main/Software/Python) se encuentra un archivo CSV de ejemplo. Se puede practicar con este, el archivo resultante debe verse de la siguiente forma al abrirse con Excel:

![image](https://user-images.githubusercontent.com/47252665/184568608-f09e1ffc-b3d0-4731-9080-56f11c2fd68f.png)

</p>

</details>

<details>
<summary id="polyscope">Polyscope</summary>
<h4>Instalación Polyscope en Ubuntu</h4>

Seguir tutorial en [este repositorio](https://github.com/arunavanag591/ursim) con las siguientes modificaciones:

1. Instalar Java con [este tutorial](https://tecadmin.net/install-oracle-java-8-ubuntu-via-ppa/)
2. Hacer cambio de curl en archivo `install.sh`:

`commonDependencies='libcurl4 openjdk-8-jre libjava3d-* ttf-dejavu* fonts-ipafont fonts-baekmuk fonts-nanum fonts-arphic-uming fonts-arphic-ukai'`

Ejemplo de `install.sh` en carpeta Polyscope.

<h4>Ejecutar programa en el Robot</h4>

TO-DO

</details>

<details>
<summary id="esp-idf">ESP-IDF</summary>
