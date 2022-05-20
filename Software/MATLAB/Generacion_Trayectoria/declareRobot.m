function [robot, numJoints, endEffector] = declareRobot(Name)
% Create a robot object and obtain some of its parameters.

%{
Create a robot object and extract important parameters.
    Inputs:
        Name:           Name of the robot
    Outputs:
        robot:          Robot object
        numJoints:      Number of joints
        endEffector:    Name of the end effector
%}

    % Load the robot object with the Name input in the function and set the format of the parameters
    robot = loadrobot(Name, "DataFormat", "column", "Gravity", [0 0 -9.81]);

    % Get the number of joints using home position
    numJoints = numel(homeConfiguration(robot));

    % Get the name of the last rigid body on the Rigidbodytree
    endEffector = robot.BodyNames{end};
end
