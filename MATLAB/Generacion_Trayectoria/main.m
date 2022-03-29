%% Main program
% This program executes all the functions needed to create the poses and configurations
% of the complex trajectory.
% The units used in the program and its functions are from the International System(IS)

%{
Comentarios:
https: // la.mathworks.com / help / robotics / ref / inversekinematics - system - object.html?searchHighlight = inverse %20kinematics&s_tid=srchtitle
%}

%% Setup

clear, clc, clear

%% Function Handles
% Pre-loads the functions that will be used in memory thus improving performance.

declareRobot    =   @declareRobot;      
setWaypoints    =   @setWaypoints;      
getTimeInterval =   @getTimeInterval;   
moveL           =   @moveL;             
moveJ           =   @moveJ;
simulateRobot   =   @simulateRobot;     
setObstacles    =   @setObstacles;      

%% Loading Robot

% Get the object robot, the number of joints and endEffector's label
[robot, numJoints, endEffector] = declareRobot("universalUR5");

% Get Joint angles, Home position, TCP position and its orientation
load UR5positions

%% Set Inverse Kinematics Paramaters

% Define Inverse Kinematics (IK) Solver 
ik = inverseKinematics('RigidBodyTree', robot);
% Weights of each joint for the IK Solver
ikWeights = ones(1, numJoints);
% Initial guess of angles of the joints
ikInitialGuess = jointHomeAngles;

%% Get Waypoints

% Name of the CSV file where the trajectory is stored
nameTrajectory  =   'hola_mundo_v3';
% Import the information of the waypoints of the trajectory
[waypoints, numberWaypoints, magnitudeDistances] = setWaypoints(nameTrajectory);

%% Obstacles
% Set the obstacles for the trajectory (The cell array can be empty)
obstCell=setObstacles();

%% Parameters of the Trajectory of the Robot's TCP

% TCP Speed(Defined by user)
tcpSpeed_ms = 1; %[m/s]

% Number of Intermediate Waypoints(Defined by user)
nIntermediateWaypoints = 5;

% Get the cummulative sum of the magnitudes of the distance (initial distance = 0 m)
csMagnitudeDistances = cumsum([0, magnitudeDistances]);

% Total time to get to each waypoint from the initial waypoint. t = d / v
total_time_to_waypoint = csMagnitudeDistances / tcpSpeed_ms;

% Get time step(ts) interval
ts = getTimeInterval(nIntermediateWaypoints, csMagnitudeDistances, tcpSpeed_ms);

%% Trajectory Graph Setup

% Type of Plot
plotMode = 1; % 0 = No Plot, 1 = Trajectory Points, 2 = Coordinate Frames

% Create Figure for the Robot Simulation
figureRobot=figure('Name','Robot','NumberTitle','off','WindowState','maximized');

% Show robot in Initial Configuration Space
show(robot, jointHomeAngles, 'Frames', 'off', 'PreservePlot', false);

% Establish graph limits
xlim([-0.8 0.8]), ylim([-0.8 0.8]), zlim([-0.5 1])
hold on

% Graph main waypoints
waypoints_positions = tform2trvec(waypoints(:, :, :));
plot3(  waypoints_positions(:, 1), ...
        waypoints_positions(:, 2), ...
        waypoints_positions(:, 3), ...
        'ro', 'LineWidth', 2);

% Show Obstacles
for count=1:size(obstCell,2)
   show(obstCell{count});
end

%% Trajectory Data Cell Array
% Cell array to store the data of the trajectory
trajectory_data = {};

%{
    Number of interval waypoints kept in moveJ(Defined by user)(Move J generates a lot of 
    intermidiate waypoints which would put a heavy load on both the simulator and 
    the physical robot, that is the reason just a fraction of the waypoints is used)
%}
intervalWaypoints=10;

%% Waypoints Joint Trajectories(This sections is just for test)
%{
    Later this section should be modified to do 2 things:
        1-Create MoveJ trajectory from home to a waypoint near the first waypoint of the complex
        trajectory.
        2-Create MoveJ trajectory from a waypoint near the last waypoint of the complex trajectory
        to home.
%}

