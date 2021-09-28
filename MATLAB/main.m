%% Main program
% This program executes all the functions needed to create
% the point of the complex trajectory.
% The units used in the program and its functions are from the International System(IS)

%% Setup

clear, clc, clear all

%% Function Handles

declareRobot        =   @declareRobot;
setWaypoints        =   @setWaypoints;
getTrajectoryTimes  =   @getTrajectoryTimes;

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

%The function return an array of poses(waypoints) the number
%of waypoints and the magnitude between consecutive
%waypoints.
[waypoints,numberWaypoints,magnitudeDistances]=setWaypoints();

%% Trajectory sample time

% TCP Speed(Defined by user)
tcpSpeed=3; %[m/s]

% Number of Intermediate Waypoints(Defined by user)
nIntermediateWaypoints=50;

% Get the cummulative sum of the magnitudes of the distance
csMagnitudeDistances=cumsum([0,magnitudeDistances]);

% Get the times between (main) Waypoints dividing by TCP speed
timesBetweenWaypoints=csMagnitudeDistances/tcpSpeed;

[trajTimes,ts]=getTrajectoryTimes(nIntermediateWaypoints,csMagnitudeDistances);



%trajTimes = 0:ts:timesBetweenWaypoints(end);
%timesBetweenWaypoints=0:10:20;
%ts = 0.2;
%trajTimes = 0:ts:timesBetweenWaypoints(end);


%% Trajectory

for count = 1:numberWaypoints-1
    timeInterval = timesBetweenWaypoints(count:count+1);
    trajInterval = timeInterval(1):ts(count):timeInterval(2);
    
    % Find the transforms from trajectory generation
    [T,vel,acc] = transformtraj(waypoints(:,:,count),waypoints(:,:,count+1),timeInterval,trajInterval);
    
    
    for idx = 1:numel(trajInterval) 
        % Solve IK
        tgtPose = T(:,:,idx);
        [config,info] = ik(endEffector,tgtPose,ikWeights,ikInitGuess);
        ikInitGuess = config;

        % Show the robot
        %show(robot,config,'Frames','off','PreservePlot',false);
        show(robot,config,'Frames','off','PreservePlot',false);
        title(['Trajectory at t = ' num2str(trajInterval(idx))])
        %Get the desired View
        view([-0.6 -0.6 0.2]);
        %view(-45, 0.5)
        drawnow
    end
    
end


