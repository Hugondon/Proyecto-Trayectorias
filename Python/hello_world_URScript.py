import os

# No se actualiza automáticamente en la interfaz de Polyscope el archivo que se modifica
# Typing a funciones que creemos

# Problema con EOL: en todos, menos el ultimo elemento de la estructura debe llevar EOL

# FILENAME = 'hello_world.script'
FILENAME = "movel_1.script"
URSCRIPT_PATH = "/home/hugo/URSim-5.10.2/programs/Proyecto/Hello_World_Python"

BASE_ANGLE_RAD = -0.604
SHOULDER_ANGLE_RAD = -1.204
ELBOW_ANGLE_RAD = -2.091
WRIST_1_ANGLE_RAD = -1.417
WRIST_2_ANGLE_RAD = 1.569
WRIST_3_ANGLE_RAD = 0


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
    structure = f"def {name}():\n"
    structure += f"\t{content}\n"
    structure += f"end"
    return structure


def while_structure(variable, condition, content):
    """While structure based on 'less than' condition and variable increments."""
    structure = f"while({variable} < {condition}):\n"
    structure += f"\t{content}\n"
    structure += f"\t{variable} = {variable} + 1\n"
    structure += f"end"
    return structure


def popup_function(msg):
    return f'popup("{msg}", blocking=True)'


def movel_function(initial_pose, radius="0.05", EOL=True):
    return (
        f"movel({initial_pose}, r={radius})\n"
        if EOL
        else f"movel({initial_pose}, r={radius})"
    )


def movej_function(initial_pose, EOL=True):
    return f"movej({initial_pose})\n" if EOL else f"movej({initial_pose})"


def get_inverse_kin_function(pose, qnear):
    return f"get_inverse_kin({pose}, qnear={qnear})"


def main():

    """Generar valores iniciales"""
    initial_configuration_space = f"[{BASE_ANGLE_RAD},{SHOULDER_ANGLE_RAD},{ELBOW_ANGLE_RAD}, {WRIST_1_ANGLE_RAD},{WRIST_2_ANGLE_RAD},{WRIST_3_ANGLE_RAD}]"
    pose_1 = Pose(0.4, -0.3, 0.4, 0, 1.57, 0)
    pose_2 = Pose(0.4, -0.3, 0.2, 0, 1.57, 0)

    """Contenido de funcion"""

    function_content = movej_function(
        get_inverse_kin_function(pose_1.generate_pose(), initial_configuration_space)
    )
    function_content += "\t" + movel_function(pose_2.generate_pose(), EOL=False)

    """ Cambiar a directorio destino """
    # print(os.getcwd())
    os.chdir(rf"{URSCRIPT_PATH}")
    # print(os.getcwd())
    """ Generar archivo """
    with open(FILENAME, "w") as file:
        # func = function("hola_mundo", popup_function("Nemo es buena peli"))
        func = function("hola_mundo", function_content)
        file.write(func)

    print(
        while_structure(
            "contador", 5, movej_function(pose_1.generate_pose(), EOL=False)
        )
    )
    # print(get_inverse_kin_function(pose_1.generate_pose(), initial_configuration_space))
    # print(initial_configuration_space)
    # print(pose_1.generate_pose())
    # print(movel_function(pose_1.generate_pose()))


if __name__ == "__main__":
    main()
