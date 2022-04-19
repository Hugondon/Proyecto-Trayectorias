% CAD Interactive Node Selector Script.
% Source:
% https://www.mathworks.com/help/pde/geometry-and-mesh.html?s_tid=CRUX_lftnav
% File format .STL
%% Pre-execution setup
close all
delete listSelectedNodesID.csv nodesTrajectoryInSurfaceID.csv
%% Function Handles
getSurfacePath  =   @getSurfacePath;

%% Create and configure Discrete Geometric Model
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
%{
% Uncomment to plot Discrete Geometry Model
pdegplot(gm);
%}

%Establish new centroid
centroid.position=[0,0,0];

%% Generate Mesh

%Establish maximum and minimum edge lenght( in milimeters)
edgeLenght.Hmax=0.01;
edgeLenght.Hmin=edgeLenght.Hmax;

% Generate a Mesh
msh = generateMesh(msd,'GeometricOrder','linear','Hmax', edgeLenght.Hmax,'Hmin', edgeLenght.Hmin);

%Nodes are extracted (units in meters)
nodes=msh.Nodes;

% Number of Faces in the Discrete Geometry Model
numFaces=gm.NumFaces;

%% Nodes in Surface
% Preallocate memory for the IDs of the nodes in the surface of the mesh
surfaceInfo.nodesInSurfaceID=cell(numFaces,1);

% Get nodes IDs of each face
for cont=1:numFaces
    surfaceInfo.nodesInSurfaceID{cont}=findNodes(msh,'region','Face',cont)';
end

%% Vertices of each face
surfaceInfo.verticesInFaces=cell(numFaces,1);
% Get nodes IDs of each all the Vertices in each Face
for cont=1:numFaces
    surfaceInfo.verticesInFaces{cont}=faceEdges(gm,cont)';
end

%% Nodes Shared between faces

%% Interactive Node Selection
%handle.a = axes;
handle.x = nodes(1,:);
handle.y = nodes(2,:);
handle.z = nodes(3,:);


% Setup button to save Data tip
boton.a=figure;
figure

% Plot Mesh in 3D
handle.p = pdemesh(msd,'FaceAlpha',1,'FaceColor',[0.9,0.9,0.9]);
hold on

%Setup Cursor Mode
handle.dcm=datacursormode;
handle.dcm.Enable = 'on';
handle.dcm.SnaptoDataVertex = 'on';
handle.dcm.DisplayStyle = 'window';

% Clear process variables 
clear unitConvertionConstant_mm2m

% Add callback figure 1 'handle.p' is clicked.
% 'click' is the callback function being called when user clicks on Figure 1
boton.a.ButtonDownFcn = {@click,handle,gm,msh,surfaceInfo,edgeLenght,nodes};


% Callback to Select Node
function click(~,~,handle,gm,msh,surfaceInfo,edgeLenght,nodes)
    
    % Get info from Data tip
    cursorInfo=getCursorInfo(handle.dcm);
    % Get position from Data tip
    userSelectedNode=cursorInfo.Position';
    % Get ID from user selected node
    userSelectedNodeID=findNodes(msh,'nearest',userSelectedNode);
    
    %{ 
    % uncomment to display ID of the user selected node
    disp(userSelectedNodeID)
    %}
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