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

@app.route("/data", methods= ["POST", "GET"])
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
        {
            "Mode" : 9,
            "Power_ON" : True,
            "Security_Stopped" : True,
            "Emergency_Stopped" : True
        },
        "Joint_Angle":
        {
            "Base_mrad" : 3.14,
            "Shoulder_mrad" : 3.14,
            "Elbow_mrad" : 3.14,
            "Wrist1_mrad" : 3.14,
            "Wrist2_mrad" : 3.14,
            "Wrist3_mrad" : 3.14
        },
        "Joint_Angle_Velocity":
        {
            "Base_mrad_s" : 3.14,
            "Shoulder_mrad_s" : 3.14,
            "Elbow_mrad_s" : 3.14,
            "Wrist1_mrad_s" : 3.14,
            "Wrist2_mrad_s" : 3.14,
            "Wrist3_mrad_s" : 3.14
        },
        "TCP_Position":
        {
            "X_tenth_mm" : 2.5,
            "Y_tenth_mm" : 2.5,
            "Z_tenth_mm" : 2.5
        },
        "TCP_Orientation":
        {
            "RX_mrad" : 1.1,
            "RY_mrad" : 1.1,
            "RZ_mrad" : 1.1
        },
        "TCP_Speed":
        {
            "X_mm_s" : 4.5,
            "Y_mm_s" : 4.5,
            "Z_mm_s" : 4.5,
            "RX_mrad_s" : 4.5,
            "RY_mrad_s" : 4.5,
            "RZ_mrad_s" : 4.5
        }
    }
]
    return jsonify(data)

if __name__ == "__main__":
    app.run(host = "0.0.0.0", port = 5000)

