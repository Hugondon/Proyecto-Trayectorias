function [trajTimes,ts] = getTrajectoryTimes(nIntermediateWaypoints,csMagnitudeDistances)
    numberWaypoints=size(csMagnitudeDistances,2);

    % Allocate memory for the Trajectory times
    trajTimes=zeros(1,numberWaypoints+(numberWaypoints-1)*nIntermediateWaypoints);
    % Allocate memory for the different sampling times
    ts=zeros(1,numberWaypoints-1);

    % Calculate Trajectory times and sampling times
    for count=1:numberWaypoints-1
        %Calculate the different times of the Trajectory using the
        % number of intermediate Waypoints and the times of the main
        % waypoints
        trajTimes(1,1+(count-1)*(nIntermediateWaypoints+1):1+count*(nIntermediateWaypoints+1))=...
            linspace(csMagnitudeDistances(count),csMagnitudeDistances(count+1),nIntermediateWaypoints+2);
        %Calculate sampling times with the times of the Trajectory using the
        % number of intermediate Waypoints and the times of the main
        % waypoints
        ts(count)=...
            (csMagnitudeDistances(count+1)-csMagnitudeDistances(count))/(nIntermediateWaypoints+1);
        %To make sure the sampling time of the program is less than the sampling time
        %of the robot
        if (ts(count)<1/125)
            ts(count)=1/125;
        end
    end
end

