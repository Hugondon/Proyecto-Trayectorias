import tkinter as tk


from tkinter import messagebox, ttk
from tkinter.filedialog import asksaveasfile, askopenfilename
from PIL import ImageTk, Image
from utils import *


class FileManager(ttk.Frame):

    DEFAULT_CSV_PATH = "C:/*.csv"
    DEFAULT_USCRIPT_PATH = "C:/*.script"
    LOGO_PATH = "Software/Python/imgs/hara_services_v3.png"
    LOGO_WIDTH, LOGO_HEIGHT = 291, 241

    def __init__(self, parent, controller):
        super().__init__(parent)

        self["style"] = "Background.TFrame"

        self.controller = controller

        """ ATTRIBUTES """
        self.csv_file_path = self.DEFAULT_CSV_PATH
        self.urscript_file_path = self.DEFAULT_USCRIPT_PATH
        self.csv_file_path_str = tk.StringVar(value=f"{self.DEFAULT_CSV_PATH}")
        self.urscript_file_path_str = tk.StringVar(
            value=f"{self.DEFAULT_USCRIPT_PATH}")

        """ LAYOUT CONFIGURATION """

        """ FIRST ROW """
        app_label = ttk.Label(
            self,
            text="CSV - URScript Parser",
            style="TextTitle.TLabel"
        )

        app_label.grid(row=0, column=1, sticky="W", pady=(5, 20))

        """ SECOND ROW """
        csv_path_label = ttk.Label(
            self,
            text="CSV File Path",
            style="LightText.TLabel"
        )
        self.csv_path_entry = ttk.Entry(
            self, width=25, textvariable=self.csv_file_path_str,
            font=("Segoe UI", 9)
        )
        load_csv_path_button = ttk.Button(
            self,
            text="Load CSV File",
            command=self.load_csv_path,
            style="FileManagerButton.TButton",
            cursor="hand2"
        )

        csv_path_label.grid(row=1, column=0, padx=(15, 5), sticky="W")
        self.csv_path_entry.grid(row=1, column=1, sticky="EW")
        load_csv_path_button.grid(row=1, column=2, sticky="EW", padx=(15, 5))

        """ THIRD ROW """
        urscript_filepath_label = ttk.Label(
            self,
            text="URScript File Path",
            style="LightText.TLabel"
        )
        self.urscript_filepath_entry = ttk.Entry(
            self, width=25,
            textvariable=self.urscript_file_path_str,
            font=("Segoe UI", 9)
        )
        urscript_button = ttk.Button(
            self,
            text="Save URScript File",
            command=self.update_urscript_path,
            style="FileManagerButton.TButton",
            cursor="hand2"
        )

        urscript_filepath_label.grid(
            row=2, column=0, padx=(15, 5), pady=(10, 10), sticky="W")
        self.urscript_filepath_entry.grid(
            row=2, column=1, pady=(10, 10), sticky="EW")
        urscript_button.grid(
            row=2, column=2, sticky="EW", padx=(15, 5), pady=(10, 10))
        """ FOURTH ROW """

        hara_logo_img = Image.open(self.LOGO_PATH)
        hara_logo_img = hara_logo_img.resize(
            (self.LOGO_WIDTH//4, self.LOGO_HEIGHT//4))
        hara_logo_img = ImageTk.PhotoImage(hara_logo_img)
        panel = ttk.Label(self, image=hara_logo_img)

        # Linea importante
        panel.image = hara_logo_img
        parse_csv_button = ttk.Button(
            self,
            text="Save to specific folder",
            command=self.parser_csv_to_urscript,
            style="FileManagerButton.TButton",
            cursor="hand2"
        )

        panel.grid(
            row=3, column=0, sticky="NW", padx=(15, 0), pady=(0, 10)
        )
        parse_csv_button.grid(
            row=3, column=2, sticky="NE", padx=(15, 5), pady=(0, 10))

    def load_csv_path(self):
        file = askopenfilename(
            title="Select New Path",
            filetypes=[("csv", ".csv")],
            defaultextension=".csv")
        if file:
            self.csv_path_entry.delete(0, tk.END)
            self.csv_path_entry.insert(0, file)
            self.csv_file_path = f"{self.csv_file_path_str.get()}"
        else:
            messagebox.showinfo(
                message="No File Selected",
                title="Error"
            )

    def update_urscript_path(self):
        self.controller.parse_csv(self.csv_file_path)
        file_path = f"{self.urscript_file_path_str.get()}"
        try:
            with open(file_path, 'w') as f:
                func = function_structure(
                    "initialization", self.controller.initialization_content)
                func += function_structure("main",
                                           self.controller.main_content)
                f.write(func)
        except OSError:
            messagebox.showinfo(
                message=f"{file_path} is not a valid path to save your file!",
                title="Error"
            )
        else:
            self.urscript_filepath_entry.delete(0, tk.END)
            self.urscript_filepath_entry.insert(0, file_path)

    def parser_csv_to_urscript(self):

        # Generación de archivo
        self.controller.parse_csv(self.csv_file_path)
        file = asksaveasfile(filetypes=[("UR script", ".script")],
                             defaultextension=".script")
        if file:
            with open(file.name, 'w') as f:
                func = function_structure(
                    "initialization", self.controller.initialization_content)
                func += function_structure("main",
                                           self.controller.main_content)
                file.write(func)
            self.urscript_filepath_entry.delete(0, tk.END)
            self.urscript_filepath_entry.insert(0, file.name)
        else:
            messagebox.showinfo(
                message="File won't be created",
                title="Error"
            )
