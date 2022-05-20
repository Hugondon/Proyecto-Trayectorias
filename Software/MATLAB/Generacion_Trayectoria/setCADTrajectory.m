function CADTrajectory = setCADTrajectory(nameTransformedCAD)
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    CADTrajectory = importdata([nameTransformedCAD,'.mat'],'-struct');
    %CADTrajectory = load([nameTransformedCAD,'.mat'], 'transformedCAD');
    CADTrajectory.NumberWaypoints = size(CADTrajectory.SurfacePathPoses,3);
    displacementVectors=tform2trvec(CADTrajectory.SurfacePathPoses);
    positions1 = displacementVectors(1:end-1,:);
    positions2 = displacementVectors(2:end,:);
    CADTrajectory.MagnitudeDistances = vecnorm((positions2-positions1)');
end

