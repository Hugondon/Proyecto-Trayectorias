%% Main program
% This program executes all the functions needed to create
% the point of the complex trajectory.
% The units used in the program and its functions are from the International System(IS)

%{
Comentarios:
Por qué calcular varias veces number of waypoints?
Más que sampling time, no debería ser time interval entre intermediate waypoints?
A qué se refiere específicamente con configuración el resultado de la ik?
https: // la.mathworks.com / help / robotics / ref / inversekinematics - system - object.html?searchHighlight = inverse %20kinematics&s_tid=srchtitle
%}

%% Setup

clear, clc, clear all

%% Function Handles

declareRobot = @declareRobot;
setWaypoints = @setWaypoints;
getSamplingTime = @getSamplingTime;

%% Loading Robot

% Get the object robot, the number of joints and endeffector
[robot, numJoint, endEffector] = declareRobot("universalUR5");

% Get Joint angles Home position; TCP position and its orientation

jointHomeAngles = [-1.055051532830572; -0.922930108454602; -2.274513081199010; -1.514247659030281; 1.572192590196492; 0.515570261039125];
toolHomeOrientation = [0; 3.141592653589793; 0];
toolHomePosition = [0; -0.270000000000000; 0.380000000000000];

%% Set Inverse Kinematics

% Define IK
ik = inverseKinematics('RigidBodyTree', robot);
ikWeights = ones(1, numJoint);
ikInitialGuess = jointHomeAngles;

%% Get Waypoints

[waypoints, numberWaypoints, magnitudeDistances] = setWaypoints();

%% Trajectory sample time

% TCP Speed(Defined by user)
tcpSpeed_ms = 3; %[m/s]

% Number of Intermediate Waypoints(Defined by user)
nIntermediateWaypoints = 50;

% Between main waypoints

% Get the cummulative sum of the magnitudes of the distance (initial distance = 0m)
csMagnitudeDistances = cumsum([0, magnitudeDistances]);

% Total time to get to each waypoint from the initial waypoint. t = d / v
total_time_to_waypoint = csMagnitudeDistances / tcpSpeed_ms;

ts = getSamplingTime(nIntermediateWaypoints, csMagnitudeDistances, tcpSpeed_ms);

%trajTimes = 0:ts:total_time_to_waypoint(end);
%total_time_to_waypoint=0:10:20;
%ts = 0.2;
%trajTimes = 0:ts:total_time_to_waypoint(end);

%% Trajectory

% Main waypoints movement
for count = 1:numberWaypoints - 1
    main_waypoints_time_interval = total_time_to_waypoint(count:count + 1);
    intermediate_waypoints_time_interval = main_waypoints_time_interval(1):ts(count):main_waypoints_time_interval(2);

    % Find the transforms from trajectory generation
    [transformation_matrix_array, vel, acc] = transformtraj(waypoints(:, :, count), waypoints(:, :, count + 1), main_waypoints_time_interval, intermediate_waypoints_time_interval);

    % Intermediate waypoints movement
    for index = 1:numel(intermediate_waypoints_time_interval)
        % Solve IK
        target_pose = transformation_matrix_array(:, :, index);
        [config, info] = ik(endEffector, target_pose, ikWeights, ikInitialGuess);
        ikInitialGuess = config;

        show(robot, config, 'Frames', 'off', 'PreservePlot', false);

        title(sprintf("Trajectory at t = %.4f s", intermediate_waypoints_time_interval(index)));

        % Get the desired View
        view([-0.6 -0.6 0.2]);
        drawnow
    end

end
