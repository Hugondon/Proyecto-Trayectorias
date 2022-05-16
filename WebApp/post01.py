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
        "dummy":
        [
            {"name": request.json['dummy'][0]['name']},
            {"number": request.json['dummy'][1]['number']}
        ]
    }
    return jsonify(data)

@app.route("/send", methods= ["POST", "GET"])
def send_data():
    data = [
        {
            "Robot_State":
            [
                {"Mode" : request.json['Robot_State'][0]['Mode']},
                {"Power_ON" : request.json['Robot_State'][1]['Power_ON']},
                {"Security_Stopped" : request.json['Robot_State'][2]['Security_Stopped']},
                {"Emergency_Stopped" : request.json['Robot_State'][3]['Emergency_Stopped']}
            ],
            "Joint_Angle":
            [
                {"Base_mrad" : request.json['Joint_Angle'][0]['Base_mrad']},
                {"Shoulder_mrad" : request.json['Joint_Angle'][1]['Shoulder_mrad']},
                {"Elbow_mrad" : request.json['Joint_Angle'][2]['Elbow_mrad']},
                {"Wrist1_mrad" : request.json['Joint_Angle'][3]['Wrist1_mrad']},
                {"Wrist2_mrad" : request.json['Joint_Angle'][4]['Wrist2_mrad']},
                {"Wrist3_mrad" : request.json['Joint_Angle'][5]['Wrist3_mrad']}
            ],
            "Joint_Angle_Velocity":
            [
                {"Base_mrad_s" : request.json['Joint_Angle_Velocity'][0]['Base_mrad_s']},
                {"Shoulder_mrad_s" : request.json['Joint_Angle_Velocity'][1]['Shoulder_mrad_s']},
                {"Elbow_mrad_s" : request.json['Joint_Angle_Velocity'][2]['Elbow_mrad_s']},
                {"Wrist1_mrad_s" : request.json['Joint_Angle_Velocity'][3]['Wrist1_mrad_s']},
                {"Wrist2_mrad_s" : request.json['Joint_Angle_Velocity'][4]['Wrist2_mrad_s']},
                {"Wrist3_mrad_s" : request.json['Joint_Angle_Velocity'][5]['Wrist3_mrad_s']}
            ],
            "TCP_Position_Orientation":
            [
                {"X_tenth_mm" : request.json['TCP_Position_Orientation'][0]['X_tenth_mm']},
                {"Y_tenth_mm" : request.json['TCP_Position_Orientation'][1]['Y_tenth_mm']},
                {"Z_tenth_mm" : request.json['TCP_Position_Orientation'][2]['Z_tenth_mm']},
                {"RX_mrad" : request.json['TCP_Position_Orientation'][3]['RX_mrad']},
                {"RY_mrad" : request.json['TCP_Position_Orientation'][4]['RY_mrad']},
                {"RZ_mrad" : request.json['TCP_Position_Orientation'][5]['RZ_mrad']}
            ],
            "TCP_Speed":
            [
                {"X_mm_s" : request.json['TCP_Speed'][0]['X_mm_s']},
                {"Y_mm_s" : request.json['TCP_Speed'][1]['Y_mm_s']},
                {"Z_mm_s" : request.json['TCP_Speed'][2]['Z_mm_s']},
                {"RX_mrad_s" : request.json['TCP_Speed'][3]['RX_mrad_s']},
                {"RY_mrad_s" : request.json['TCP_Speed'][4]['RY_mrad_s']},
                {"RZ_mrad_s" : request.json['TCP_Speed'][5]['RZ_mrad_s']}
            ]
        }
    ]
    print(json.dumps(data, indent=2))
    return jsonify(data)

if __name__ == "__main__":
    app.run(host = "0.0.0.0", port = 5000)

