declareRobot                =   @declareRobot;
jointHomeAngles = deg2rad([180;-84.49;-112.3;-90;90;0]);
% Get the object robot, the number of joints and endEffector's label
[robot, numJoints, endEffector] = declareRobot("universalUR5");
figureRobot=figure('Name','Robot','NumberTitle','off','WindowState','maximized');
show(robot, jointHomeAngles, 'Frames', 'off', 'PreservePlot', false);