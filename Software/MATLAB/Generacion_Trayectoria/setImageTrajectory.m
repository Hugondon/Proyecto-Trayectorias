function imageTrajectory = setImageTrajectory(nameImageTrajectory)
%SETIMAGETRAJECTORY Summary of this function goes here
%   Detailed explanation goes here
    imageTrajectory.Waypoints = importdata([nameImageTrajectory,'.mat']);
    %CADTrajectory = load([nameTransformedCAD,'.mat'], 'transformedCAD');
    imageTrajectory.NumberWaypoints = size(imageTrajectory.Waypoints,3);
    %waypoints = imageTrajectory.Waypoints;
    displacementVectors=tform2trvec(imageTrajectory.Waypoints);
    positions1 = displacementVectors(1:end-1,:);
    positions2 = displacementVectors(2:end,:);
    imageTrajectory.MagnitudeDistances = vecnorm((positions2-positions1)');
end

