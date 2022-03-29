%% Main Node
% ID of the Node of Interest
NumNode=100;

% Get coordinates of main node
nodeM=nodes(:,NumNode);


% Radius of the search
nodeSphereRadius=15;

% Number of Faces in the DiscreteGeometry
numFaces=gm.NumFaces;

% Get the ID of the nodes in the surface of the mesh
nodesInFaceID=findNodes(msh,'region','Face',1:numFaces);

% Get the ID of the nodes within the radius of search from the main node
nearNodesInRadiusID=findNodes(msh,'radius',nodeM,nodeSphereRadius);

% Intersection between nodes in the surface and nodes near main node
nearNodesInFaceID=intersect(nodesInFaceID,nearNodesInRadiusID);

% Get the coordinates of the near nodes
nearNodes=nodes(:,nearNodesInFaceID);

% Plot main node
plot3(nodeM(1,1),nodeM(2,1),nodeM(3,1),'r*','MarkerSize',10);

% Plot near nodes in face
plot3(nearNodes(1,:),nearNodes(2,:),nearNodes(3,:),'ro','MarkerSize',10);
