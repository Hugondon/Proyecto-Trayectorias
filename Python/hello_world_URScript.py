import os

# No se actualiza automáticamente en la interfaz de Polyscope

# FILENAME = 'hello_world.script'
URSCRIPT_PATH = '/home/hugo/URSim-5.10.2/programs/Proyecto/Hello_World_Python'

def function(name, content):
    function_structure = ''
    function_structure += f'def {name}():'
    function_structure += f'\n\t{content}'
    function_structure += f'\nend'
    return function_structure
def popup_function(msg):
    return f'popup("{msg}", blocking=True)'

def main():
    
    """ Cambiar a directorio destino """
    # print(os.getcwd())    
    os.chdir(rf"{URSCRIPT_PATH}")
    # print(os.getcwd())
    """ Generar archivo """
    with open(FILENAME, 'w') as file:
        func = function('hola_mundo', popup_function("Nemo es buena peli"))
        file.write(func)
    
if __name__ == '__main__':
    main()
