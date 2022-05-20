function surfacePathPoses = calculatePosesOfSurfaceNodes(nameFileNodesInSurfacePathID,gm,msh,nodes,surfaceInfo,edgeLenght)
%CALCULATEPOSEOFSURFACENODE Summary of this function goes here
%   Detailed explanation goes here
    %% Function Handle
    calculateUnitNormalVertex       =   @calculateUnitNormalVertex;
    calculateUnitTangentialVertex   =   @calculateUnitTangentialVertex;
    %% Extract information from file
    % Extract nodes IDs from CSV file
    nodesInSurfacaPathID=readmatrix(nameFileNodesInSurfacePathID);
    % Get quantity of nodes in surface path
    numberOfNodesInSurfacePath=size(nodesInSurfacaPathID,1);

    %% Calculate base Vectors
    % Calculate unit Basis Vector Uz
    basisZVector = calculateUnitNormalVertex(nodesInSurfacaPathID,gm,msh,nodes,surfaceInfo,edgeLenght);
    % Calculate unit Basis Vector Ux
    basisXVector = calculateUnitTangentialVertex(nodesInSurfacaPathID,gm,msh,nodes,surfaceInfo,edgeLenght);
    % Calculate unit Basis Vector Uy
    basisYVector = cross(basisZVector,basisXVector);

    % The following step ensure that all three basis vectors are orthogonal
    % Correct unit Basis Vector Uz
    basisZVector = cross(basisXVector,basisYVector);

    %% Build Pose
    % Preallocate memory
    surfacePathPoses = zeros(4,4,numberOfNodesInSurfacePath);

    % Insert Scaling factor
    surfacePathPoses(4,4,:) = 1;
    % Insert Basis Vectors
    surfacePathPoses(1:3,1,:) = basisXVector';
    surfacePathPoses(1:3,2,:) = basisYVector';
    surfacePathPoses(1:3,3,:) = basisZVector';
    % Insert Displacement Vector
    surfacePathPoses(1:3,4,:) = nodes(:,nodesInSurfacaPathID);
end

