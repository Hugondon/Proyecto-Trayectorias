import os

# No se actualiza automáticamente en la interfaz de Polyscope

FILENAME = 'hello_world.script'
URSCRIPT_PATH = '/home/hugo/URSim-5.10.2/programs/Proyecto/Hello_World_Python'


script_output = ''

def main():
    
    """ Cambiar a directorio destino """
    # print(os.getcwd())    
    os.chdir(rf"{URSCRIPT_PATH}")
    # print(os.getcwd())
    """ Generar archivo """
    with open(FILENAME, 'w') as file:
        file.write('def hola_mundo():\n\tpopup("Me la pelas Dios", blocking=True)\nend')
    
if __name__ == '__main__':
    main()
