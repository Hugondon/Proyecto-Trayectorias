map3D = occupancyMap3D(100);

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

ax = exampleHelperVisualizeCollisionEnvironment(worldCollisionArray)

hold on
show(platform1)
show(platform2)
show(lightFixture)

% obs=0.65;
% updateOccupancy(map3D,obstacleGroup,obs)
show(map3D)
hold on
grid on
xlim([-0.8 0.8]), ylim([-0.8 0.8]), zlim([-0.5 1])
if exist("citymap.ot",'file')
    delete("citymap.ot")
end
filePath = fullfile(pwd,"citymap.ot");
exportOccupancyMap3D(map3D,filePath)