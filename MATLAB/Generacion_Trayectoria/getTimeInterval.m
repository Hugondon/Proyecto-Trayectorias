function ts = getTimeInterval(nIntermediateWaypoints, csMagnitudeDistances, tcpSpeed)
% getTimeInterval.m Calculate the sampling time between waypoints for ik solver

%{
Calculate the sampling time between waypoints for ik solver
    Inputs:
        nIntermediateWaypoints:     Number of intermidiate Waypoints
        csMagnitudeDistances:       Cumulative sum of the magnitude of the distance
                                    between consecutive waypoints
        tcpSpeed:                   Desired speed of the TCP (User defined)
    Outputs:
        ts:                         Time interval between intermediate waypoints
%}

    % Get amount of main waypoints
    numberWaypoints = size(csMagnitudeDistances, 2);

    % Allocate memory for the different sampling times and number of intermediate Waypoints
    ts = zeros(1, numberWaypoints - 1);
    
    % Calculate Trajectory times and sampling times
    for count = 1:numberWaypoints - 1
        
        % Get distance between waypoints 
        distanceBetweenWaypoints=(csMagnitudeDistances(count + 1) - csMagnitudeDistances(count));
         
        %{
            Calculate sampling times with the times of the Trajectory using the
            number of intermediate Waypoints, TCP speed and the times of the main
            waypoints
        %}
        ts(count) = ...
            distanceBetweenWaypoints/ ...
            ((nIntermediateWaypoints + 1) * tcpSpeed);
        
        %To make sure the sampling time of the program is less than the sampling time of the robot
        if (ts(count) < 1/125)
            ts(count) = 1/125;  
        end

    end

end
