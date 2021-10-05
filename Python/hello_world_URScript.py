import os

# No se actualiza automáticamente en la interfaz de Polyscope el archivo que se modifica
# Hacer objeto para poses ?
# Typing a funciones que creemos
# Argumentos opcionales

# FILENAME = 'hello_world.script'
FILENAME = 'movel_1.script'
URSCRIPT_PATH = '/home/hugo/URSim-5.10.2/programs/Proyecto/Hello_World_Python'
class Pose:
    def __init__(self, x, y, z, rx, ry, rz):
        self.x = x
        self.y = y
        self.z = z
        self.rx = rx
        self.ry = ry
        self.rz = rz
    
    def generate_pose(self):
        return f"p[{self.x}, {self.y}, {self.z}, {self.rx}, {self.ry}, {self.rz}]"


def function(name, content):
    function_structure = ''
    function_structure += f'def {name}():'
    function_structure += f'\n\t{content}'
    function_structure += f'\nend'
    return function_structure
def popup_function(msg):
    return f'popup("{msg}", blocking=True)'
def movel_function(initial_pose):
    return f'movel({initial_pose})'


def main():
    
    """ Cambiar a directorio destino """
    # print(os.getcwd())    
    os.chdir(rf"{URSCRIPT_PATH}")
    # print(os.getcwd())
    """ Generar archivo """
    # with open(FILENAME, 'w') as file:
    #     func = function('hola_mundo', popup_function("Nemo es buena peli"))
    #     file.write(func)
    
    pose_1 = Pose(0.4, -0.3, 0.4, 0, 1.57, 0)
    print(pose_1.generate_pose())
    print(movel_function(pose_1.generate_pose()))
    
if __name__ == '__main__':
    main()
