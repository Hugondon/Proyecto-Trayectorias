%% Set the Waypoints, get the number of waypoints and the diatance betweenthe consecutive waypoints.

function [waypoints, number_waypoints, magnitude_distances] = setWaypoints()
    %Get positions declare w.r.t Global reference
    positions = [-0.5, -0.3, 0.4; ...
                0, -0.3, 0.2; ...
                0.5, -0.3, 0.4; ...
                -0.5, -0.3, 0.4];
    %Get orientations(in rotation vector)
    orientations = [0, 1, 0, pi; ...
                    0, 1, 0, pi; ...
                    0, 1, 0, pi; ...
                    0, 1, 0, pi];

    %Get number of positions
    number_waypoints = size(positions, 1);

    % Reserve memory
    waypoints = zeros(4, 4, number_waypoints);

    % Process variables to get the magnitude of the distance
    pos1 = positions(2:end, :);
    pos2 = positions(1:end - 1, :);

    % Get the magnitude of the distance and store it on a matrix
    magnitude_distances = vecnorm((pos1 - pos2)');
    % Transpose the matrix with the magnitude of the distances
    %magnitude_distances=magnitude_distances';

    clear pos1 pos2

    % Get poses with positions and orientations
    waypoints(:, :, :) = pagemtimes(trvec2tform(positions(:, :)), axang2tform(orientations(:, :)));
end
