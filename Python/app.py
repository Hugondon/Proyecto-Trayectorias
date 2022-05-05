import csv
import os
import tkinter as tk

from frames import FileManager
from tkinter import ttk
from utils import *

COLOUR_PRIMARY = "#ecf2f0"
COLOUR_SECONDARY = "#b5effd"
COLOUR_LIGHT_BACKGROUND = "#fff"
COLOUR_GRAY_BACKGROUND = "#c3c3c3"
COLOUR_LIGHT_TEXT = "#000000"
COLOUR_DARK_TEXT = "#000000"

"""
Pendientes:

1. No me agrada row de URScript file path. Modificar para nada más asignar nombre?

"""


class Parser(tk.Tk):

    MOVEJ_MOVEMENT = 0
    MOVEL_MOVEMENT = 1

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        style = ttk.Style(self)
        style.theme_use("clam")

        style.configure("FileManager.TFrame",
                        background=COLOUR_LIGHT_BACKGROUND)
        style.configure("Background.TFrame", background=COLOUR_PRIMARY)
        style.configure(
            "ParserText.TLabel",
            background=COLOUR_GRAY_BACKGROUND,
            foreground=COLOUR_DARK_TEXT,
            font=("Segoe UI", 10)
        )
        style.configure(
            "LightText.TLabel",
            background=COLOUR_PRIMARY,
            foreground=COLOUR_LIGHT_TEXT,
            font=("Segoe UI", 10)
        )
        style.configure(
            "TextTitle.TLabel",
            background=COLOUR_PRIMARY,
            foreground=COLOUR_LIGHT_TEXT,
            font=("Segoe UI", 14, "bold")
        )
        style.configure(
            "FileManagerButton.TButton",
            background=COLOUR_SECONDARY,
            foreground=COLOUR_LIGHT_TEXT,
            font=("Segoe UI", 10),
        )
        self["background"] = COLOUR_PRIMARY

        """ ATTRIBUTES """

        self.title("HARA Parser")
        self.movements_list = []
        self.poses_list = []
        self.configuration_spaces_list = []

        self.initialization_content = ""
        self.main_initialization = ""
        self.main_content = ""

        """ LAYOUT CONFIGURATION """
        self.columnconfigure(0, weight=1)
        self.rowconfigure(1, weight=1)

        container = ttk.Frame(self)
        container.grid(row=0, column=0, sticky="NS")
        container.columnconfigure(0, weight=1)

        conversation_frame = FileManager(container, self)
        conversation_frame.grid(row=0, column=0, sticky="NESW")

    def parse_csv(self, CSV_FILE_PATH):
        """ Reset lists """
        self.movements_list = []
        self.poses_list = []
        self.configuration_spaces_list = []

        """Leer archivo CSV."""
        with open(CSV_FILE_PATH, "r") as file:
            next(file)  # Por si es necesario saltarse la primera linea
            csv_rows = csv.reader(file)
            for row in csv_rows:
                if row[0] == "":
                    break
                movement_type = int(row[0])
                current_pose = Pose(
                    x=float(row[1]),
                    y=float(row[2]),
                    z=float(row[3]),
                    rx=float(row[4]),
                    ry=float(row[5]),
                    rz=float(row[6]),
                )

                self.movements_list.append(movement_type)
                self.poses_list.append(current_pose)
                if movement_type == self.MOVEJ_MOVEMENT:
                    current_configuration_space = ConfigurationSpace(
                        base_angle_rad=float(row[7]),
                        shoulder_angle_rad=float(row[8]),
                        elbow_angle_rad=float(row[9]),
                        wrist_1_angle_rad=float(row[10]),
                        wrist_2_angle_rad=float(row[11]),
                        wrist_3_angle_rad=float(row[12]),
                    )
                else:
                    # Ponemos lugar string vacío para indicar que no hubo configuration space en esa row
                    current_configuration_space = ""
                self.configuration_spaces_list.append(
                    current_configuration_space)

        """Generacion de Script."""
        initial_configuration_space = ConfigurationSpace(
            BASE_ANGLE_RAD,
            SHOULDER_ANGLE_RAD,
            ELBOW_ANGLE_RAD,
            WRIST_1_ANGLE_RAD,
            WRIST_2_ANGLE_RAD,
            WRIST_3_ANGLE_RAD,
        )

        pose_1 = self.poses_list[0]

        # Inicializaciones en Script.

        self.initialization_content = "\t" + "global program_counter = 1\n"
        # self.initialization_content = request_integer_from_primary_client_function(
        #     "program_counter", "Inserte cantidad de repeticiones:"
        # )

        self.initialization_content += movej_function(
            get_inverse_kin_function(pose_1, initial_configuration_space)
        )

        #  main en Script.

        self.main_initialization = f"\tcounter = 0\n"
        self.main_content = ""

        # Empezamos desde el segundo elemento debido a que el primero siempre será el de inicialización
        for index, pose in enumerate(self.poses_list[1:], 1):
            if self.movements_list[index] == self.MOVEJ_MOVEMENT:
                self.main_content += movej_function(
                    get_inverse_kin_function(
                        pose, self.configuration_spaces_list[index])
                )
            else:
                self.main_content += movel_function(pose)

        self.main_content = while_structure(
            "counter", "program_counter", self.main_content)
        self.main_content = self.main_initialization + self.main_content


app = Parser()
app.mainloop()
