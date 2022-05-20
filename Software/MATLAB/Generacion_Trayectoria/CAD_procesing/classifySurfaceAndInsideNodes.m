function [surfaceNodesID,insideNodesID] = classifySurfaceAndInsideNodes(gm,msh,nodes,surfaceInfo,searchRadius,normalVertexOriginNodeID)
% Get the nodes within a search radius of "normalVertexOriginNodeID" and classify them in surface 
% nodes and the nodes inside.
%{ 
Classify inside and outside nodes:
1-Registers in a list "nodesInSearchRadiusID" all the nodes inside the search radius of the main node
2-Eliminate the origin node from the list
3-Get the ID of the face to which the node belongs
4-Make the set operation intersection to get the nodes within search radius"nodesInSearchRadiusID"
    and in the face "surfaceInfo.nodesInSurfaceID{nearestFace2NormalVertexOriginNodeID}" and save it 
    on a list "surfaceNodesID"
5-Make the set operation of difference with the "surfaceNodesID" list and the
    "nodesInSearchRadiusID". This left just the nodes inside the mesh.

    Input:
        gm:                         Discrete Geometric Model.
        msh:                        Mesh obtain from the Discrete Geometric Model.
        nodes:                      List that links The nodes ID and its cartesian coordinates.
        surfaceInfo:                Contains important information about the surface, such as
                                    vertices of the discrete geometric model and the nodes of 
                                    each face of the mesh.
        searchRadius:               Search radius use to find neighbor nodes.
        normalVertexOriginNodeID:   The origin node which is the origin of the search sphere.
    Output:
        surfaceNodesID:             Nodes in search radius and in the surface of the mesh.
        insideNodesID:              Nodes in search radius and inside the mesh.
%}
    %% Recolect data from the neighboring nodes
    % Find Nodes within search radius and eliminate the origin node from the list
    nodesInSearchRadiusID=setdiff(...
        findNodes(msh,"radius",nodes(:,normalVertexOriginNodeID),searchRadius),...
        normalVertexOriginNodeID);
    % Get ID of the face where the node belong
    nearestFace2NormalVertexOriginNodeID=nearestFace(gm,nodes(:,normalVertexOriginNodeID)');
    %% Classify nodes
    % Get nodes in surface
    surfaceNodesID=intersect(nodesInSearchRadiusID,...
        surfaceInfo.nodesInSurfaceID{nearestFace2NormalVertexOriginNodeID});
    % Get nodes inside
    insideNodesID=setdiff(nodesInSearchRadiusID,surfaceNodesID);
end

