map3D = occupancyMap3D(10);

pose = [ 0 0 0 1 0 0 0];

points = repmat((0:0.25:2)', 1, 3);
points2 = [(0:0.25:2)' (2:-0.25:0)' (0:0.25:2)'];
maxRange = 5;

insertPointCloud(map3D,pose,points,maxRange)
show(map3D)

insertPointCloud(map3D,pose,points2,3)
show(map3D)
hold on
grid on