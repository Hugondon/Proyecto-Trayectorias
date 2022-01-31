
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
ikWeights = ones(1, numJoints);
ik = inverseKinematics('RigidBodyTree',robot);


%% Trajectory Poses

% Poses
waypoints=zeros(4,4,4);
waypoints(:,:,1)=trvec2tform([0.4,0.5,0.7])*axang2tform([1 0 0 pi]);
waypoints(:,:,2)=trvec2tform([-0.4,0.5,0.7])*axang2tform([1 0 0 pi]);
waypoints(:,:,3)=trvec2tform([0,-0.5,0.7])*axang2tform([1 0 0 pi]);
waypoints(:,:,4)=trvec2tform([0.4,0.5,0.7])*axang2tform([1 0 0 pi]);

numMainWaypoints=size(waypoints,3);

% Configuration of the poses
configMat=zeros(numMainWaypoints,6);

for count=1:numMainWaypoints
    configMat(count,:)=ik(endEffector,waypoints(:,:,count),ikWeights,ikInitialGuess)';
end

%% Trajectory Data
trajectory_data=cell(numMainWaypoints-1,3);

%% Graph Parameters
plotMode=1;
intervalWaypoints=10;

%% Rapidly exploring Random Tree (RRT)
% Create tree
rrt = manipulatorRRT(robot,obstCell);
% Set random seed to zero
rng(0)
% Plan Trajectory
pathCell=cell(numMainWaypoints-1,1);

for count=1:numMainWaypoints-1
    path = plan(rrt,configMat(count,:),configMat(count+1,:));
    pathCell{count}=path;
end


% Interpolate Trajectory
for count=1:numMainWaypoints-1
    interpPath = interpolate(rrt,pathCell{count})';
    trajectory_data{count,1}=0;
    trajectory_data{count,3}=interpPath(:,1:intervalWaypoints:end);
end

%% Figure setup

% Create Figure
figureRobot=figure('Name','Robot','NumberTitle','off','WindowState','maximized');
% Show robot
show(robot, jointHomeAngles, 'Frames', 'off', 'PreservePlot', false);
hold on
grid on

waypoints_positions = tform2trvec(waypoints(:, :, :));
plot3(waypoints_positions(:, 1),waypoints_positions(:, 2),waypoints_positions(:, 3), ...
    'ro', 'LineWidth', 2);

% Show Obstacles
for count=1:size(obstCell,2)
   show(obstCell{count});
end

% Establish axis limits
xlim([-0.8 0.8]), ylim([-0.8 0.8]), zlim([-0.5 1.2])

% Number of waypoints between main waypoints
numWaypoints=zeros(numMainWaypoints-1,1);
for count = 1:numMainWaypoints-1
    numWaypoints(count,1)=size(trajectory_data{count,3},2);
end

%% Waypoints obtain through RRT
% waypointsRRT=zeros(4,4,numWaypoints);

for count1 = 1:numMainWaypoints-1
    waypointsRRT=zeros(4,4,numWaypoints(count1,1));
    
    for count2 = 1:numWaypoints(count1,1)
        waypointsRRT(:,:,count2)=getTransform(robot,trajectory_data{count1,3}(:,count2),endEffector);
        
    end
    
   trajectory_data{count1,2}=waypointsRRT;
end


%% Simulate Robot
figureRobot = simulateRobot(plotMode,trajectory_data, robot,figureRobot,[0.4,0.4,0.3]);

