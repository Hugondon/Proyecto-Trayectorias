import os
import typing

"""
Pendientes:
    1. No se actualiza automáticamente en la interfaz de Polyscope el archivo que se modifica
    2. Problema con EOL: en todos, menos el ultimo elemento de la estructura (debe llevar EOLC=True)
    3. Problema con tabs. en todos, menos el primero
    
    Hacerlo por archivos que escriban diferentes funciones ? 
"""

"""
Estandarización:
    1. EOL
    2. Tab
    3. Funciones

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
    def __init__(self, x: float, y: float, z: float, rx: float, ry: float, rz: float):
        self.x = x
        self.y = y
        self.z = z
        self.rx = rx
        self.ry = ry
        self.rz = rz

    def generate_pose(self) -> str:
        return f"p[{self.x}, {self.y}, {self.z}, {self.rx}, {self.ry}, {self.rz}]"


def function_structure(name: str, content: str) -> str:
    """Function structure string generator."""
    structure = f"def {name}():\n"
    structure += f"\t{content}\n"
    structure += f"end\n"
    return structure


def while_structure(variable: str, condition: str, content: str) -> str:
    """While structure based on 'less than' condition and variable increments."""
    structure = f"while({variable} < {condition}):\n"
    structure += f"\t{content}\n"
    structure += f"\t{variable} = {variable} + 1\n"
    structure += f"\tend\n"
    return structure


def popup_function(msg: str) -> str:
    """Return string for popup function."""
    return f'popup("{msg}", blocking=True)'


def movel_function(initial_pose: str, radius: str = "0.05", EOLC=True) -> str:
    """Return string for movel function."""
    return (
        f"movel({initial_pose}, r={radius})\n"
        if EOLC
        else f"movel({initial_pose}, r={radius})"
    )


def movej_function(initial_pose: str, EOLC: bool = True) -> str:
    """Return string for movej function."""
    return f"movej({initial_pose})\n" if EOLC else f"movej({initial_pose})"


def get_inverse_kin_function(pose: str, qnear: str) -> str:
    """Return string for get_inverse_king function."""
    return f"get_inverse_kin({pose}, qnear={qnear})"


def request_integer_from_primary_client_function(variable: str, msg: str) -> str:
    """Return string for assigment of variable using UI."""
    return f'global {variable} = request_integer_from_primary_client("{msg}")\n'


def main():

    """Valores iniciales"""

    initial_configuration_space = f"[{BASE_ANGLE_RAD},{SHOULDER_ANGLE_RAD},{ELBOW_ANGLE_RAD}, {WRIST_1_ANGLE_RAD},{WRIST_2_ANGLE_RAD},{WRIST_3_ANGLE_RAD}]"
    pose_1 = Pose(0.4, -0.4, 0.4, 0, 1.57, 0)
    pose_2 = Pose(0.4, -0.2, 0.4, 0, 1.57, 0)
    pose_3 = Pose(0.4, -0.2, 0.6, 0, 1.57, 0)
    pose_4 = Pose(0.4, -0.4, 0.6, 0, 1.57, 0)
    pose_5 = Pose(0.4, -0.4, 0.4, 0, 1.57, 0)

    """ Inicializaciones en Script."""

    # initialization_content = "counter = 0\n"
    initialization_content = request_integer_from_primary_client_function(
        "counter", "Inserte cantidad de repeticiones:"
    )

    initial_configuration_space_str = get_inverse_kin_function(
        pose_1.generate_pose(), initial_configuration_space
    )

    initialization_content += "\t" + movej_function(initial_configuration_space_str)

    """ main en Script."""

    main_content = movel_function(pose_2.generate_pose())
    main_content += "\t" + movel_function(pose_3.generate_pose())
    main_content += "\t" + movel_function(pose_4.generate_pose())
    main_content += "\t" + movel_function(pose_5.generate_pose())
    main_content += "\t" + movel_function(pose_1.generate_pose(), EOLC=False)

    """ Generación de archivo"""

    # Cambiar a directorio destino

    # print(os.getcwd())
    os.chdir(rf"{URSCRIPT_FILE_PATH}")
    # print(os.getcwd())

    # Escribir archivo
    with open(FILENAME, "w") as file:
        # func = function_structure("hola_mundo", popup_function("Nemo es buena peli"))
        func = function_structure("initialization", initialization_content)
        func += function_structure("main", main_content)

        file.write(func)


if __name__ == "__main__":
    main()
