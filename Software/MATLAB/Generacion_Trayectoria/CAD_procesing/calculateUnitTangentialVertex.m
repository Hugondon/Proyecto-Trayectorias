function unitTangentialVertex = calculateUnitTangentialVertex(nodesInSurfacaPathID,gm,msh,nodes,surfaceInfo,edgeLenght)
    %CALCULATEUNIT Summary of this function goes here
    %   Detailed explanation goes here
    %% Extract information from file
    % Get nodes in surface path
    %nodesInSurfacaPathID=readmatrix(nameFileNodesInSurfacePathID);
    % Get spatial coordinates of nodes
    nodesInSurfacePath = nodes(:,nodesInSurfacaPathID)';
    % Get quantity of nodes in surface path
    numberOfNodesInSurfacePath=size(nodesInSurfacaPathID,1);

    % Preallocate memory for normal vectors
    unitTangentialVertex=zeros(numberOfNodesInSurfacePath,3);

    %% Calculate Tangential Vertex
    % Calculate all tangential vertex except the last one
    unitTangentialVertex(1:end-1,:) = nodesInSurfacePath(2:end,:)-nodesInSurfacePath(1:end-1,:);
    % The last tangential vertex is the same as one before.
    unitTangentialVertex(end,:) = unitTangentialVertex(end-1,:);
%     %% Correcting rounding error
%     % Minimum quantity admited as a vector component
%     magnitudeComponentThreshold=9E-5;
%     % Checks if all componenets are above threshold
%     isGreaterThanThreshold = abs(unitNormalVertex(contNodesInSurfacePath,:))>= magnitudeComponentThreshold;
%     % Corrects if at least one component is under the threshold
%     if (~all(isGreaterThanThreshold))
%         unitNormalVertex(contNodesInSurfacePath,:) = unitNormalVertex(contNodesInSurfacePath,:) .* isGreaterThanThreshold;
%     end
%     
    %% Calculate unit tangential vector
    unitTangentialVertex = unitTangentialVertex./vecnorm(unitTangentialVertex')';
end

