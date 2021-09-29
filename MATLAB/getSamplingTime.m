function ts = getSamplingTime(nIntermediateWaypoints, csMagnitudeDistances, tcpSpeed)
    % getSamplingTime.m Calculate the sampling time between waypoints for ik solver
    % Inputs:
    % nIntermediateWaypoints: Number of intermediate waypoints defined by the user
    % csMagnitudeDistances: cummulative sum of the magnitudes of the distances between main waypoints
    % tcpSpeed: tcp speed defined by the user.
    % Outputs:
    % ts: Time interval between intermediate waypoints

    % Get amount of columns
    numberWaypoints = size(csMagnitudeDistances, 2);

    % Allocate memory for the Trajectory times
    %trajTimes=zeros(1,numberWaypoints+(numberWaypoints-1)*nIntermediateWaypoints);

    % Allocate memory for the different sampling times
    ts = zeros(1, numberWaypoints - 1);

    % Calculate Trajectory times and sampling times
    for count = 1:numberWaypoints - 1
        %Calculate the different times of the Trajectory using the
        % number of intermediate Waypoints and the times of the main
        % waypoints
        %trajTimes(1,1+(count-1)*(nIntermediateWaypoints+1):1+count*(nIntermediateWaypoints+1))=...
        %linspace(csMagnitudeDistances(count),csMagnitudeDistances(count+1),nIntermediateWaypoints+2);
        %Calculate sampling times with the times of the Trajectory using the
        % number of intermediate Waypoints, TCP speed and the times of the main
        % waypoints
        ts(count) = ...
            (csMagnitudeDistances(count + 1) - csMagnitudeDistances(count)) ...
            / ...
            ((nIntermediateWaypoints + 1) * tcpSpeed);
        %To make sure the sampling time of the program is less than the sampling time
        %of the robot
        if (ts(count) < 1/125)
            ts(count) = 1/125;
        end

    end

end
