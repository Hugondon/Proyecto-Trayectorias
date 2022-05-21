
%% Function Handles
declareRobot                =   @declareRobot;  
processedCADTransformation  =   @processedCADTransformation;

%% Loading Robot

% Get the object robot, the number of joints and endEffector's label
[robot, numJoints, endEffector] = declareRobot("universalUR5");

% Get Joint angles, Home position, TCP position and its orientation
load UR5positions
%% Show Robot
% Create Figure for the Robot Simulation
figureRobot=figure('Name','CAD Placement Figure','NumberTitle','off','WindowState','maximized');
%jointHomeAngles(1) = -pi/2;
%jointHomeAngles(6) = 0;
%jointHomeAngles = deg2rad([180-97.94;-75.92;80.51;-5.65;85.82;1.35]);
jointHomeAngles = deg2rad([180;-84.49;-112.3;-90;90;0]);
% Show robot in Initial Configuration Space
% show(robot, jointHomeAngles);
show(robot, jointHomeAngles, 'Frames', 'off', 'PreservePlot', false);
hold on
%% Loading Processed CAD
load CAD_procesing\processedCAD.mat
load CAD_procesing\CADparameters.mat
processedCAD.DiscreteGeometry   =   gm;
processedCAD.SurfacePathPoses   =   surfacePathPoses;
processedCAD.ReferenceFrame     =   eye(4);

%% Modifing Processed CAD
displacementVector  =   [0.5,0,0.14];
rotationVector      =   tform2axang(axang2tform([1,0,0,5*pi/4])*axang2tform([0,1,0,pi/2]));
%rotationVector      =   [1,0,0,0];
transformedCAD = processedCADTransformation(processedCAD,displacementVector,rotationVector);

%% Save Struct
save('transformedCAD.mat','-struct','transformedCAD');

%% Plot Geometric Model
pdegplot(transformedCAD.DiscreteGeometry);
hold on

%% Plot Surface Pose Path
plotTransforms(tform2trvec(transformedCAD.SurfacePathPoses),tform2quat(transformedCAD.SurfacePathPoses), 'FrameSize', 0.05);
hold on
xlim([0,1])
ylim([0,1])
zlim([0,0.8])
view([1,1,0.5]);