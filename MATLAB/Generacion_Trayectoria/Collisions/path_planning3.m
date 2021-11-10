%https://www.mathworks.com/help/nav/ref/statespacese3.html

mapData = load('dMapCityBlock.mat');
omap = mapData.omap;
omap.FreeThreshold = 0.5;
inflate(omap,1)
ss = stateSpaceSE3([-20 220;
    -20 220; %X
    -10 100; 
    inf inf;
    inf inf;
    inf inf;
    inf inf]);

sv = validatorOccupancyMap3D(ss);

sv.Map = omap;
sv.ValidationDistance = 0.1;

planner = plannerRRT(ss,sv);
planner.MaxConnectionDistance = 50;
planner.MaxIterations = 1000;

planner.GoalReachedFcn = @(~,x,y)(norm(x(1:3)-y(1:3))<5);
planner.GoalBias = 0.1;

start = [40 180 25 0.7 0.2 0 0.1];
goal = [170 100 10 0.3 0 0.1 0.6];

[pthObj,solnInfo] = plan(planner,start,goal);
isValid = isStateValid(sv,pthObj.States);


isPathValid = zeros(size(pthObj.States,1)-1,1,'logical');
for i = 1:size(pthObj.States,1)-1
    [isPathValid(i),~] = isMotionValid(sv,pthObj.States(i,:),...
        pthObj.States(i+1,:));
end
isPathValid

show(omap)
hold on
scatter3(start(1,1),start(1,2),start(1,3),'g','filled') % draw start state
scatter3(goal(1,1),goal(1,2),goal(1,3),'r','filled')    % draw goal state
plot3(pthObj.States(:,1),pthObj.States(:,2),pthObj.States(:,3),...
    'r-','LineWidth',2) % draw path
