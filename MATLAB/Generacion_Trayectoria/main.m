%% Main program
% This program executes all the functions needed to create
% the point of the complex trajectory.
% The units used in the program and its functions are from the International System(IS)

%{
Comentarios:
Por qué calcular varias veces number of waypoints?
A qué se refiere específicamente con configuración el resultado de la ik?
https: // la.mathworks.com / help / robotics / ref / inversekinematics - system - object.html?searchHighlight = inverse %20kinematics&s_tid=srchtitle
%}

%% Setup

clear, clc, clear

%% Function Handles

declareRobot    = @declareRobot;
setWaypoints    = @setWaypoints;
getTimeInterval = @getTimeInterval;

%% Loading Robot

% Get the object robot, the number of joints and endeffector
[robot, numJoint, endEffector] = declareRobot("universalUR5");

% Get Joint angles Home position; TCP position and its orientation

% jointHomeAngles = [-1.055051532830572; -0.922930108454602; -2.274513081199010; -1.514247659030281; 1.572192590196492; 0.515570261039125];
% toolHomeOrientation = [0; 3.141592653589793; 0];
% toolHomePosition = [0; -0.270000000000000; 0.380000000000000];
load UR5positions
%% Set Inverse Kinematics

% Define IK
ik = inverseKinematics('RigidBodyTree', robot);
ikWeights = ones(1, numJoint);
ikInitialGuess = jointHomeAngles;

%% Get Waypoints

[waypoints, numberWaypoints, magnitudeDistances] = setWaypoints();

%% Trajectory Time Intervals

% TCP Speed(Defined by user)
tcpSpeed_ms = 1; %[m/s]

% Number of Intermediate Waypoints(Defined by user)
nIntermediateWaypoints = 20;

% Between main waypoints

% Get the cummulative sum of the magnitudes of the distance (initial distance = 0m)
csMagnitudeDistances = cumsum([0, magnitudeDistances]);

% Total time to get to each waypoint from the initial waypoint. t = d / v
total_time_to_waypoint = csMagnitudeDistances / tcpSpeed_ms;

[ts,real_intermediate_waypoints]= getTimeInterval(nIntermediateWaypoints, csMagnitudeDistances, tcpSpeed_ms);

%trajTimes = 0:ts:total_time_to_waypoint(end);
%total_time_to_waypoint=0:10:20;
%ts = 0.2;
%trajTimes = 0:ts:total_time_to_waypoint(end);

%% Parameters of the Graphed Trajectory 

% Type of Plot
plotMode = 2; % 0 = No Plot, 1 = Trajectory Points, 2 = Coordinate Frames

% Show robot in Initial Configuration Space
show(robot,jointHomeAngles,'Frames','off','PreservePlot',false);

% Establish graph limits
xlim([-1 1]), ylim([-1 1]), zlim([-0.5 1.5])
hold on

% Graph main waypoints
waypoints_positions = tform2trvec(waypoints(:,:,:));
plot3(  waypoints_positions(:,1),...
        waypoints_positions(:,2),...
        waypoints_positions(:,3),...
        'ro','LineWidth',2);


%% Trajectory Data Cell Array

trajectory_data=cell(3,numberWaypoints-1);


%% Calculate Poses

for count = 1:numberWaypoints - 1
    % Extract the starting and finishing waypoint times of the segment of the trajectory
    main_waypoints_time_interval = total_time_to_waypoint(count:count + 1);
    % Get the times of the intermediate waypoints in the segment of the trajectory
    intermediate_waypoints_time_interval = main_waypoints_time_interval(1):ts(count):main_waypoints_time_interval(2);


    % Find the transforms from trajectory generation
    % Change transformation_matrix_array
    [transformation_matrix_array, vel, acc] =...
        transformtraj(waypoints(:, :, count),...
        waypoints(:, :, count + 1),...
        main_waypoints_time_interval,...
        intermediate_waypoints_time_interval);
    % 
    if count>1
        transformation_matrix_array(:,:,1)=[];
    end
    
    % Save type of movements and poses
    % Movement Type   
    trajectory_data{1,count}=1; % MoveJ=0 MoveL=1
    % Poses
    trajectory_data{2,count}=transformation_matrix_array;
end


%% Graph Trajectory

for count = 1:numberWaypoints - 1

    % Trajectory visualization for the segment
    if plotMode == 1
        eePos = tform2trvec(trajectory_data{2,count});
        plot3(eePos(:,1),eePos(:,2),eePos(:,3),'-^','Color','k')
        %set(hTraj,'xdata',eePos(:,1),'ydata',eePos(:,2),'zdata',eePos(:,3));
    elseif plotMode == 2
        plotTransforms(tform2trvec(trajectory_data{2,count}),...
            tform2quat(trajectory_data{2,count}),'FrameSize',0.05);
    end
end


%% Robot Inverse Kinematics and Simulate Robot

for count = 1:numberWaypoints - 1
 
    % Intermediate waypoints movement
    for index = 1:size(trajectory_data{2,count},3)
        % Solve IK
        target_pose = trajectory_data{2,count}(:, :, index);

        % Configuration contains the angle for each joint.
        [configuration_space, info] = ik(endEffector, target_pose, ikWeights, ikInitialGuess);
        ikInitialGuess = configuration_space;

        show(robot, configuration_space, 'Frames', 'off', 'PreservePlot', false);

        title(sprintf("Trajectory at t = %.4f s", intermediate_waypoints_time_interval(index)));

        % Get the desired View
        view([-0.6 -0.6 0.2]);
        drawnow
    end

end



% % Main waypoints movement
% for count = 1:numberWaypoints - 1
%     main_waypoints_time_interval = total_time_to_waypoint(count:count + 1);
%     intermediate_waypoints_time_interval = main_waypoints_time_interval(1):ts(count):main_waypoints_time_interval(2);
% 
% 
%     % Find the transforms from trajectory generation
%     [transformation_matrix_array, vel, acc] =...
%         transformtraj(waypoints(:, :, count),...
%         waypoints(:, :, count + 1),...
%         main_waypoints_time_interval,...
%         intermediate_waypoints_time_interval);
%     
%     % Trajectory visualization for the segment
%     if plotMode == 1
%         eePos = tform2trvec(transformation_matrix_array);
%         plot3(eePos(:,1),eePos(:,2),eePos(:,3),'-^','Color','k')
%         %set(hTraj,'xdata',eePos(:,1),'ydata',eePos(:,2),'zdata',eePos(:,3));
%     elseif plotMode == 2
%         plotTransforms(tform2trvec(transformation_matrix_array),...
%             tform2quat(transformation_matrix_array),'FrameSize',0.05);
%     end
%     
%     % Intermediate waypoints movement
%     for index = 1:numel(intermediate_waypoints_time_interval)
%         % Solve IK
%         target_pose = transformation_matrix_array(:, :, index);
% 
%         % Configuration contains the angle for each joint.
%         [configuration_space, info] = ik(endEffector, target_pose, ikWeights, ikInitialGuess);
%         ikInitialGuess = configuration_space;
% 
%         show(robot, configuration_space, 'Frames', 'off', 'PreservePlot', false);
% 
%         title(sprintf("Trajectory at t = %.4f s", intermediate_waypoints_time_interval(index)));
% 
%         % Get the desired View
%         view([-0.6 -0.6 0.2]);
%         drawnow
%     end
% 
%  end
