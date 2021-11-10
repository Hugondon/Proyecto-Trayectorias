%https://www.mathworks.com/help/nav/ref/occupancymap3d.setoccupancy.html#d123e94687

map3D = occupancyMap3D(100);
intervalMesh=0.005;
numberObstacles=3;
obstacleLimits=zeros(2,3,numberObstacles);
obstacleLimits(:,:,1)=[0,0,0;0.2,0.2,0.2];
obstacleLimits(:,:,2)=[-0.4,-0.4,0.2;-0.2,-0.2,0.4];
obstacleLimits(:,:,3)=[-0.2,-0.2,0;0,0,0.2];

% obstacleLimits=obstacleLimits*100

% obstacleGroup=zeros(,3);
intermediateMatrix=cell(numberObstacles,1);
for counto=1:numberObstacles
    [xobstacle,yobstacle,zobstacle] = meshgrid( obstacleLimits(1,1,counto):intervalMesh:obstacleLimits(2,1,counto)-intervalMesh,...
                                                obstacleLimits(1,2,counto):intervalMesh:obstacleLimits(2,2,counto)-intervalMesh,...
                                                obstacleLimits(1,3,counto):intervalMesh:obstacleLimits(2,3,counto)-intervalMesh);
    intermediateMatrix{counto,1}=[xobstacle(:),yobstacle(:),zobstacle(:)];
end
obstacleGroup=[intermediateMatrix{1,1};...
    intermediateMatrix{2,1};...
    intermediateMatrix{3,1}];

% [xBuilding1,yBuilding1,zBuilding1] = meshgrid(-1:0.01:0.99,-1:0.01:0.99,0:0.01:0.99);
% 
% xyzBuildings = [xBuilding1(:) yBuilding1(:) zBuilding1(:)];

obs=0.65;
updateOccupancy(map3D,obstacleGroup,obs)
show(map3D)
hold on
grid on
xlim([-0.8 0.8]), ylim([-0.8 0.8]), zlim([-0.5 1])
if exist("citymap.ot",'file')
    delete("citymap.ot")
end
filePath = fullfile(pwd,"citymap.ot");
exportOccupancyMap3D(map3D,filePath)