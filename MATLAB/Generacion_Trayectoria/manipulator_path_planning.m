declareRobot    =   @declareRobot;
load UR5positions
ikInitialGuess = jointHomeAngles;

% robot = loadrobot("kukaIiwa14","DataFormat","row");
[robot, numJoints, endEffector] = declareRobot("universalUR5");
env = {collisionBox(0.5, 0.5, 0.05) collisionSphere(0.2)};
env{1}.Pose(3, end) = -0.05;
env{2}.Pose(1:3, end) = [0.1 0.5 0.7];

show(robot);
hold on
show(env{1})
show(env{2})

rrt = manipulatorRRT(robot,env);

% startConfig = [0.08 -0.65 0.05 0.02 0.04 0.49 0.04];
% goalConfig =  [2.97 -1.05 0.05 0.02 0.04 0.49 0.04];

startPose = trvec2tform([0.6,0.5,0.7])*axang2tform([1 0 0 pi]);
endPose = trvec2tform([-0.3,0.5,0.7])*axang2tform([1 0 0 pi]);

ik = inverseKinematics('RigidBodyTree',robot);
ikWeights = ones(1, numJoints);
startConfig = ik(endEffector,startPose,ikWeights,ikInitialGuess);
endConfig = ik(endEffector,endPose,ikWeights,ikInitialGuess);


rng(0)
path = plan(rrt,startConfig',endConfig');
interpPath = interpolate(rrt,path);
clf
xlim([-0.8 0.8]), ylim([-0.8 0.8]), zlim([-0.5 1])
for i = 1:40:size(interpPath,1)
    show(robot,interpPath(i,:)','Frames', 'off');
    hold on
    show(env{1})
    show(env{2})
    view([-0.6 -1 0.2]);
    drawnow
%     hold off
end
