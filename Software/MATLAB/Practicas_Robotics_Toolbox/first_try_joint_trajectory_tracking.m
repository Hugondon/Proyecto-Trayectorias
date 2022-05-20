% https://www.mathworks.com/help/robotics/ug/simulate-joint-space-trajectory-tracking.html


robot = loadrobot("abbIrb120T","DataFormat","column","Gravity",[0 0 -9.81]);
%robot = loadrobot("universalUR5","DataFormat","column","Gravity",[0 0 -9.81]);
numJoints = numel(homeConfiguration(robot));

% Set up simulation parameters
tSpan = 0:0.01:0.5;
% Initial joint position
q0 = zeros(numJoints,1);
q0(2) = pi/4; % Something off center
%Initial Joint velocity
qd0 = zeros(numJoints,1);
%State vector of Joints position and velocity
initialState = [q0; qd0];

% Set up joint control targets
targetJointPosition = [pi/2 pi/3 pi/6 2*pi/3 -pi/2 -pi/3]';
targetJointVelocity = zeros(numJoints,1);
targetJointAcceleration = zeros(numJoints,1);

%show(robot,targetJointPosition)

%% Computed-Torque Control
computedTorqueMotion = jointSpaceMotionModel("RigidBodyTree",robot,"MotionType","ComputedTorqueControl");
updateErrorDynamicsFromStep(computedTorqueMotion,0.2,0.1);
%This motion model requires position, velocity, and acceleration to be provided.
qDesComputedTorque = [targetJointPosition; targetJointVelocity; targetJointAcceleration];

%% Independent Joint Control

IndepJointMotion = jointSpaceMotionModel("RigidBodyTree",robot,"MotionType","IndependentJointMotion");
updateErrorDynamicsFromStep(IndepJointMotion,0.2,0.1);

qDesIndepJoint = [targetJointPosition; targetJointVelocity; targetJointAcceleration];

%% Proportional-Derivative Control

pdMotion = jointSpaceMotionModel("RigidBodyTree",robot,"MotionType","PDControl");
pdMotion.Kp = diag(300*ones(1,6));
pdMotion.Kd = diag(10*ones(1,6));

qDesPD = [targetJointPosition; targetJointVelocity];

%% ODE Solver

[tComputedTorque,yComputedTorque] = ode45(@(t,y)derivative(computedTorqueMotion,y,qDesComputedTorque),tSpan,initialState);
[tIndepJoint,yIndepJoint] = ode45(@(t,y)derivative(IndepJointMotion,y,qDesIndepJoint),tSpan,initialState);
[tPD,yPD] = ode15s(@(t,y)derivative(pdMotion,y,qDesPD),tSpan,initialState);

%% Plot Result

% Computed Torque Control
figure
subplot(2,1,1)
plot(tComputedTorque,yComputedTorque(:,1:numJoints)) % Joint position
hold all
plot(tComputedTorque,targetJointPosition*ones(1,length(tComputedTorque)),'--') % Joint setpoint
title('Computed Torque Motion: Joint Position')
xlabel('Time (s)')
ylabel('Position (rad)')
subplot(2,1,2)
plot(tComputedTorque,yComputedTorque(:,numJoints+1:end)) % Joint velocity
title('Joint Velocity')
xlabel('Time (s)')
ylabel('Velocity (rad/s)')

% Independent Joint Motion
figure
subplot(2,1,1)
plot(tIndepJoint,yIndepJoint(:,1:numJoints))
hold all
plot(tIndepJoint,targetJointPosition*ones(1,length(tIndepJoint)),'--')
title('Independent Joint Motion: Position')
xlabel('Time (s)')
ylabel('Position (rad)')
subplot(2,1,2);
plot(tIndepJoint,yIndepJoint(:,numJoints+1:end))
title('Joint Velocity')
xlabel('Time (s)')
ylabel('Velocity (rad/s)')

% PD with Gravity Compensation
figure
subplot(2,1,1)
plot(tPD,yPD(:,1:numJoints))
hold all
plot(tPD,targetJointPosition*ones(1,length(tPD)),'--')
title('PD Controlled Joint Motion: Position')
xlabel('Time (s)')
ylabel('Position (rad)')
subplot(2,1,2)
plot(tPD,yPD(:,numJoints+1:end))
title('Joint Velocity')
xlabel('Time (s)')
ylabel('Velocity (rad/s)')

% exampleHelperRigidBodyTreeAnimation(robot,yComputedTorque,1);
% exampleHelperRigidBodyTreeAnimation(robot,yIndepJoint,1);
% exampleHelperRigidBodyTreeAnimation(robot,yPD,1);