%% Main program
% This program executes all the functions needed to create
% the point of the complex trajectory.
% The units used in the program and its functions are from the International System(IS)

%{
Comentarios:
https: // la.mathworks.com / help / robotics / ref / inversekinematics - system - object.html?searchHighlight = inverse %20kinematics&s_tid=srchtitle
%}

%% Setup

clear, clc, clear

%% Function Handles

declareRobot    =   @declareRobot;
setWaypoints    =   @setWaypoints;
getTimeInterval =   @getTimeInterval;
moveL           =   @moveL;
simulateRobot   =   @simulateRobot;

%% Loading Robot

% Get the object robot, the number of joints and endeffector
[robot, numJoint, endEffector] = declareRobot("universalUR5");

% Get Joint angles Home position; TCP position and its orientation

% jointHomeAngles = [-1.055051532830572; -0.922930108454602; -2.274513081199010; -1.514247659030281; 1.572192590196492; 0.515570261039125];
% toolHomeOrientation = [0; 3.141592653589793; 0];
% toolHomePosition = [0; -0.270000000000000; 0.380000000000000];
load UR5positions
%% Set Inverse Kinematics Paramaters

% Define IK
ik = inverseKinematics('RigidBodyTree', robot);
ikWeights = ones(1, numJoint);
ikInitialGuess = jointHomeAngles;

%% Get Waypoints

[waypoints, numberWaypoints, magnitudeDistances] = setWaypoints();

%% Trajectory Time Intervals

% TCP Speed(Defined by user)
tcpSpeed_ms = 1; %[m/s]

% Number of Intermediate Waypoints(Defined by user)
nIntermediateWaypoints = 1;

% Between main waypoints

% Get the cummulative sum of the magnitudes of the distance (initial distance = 0m)
csMagnitudeDistances = cumsum([0, magnitudeDistances]);

% Total time to get to each waypoint from the initial waypoint. t = d / v
total_time_to_waypoint = csMagnitudeDistances / tcpSpeed_ms;

ts = getTimeInterval(nIntermediateWaypoints, csMagnitudeDistances, tcpSpeed_ms);

%% Parameters of the Trajectory Graph 

% Type of Plot
plotMode = 1; % 0 = No Plot, 1 = Trajectory Points, 2 = Coordinate Frames

figureRobot=figure('Name','Robot','NumberTitle','off','WindowState','maximized');

% Show robot in Initial Configuration Space
show(robot, jointHomeAngles, 'Frames', 'off', 'PreservePlot', false);

% Establish graph limits
xlim([-0.8 0.8]), ylim([-0.8 0.8]), zlim([-0.5 1])
hold on

% Graph main waypoints
waypoints_positions = tform2trvec(waypoints(:, :, :));
plot3(waypoints_positions(:, 1), ...
    waypoints_positions(:, 2), ...
    waypoints_positions(:, 3), ...
    'ro', 'LineWidth', 2);

%% Trajectory Data Cell Array

%trajectory_data = cell(3, numberWaypoints - 1);

%% Calculate Poses and Inverse Kinematics
trajectory_data= moveL( waypoints,total_time_to_waypoint,ts,...
                        ik,endEffector,ikWeights,ikInitialGuess);

%% Graph Trajectory and Simulate Robot                      
figureRobot = simulateRobot(plotMode,trajectory_data,...
                            robot,figureRobot);

%% Convertion to CSV
FILENAME = 'trajectory.csv';
% Mustn't be changed to [] although warning says so.
COLUMN_HEADERS = {"Tipo de Movimiento", ...
                "X [m]", "Y [m]", "Z [m]", ...
                "Rx [rad]", "Ry [rad]", "Rz [rad]", ...
                "Base [rad]", "Shoulder [rad]", "Elbow [rad]", ...
                "Wrist 1 [rad]", "Wrist 2 [rad]", "Wrist 3 [rad]"};

% Write row containing column headers.
writecell(COLUMN_HEADERS, FILENAME, 'WriteMode', 'overwrite');

for main_waypoint = 1:size(trajectory_data, 2)

    % Prepare trajectory information
    movement_type = cell2mat(trajectory_data(1, main_waypoint));
    poses_array = cell2mat(trajectory_data(2, main_waypoint));
    configuration_space = cell2mat(trajectory_data(3, main_waypoint));

    for intermediate_waypoints = 1:size(poses_array, 3)
        % Obtain configuration space information
        intermediate_configuration_space = configuration_space(:, intermediate_waypoints);
        
        % Obtain pose information
        pose = poses_array(:, :, intermediate_waypoints);
        axis_angle_rotation = tform2axang(pose);
        pose_rotation = axis_angle_rotation(1, 1:3) .* axis_angle_rotation(1, 4);
        pose_translation = tform2trvec(pose);

        csv_information = [movement_type, pose_translation, pose_rotation, intermediate_configuration_space'];
        writematrix(csv_information, FILENAME, 'WriteMode', 'append');
    end

end
% clear axis_angle_rotation pose_rotation pose_translation COLUMN_HEADERS ik ikWeights...
%     ikInitialGuess poses_array configuration_space FILENAME nIntermediateWaypoints...
%     intermediate_waypoints main_waypoint movement_type pose tcpSpeed_ms ...
%     total_time_to_waypoint ans
% Falta el moveJ

