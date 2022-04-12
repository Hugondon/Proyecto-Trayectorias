function [] = convert2csv(trajectory_data,FILENAME)
%CONVERT2CSV Summary of this function goes here
%   Detailed explanation goes here

    % File name
    %FILENAME = 'trajectory2.csv';
    % Mustn't be changed to [] although warning says so.
    COLUMN_HEADERS = {"Tipo de Movimiento", ...
                    "X [m]", "Y [m]", "Z [m]", ...
                    "Rx [rad]", "Ry [rad]", "Rz [rad]", ...
                    "Base [rad]", "Shoulder [rad]", "Elbow [rad]", ...
                    "Wrist 1 [rad]", "Wrist 2 [rad]", "Wrist 3 [rad]"};

    % Write row containing column headers.
    writecell(COLUMN_HEADERS, FILENAME, 'WriteMode', 'overwrite');

    for main_waypoint = 1:size(trajectory_data, 1)

        % Prepare trajectory information

        % Movement type (Joint Movement=0 Linear Movement=1)
        movement_type = cell2mat(trajectory_data(main_waypoint,1));
        % Array of Poses
        poses_array = cell2mat(trajectory_data(main_waypoint,2));
        % Array of Configurations spaces
        configuration_space = cell2mat(trajectory_data(main_waypoint,3));

        for intermediate_waypoints = 1:size(poses_array, 3)
            % Obtain configuration space information
            intermediate_configuration_space = configuration_space(:, intermediate_waypoints);

            % Obtain pose
            pose = poses_array(:, :, intermediate_waypoints);
            % Axis of rotation [ux,uy,uz,theta]
            axis_angle_rotation = tform2axang(pose);
            % Axis of rotation [Rx,Ry,Rz]
            pose_rotation = axis_angle_rotation(1, 1:3) .* axis_angle_rotation(1, 4);
            % Translations
            pose_translation = tform2trvec(pose);

            % Building CSV array
            csv_information = [movement_type, pose_translation, pose_rotation, intermediate_configuration_space'];
            % Writing CSV array in CSV file
            writematrix(csv_information, FILENAME, 'WriteMode', 'append');
        end
    end
end

