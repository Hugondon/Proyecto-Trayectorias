import os
import typing

"""
Pendientes:
    1. No se actualiza automáticamente en la interfaz de Polyscope el archivo que se modifica
    Hacerlo por archivos que escriban diferentes funciones ? 
"""

"""
Estandarización:
    1. EOL: Se debe hacer EOLC (End of Line)=True para la última línea llamada en cada función.
    2. Tab: Se debe hacer SOL (Start of Line)=True cuando no se desee poner el tab inicial

    Solamente es necesaria para funciones que puedan o no estar dentro de otras.
"""


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


class ConfigurationSpace:
    def __init__(
        self,
        base_angle_rad: float,
        shoulder_angle_rad: float,
        elbow_angle_rad: float,
        wrist_1_angle_rad: float,
        wrist_2_angle_rad: float,
        wrist_3_angle_rad: float,
    ):
        self.base_angle_rad = base_angle_rad
        self.shoulder_angle_rad = shoulder_angle_rad
        self.elbow_angle_rad = elbow_angle_rad
        self.wrist_1_angle_rad = wrist_1_angle_rad
        self.wrist_2_angle_rad = wrist_2_angle_rad
        self.wrist_3_angle_rad = wrist_3_angle_rad

    def __str__(self) -> str:
        return f"[{self.base_angle_rad}, {self.shoulder_angle_rad}, {self.elbow_angle_rad}, {self.wrist_1_angle_rad}, {self.wrist_2_angle_rad}, {self.wrist_3_angle_rad}]"


class Pose:
    def __init__(self, x: float, y: float, z: float, rx: float, ry: float, rz: float):
        self.x = x
        self.y = y
        self.z = z
        self.rx = rx
        self.ry = ry
        self.rz = rz

    def __str__(self) -> str:
        return f"p[{self.x}, {self.y}, {self.z}, {self.rx}, {self.ry}, {self.rz}]"


def function_structure(name: str, content: str) -> str:
    """Function structure string generator."""
    structure = f"def {name}():\n"
    structure += f"{content}"
    structure += f"end\n"
    return structure


def while_structure(variable: str, condition: str, content: str) -> str:
    """While structure based on 'less than' condition and variable increments."""
    structure = f"\twhile({variable} < {condition}):\n"
    structure += f"{content}"
    structure += f"\t{variable} = {variable} + 1\n"
    structure += f"\tend\n"
    return structure


def popup_function(msg: str) -> str:
    """Return string for popup function."""
    return f'popup("{msg}", blocking=True)'


def movel_function(
    pose: str, radius: str = "0.0", EOLC: bool = True, SOL: bool = False
) -> str:
    """Return string for movel function."""
    return_string = ""
    if not SOL:
        return_string += "\t"

    return_string += f"movel(pose_trans(starting_pose_tcp, pose_trans(first_trajectory_pose,{pose})), r={radius})"
    # return_string += f"movel({pose}, r={radius})"

    if EOLC:
        return_string += "\n"

    return return_string


def movej_function(pose: str, EOLC: bool = True, SOL: bool = False) -> str:
    """Return string for movej function."""

    return_string = ""
    if not SOL:
        return_string += "\t"

    return_string += f"movej({pose})"

    if EOLC:
        return_string += "\n"

    return return_string


def get_actual_tcp_pose() -> str:
    """Return string for get_actual_tcp_pose function."""
    return "get_actual_tcp_pose()"


def get_inverse_kin_function(pose: str, qnear: str) -> str:
    """Return string for get_inverse_king function."""
    return f"get_inverse_kin({pose}, qnear={qnear})"


def request_integer_from_primary_client_function(
    variable: str, msg: str, SOL: bool = False
) -> str:
    """Return string for assigment of variable using UI."""
    return_string = ""
    if not SOL:
        return_string += "\t"

    return_string += (
        f'global {variable} = request_integer_from_primary_client("{msg}")\n'
    )
    return return_string


def main():
    """Valores iniciales"""

    initial_configuration_space = ConfigurationSpace(
        BASE_ANGLE_RAD,
        SHOULDER_ANGLE_RAD,
        ELBOW_ANGLE_RAD,
        WRIST_1_ANGLE_RAD,
        WRIST_2_ANGLE_RAD,
        WRIST_3_ANGLE_RAD,
    )

    pose_1 = Pose(0.4, -0.4, 0.4, 0, 1.57, 0)
    pose_2 = Pose(0.4, -0.2, 0.4, 0, 1.57, 0)
    pose_3 = Pose(0.4, -0.2, 0.6, 0, 1.57, 0)
    pose_4 = Pose(0.4, -0.4, 0.6, 0, 1.57, 0)
    pose_5 = Pose(0.4, -0.4, 0.4, 0, 1.57, 0)

    """ Inicializaciones en Script."""

    # initialization_content = "\t" + "counter = 0\n"
    initialization_content = request_integer_from_primary_client_function(
        "counter", "Inserte cantidad de repeticiones:"
    )

    initialization_content += movej_function(
        get_inverse_kin_function(pose_1, initial_configuration_space)
    )

    """ main en Script."""

    main_content = movel_function(pose_2)
    main_content += movel_function(pose_3)
    main_content += movel_function(pose_4)
    main_content += movel_function(pose_5)
    main_content += movel_function(pose_1)

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
