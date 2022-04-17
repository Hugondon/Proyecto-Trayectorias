% Source:
% https://www.mathworks.com/help/pde/geometry-and-mesh.html?s_tid=CRUX_lftnav
% File format .STL
%% Pre-execution setup
close all
delete listSelectedNodesID.csv nodesTrajectoryInSurfaceID.csv
%% Function Handles
getSurfacePath  =   @getSurfacePath;

%% Create and configure DiscreteGeometric model
% Create PDE model
msd = createpde;

% Import STL into the PDE model
gm=importGeometry(msd,'Part\cilindro_r100_h400_mm.STL');

%Conversion constant, from milimiters to meters
unitConvertionConstant_mm2m=1E-3;

% Convert from milimiters to meters
gm=scale(gm,unitConvertionConstant_mm2m);

%Get centroid
centroid.position=mean(gm.Vertices,1);

% Align origin an centroid from the Geometric model
gm=translate(gm,-1*centroid.position);

% To plot Discrete Geometry
%pdegplot(gm)

%Establish new centroid
centroid.position=[0,0,0];

%% Generate Mesh

%Establish maximum and minimum edge lenght( in milimeters)
edgeLenght.Hmax=0.01;
edgeLenght.Hmin=edgeLenght.Hmax/4;

% Generate a Mesh
msh = generateMesh(msd,'GeometricOrder','linear','Hmax', edgeLenght.Hmax,'Hmin', edgeLenght.Hmin);

%Nodes are extracted (units meters)
nodes=msh.Nodes;

% Number of Faces in the DiscreteGeometry
numFaces=gm.NumFaces;

%% Surface centroids
% % Preallocate memory for the IDs of the nodes in the surface of the mesh
% surfaceInfo.nodesInSurfaceID=cell(numFaces,1);
% 
% % Get nodes IDs of each face
% for cont=1:numFaces
%     surfaceInfo.nodesInSurfaceID{cont}=findNodes(msh,'region','Face',cont)';
% end
% 
% % Preallocate memory for face centroids
% surfaceInfo.centroidFaces=zeros(numFaces,3);
% 
% % Get Centroid of each face
% for cont=1:numFaces
%    surfaceInfo.centroidFaces(cont,:)=mean(nodes(:,surfaceInfo.nodesInSurfaceID{cont,:}),2);
% end
% 
% surfaceInfo.nearestNodeInFace2CentroidID=zeros(numFaces,1);
% 
% % Get the node on face nearest to the centroid
% for cont=1:numFaces
%     distCentroid2FaceNodes=...
%         surfaceInfo.centroidFaces(cont,:)-nodes(:,surfaceInfo.nodesInSurfaceID{cont,:})';
%     
%     [~,idxNearestNode2Centroid]=min(vecnorm(distCentroid2FaceNodes'));
%     surfaceInfo.nearestNodeInFace2CentroidID(cont,1)=...
%         surfaceInfo.nodesInSurfaceID{cont,:}(idxNearestNode2Centroid,:);
%    
% end

%% Vertices of each face
surfaceInfo.VerticesInFaces=cell(numFaces,1);
% Get nodes IDs of each all the Vertices in each Face
for cont=1:numFaces
    surfaceInfo.VerticesInFaces{cont}=faceEdges(gm,cont)';
end


%% Graph Mesh
% Create figure
% figureCAD=figure('Name','CAD Model','NumberTitle','off','WindowState','maximized','Pointer','crosshair');
% 
% % Graph mesh
% pdemesh(msd,'FaceAlpha',0.8)


%% Test 
%handle.a = axes;
handle.x = nodes(1,:);
handle.y = nodes(2,:);
handle.z = nodes(3,:);


% Setup button to save Data tip
boton.a=figure;
figure

% plot in 3D
handle.p = pdemesh(msd,'FaceAlpha',1,'FaceColor',[0.9,0.9,0.9]);
hold on

%Setup Cursor Mode
handle.dcm=datacursormode;
handle.dcm.Enable = 'on';
handle.dcm.SnaptoDataVertex = 'on';
handle.dcm.DisplayStyle = 'window';

% Clear process variables 
clear unitConvertionConstant_mm2m


% % Plot centroid of faces
% % figure(2)
% plot3(  surfaceInfo.centroidFaces(:,1),...
%         surfaceInfo.centroidFaces(:,2),...
%         surfaceInfo.centroidFaces(:,3),...
%         'r*','MarkerSize',15)
%     
% % Plot nearest node to the centroid
% % figure(2)
% figure(2)
% plot3(nodes(1,surfaceInfo.nearestNodeInFace2CentroidID)',...
%     nodes(2,surfaceInfo.nearestNodeInFace2CentroidID)',...
%     nodes(3,surfaceInfo.nearestNodeInFace2CentroidID)',...
%     'm*','MarkerSize',15)

% add callback when point on plot object 'handle.p' is selected
% 'click' is the callback function being called when user clicks a point on plot
boton.a.ButtonDownFcn = {@click,handle,gm,msh,surfaceInfo,edgeLenght,nodes};
%handle.p.ButtonDownFcn= {@click,handle,gm,msh,nodes};


%Callback to define the click
function click(~,~,handle,gm,msh,surfaceInfo,edgeLenght,nodes)
    
    % Get info from Data tip
    cursorInfo=getCursorInfo(handle.dcm);
    % Get position from Data tip
    userSelectedNode=cursorInfo.Position';
    % Get ID from user selected node
    userSelectedNodeID=findNodes(msh,'nearest',userSelectedNode);
    
    % Display ID of the user selected node
    disp(userSelectedNodeID)
    % Select figure to plot
    figure(2);
    %Plot Node
    plot3(  userSelectedNode(1,1),...
            userSelectedNode(2,1),...
            userSelectedNode(3,1),...
            'r*','MarkerSize',20);
    % Save node in CSV file
    writematrix(userSelectedNodeID,'listSelectedNodesID.csv','WriteMode','append','Delimiter','comma');

    % Get all the reference nodes
    listSelectedNodesID=readmatrix('listSelectedNodesID.csv');
    % If the quantity of reference nodes is bigger than one a trajectory can be plotted
    if(size(listSelectedNodesID,1)>1)
        % Get the middle node in surface
        nodesTrajectoryInSurfaceID = getSurfacePath(gm,msh,surfaceInfo,edgeLenght,nodes,listSelectedNodesID');

        % If the quantity of reference nodes is bigger than two the fist node is elimineted to avoid
        % node repetition
        if size(listSelectedNodesID,1)>2
            nodesTrajectoryInSurfaceID(1)=[];
        end
        % The nodes in the surface path are saved in a CSV file
        writematrix(nodesTrajectoryInSurfaceID','nodesTrajectoryInSurfaceID.csv','WriteMode','append','Delimiter','comma');
        % The newly obtain nodes are plotted
        plot3(...
                nodes(1,nodesTrajectoryInSurfaceID),...
                nodes(2,nodesTrajectoryInSurfaceID),...
                nodes(3,nodesTrajectoryInSurfaceID),...
                '-*k','MarkerSize',15);
    end

end



 



% It could be that the mesh can be graphed and the user selects the nodes it wants in the trajectory