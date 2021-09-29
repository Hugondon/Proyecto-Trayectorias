function [robot, numJoints, endEffector] = declareRobot(Name)
    % declareRobot.m Create a robot object and obtain some of its parameters.
    % Inputs:
    % Name: string containing robot name (e.g "universalUR3", "universalUR5")
    % Outputs:
    % robot: rigidBodyTree object.
    % numJoints: number of joints from robot
    % endEffector: tool connected at the end of robot.

    % Load the robot object with the Name input in the function and set the format of the parameters
    robot = loadrobot(Name, "DataFormat", "column", "Gravity", [0 0 -9.81]);

    % Get the number of joints using home position
    numJoints = numel(homeConfiguration(robot));

    % Get the name of the last rigid body on the Rigidbodytree
    endEffector = robot.BodyNames{end};
end
