function [waypoints, number_waypoints, distances_magnitude_m] = setWaypoints()
    %X=[-0.7,0.7]
    %Z=[0.2,0.7]


    nameTrajectory='cruz';
    % setWaypoints.m Returns an array of poses (waypoints), the number of waypoints and
    % the magnitude of the distance between consecutive waypoints.
    % Inputs:
    % -
    % Outputs:
    % waypoints: a vector representing poses.
    % number_waypoints: amount of waypoints in the vector
    % distances_magnitude_m: magnitudes of the distances between waypoints

    % Get positions declare w.r.t Global reference (Robot base)
%     positions_m = [-0.5, -0.3, 0.4; ...
%                     0, -0.3, 0.2; ...
%                     0.5, -0.3, 0.4; ...
%                     -0.5, -0.3, 0.4];
% 
%     % Get orientations (in rotation vector)
%     orientations = [0, 1, 0, pi; ...
%                     0, 1, 0, pi; ...
%                     0, 1, 0, pi; ...
%                     0, 1, 0, pi];
    %nameTrajectory = 'triangule';
    waypointStruct=load(['Test_trajectories/',nameTrajectory,'.mat']);
                
    % Get number of positions
    number_waypoints = size(waypointStruct.positions_m, 1);

    % Allocate memory
    waypoints = zeros(4, 4, number_waypoints);

    % Process variables to get the magnitude of the distance
    pos1 = waypointStruct.positions_m(2:end, :);
    pos2 = waypointStruct.positions_m(1:end - 1, :);

    % Get the magnitude of the distance and store it on a matrix
    distances_magnitude_m = vecnorm((pos1 - pos2)');

    clear pos1 pos2

    % Get poses with positions and orientations
    waypoints(:, :, :) = pagemtimes(trvec2tform(waypointStruct.positions_m(:, :)),...
        axang2tform(waypointStruct.orientations(:, :)));
end
