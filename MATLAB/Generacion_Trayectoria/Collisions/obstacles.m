%https://www.mathworks.com/help/nav/ref/occupancymap3d.setoccupancy.html#d123e94687

map3D = occupancyMap3D;
[xGround,yGround,zGround] = meshgrid(0:100,0:100,0);
xyzGround = [xGround(:) yGround(:) zGround(:)];
occval = 0;
setOccupancy(map3D,xyzGround,occval)
hold on
grid on
[xBuilding1,yBuilding1,zBuilding1] = meshgrid(20:30,50:60,0:30);
[xBuilding2,yBuilding2,zBuilding2] = meshgrid(50:60,10:30,0:40);
[xBuilding3,yBuilding3,zBuilding3] = meshgrid(40:60,50:60,0:50);
[xBuilding4,yBuilding4,zBuilding4] = meshgrid(70:80,35:45,0:60);

xyzBuildings = [xBuilding1(:) yBuilding1(:) zBuilding1(:);...
                xBuilding2(:) yBuilding2(:) zBuilding2(:);...
                xBuilding3(:) yBuilding3(:) zBuilding3(:);...
                xBuilding4(:) yBuilding4(:) zBuilding4(:)];
                
            
%obs = rand(length(xyzBuildings),1);
obs=0.65;
updateOccupancy(map3D,xyzBuildings,obs)
show(map3D) 
if exist("citymap.ot",'file')
    delete("citymap.ot")
end
filePath = fullfile(pwd,"citymap.ot");
exportOccupancyMap3D(map3D,filePath)