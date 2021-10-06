import os

"""
Pendientes:
    1. No se actualiza automáticamente en la interfaz de Polyscope el archivo que se modifica
    2. Problema con EOL: en todos, menos el ultimo elemento de la estructura debe llevar EOLC
    3. Problema con tabs. Hay que andar poniendo a todos, menos al primero
    4. Typing a funciones que creemos
"""

# FILENAME = 'hello_world.script'
# FILENAME = "movel_1.script"
FILENAME = "movel_2.script"
URSCRIPT_FILE_PATH = "/home/hugo/URSim-5.10.2/programs/Proyecto/Hello_World_Python"
# URSCRIPT_FILE_PATH = "/home/damiau/ursim-5.9.4.1031232/programs"


BASE_ANGLE_RAD = -0.604
SHOULDER_ANGLE_RAD = -1.204
ELBOW_ANGLE_RAD = -2.091
WRIST_1_ANGLE_RAD = -1.417
WRIST_2_ANGLE_RAD = 1.569
WRIST_3_ANGLE_RAD = 0
# BASE_ANGLE_RAD = -1.055051532830572
# SHOULDER_ANGLE_RAD = -0.922930108454602
# ELBOW_ANGLE_RAD = -2.274513081199010
# WRIST_1_ANGLE_RAD = -1.514247659030281
# WRIST_2_ANGLE_RAD = 1.572192590196492
# WRIST_3_ANGLE_RAD = 0.515570261039125


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


def function_structure(name, content):
    """Function structure string generator."""
    structure = f"def {name}():\n"
    structure += f"\t{content}\n"
    structure += f"end"
    return structure


def while_structure(variable, condition, content):
    """While structure based on 'less than' condition and variable increments."""
    structure = f"while({variable} < {condition}):\n"
    structure += f"\t{content}\n"
    structure += f"\t{variable} = {variable} + 1\n"
    structure += f"\tend"
    return structure


def popup_function(msg):
    """Return popup function string."""
    return f'popup("{msg}", blocking=True)'


def movel_function(initial_pose, radius="0.05", EOLC=True):
    """Return movel function string."""
    return (
        f"movel({initial_pose}, r={radius})\n"
        if EOLC
        else f"movel({initial_pose}, r={radius})"
    )


def movej_function(initial_pose, EOLC=True):
    """Return movej function string."""
    return f"movej({initial_pose})\n" if EOLC else f"movej({initial_pose})"


def get_inverse_kin_function(pose, qnear):
    """Return get_inverse_king function string."""
    return f"get_inverse_kin({pose}, qnear={qnear})"


def main():

    # Valores iniciales
    initial_configuration_space = f"[{BASE_ANGLE_RAD},{SHOULDER_ANGLE_RAD},{ELBOW_ANGLE_RAD}, {WRIST_1_ANGLE_RAD},{WRIST_2_ANGLE_RAD},{WRIST_3_ANGLE_RAD}]"
    pose_1 = Pose(0.4, -0.4, 0.4, 0, 1.57, 0)
    pose_2 = Pose(0.4, -0.2, 0.4, 0, 1.57, 0)
    pose_3 = Pose(0.4, -0.2, 0.6, 0, 1.57, 0)
    pose_4 = Pose(0.4, -0.4, 0.6, 0, 1.57, 0)
    pose_5 = Pose(0.4, -0.4, 0.4, 0, 1.57, 0)

    initial_configuration_space_str = get_inverse_kin_function(
        pose_1.generate_pose(), initial_configuration_space
    )

    # Contenido de funcion structure

    function_content = "counter = 0\n"
    function_content += "\t" + movej_function(initial_configuration_space_str)

    function_content += "\t" + movel_function(pose_2.generate_pose())
    function_content += "\t" + movel_function(pose_3.generate_pose())
    function_content += "\t" + movel_function(pose_4.generate_pose())
    function_content += "\t" + movel_function(pose_5.generate_pose())
    function_content += "\t" + movel_function(pose_1.generate_pose(), EOLC=False)

    # Escritura en archivo

    """ Cambiar a directorio destino """
    # print(os.getcwd())
    os.chdir(rf"{URSCRIPT_FILE_PATH}")
    # print(os.getcwd())
    """ Generar archivo """
    with open(FILENAME, "w") as file:
        # func = function_structure("hola_mundo", popup_function("Nemo es buena peli"))
        func = function_structure("hola_mundo", function_content)
        file.write(func)

    # print(get_inverse_kin_function(pose_1.generate_pose(), initial_configuration_space))
    # print(initial_configuration_space)
    # print(pose_1.generate_pose())
    # print(movel_function(pose_1.generate_pose()))


if __name__ == "__main__":
    main()
