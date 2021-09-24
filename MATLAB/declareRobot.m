function [robot,numJoints,endEffector]=declareRobot(Name)
% Load the robot object with the Name input in the function
% and set the format of the parameters
robot = loadrobot(Name,"DataFormat","column","Gravity",[0 0 -9.81]);

%Get the number of joints using home position
numJoints = numel(homeConfiguration(robot));

%Get the name of the last eigid body on the Rigidbodytree
endEffector=robot.BodyNames{end};
end
