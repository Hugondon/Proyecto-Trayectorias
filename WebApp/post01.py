from flask import Flask, redirect, url_for, jsonify, render_template, request
import json
from data import data
from tabulate import tabulate

app = Flask(__name__)
robot_state_list = []
joint_angle_list = []
joint_angle_velocity_list = []
tcp_posititon_orientation_list = []
tcp_speed_list = []
row_list = []
current_index = 0


@app.route("/")
def home():
    return render_template("dataset.html")


@app.route("/admin", methods=["POST", "GET"])
def admin():
    if request.method == "POST":
        user = request.form["dat"]
        return redirect(url_for("user", usr=user))
    else:
        return render_template("admin.html")


@app.route("/<usr>")
def user(usr):
    return f"<h1>{usr}</h1>"

###########################################################################


@app.route("/data", methods=["POST"])
def det_data():
    data = {
        "dummy":
        [
            {"name": request.json['dummy'][0]['name']},
            {"number": request.json['dummy'][1]['number']}
        ]
    }
    return jsonify(data)


@app.route("/send", methods=["POST", "GET"])
def send_data():
    global current_index
    global robot_state_list
    global joint_angle_list
    global joint_angle_velocity_list
    global tcp_posititon_orientation_list
    global tcp_speed_list
    robot_state_mode = request.json['Robot_State'][0]['Mode']
    robot_state_power_on = request.json['Robot_State'][1]['Power_ON']
    robot_state_security_stopped = request.json['Robot_State'][2]['Security_Stopped']
    robot_state_emergency_stopped = request.json['Robot_State'][3]['Emergency_Stopped']

    joint_angle_base_mrad = request.json['Joint_Angle'][0]['Base_mrad']
    joint_angle_shoulder_mrad = request.json['Joint_Angle'][1]['Shoulder_mrad']
    joint_angle_elbow_mrad = request.json['Joint_Angle'][2]['Elbow_mrad']
    joint_angle_wrist_1_mrad = request.json['Joint_Angle'][3]['Wrist1_mrad']
    joint_angle_wrist_2_mrad = request.json['Joint_Angle'][4]['Wrist2_mrad']
    joint_angle_wrist_3_mrad = request.json['Joint_Angle'][5]['Wrist3_mrad']

    joint_angle_velocity_base_mrad_s = request.json['Joint_Angle_Velocity'][0]['Base_mrad_s']
    joint_angle_velocity_shoulder_mrad_s = request.json['Joint_Angle_Velocity'][1]['Shoulder_mrad_s']
    joint_angle_velocity_elbow_elbow_mrad_s = request.json['Joint_Angle_Velocity'][2]['Elbow_mrad_s']
    joint_angle_velocity_wrist_1_mrad_s = request.json['Joint_Angle_Velocity'][3]['Wrist1_mrad_s']
    joint_angle_velocity_wrist_2_mrad_s = request.json['Joint_Angle_Velocity'][4]['Wrist2_mrad_s']
    joint_angle_velocity_wrist_3_mrad_s = request.json['Joint_Angle_Velocity'][5]['Wrist3_mrad_s']

    tcp_position_orientation_x = request.json['TCP_Position_Orientation'][0]['X_tenth_mm']
    tcp_position_orientation_y = request.json['TCP_Position_Orientation'][1]['Y_tenth_mm']
    tcp_position_orientation_z = request.json['TCP_Position_Orientation'][2]['Z_tenth_mm']
    tcp_position_orientation_rx = request.json['TCP_Position_Orientation'][3]['RX_mrad']
    tcp_position_orientation_ry = request.json['TCP_Position_Orientation'][4]['RY_mrad']
    tcp_position_orientation_rz = request.json['TCP_Position_Orientation'][5]['RZ_mrad']

    tcp_speed_x = request.json['TCP_Speed'][0]['X_mm_s']
    tcp_speed_y = request.json['TCP_Speed'][1]['Y_mm_s']
    tcp_speed_z = request.json['TCP_Speed'][2]['Z_mm_s']
    tcp_speed_rx = request.json['TCP_Speed'][3]['RX_mrad_s']
    tcp_speed_ry = request.json['TCP_Speed'][4]['RY_mrad_s']
    tcp_speed_rz = request.json['TCP_Speed'][5]['RZ_mrad_s']

    data = [
        {
            "Robot_State":
            [
                {"Mode": robot_state_mode},
                {"Power_ON": robot_state_power_on},
                {"Security_Stopped": robot_state_security_stopped},
                {"Emergency_Stopped": robot_state_emergency_stopped}
            ],
            "Joint_Angle":
            [
                joint_angle_base_mrad,
                joint_angle_shoulder_mrad,
                joint_angle_elbow_mrad,
                joint_angle_wrist_1_mrad,
                joint_angle_wrist_2_mrad,
                joint_angle_wrist_3_mrad,
            ],
            "Joint_Angle_Velocity":
            [joint_angle_velocity_base_mrad_s,
             joint_angle_velocity_shoulder_mrad_s,
             joint_angle_velocity_elbow_elbow_mrad_s,
             joint_angle_velocity_wrist_3_mrad_s,
             joint_angle_velocity_wrist_1_mrad_s,
             joint_angle_velocity_wrist_2_mrad_s,
             ],
            "TCP_Position_Orientation":
            [
                {"X_tenth_mm": tcp_position_orientation_x},
                {"Y_tenth_mm": tcp_position_orientation_y},
                {"Z_tenth_mm": tcp_position_orientation_z},
                {"RX_mrad": tcp_position_orientation_rx},
                {"RY_mrad": tcp_position_orientation_ry},
                {"RZ_mrad": tcp_position_orientation_rz}
            ],
            "TCP_Speed":
            [
                {"X_mm_s": tcp_speed_x},
                {"Y_mm_s": tcp_speed_y},
                {"Z_mm_s": tcp_speed_z},
                {"RX_mrad_s": tcp_speed_rx},
                {"RY_mrad_s": tcp_speed_ry},
                {"RZ_mrad_s": tcp_speed_rz}
            ]
        }
    ]

    robot_state_row = [current_index, robot_state_mode, robot_state_power_on,
                       robot_state_security_stopped,
                       robot_state_emergency_stopped]

    joint_angle_row = [
        current_index,
        joint_angle_base_mrad,
        joint_angle_shoulder_mrad,
        joint_angle_elbow_mrad,
        joint_angle_wrist_1_mrad,
        joint_angle_wrist_2_mrad,
        joint_angle_wrist_3_mrad,
    ]

    joint_angle_velocity_row = [
        current_index,
        joint_angle_velocity_base_mrad_s,
        joint_angle_velocity_shoulder_mrad_s,
        joint_angle_velocity_elbow_elbow_mrad_s,
        joint_angle_velocity_wrist_1_mrad_s,
        joint_angle_velocity_wrist_2_mrad_s,
        joint_angle_velocity_wrist_3_mrad_s,
    ]
    tcp_position_orientation_row = [
        current_index,
        tcp_position_orientation_x,
        tcp_position_orientation_y,
        tcp_position_orientation_z,
        tcp_position_orientation_rx,
        tcp_position_orientation_ry,
        tcp_position_orientation_rz,

    ]
    tcp_speed_row = [
        current_index,
        tcp_speed_x,
        tcp_speed_y,
        tcp_speed_z,
        tcp_speed_rx,
        tcp_speed_ry,
        tcp_speed_rz

    ]

    robot_state_list.append(robot_state_row)
    joint_angle_list.append(joint_angle_row)
    joint_angle_velocity_list.append(joint_angle_velocity_row)
    tcp_posititon_orientation_list.append(tcp_position_orientation_row)
    tcp_speed_list.append(tcp_speed_row)

    # Print Robot State
    print(
        tabulate(
            robot_state_list,
            headers=['Index',
                     'Mode',
                     'Power On',
                     'Security Stopped',
                     'Emergency Stopped'],
            tablefmt='fancy_grid')
    )

    # Print Joint Angle
    print(
        tabulate(
            joint_angle_list,
            headers=['Index', 'Base [mrad]',
                     'Shoulder [mrad]', 'Elbow [mrad]',
                     'Wrist 1 [mrad]', 'Wrist 2 [mrad]', 'Wrist 3 [mrad]'],
            tablefmt='fancy_grid')
    )

    # Print Joint Angle Velocity
    print(
        tabulate(
            joint_angle_velocity_list,
            headers=['Index', 'Base[mrad/s]', 'Shoulder[mrad/s]', 'Elbow[mrad/s]',
                     'Wrist 1 [mrad/s]', 'Wrist 2 [mrad/s]', 'Wrist 3 [mrad/s]'],
            tablefmt='fancy_grid'

        )
    )

    # Print TCP Position / Orientation
    print(tabulate(tcp_posititon_orientation_list,
                   headers=['Index', 'X [mm/10]', 'Y [mm/10]',
                            'Z [mm/10]', 'RX [mrad]', 'RY [mrad]', 'RZ [mrad]', ],
                   tablefmt='fancy_grid'))

    print(tabulate(tcp_speed_list,
                   headers=['Index', 'X [mm/s]', 'Y [mm/s]', 'Z [mm/s]',
                            'RX [mrad/s]', 'RY [mrad/s]', 'RZ [mrad/s]'],
                   tablefmt='fancy_grid'))
    # print(json.dumps(data, indent=2))
    current_index += 1
    return jsonify(data)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
