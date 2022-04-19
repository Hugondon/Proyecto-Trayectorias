function unitNormalVertex = calculateUnitNormalVertex(nameFileNodesInSurfacePathID,gm,msh,nodes,surfaceInfo,edgeLenght)
%CALCULATENORMALVERTEX Summary of this function goes here
%   Detailed explanation goes here
    %% Function Handles
    classifySurfaceAndInsideNodes   =   @classifySurfaceAndInsideNodes;
    calculateVectorBetween2Nodes    =   @calculateVectorBetween2Nodes;
    unitVectorOfSum                 =   @unitVectorOfSum;
    %% Extract information from file
    % Get nodes in surface path
    nodesInSurfacaPathID=readmatrix(nameFileNodesInSurfacePathID);
    % Get quantity of nodes in surface path
    numberOfNodesInSurfacePath=size(nodesInSurfacaPathID,1);

    % Preallocate memory for normal vectors
    unitNormalVertex=zeros(numberOfNodesInSurfacePath,3);

    for contNodesInSurfacePath=1:numberOfNodesInSurfacePath
        %% Classify surface nodes and inside nodes
        [surfaceNodesID,insideNodesID]  =   classifySurfaceAndInsideNodes(gm,msh,nodes,surfaceInfo,...
                                            edgeLenght.Hmax*1.1,nodesInSurfacaPathID(contNodesInSurfacePath));
        
        %% Obtain outward direction
        normalVertexFromInside = calculateVectorBetween2Nodes(nodes,nodesInSurfacaPathID(contNodesInSurfacePath),insideNodesID);
        unitNormalVertexFromInside = -1*unitVectorOfSum(normalVertexFromInside);
        
        %% Obtain normal vertex with arbitrary direction

        % Calculate vectors from the nodes in surface and nodes inside
        vectorsInSurface = calculateVectorBetween2Nodes(nodes,nodesInSurfacaPathID(contNodesInSurfacePath),surfaceNodesID);
        % Get number of Vectors in surface
        quantityVectorsInSurface=size(vectorsInSurface,2);
        
        % Preallocate memory for normal vertex obtain from the nodes in the surface
        normalVertexFromSurface=zeros(3,quantityVectorsInSurface);

        % Pre calculate the first normal vertex to use it as a reference for direction
        normalVertexFromSurface(:,1)   =...
                cross(  vectorsInSurface(:,1), ...
                        vectorsInSurface(:,2));


        for contSurfaceVectors=2:quantityVectorsInSurface-1
            % Calculate normal vertex
            normalVertexFromSurface(:,contSurfaceVectors)   =...
                cross(  vectorsInSurface(:,contSurfaceVectors), ...
                        vectorsInSurface(:,contSurfaceVectors+1));
            % Checks if the first normal vertex and the normal vertex are pointing in a similar
            % direction
            arePointingInSimilarDirections=sign(dot( normalVertexFromSurface(:,1),...
                                                    normalVertexFromSurface(:,contSurfaceVectors)));
            % If the normal vertex is not pointing in a similar direction its direction is inverted
            if(arePointingInSimilarDirections==-1)
                normalVertexFromSurface(:,contSurfaceVectors)=-1*normalVertexFromSurface(:,contSurfaceVectors);
            end
        end
        unitNormalVertexFromSurface = unitVectorOfSum(normalVertexFromSurface);

        %% Correct direction of Unit Vertex Normal

        %Check if the two vector are pointing in similar directions
        areNormalVertexPointingInSimilarDirections=...
                                    sign(dot(unitNormalVertexFromSurface,unitNormalVertexFromInside));
        

        % If the normal vertex is not pointing in a similar direction its direction is inverted
        if(areNormalVertexPointingInSimilarDirections==-1)
            unitNormalVertex(contNodesInSurfacePath,:)=-1*unitNormalVertexFromSurface';
        else
             unitNormalVertex(contNodesInSurfacePath,:)=unitNormalVertexFromSurface';
        end
    end
end

