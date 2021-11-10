
declareRobot    =   @declareRobot;
load UR5positions
ikInitialGuess = jointHomeAngles;


% Create two platforms
platform1 = collisionBox(0.5,0.5,0.25);
platform1.Pose = trvec2tform([-0.5 0.4 0.2]);

platform2 = collisionBox(0.5,0.5,0.25);
platform2.Pose = trvec2tform([0.5 0.2 0.2]);

% Add a light fixture, modeled as a sphere
lightFixture = collisionSphere(0.1);
lightFixture.Pose = trvec2tform([0 0.2 0.5]);

% Store in a cell array for collision-checking
worldCollisionArray = {platform1 platform2 lightFixture};

% ax = exampleHelperVisualizeCollisionEnvironment(worldCollisionArray);
[robot, numJoints, endEffector] = declareRobot("universalUR5");
% show(robot,homeConfiguration(robot),"Parent",ax,'Frames', 'off');



startPose = trvec2tform([-0.5,0.5,0.4])*axang2tform([1 0 0 pi]);
endPose = trvec2tform([0.5,0.2,0.4])*axang2tform([1 0 0 pi]);

waypoinst= zeros(4,4,2);
waypoinst(:,:,1)    =   trvec2tform([-0.5,0.5,0.4])*axang2tform([1 0 0 pi]);
waypoinst(:,:,2)    =   trvec2tform([0.5,0.2,0.4])*axang2tform([1 0 0 pi]);

% Use a fixed random seed to ensure repeatable results
rng(0);
ik = inverseKinematics('RigidBodyTree',robot);
ikWeights = ones(1, numJoints);
startConfig = ik(endEffector,startPose,ikWeights,ikInitialGuess);
endConfig = ik(endEffector,endPose,ikWeights,ikInitialGuess);

% Show initial and final positions
% show(robot,startConfig,'Frames', 'off');
% show(robot,endConfig,'Frames', 'off');

% q = trapveltraj([jointHomeAngles,startConfig],200);
q = trapveltraj([-0.5,0.5,0.4;0.5,0.2,0.4]',200);

% Initialize outputs
inCollision = false(length(q), 1); % Check whether each pose is in collision
worldCollisionPairIdx = cell(length(q),1); % Provide the bodies that are in collision

for i = 1:length(q)
    
    [inCollision(i),sepDist] = checkCollision(robot,q(:,i),worldCollisionArray,"IgnoreSelfCollision","on","Exhaustive","on");
    
    [bodyIdx,worldCollisionObjIdx] = find(isnan(sepDist)); % Find collision pairs
    worldCollidingPairs = [bodyIdx,worldCollisionObjIdx]; 
    worldCollisionPairIdx{i} = worldCollidingPairs;
    
end



isTrajectoryInCollision = any(inCollision)
%% Falta resolver el como planear la trayectoria si hay colision

% Visualize the environment.
% ax = exampleHelperVisualizeCollisionEnvironment(worldCollisionArray);

% Add the robotconfigurations & highlight the colliding bodies.
% show(robot,q(:,collidingIdx1),"Parent",ax,'Frames', 'off',"PreservePlot",false);
% exampleHelperHighlightCollisionBodies(robot,collidingBodies1 + 1,ax);
% show(robot,q(:,collidingIdx2),"Parent"',ax,'Frames', 'off');
% exampleHelperHighlightCollisionBodies(robot,collidingBodies2 + 1,ax);


intermediatePose1 = trvec2tform([-.3 -.2 .6])*axang2tform([0 1 0 -pi/4]); % Out and around the sphere
intermediatePose2 = trvec2tform([0.2,0.2,0.6])*axang2tform([1 0 0 pi]); % Come in from above

intermediateConfig1 = ik(endEffector,intermediatePose1,ikWeights,q(:,collidingIdx1));
intermediateConfig2 = ik(endEffector,intermediatePose2,ikWeights,q(:,collidingIdx2));

% Show the new intermediate poses
% ax = exampleHelperVisualizeCollisionEnvironment(worldCollisionArray);
% show(robot,intermediateConfig1,"Parent",ax,'Frames', 'off',"PreservePlot",false);
% show(robot,intermediateConfig2,"Parent",ax,'Frames', 'off');

[q,qd,qdd,t] = trapveltraj([ikInitialGuess,startConfig,endConfig],200,"EndTime",2);

%Initialize outputs
inCollision = false(length(q),1); % Check whether each pose is in collision
for i = 1:length(q)
    inCollision(i) = checkCollision(robot,q(:,i),worldCollisionArray,"IgnoreSelfCollision","on");
end
isTrajectoryInCollision = any(inCollision)


% Plot the environment
ax2 = exampleHelperVisualizeCollisionEnvironment(worldCollisionArray);

% Visualize the robot in its home configuration
show(robot,startConfig,"Parent",ax2,'Frames', 'off');

% Update the axis size
axis equal

% Loop through the other positions
for i = 1:length(q)
    show(robot,q(:,i),"Parent",ax2,'Frames', 'off',"PreservePlot",false);
    
    % Update the figure    
    drawnow
end
