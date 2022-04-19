function [surfaceNodesID,insideNodesID] = classifySurfaceAndInsideNodes(gm,msh,nodes,surfaceInfo,searchRadius,normalVertexOriginNodeID)
% Get the nodes witihn a search radius of "normalVertexOriginNodeID" and classify them in surface 
% nodes and the nodes inside.

% Get ID of the face where the node belong
nearestFace2NormalVertexOriginNodeID=nearestFace(gm,nodes(:,normalVertexOriginNodeID)');
% Find Nodes within search radius
nodesInSearchRadiusID=findNodes(msh,"radius",nodes(:,normalVertexOriginNodeID),searchRadius);
% Get nodes in surface
surfaceNodesID=setdiff(intersect(nodesInSearchRadiusID,surfaceInfo.nodesInSurfaceID{nearestFace2NormalVertexOriginNodeID}),normalVertexOriginNodeID);
% Get nodes inside
insideNodesID=setdiff(nodesInSearchRadiusID,surfaceNodesID);
end

