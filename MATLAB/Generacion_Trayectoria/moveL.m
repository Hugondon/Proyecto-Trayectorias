function trajectory_data= moveL(waypoints,total_time_to_waypoint,ts,...
                                ik,endEffector,ikWeights,ikInitialGuess)
%
numberWaypoints=size(waypoints,3);

%Get number of translations between waypoints
trajectory_data = cell(3, numberWaypoints - 1);   
    %% Calculate Poses

    for count = 1:numberWaypoints - 1

        % Extract the starting and finishing waypoint times of the segment of the trajectory
        main_waypoints_time_interval = total_time_to_waypoint(count:count + 1);
        % Get the times of the intermediate waypoints in the segment of the trajectory
        intermediate_waypoints_time_interval = main_waypoints_time_interval(1):ts(count):main_waypoints_time_interval(2);

        % Find the transforms from trajectory generation
        % Change transformation_matrix_array
        [transformation_matrix_array, vel, acc] = ...
            transformtraj(waypoints(:, :, count), ...
            waypoints(:, :, count + 1), ...
            main_waypoints_time_interval, ...
            intermediate_waypoints_time_interval);


        % To avoid repeated Waypoints
        if count > 1
            transformation_matrix_array(:, :, 1) = [];
        end

        % Save type of movements and poses
        % Movement Type
        trajectory_data{1, count} = 1; % MoveJ=0 MoveL=1
        % Poses
        trajectory_data{2, count} = transformation_matrix_array;
    end


    %% Robot Inverse Kinematics

    for count = 1:numberWaypoints - 1

        % Get number of Configurations on the configuration space
        size_config_space = size(trajectory_data{2, count}, 3);

        % Reserve memory for the configurations
        config_space_data = zeros(6, size_config_space);

        % Intermediate waypoints movement
        for index = 1:size_config_space

            % Solve IK
            target_pose = trajectory_data{2, count}(:, :, index);

            % Configuration contains the angle for each joint.
            [configuration_space, info] = ik(endEffector, target_pose, ikWeights, ikInitialGuess);
            ikInitialGuess = configuration_space;

            % Save the configuration space in a matrix
            config_space_data(:, index) = configuration_space;
        end

        % Save the configuration space in trajectory data to use
        % it in the Simulation of the robot
        trajectory_data{3, count} = config_space_data;
    end
end

