% This script was a test for the moveJ function
%% Function Handles
declareRobot    =   @declareRobot;
setObstacles    =   @setObstacles;
simulateRobot   =   @simulateRobot;

%% Load Robot
load UR5positions
ikInitialGuess = jointHomeAngles;
[robot, numJoints, endEffector] = declareRobot("universalUR5");

%% Obstacles
obstCell=setObstacles();

%% Inverse Kinematics Solver Setup
% Inverse kinematics weights for the solver
ikWeights = ones(1, numJoints);
ik = inverseKinematics('RigidBodyTree',robot);


%% Trajectory Poses

% Poses
waypoints=zeros(4,4,4);
waypoints(:,:,1)=trvec2tform([0.4,0.5,0.7])*axang2tform([1 0 0 pi]);
waypoints(:,:,2)=trvec2tform([-0.4,0.5,0.7])*axang2tform([1 0 0 pi]);
waypoints(:,:,3)=trvec2tform([0,-0.5,0.7])*axang2tform([1 0 0 pi]);
waypoints(:,:,4)=trvec2tform([0.4,0.5,0.7])*axang2tform([1 0 0 pi]);

% Number of waypoints
numMainWaypoints=size(waypoints,3);

% Allocate memory for the robot poses
configMat=zeros(numMainWaypoints,6);

% Get the configuration for each pose
for count=1:numMainWaypoints
    % Calculate inverse kinematics of the poses on "waypoints"
    configMat(count,:)=ik(endEffector,waypoints(:,:,count),ikWeights,ikInitialGuess)';
end

%% Trajectory Data
trajectory_data=cell(numMainWaypoints-1,3);

%% Graph Parameters
% Mode to graph
plotMode=1;
% Interval waypoints between main waypoints
intervalWaypoints=10;

%% Rapidly exploring Random Tree (RRT)
% Create tree
rrt = manipulatorRRT(robot,obstCell);
% Set random seed to zero
rng(0)
% Allocate memory for the configurations between main waypoints
pathCell=cell(numMainWaypoints-1,1);

% Get poses between main waypoints
for count=1:numMainWaypoints-1
    % Get configurations of the main waypoints and the neccesary intermidiate waypoints to plan the
    % trajectory
    path = plan(rrt,configMat(count,:),configMat(count+1,:));
    % Save the configurations
    pathCell{count}=path;
end


% Interpolate Configurations
for count=1:numMainWaypoints-1
    % Interpolate between configurations
    interpPath = interpolate(rrt,pathCell{count})';
    % Establish movement type
    trajectory_data{count,1}=0;
    % Save configurations
    trajectory_data{count,3}=interpPath(:,1:intervalWaypoints:end);
end

%% Figure setup

% Create Figure
figureRobot=figure('Name','Robot','NumberTitle','off','WindowState','maximized');
% Show robot
show(robot, jointHomeAngles, 'Frames', 'off', 'PreservePlot', false);
hold on
grid on

% Establish axis limits
xlim([-0.8 0.8]), ylim([-0.8 0.8]), zlim([-0.5 1.2])

% Show Obstacles
for count=1:size(obstCell,2)
   show(obstCell{count});
end

%% Graph Trajectory
waypoints_positions = tform2trvec(waypoints(:, :, :));
plot3(waypoints_positions(:, 1),waypoints_positions(:, 2),waypoints_positions(:, 3), ...
    'ro', 'LineWidth', 2);


%% Waypoints obtain through RRT

% Allocate memory for number of waypoints between main waypoints
numIntermidiateWaypoints=zeros(numMainWaypoints-1,1);

% Get the number of intermidiate waypoints between each main waypoint pair
for count = 1:numMainWaypoints-1
    numIntermidiateWaypoints(count,1)=size(trajectory_data{count,3},2);
end


for count1 = 1:numMainWaypoints-1
    % Allocate memory for Waypoints generated through RRT
    waypointsRRT=zeros(4,4,numIntermidiateWaypoints(count1,1));
    
    % Apply forward kinematics to obtain poses of each configuration
    for count2 = 1:numIntermidiateWaypoints(count1,1)
        waypointsRRT(:,:,count2)=getTransform(robot,trajectory_data{count1,3}(:,count2),endEffector);
        
    end
    % Save poses
    trajectory_data{count1,2}=waypointsRRT;
end


%% Simulate Robot
figureRobot = simulateRobot(plotMode,trajectory_data, robot,figureRobot,[0.4,0.4,0.3]);

