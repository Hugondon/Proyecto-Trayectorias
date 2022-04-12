function [waypoints, number_waypoints, distances_magnitude_m] = setWaypoints(nameTrajectory)
%SETWAYPOINTS Returns the following information about the trajectory: list of waypoints, the number of waypoints and the cumulative sum of the magnitudes of the distances between consecutive waypoints.

%{
This function do 2 things:
    1-Import mat File
        Input:
            nameTrajectory:         Name of the mat file where the trajectory is stored.
        Output:
            waypointStruct:         Structure storing the trajectory information.

    2-Extract Information of the mat file
        Input:
            waypointStruct:         Structure storing the trajectory information.
        Output:
            waypoints:              Array of Poses.
            number_waypoints:       Number of poses in the variable "waypoints".
            distances_magnitude_m:  Cumulative sum of the magnitudes of the distances between
                                    consecutive waypoints.
%}
    
    %% Note: Physical limits of the robot
        % X=[-0.7,0.7]
        % Y=[-0.7,0.7]
        % Z=[0.2,0.7]


    %% Import File
    
    % Importing the mat file
    waypointStruct=load(['Test_trajectories/',nameTrajectory,'.mat']);
    
    %% Information extractions
    
    % Get number of positions
    number_waypoints = size(waypointStruct.positions_m, 1);

    
    % Allocate memory
    waypoints = zeros(4, 4, number_waypoints);

    % Process variables to get the magnitude of the distance
    pos1 = waypointStruct.positions_m(2:end, :);
    pos2 = waypointStruct.positions_m(1:end - 1, :);

    % Get the magnitude of the distance and store it on a matrix
    distances_magnitude_m = vecnorm((pos1 - pos2)');
    
    % Delete process variables
    clear pos1 pos2
    
    % Get poses with positions and orientations
    waypoints(:, :, :) = pagemtimes(trvec2tform(waypointStruct.positions_m(:, :)),...
                                    axang2tform(waypointStruct.orientations(:, :)) );
end
