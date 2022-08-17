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

%% User selected variables
jointHomeAngles = deg2rad([180;-84.49;-112.3;-90;90;0]);
% Select trajectory 0: Test Trajectory 1: CAD Trajectory 2: Image Trajectory
typeTrajectory = 2;
% TCP Speed(Defined by user)
tcpSpeed_ms = 0.02; %[m/s]
% Number of Intermediate Waypoints(Defined by user)
nIntermediateWaypoints = 0;
% Type of Plot
plotMode = 1; % 0 = No Plot, 1 = Trajectory Points, 2 = Coordinate Frames of TCP 3 = Coordinate Frames of Surface Path
viewVector = [0.6 0.6 0.3]; 
% Simulation Mode 0: No simulation 1: Simulate robot
simulationMode = 0;

%% Function Handles
% Pre-loads the functions that will be used in memory thus improving performance.

declareRobot                =   @declareRobot;      
setTestTrajectory           =   @setTestTrajectory;      
getTimeInterval             =   @getTimeInterval;   
moveL                       =   @moveL;             
moveJ                       =   @moveJ;
simulateRobot               =   @simulateRobot;     
setObstacles                =   @setObstacles;
setCADTrajectory            =   @setCADTrajectory;
processedCADTransformation  =   @processedCADTransformation;
imageTrajectory             =   @imageTrajectory;

%% User 

%% Loading Robot

% Get the object robot, the number of joints and endEffector's label
[robot, numJoints, endEffector] = declareRobot("universalUR5");

% Get Joint angles, Home position, TCP position and its orientation
load UR5positions
%jointHomeAngles(1) = -pi/2;
%jointHomeAngles = deg2rad([180-94.94;-75.92;80.51;-100.65;89.82;1.35]);
%jointHomeAngles = deg2rad([-94.94;-75.92;80.51;-100.65;89.82-180;1.35]);
%jointHomeAngles = deg2rad([180;-84.49;-112.3;-165.65;-112.4;181.95]);


%% Set Inverse Kinematics Paramaters

% Define Inverse Kinematics (IK) Solver 
ik = inverseKinematics('RigidBodyTree', robot);
% Weights of each joint for the IK Solver
ikWeights = ones(1, numJoints);
% Initial guess of angles of the joints
ikInitialGuess = jointHomeAngles;

%% Get Waypoints
switch typeTrajectory
    case 0
        % Name of the CSV file where the trajectory is stored
        nameTrajectory  =   'trajectory.csv';
        % Import the information of the waypoints of the trajectory
        [waypoints, numberWaypoints, magnitudeDistances] = setTestTrajectory(nameTrajectory);
        CADTrajectory.SurfacePathPoses = waypoints;
        toolPoseAdejustment = eye(4);
    case 1 
        nameTransformedCAD = 'transformedCAD';
        CADTrajectory = setCADTrajectory(nameTransformedCAD);
        waypoints = CADTrajectory.SurfacePathPoses;
        numberWaypoints = CADTrajectory.NumberWaypoints;
        magnitudeDistances = CADTrajectory.MagnitudeDistances;
        % Adjustment between the pose of the tool and the pose of the Surface Pose Path
        toolPoseAdejustment = trvec2tform([0,0,0])*axang2tform([0,1,0,pi])*axang2tform([0,0,1,pi/2]);
    case 2
        nameImageTrajectory = 'trajectoryPoses';
        imageTrajectory = setImageTrajectory(nameImageTrajectory);
        waypoints = imageTrajectory.Waypoints;
        CADTrajectory.SurfacePathPoses = waypoints;
        numberWaypoints = imageTrajectory.NumberWaypoints;
        magnitudeDistances = imageTrajectory.MagnitudeDistances;
        % Adjustment between the pose of the tool and the pose of the Surface Pose Path
        toolPoseAdejustment = trvec2tform([0,0,0])*axang2tform([1,0,0,-pi/2])*axang2tform([0,1,0,pi]);
end
%% TCP Pose adjustment
% Adjust Waypoinst to tool pose
waypoints = pagemtimes(waypoints,toolPoseAdejustment);

%% Obstacles
% Set the obstacles for the trajectory (The cell array can be empty)
%obstCell=setObstacles();
obstCell={};

%% Parameters of the Trajectory of the Robot's TCP

% Get the cummulative sum of the magnitudes of the distance (initial distance = 0 m)
csMagnitudeDistances = cumsum([0, magnitudeDistances]);

% Total time to get to each waypoint from the initial waypoint. t = d / v
total_time_to_waypoint = double(csMagnitudeDistances / tcpSpeed_ms);

% Get time step(ts) interval
ts = getTimeInterval(nIntermediateWaypoints, csMagnitudeDistances, tcpSpeed_ms);



%% Trajectory Graph Setup



% Create Figure for the Robot Simulation
figureRobot=figure('Name','Robot','NumberTitle','off','WindowState','maximized');

