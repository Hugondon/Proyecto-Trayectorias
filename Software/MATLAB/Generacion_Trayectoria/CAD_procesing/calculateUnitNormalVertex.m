function unitNormalVertex = calculateUnitNormalVertex(nodesInSurfacaPathID,gm,msh,nodes,surfaceInfo,edgeLenght)
%CALCULATENORMALVERTEX Calculates Unit Normal Vertex of each node.
%{
Use the neighbor nodes to calculate the normal vertex of the origin node

%}
    %% Function Handles
    classifySurfaceAndInsideNodes   =   @classifySurfaceAndInsideNodes;
    calculateVectorBetween2Nodes    =   @calculateVectorBetween2Nodes;
    unitVectorOfSum                 =   @unitVectorOfSum;
    %% Extract information from file
    % Get nodes in surface path
    %nodesInSurfacaPathID=readmatrix(nameFileNodesInSurfacePathID);
    % Get quantity of nodes in surface path
    numberOfNodesInSurfacePath=size(nodesInSurfacaPathID,1);

    % Preallocate memory for normal vectors
    unitNormalVertex=zeros(numberOfNodesInSurfacePath,3);
    %% Iterate through all the nodes
    for contNodesInSurfacePath=1:numberOfNodesInSurfacePath
        %% Classify surface nodes and inside nodes
        [surfaceNodesID,insideNodesID]  =   classifySurfaceAndInsideNodes(gm,msh,nodes,surfaceInfo,...
                                            edgeLenght.Hmax*2,nodesInSurfacaPathID(contNodesInSurfacePath));
        
        %% Obtain outward direction
        % Calculate a normal vector using the nodes from inside
        normalVertexFromInside = calculateVectorBetween2Nodes(nodes,nodesInSurfacaPathID(contNodesInSurfacePath),insideNodesID);
        % Sum all the vectors, calculate the unit vector and make it point outward instead of inward
        unitNormalVertexFromInside = -1*unitVectorOfSum(normalVertexFromInside);
        
        %% Obtain normal vertex with arbitrary direction

        % Calculate vectors from the nodes in surface and nodes inside
        vectorsInSurface = calculateVectorBetween2Nodes(nodes,nodesInSurfacaPathID(contNodesInSurfacePath),surfaceNodesID);
        % Get number of Vectors in surface
        quantityVectorsInSurface=size(vectorsInSurface,2);
        
        % Preallocate memory for normal vertex obtain from the nodes in the surface
        normalVertexFromSurface=zeros(3,quantityVectorsInSurface);

        % Pre calculate the first normal vertex to use it as a reference for direction
        normalVertexFromSurface(:,1)   = cross(vectorsInSurface(:,1),vectorsInSurface(:,2));
        %disp(nearNodesInSurface);

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
        %Get the sum of all the normal vertex and gets the unit vertex
        unitNormalVertexFromSurface = unitVectorOfSum(normalVertexFromSurface);

        %% Correct direction of Unit Vertex Normal

        %Check if the two vector are pointing in similar directions
        areNormalVertexPointingInSimilarDirections=...
                                    dot(unitNormalVertexFromSurface,unitNormalVertexFromInside)>0;
        

        % If the normal vertex is not pointing in a similar direction its direction is inverted
        if(~areNormalVertexPointingInSimilarDirections)
            unitNormalVertex(contNodesInSurfacePath,:)=-1*unitNormalVertexFromSurface';
        else
            unitNormalVertex(contNodesInSurfacePath,:)=unitNormalVertexFromSurface';
        end
        %% Correcting rounding error
        % Minimum quantity admited as a vector component
        magnitudeComponentThreshold=9E-4;
        % Checks if all componenets are above threshold
        isGreaterThanThreshold = abs(unitNormalVertex(contNodesInSurfacePath,:))>= magnitudeComponentThreshold;
        % Corrects if at least one component is under the threshold
        if (~all(isGreaterThanThreshold))
            % Eliminates the components that are below threshold
            unitNormalVertex(contNodesInSurfacePath,:) =...
                unitNormalVertex(contNodesInSurfacePath,:) .* isGreaterThanThreshold;
            % Get the vector with the corrected components
            unitNormalVertex(contNodesInSurfacePath,:) =...
                unitNormalVertex(contNodesInSurfacePath,:)/vecnorm(unitNormalVertex(contNodesInSurfacePath,:));
        end
        %% Remarking dominant component
        isAnyComponentAlmostOne = unitNormalVertex(contNodesInSurfacePath,:)>0.99999;
        if (any(isAnyComponentAlmostOne))
            unitNormalVertex(contNodesInSurfacePath,:) = isAnyComponentAlmostOne;
        end
    end
end