% Trajectory 1 of moveJ
waypointsJ1=zeros(4,4,2);
waypointsJ1(:,:,1)=trvec2tform([-0.4,-0.4,0.5])*axang2tform([1 0 0 pi]);
waypointsJ1(:,:,2)=trvec2tform(tform2trvec(waypoints(:,:,1)))*axang2tform([1 0 0 pi]);
%waypointsJ1(:,:,2)=trvec2tform([-0.3,0.34,0.57])*axang2tform([1 0 0 pi]);

% Trajectory 2 of moveJ
waypointsJ2=zeros(4,4,2);
waypointsJ2(:,:,2)=waypointsJ1(:,:,1);
waypointsJ2(:,:,1)=waypointsJ1(:,:,2);

%% Rapidly exploring Random Tree (RRT)
% So that moveJ can avoid obstacles

% Set random seed to zero
rng(0)
% Create tree in the Jointspace
rrt = manipulatorRRT(robot,obstCell);

%% Calculate Poses and Inverse Kinematics

%MoveJ from home to shape of interest
trajectory_data = moveJ(    robot,endEffector,ikInitialGuess,ikWeights,ik,...
                            waypointsJ1,obstCell,rrt,...
                            plotMode,intervalWaypoints,...
                            trajectory_data);
% Shape of interest
trajectory_data= moveL(     waypoints,total_time_to_waypoint,ts,...
                            ik,endEffector,ikWeights,ikInitialGuess,...
                            trajectory_data);
                    
%MoveJ from shape of interest to home                
trajectory_data = moveJ(    robot,endEffector,ikInitialGuess,ikWeights,ik,...
                            waypointsJ2,obstCell,rrt,...
                            plotMode,intervalWaypoints,...
                            trajectory_data);


%% Graph Trajectory and Simulate Robot                      
figureRobot = simulateRobot(plotMode,trajectory_data,...
                            robot,figureRobot,[-0.6 -0.6 0.5]);
                        %   Ux      Uy      Uz
                        %[  -0.6    -0.2    0.8 ]
                        %[  -0.6    -1      0.2 ]
                        %[  0.6     -1      0   ]
                        %[  -0.6    -0.6    0.5 ]

%% Convertion to CSV

% File name
FILENAME = 'trajectory.csv';
% Mustn't be changed to [] although warning says so.
COLUMN_HEADERS = {"Tipo de Movimiento", ...
                "X [m]", "Y [m]", "Z [m]", ...
                "Rx [rad]", "Ry [rad]", "Rz [rad]", ...
                "Base [rad]", "Shoulder [rad]", "Elbow [rad]", ...
                "Wrist 1 [rad]", "Wrist 2 [rad]", "Wrist 3 [rad]"};

% Write row containing column headers.
writecell(COLUMN_HEADERS, FILENAME, 'WriteMode', 'overwrite');

for main_waypoint = 1:size(trajectory_data, 1)

    % Prepare trajectory information
    
    % Movement type (Joint Movement=0 Linear Movement=1)
    movement_type = cell2mat(trajectory_data(main_waypoint,1));
    % Array of Poses
    poses_array = cell2mat(trajectory_data(main_waypoint,2));
    % Array of Configurations spaces
    configuration_space = cell2mat(trajectory_data(main_waypoint,3));

    for intermediate_waypoints = 1:size(poses_array, 3)
        % Obtain configuration space information
        intermediate_configuration_space = configuration_space(:, intermediate_waypoints);
        
        % Obtain pose
        pose = poses_array(:, :, intermediate_waypoints);
        % Axis of rotation [ux,uy,uz,theta]
        axis_angle_rotation = tform2axang(pose);
        % Axis of rotation [Rx,Ry,Rz]
        pose_rotation = axis_angle_rotation(1, 1:3) .* axis_angle_rotation(1, 4);
        % Translations
        pose_translation = tform2trvec(pose);
        
        % Building CSV array
        csv_information = [movement_type, pose_translation, pose_rotation, intermediate_configuration_space'];
        % Writing CSV array in CSV file
        writematrix(csv_information, FILENAME, 'WriteMode', 'append');
    end

end

% Delete process variables
clear   axis_angle_rotation pose_rotation pose_translation COLUMN_HEADERS ik ikWeights...
        ikInitialGuess poses_array configuration_space FILENAME nIntermediateWaypoints...
        intermediate_waypoints main_waypoint movement_type pose tcpSpeed_ms ...
        total_time_to_waypoint count declareRobot getTimeInterval moveL moveJ...
        numJoints setObstacles setWaypoints simulateRobot nameTrajectory


