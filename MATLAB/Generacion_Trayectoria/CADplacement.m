
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
jointHomeAngles(1) = -pi/2;
%jointHomeAngles(6) = 0;
% Show robot in Initial Configuration Space
show(robot, jointHomeAngles);
%show(robot, jointHomeAngles, 'Frames', 'off', 'PreservePlot', false);
hold on
%% Loading Processed CAD
load CAD_procesing\processedCAD.mat
load CAD_procesing\CADparameters.mat
processedCAD.DiscreteGeometry   =   gm;
processedCAD.SurfacePathPoses   =   surfacePathPoses;
processedCAD.ReferenceFrame     =   eye(4);

%% Modifing Processed CAD
displacementVector  =   [0.15,0.68,0.125];
rotationVector      =   [0,0,1,-pi/4];
%rotationVector= [0.3574    0.8629   -0.3574    1.7178]
transformedCAD = processedCADTransformation(processedCAD,displacementVector,rotationVector);

%% Save Struct
save('transformedCAD.mat','-struct','transformedCAD');

%% Plot Geometric Model
pdegplot(transformedCAD.DiscreteGeometry);
hold on

%% Plot Surface Pose Path
plotTransforms(tform2trvec(transformedCAD.SurfacePathPoses),tform2quat(transformedCAD.SurfacePathPoses), 'FrameSize', 0.05);
hold on

view([1,1,0.5]);