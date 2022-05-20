function middleNodeInSurfaceID = getMiddleSurfaceNode(gm,msh,surfaceInfo,edgeLenght,nodes,referenceNodesID)
% Get the middle surface node between two reference nodes.
%{
Get the middle spatial point (MSP) between the two reference nodes and finds the closest surface node to 
the MSP.
    Inputs:
        gm:                         Discrete Geometric Model.
        msh:                        Mesh obtain from the Discrete Geometric Model.
        surfaceInfo:                Contains important information about the surface, such as
                                    vertices of the discrete geometric model and the nodes of 
                                    each face of the mesh.
        edgeLenght:                 Parameters of minimum and maximum edge lenght on the mesh.
        nodes:                      List of spatial coordinate of the nodes. 
                                    The ID of the node is also column index.
        referenceNodesID:           Row Vector of the IDs of two reference nodes.
    Outputs:
        middleNodeInSurfaceID:      ID of the surface node between two reference nodes.
%}
    %% Middle Spatial Point (MSP) and important information

    % Get coordinates of the two reference nodes
    referenceNodes=nodes(:,referenceNodesID);
    
    % Get Middle Spatial Point(MSP)
    middleSpatialPoint=((referenceNodes(:,2)+referenceNodes(:,1))/2);
    %{
    % Uncomment to plot the Middle Spatial Point(MSP)
    figure(2)
    plot3(middleSpatialPoint(1,1),middleSpatialPoint(2,1),middleSpatialPoint(3,1),'m*','MarkerSize',15);
    %}
    
    % Get nearest node face to the MSP
    nearestFace2MSPID=nearestFace(gm,middleSpatialPoint');
    %{ 
    % uncomment to plot nodes in nearest face from Middle Spatial Point(MSP)
    plot3(  nodes(1,surfaceInfo.nodesInSurfaceID(nearestFace2MSPID)),...
                nodes(2,surfaceInfo.nodesInSurfaceID(nearestFace2MSPID)),...
                nodes(3,surfaceInfo.nodesInSurfaceID(nearestFace2MSPID)),...
                'm*','MarkerSize',15)
    %}

    % Get the nearest node to the MSP
    nearestNode2MSPID=findNodes(msh,'nearest',middleSpatialPoint);
    

    %{ 
    2 Processes to achive the same result.
    There are two processes to find the middle surface node, the simple and the complex one. The
    simple is useful if the MSP is outside the mesh or a little bit inside in the mesh. If the MSP
    is below-threshold-inside the mesh then the complex process most be used.
    %}
    %% Simple process

    % Check if the nearest node to the MSP is in face
    isNearestNodeInFace=ismember(nearestNode2MSPID,surfaceInfo.nodesInSurfaceID{nearestFace2MSPID});
    % If nearest node to MSP is in face the function can stop executing
    if(isNearestNodeInFace==true)
        middleNodeInSurfaceID=nearestNode2MSPID;
        return
    end

    % If nearest node to MSP is not in face then another process most be done
    %% Complex process(CP): Initial search radius
    % Get Nodes in Surface
    nodesInNearestSurfaceID=surfaceInfo.verticesInFaces{nearestFace2MSPID};
    % Get vector from Middle Spatial Point(MSP) to vertices of the surface
    vectorsFromMSP2FaceVertices=nodes(:,nodesInNearestSurfaceID)-middleSpatialPoint;
    % Get the norm of the vectors "vectorsFromMSP2FaceVertices"
    normVectorsFromMSP2FaceVertices=vecnorm(vectorsFromMSP2FaceVertices);
    % Get the minimum of the norm of "normVectorsFromMSP2FaceVertices"
    minNormVectorsFromMSP2FaceVertices=min(normVectorsFromMSP2FaceVertices);
     
    % Initial search Radius
    searchRadius=minNormVectorsFromMSP2FaceVertices;

    % Clear process variables
    clear nodesInNearestSurfaceID vectorsFromMSP2FaceVertices normVectorsFromMSP2FaceVertices...
          minNormVectorsFromMSP2FaceVertices

    %% CP: Search for middle node in surface

    % Establish while loop conditional
    isaNodeInRadiusAndInSurface=false;

    % Iterates until it finds the closest surface node from the Middle Spatial Point (MSP)
    while (isaNodeInRadiusAndInSurface==false)
        % Get nodes in search radius
        nodesInRadiusOfMSP=findNodes(msh,"radius",middleSpatialPoint,searchRadius);
        %  Extract just the nodes that are in the surface and ignore the "referenceNodesID"
        nodesInRadiusAndInSurfaceID=setdiff(intersect(nodesInRadiusOfMSP,surfaceInfo.nodesInSurfaceID{nearestFace2MSPID}),referenceNodesID);
        % Check if there is at least one node within search radius and in surface
        isaNodeInRadiusAndInSurface=~isempty(nodesInRadiusAndInSurfaceID);

        if (isaNodeInRadiusAndInSurface)
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