% Show robot in Initial Configuration Space
show(robot, jointHomeAngles, 'Frames', 'off', 'PreservePlot', false);

% Establish graph limits
xlim([-0.6 0.6]), ylim([-0.6 0.6]), zlim([0 1])
hold on

% Graph main waypoints
% waypoints_positions = tform2trvec(waypoints(:, :, :));
% plot3(  waypoints_positions(:, 1), ...
%         waypoints_positions(:, 2), ...
%         waypoints_positions(:, 3), ...
%         'ro', 'LineWidth', 2);

% Show Obstacles
for count=1:size(obstCell,2)
   show(obstCell{count});
end

if (typeTrajectory==1)
   displacementVector = tform2trvec(CADTrajectory.ReferenceFrame);
   rotationVector= tform2axang(CADTrajectory.ReferenceFrame);
   CADTrajectory.DiscreteGeometry = rotate(CADTrajectory.DiscreteGeometry,rad2deg(rotationVector(1,4)),[0,0,0],rotationVector(1,1:3));
   CADTrajectory.DiscreteGeometry = translate(CADTrajectory.DiscreteGeometry,displacementVector);
   pdegplot(CADTrajectory.DiscreteGeometry);
   clear displacementVector rotationVector
end
hold on
%% Trajectory Data Cell Array
% Cell array to store the data of the trajectory
trajectory_data = {};

%{
    Number of interval waypoints kept in moveJ(Defined by user)(Move J generates a lot of 
    intermidiate waypoints which would put a heavy load on both the simulator and 
    the physical robot, that is the reason just a fraction of the waypoints is used)
%}
intervalWaypoints=1;

%% Waypoints Joint Trajectories(This sections is just for test)
%{
    Later this section should be modified to do 2 things:
        1-Create MoveJ trajectory from home to a waypoint near the first waypoint of the complex
        trajectory.
        2-Create MoveJ trajectory from a waypoint near the last waypoint of the complex trajectory
        to home.
%}

% % Trajectory 1 of moveJ
% waypointsJ1=zeros(4,4,2);
% waypointsJ1(:,:,1)=trvec2tform([-0.4,-0.4,0.5])*axang2tform([1 0 0 pi]);
% waypointsJ1(:,:,2)=trvec2tform(tform2trvec(waypoints(:,:,1)))*axang2tform([1 0 0 pi]);
% %waypointsJ1(:,:,2)=trvec2tform([-0.3,0.34,0.57])*axang2tform([1 0 0 pi]);
% 
% % Trajectory 2 of moveJ
% waypointsJ2=zeros(4,4,2);
% waypointsJ2(:,:,2)=waypointsJ1(:,:,1);
% waypointsJ2(:,:,1)=waypointsJ1(:,:,2);

%% Rapidly exploring Random Tree (RRT)
% So that moveJ can avoid obstacles

% Set random seed to zero
rng(0)
% Create tree in the Jointspace
rrt = manipulatorRRT(robot,obstCell);

%% Calculate Poses and Inverse Kinematics

% %MoveJ from home to shape of interest
% trajectory_data = moveJ(    robot,endEffector,ikInitialGuess,ikWeights,ik,...
%                             waypointsJ1,obstCell,rrt,...
%                             plotMode,intervalWaypoints,...
%                             trajectory_data);
% Shape of interest
trajectory_data= moveL(     waypoints,total_time_to_waypoint,ts,...
                            ik,endEffector,ikWeights,ikInitialGuess,...
                            trajectory_data);
                    
% %MoveJ from shape of interest to home                
% trajectory_data = moveJ(    robot,endEffector,ikInitialGuess,ikWeights,ik,...
%                             waypointsJ2,obstCell,rrt,...
%                             plotMode,intervalWaypoints,...
%                             trajectory_data);

%% Convertion to CSV
FILENAME = 'trajectory.csv';
convert2csv(trajectory_data,FILENAME);

%% Graph Trajectory and Simulate Robot
switch simulationMode
    case 1
        figureRobot = simulateRobot(plotMode,trajectory_data,CADTrajectory.SurfacePathPoses,robot,figureRobot,viewVector);
                                %   Ux      Uy      Uz
                                %[  -0.6    -0.2    0.8 ]
                                %[  -0.6    -1      0.2 ]
                                %[  0.6     -1      0   ]
                                %[  -0.6    -0.6    0.5 ]
end


%% Delete process variables
clear   axis_angle_rotation pose_rotation pose_translation COLUMN_HEADERS ik ikWeights...
        ikInitialGuess poses_array configuration_space FILENAME nIntermediateWaypoints...
        intermediate_waypoints main_waypoint movement_type pose tcpSpeed_ms ...
        count declareRobot getTimeInterval moveL moveJ...
        numJoints setObstacles setWaypoints simulateRobot nameTrajectory





