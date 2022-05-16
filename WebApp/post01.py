from flask import Flask, redirect, url_for, jsonify, render_template, request
import json
from data import data

app = Flask(__name__)

@app.route("/")
def home():
    return render_template("dataset.html")

@app.route("/admin", methods=["POST", "GET"])
def admin():
    if request.method == "POST":
        user = request.form["dat"]
        return redirect(url_for("user", usr = user))
    else:
        return render_template("admin.html")

@app.route("/<usr>")
def user(usr):
    return f"<h1>{usr}</h1>"

###########################################################################

@app.route("/data", methods= ["POST"])
def det_data():
    data = {
        "name": request.json['name'],
        "number": request.json['number']
    }
    return jsonify(data)

@app.route("/send", methods= ["POST", "GET"])
def send_data():
    data = [
    {
        "Robot_State":
        [
            {"Mode" : request.json['Mode']},
            {"Power_ON" : request.json['Power_ON']},
            {"Security_Stopped" : request.json['Security_Stopped']},
            {"Emergency_Stopped" : request.json['Emergency_Stopped']}
        ],
        "Joint_Angle":
        [
            {"Base_mrad" : request.json['Base_mrad']},
            {"Shoulder_mrad" : request.json['Shoulder_mrad']},
            {"Elbow_mrad" : request.json['Elbow_mrad']},
            {"Wrist1_mrad" : request.json['Wrist1_mrad']},
            {"Wrist2_mrad" : request.json['Wrist2_mrad']},
            {"Wrist3_mrad" : request.json['Wrist3_mrad']}
        ],
        "Joint_Angle_Velocity":
        [
            {"Base_mrad_s" : request.json['Base_mrad_s']},
            {"Shoulder_mrad_s" : request.json['Shoulder_mrad_s']},
            {"Elbow_mrad_s" : request.json['Elbow_mrad_s']},
            {"Wrist1_mrad_s" : request.json['Wrist1_mrad_s']},
            {"Wrist2_mrad_s" : request.json['Wrist2_mrad_s']},
            {"Wrist3_mrad_s" : request.json['Wrist3_mrad_s']}
        ],
        "TCP_Position_Orientation":
        [
            {"X_tenth_mm" : request.json['X_tenth_mm']},
            {"Y_tenth_mm" : request.json['Y_tenth_mm']},
            {"Z_tenth_mm" : request.json['Z_tenth_mm']},
            {"RX_mrad" : request.json['RX_mrad']},
            {"RY_mrad" : request.json['RY_mrad']},
            {"RZ_mrad" : request.json['RZ_mrad']}
        ],
        "TCP_Speed":
        [
            {"X_mm_s" : request.json['X_mm_s']},
            {"Y_mm_s" : request.json['Y_mm_s']},
            {"Z_mm_s" : request.json['Z_mm_s']},
            {"RX_mrad_s" : request.json['RX_mrad_s']},
            {"RY_mrad_s" : request.json['RY_mrad_s']},
            {"RZ_mrad_s" : request.json['RZ_mrad_s']}
        ]
    }
]
    return jsonify(data)

if __name__ == "__main__":
    app.run(host = "0.0.0.0", port = 5000)

