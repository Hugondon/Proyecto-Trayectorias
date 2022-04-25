
%% Function Handles
declareRobot    =   @declareRobot;  


%% Loading Robot

% Get the object robot, the number of joints and endEffector's label
[robot, numJoints, endEffector] = declareRobot("universalUR5");

% Get Joint angles, Home position, TCP position and its orientation
load UR5positions
%% Show Robot
% Create Figure for the Robot Simulation
figureRobot=figure('Name','CAD Placement Figure','NumberTitle','off','WindowState','maximized');

% Show robot in Initial Configuration Space
show(robot, jointHomeAngles, 'Frames', 'off', 'PreservePlot', false);
hold on
%% Loading Geometric Model
load CAD_procesing\processedCAD.mat
gm = translate(gm,[0,0.5,0]);
pdegplot(gm);