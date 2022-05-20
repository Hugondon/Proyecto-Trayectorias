function figureRobot = simulateRobot(plotMode,trajectory_data,surfacePosePath,robot,figureRobot,viewVector)
%SIMULATEROBOT Graphs the trajectory and simulates the robot following the trajectory.

%{
This function does 2 things:

    1-Graphs the trajectory the robot will follow:
        Inputs:
            plotMode            Dictates how the trajectory will be ploted
            trajectory_data     This holds the information of the trajectory
            figureRobot         Is were the trajectory will be plotted
        Outputs:
            figureRobot (with trajectory plotted)

    2-Simulates The robot following the trajectory
        Inputs:
            trajectory_data     This holds the information of the trajectory
            robot               Robot object
            figureRobot         Is were were the robot will be simulated
            viewVector          Perspective of the robot simulation
        Outputs:
            figureRobot (with simulation of the robot)
%}

%% Initial setup
    % Opens the figure of the robot
    figure(figureRobot);
    % Get the number of translations in the trajectory
    numberTranslations =   size(trajectory_data,1);
    
%% Graph Trajectory

    for count = 1:numberTranslations

        % Trajectory visualization of the Waypoints for the segment
        if plotMode == 1
            tcp_position = tform2trvec(trajectory_data{count,2});
            plot3(tcp_position(:, 1), tcp_position(:, 2), tcp_position(:, 3), '-^', 'Color', 'k');

        % Trajectory visualization of the TCP poses for the segment
        elseif plotMode == 2
            plotTransforms(tform2trvec(trajectory_data{count,2}),tform2quat(trajectory_data{count,2}), 'FrameSize', 0.05);
        % Trajectory visualization of the Surface Path Poses for the segment
        elseif plotMode == 3
            plotTransforms(tform2trvec(surfacePosePath(:,:,count)),tform2quat(surfacePosePath(:,:,count)), 'FrameSize', 0.05);
        end
        
    end

%% Simulate Robot

    for count = 1:numberTranslations

        % Intermediate waypoints movement
        for index = 1:size(trajectory_data{count,3}, 2)

            show(robot, trajectory_data{count,3}(:, index), 'Frames', 'off', 'PreservePlot', false);
            %show(robot, trajectory_data{ ,3}(:, ), 'Frames', 'off', 'PreservePlot', false)
            %title(sprintf("Trajectory at t = %.4f s", intermediate_waypoints_time_interval(index)));

            % Get the desired View
            view(viewVector);
            drawnow
        end

    end
end

