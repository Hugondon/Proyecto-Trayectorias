function middleNodeInSurfaceID = getMiddleSurfaceNode(gm,msh,surfaceInfo,edgeLenght,nodes,referenceNodesID)
    %GETMIDDLENODE Summary of this function goes here
    %   Detailed explanation goes here
    
    % Get coordinates of the two reference nodes
    referenceNodes=nodes(:,referenceNodesID);
    
    % Get Middle Spatial Point(MSP)
    middleSpatialPoint=((referenceNodes(:,2)+referenceNodes(:,1))/2);
    %Plot middle point
    %figure(2)
    %plot3(middleSpatialPoint(1,1),middleSpatialPoint(2,1),middleSpatialPoint(3,1),'m*','MarkerSize',15)
    
    % Get nearest node face to the MSP
    nearestFace2MSPID=nearestFace(gm,middleSpatialPoint');
%     plot3(  nodes(1,surfaceInfo.nodesInSurfaceID(nearestFace2MSPID)),...
%             nodes(2,surfaceInfo.nodesInSurfaceID(nearestFace2MSPID)),...
%             nodes(3,surfaceInfo.nodesInSurfaceID(nearestFace2MSPID)),...
%             'm*','MarkerSize',15)

    % Get the nearest node to the MSP
    nearestNode2MSPID=findNodes(msh,'nearest',middleSpatialPoint);
    
    % Check if the nearest node to the MSP is in face
    isNearestNodeInFace=ismember(nearestNode2MSPID,surfaceInfo.nodesInSurfaceID{nearestFace2MSPID});
    % If nearest node to MSP is in face the function can stop executing
    if(isNearestNodeInFace==true)
        middleNodeInSurfaceID=nearestNode2MSPID;
        return
    end

    % If nearest node to MSP is not in face then another process most follow
    %% Initial Search Radius
    % Get Nodes in Surface
    nodesInNearestSurfaceID=surfaceInfo.VerticesInFaces{nearestFace2MSPID};
    % Get vector from Middle Spatial Point(MSP) to vertices of the surface
    vectorsFromMSP2FaceVertices=nodes(:,nodesInNearestSurfaceID)-middleSpatialPoint;
    % Get the norm of the vectors "vectorsFromMSP2FaceVertices"
    normVectorsFromMSP2FaceVertices=vecnorm(vectorsFromMSP2FaceVertices);
    % Get the mean of the norm of "normVectorsFromMSP2FaceVertices"
    meanNormVectorsFromMSP2FaceVertices=mean(normVectorsFromMSP2FaceVertices,2);
    
    % Initial search Radius
    searchRadius=meanNormVectorsFromMSP2FaceVertices;

    %% Search for middel node in surface

    % Establish while loop conditional
    isaNodeInRadiusAndInSurface=false;
    while (isaNodeInRadiusAndInSurface==false)
        % Get nodes in search radius
        nodesInRadiusOfMSP=findNodes(msh,"radius",middleSpatialPoint,searchRadius);
        %  Extract just the nodes that are in the surface and ignore the "referenceNodesID"
        nodesInRadiusAndInSurfaceID=setdiff(intersect(nodesInRadiusOfMSP,surfaceInfo.nodesInSurfaceID{nearestFace2MSPID}),referenceNodesID);
        % Check if there is at least one node within search radius and in surface
        %isaNodeInRadiusAndInSurface=~isempty(nodesInRadiusAndInSurfaceID);


        if (~isempty(nodesInRadiusAndInSurfaceID)==true)
            % Calculate the vectors from MSP to the nearest nodes in surface
            vectors2Surface=nodes(:,nodesInRadiusAndInSurfaceID)-middleSpatialPoint;
            % Get the index from the node which is closest to the MSP
            [~,idxNearestNode2MSP]=min(vecnorm(vectors2Surface));
            % Get the ID of the node closes to the MSP
            middleNodeInSurfaceID=nodesInRadiusAndInSurfaceID(idxNearestNode2MSP,1);

            break
        end

        % Makes the search radius bigger for the next iteration
        searchRadius=searchRadius+edgeLenght.Hmax;
    end
end

