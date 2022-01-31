function final_trajectory_data = moveJ(robot,endEffector,ikInitialGuess,ikWeights,ik,...
                                waypoints,obstCell,rrt,...
                                plotMode,intervalWaypoints,...
                                complete_trajectory_data)
% MOVEJ Calculates the IK for joint movement of the robot and avoid obstacles

%{
Calculates the IK for linear movement of the robot
    Inputs:
        robot:
        endEffector:                Name of the end effector
        ikInitialGuess:             Initial Configuration space guess
        ikWeights:                  Weights of each joint for the IK Solver
        ik:                         Inverse Kinematic(IK) solver
        waypoints:                  The array of poses of the trajectory
        obstCell:                   Cell array that collision box and pose of each obstacle
        rrt:                        Rapidly exploring Random Tree
        intervalWaypoints:          Number of interval waypoints keep in moveJ
        complete_trajectory_data:   Cell array of the trajectory data
    Outputs:
        final_trajectory_data:      Cell array of the trajectory data(updated)

%}

%% Configurations of the robot

% Get the number of main waypoints
numMainWaypoints=size(waypoints,3);

% Allocate memory for the configuration of the poses
configMat=zeros(numMainWaypoints,6);

% Get the configurations of the robots to get the desired TCP pose
for count=1:numMainWaypoints
    configMat(count,:)=ik(endEffector,waypoints(:,:,count),ikWeights,ikInitialGuess)';
end

%% Trajectory Data
trajectory_data=cell(numMainWaypoints-1,3);

%% Rapidly exploring Random Tree (RRT)

% Plan Trajectory

% Allocate memory for path obtain through rrt
pathCell=cell(numMainWaypoints-1,1);

% Get path planning for each consecutive waypoints
for count=1:numMainWaypoints-1
    path = plan(rrt,configMat(count,:),configMat(count+1,:));
    pathCell{count}=path;
end


% Interpolate Trajectory
for count=1:numMainWaypoints-1
    % Interpolation of the paths
    interpPath = interpolate(rrt,pathCell{count})';
    
    % Store results
    trajectory_data{count,1}=0; % MoveJ=0 MoveL=1
    trajectory_data{count,3}=interpPath(:,1:intervalWaypoints:end);
end
%% Number of waypoints between main waypoints

% Allocater memory for the number of intermidiate waypoints between main waypoints
numWaypoints=zeros(numMainWaypoints-1,1);

for count = 1:numMainWaypoints-1
    % Number of waypoints between main waypoints
    numWaypoints(count,1)=size(trajectory_data{count,3},2);
end

%% Waypoints obtain through configuration space

for count1 = 1:numMainWaypoints-1
    % Allocate memory for waypoins obtain through Configuration Space(CS)
    waypointsCS=zeros(4,4,numWaypoints(count1,1));
    
    
    for count2 = 1:numWaypoints(count1,1)
        % Inputs the configuration space in the robot the pose is obtained
        waypointsCS(:,:,count2)=getTransform(robot,trajectory_data{count1,3}(:,count2),endEffector);
        
    end
    
    % Store results
    trajectory_data{count1,2}=waypointsCS;
end
    %% Append Trajectories
    
    % Get the number of waypoints in trajectory data
    numWaypointsTD=size(complete_trajectory_data,1);
    
    % Appends the trajectory data that was input in the function and
    % the one generated by the funtion
    if numWaypointsTD == 0
        final_trajectory_data=trajectory_data;
    elseif numWaypointsTD > 0   
        final_trajectory_data=[complete_trajectory_data;trajectory_data];
    end
end

