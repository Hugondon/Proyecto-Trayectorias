%% Main program
% This program executes all the functions needed to create
% the point of the complex trajectory.

%% Setup

clear, clc, clear

%% Function Handles

declareRobot    =   @declareRobot;
setWaypoints    =   @setWaypoints;

%% Loading Robot

%Get the object robot, the number of joints and endeffector
[robot,numJoint,endEffector]=declareRobot("universalUR5");

%Get Joint angles Home position and TCP position and
%orientation
load UR5positions

%% Set Inverse Kinematics

% Define IK
ik = inverseKinematics('RigidBodyTree',robot);
ikWeights = [1 1 1 1 1 1];
ikInitGuess = jointHomeAngles;

%% Get Waypoints
[waypoints,numberWaypoints]=setWaypoints();

%% Trajectory sample time
% Esto se puede mejorar obteniendo las distancias y
% dividirlo por la velocidad
timesBetweenWaypoints=0:10:20;
ts = 0.2;
trajTimes = 0:ts:timesBetweenWaypoints(end);


%% Trajectory

for count = 1:numberWaypoints-1
    timeInterval = timesBetweenWaypoints(count:count+1);
    trajTimes = timeInterval(1):ts:timeInterval(2);
    
    % Find the transforms from trajectory generation
    [T,vel,acc] = transformtraj(waypoints(:,:,count),waypoints(:,:,count+1),timeInterval,trajTimes);
    
    
    for idx = 1:numel(trajTimes) 
        % Solve IK
        tgtPose = T(:,:,idx);
        [config,info] = ik(endEffector,tgtPose,ikWeights,ikInitGuess);
        ikInitGuess = config;

        % Show the robot
        %show(robot,config,'Frames','off','PreservePlot',false); %Cambiar orientacion de la grafica
        show(robot,config,'PreservePlot',false);
        title(['Trajectory at t = ' num2str(trajTimes(idx))])
        %Get the desired View
        view([-0.6 -0.6 0.2]);
        %view(-45, 0.5)
        drawnow
    end
    
end


