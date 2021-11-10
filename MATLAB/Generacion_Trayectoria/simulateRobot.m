function figureRobot = simulateRobot(plotMode,trajectory_data,robot,figureRobot)
%SIMULATEROBOT Summary of this function goes here
%   Detailed explanation goes here

    figure(figureRobot);
    numberTranslations =   size(trajectory_data,2);
    %% Graph Trajectory

    for count = 1:numberTranslations

        % Trajectory visualization of the Waypoints for the segment
        if plotMode == 1
            tcp_position = tform2trvec(trajectory_data{2, count});
            plot3(tcp_position(:, 1), tcp_position(:, 2), tcp_position(:, 3), '-^', 'Color', 'k');

            % Trajectory visualization of the TCP poses for the segment
        elseif plotMode == 2
            plotTransforms(tform2trvec(trajectory_data{2, count}), ...
                tform2quat(trajectory_data{2, count}), 'FrameSize', 0.05);
        end

    end

    %% Simulate Robot

    for count = 1:numberTranslations

        % Intermediate waypoints movement
        for index = 1:size(trajectory_data{2, count}, 3)

            show(robot, trajectory_data{3, count}(:, index), 'Frames', 'off', 'PreservePlot', false);

            %title(sprintf("Trajectory at t = %.4f s", intermediate_waypoints_time_interval(index)));

            % Get the desired View
            view([-0.6 -1 0.2]);
            drawnow
        end

    end
end

