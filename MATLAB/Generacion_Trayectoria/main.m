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

declareRobot = @declareRobot;
setWaypoints = @setWaypoints;
getTimeInterval = @getTimeInterval;

%% Loading Robot

% Get the object robot, the number of joints and endeffector
[robot, numJoint, endEffector] = declareRobot("universalUR5");

% Get Joint angles Home position; TCP position and its orientation

% jointHomeAngles = [-1.055051532830572; -0.922930108454602; -2.274513081199010; -1.514247659030281; 1.572192590196492; 0.515570261039125];
% toolHomeOrientation = [0; 3.141592653589793; 0];
% toolHomePosition = [0; -0.270000000000000; 0.380000000000000];
load UR5positions
%% Set Inverse Kinematics

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
nIntermediateWaypoints = 20;

% Between main waypoints

% Get the cummulative sum of the magnitudes of the distance (initial distance = 0m)
csMagnitudeDistances = cumsum([0, magnitudeDistances]);

% Total time to get to each waypoint from the initial waypoint. t = d / v
total_time_to_waypoint = csMagnitudeDistances / tcpSpeed_ms;

ts = getTimeInterval(nIntermediateWaypoints, csMagnitudeDistances, tcpSpeed_ms);

%% Parameters of the Graphed Trajectory

% Type of Plot
plotMode = 1; % 0 = No Plot, 1 = Trajectory Points, 2 = Coordinate Frames

% Show robot in Initial Configuration Space
show(robot, jointHomeAngles, 'Frames', 'off', 'PreservePlot', false);

% Establish graph limits
xlim([-1 1]), ylim([-1 1]), zlim([-0.5 1.5])
hold on

% Graph main waypoints
waypoints_positions = tform2trvec(waypoints(:, :, :));
plot3(waypoints_positions(:, 1), ...
    waypoints_positions(:, 2), ...
    waypoints_positions(:, 3), ...
    'ro', 'LineWidth', 2);

%% Trajectory Data Cell Array

trajectory_data = cell(3, numberWaypoints - 1);

%% Calculate Poses

for count = 1:numberWaypoints - 1

    % Extract the starting and finishing waypoint times of the segment of the trajectory
    main_waypoints_time_interval = total_time_to_waypoint(count:count + 1);
    % Get the times of the intermediate waypoints in the segment of the trajectory
    intermediate_waypoints_time_interval = main_waypoints_time_interval(1):ts(count):main_waypoints_time_interval(2);

    % Find the transforms from trajectory generation
    % Change transformation_matrix_array
    [transformation_matrix_array, vel, acc] = ...
        transformtraj(waypoints(:, :, count), ...
        waypoints(:, :, count + 1), ...
        main_waypoints_time_interval, ...
        intermediate_waypoints_time_interval);

    % To avoid repeated Waypoints
    if count > 1
        transformation_matrix_array(:, :, 1) = [];
    end

    % Save type of movements and poses
    % Movement Type
    trajectory_data{1, count} = 1; % MoveJ=0 MoveL=1
    % Poses
    trajectory_data{2, count} = transformation_matrix_array;
end

%% Graph Trajectory

for count = 1:numberWaypoints - 1

    % Trajectory visualization of the Waypoints for the segment
    if plotMode == 1
        tcp_position = tform2trvec(trajectory_data{2, count});
        plot3(tcp_position(:, 1), tcp_position(:, 2), tcp_position(:, 3), '-^', 'Color', 'k');

        % Trajectory visualization of the TCP poses for the segment
    elseif plotMode == 2
        plotTransforms(tform2trvec(trajectory_data{2, count}), ...
            tform2quat(trajectory_data{2, count}), 'FrameSize', 0.05);
    end

end

%% Robot Inverse Kinematics

for count = 1:numberWaypoints - 1

    % Get number of Configurations on the configuration space
    size_config_space = size(trajectory_data{2, count}, 3);

    % Reserve memory for the configurations
    config_space_data = zeros(6, size_config_space);

    % Intermediate waypoints movement
    for index = 1:size_config_space

        % Solve IK
        target_pose = trajectory_data{2, count}(:, :, index);

        % Configuration contains the angle for each joint.
        [configuration_space, info] = ik(endEffector, target_pose, ikWeights, ikInitialGuess);
        ikInitialGuess = configuration_space;

        % Save the configuration space in a matrix
        config_space_data(:, index) = configuration_space;
    end

    % Save the configuration space in trajectory data to use
    % it in the Simulation of the robot
    trajectory_data{3, count} = config_space_data;
end

%% Simulate Robot

for count = 1:numberWaypoints - 1

    % Intermediate waypoints movement
    for index = 1:size(trajectory_data{2, count}, 3)

        show(robot, trajectory_data{3, count}(:, index), 'Frames', 'off', 'PreservePlot', false);

        title(sprintf("Trajectory at t = %.4f s", intermediate_waypoints_time_interval(index)));

        % Get the desired View
        view([-0.6 -0.6 0.2]);
        drawnow
    end

end

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

    % Obtain configuration space information
    configuration_space = configuration_space(:, main_waypoint);

    for intermediate_waypoints = 1:size(poses_array, 3)
        % Obtain pose information
        pose = poses_array(:, :, intermediate_waypoints);
        axis_angle_rotation = tform2axang(pose);
        pose_rotation = axis_angle_rotation(1, 1:3) .* axis_angle_rotation(1, 4);
        pose_translation = tform2trvec(pose);

        csv_information = [movement_type, pose_translation, pose_rotation, configuration_space'];
        writematrix(csv_information, FILENAME, 'WriteMode', 'append');
    end

end

% Falta el moveJ

% Tal vez agregar clears
