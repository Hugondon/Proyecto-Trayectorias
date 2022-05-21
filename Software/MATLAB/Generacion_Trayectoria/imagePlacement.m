%% Robot
declareRobot    =   @declareRobot;
jointHomeAngles = deg2rad([180;-84.49;-112.3;-90;90;0]);
% Get the object robot, the number of joints and endEffector's label
[robot, numJoints, endEffector] = declareRobot("universalUR5");
figureRobot=figure('Name','Robot','NumberTitle','off','WindowState','maximized');
show(robot, jointHomeAngles, 'PreservePlot', false);
hold on 
grid on

view([1,0,0])
%% Image
load Image_processing\waypoints.mat
numWaypoints= size(waypoints,3);
placementTransformationMatrix = trvec2tform([0.6,0,0.4])*axang2tform([0,0,1,0]);
trajectoryPoses = pagemtimes(placementTransformationMatrix,waypoints);

for cont = 1:numWaypoints
    plotTransforms(tform2trvec(trajectoryPoses(:,:,cont)),tform2quat(trajectoryPoses(:,:,cont)), 'FrameSize', 0.02);
end

save('trajectoryPoses.mat','trajectoryPoses');