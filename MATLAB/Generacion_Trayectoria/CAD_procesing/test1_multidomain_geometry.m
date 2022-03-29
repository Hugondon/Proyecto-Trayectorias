% Source:
% https://www.mathworks.com/help/pde/geometry-and-mesh.html?s_tid=CRUX_lftnav
% File format .STL
%% Function Handles


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
centroid=mean(gm.Vertices,1);

% Align origin an centroid from the Geometric model
gm=translate(gm,-1*centroid);

%Establish new centroid
centroid=[0,0,0];

%% Generate Mesh

% Generate a Mesh
msh = generateMesh(msd,'GeometricOrder','linear','Hmax', 0.01);

%Nodes are extracted (units m)
nodes=msh.Nodes;

% Number of Faces in the DiscreteGeometry
numFaces=gm.NumFaces;

% Get the ID of the nodes in the surface of the mesh
nodesInSurfaceID=findNodes(msh,'region','Face',1:numFaces);

%% Graph Mesh
% Create figure
% figureCAD=figure('Name','CAD Model','NumberTitle','off','WindowState','maximized','Pointer','crosshair');
% 
% % Graph mesh
% pdemesh(msd,'FaceAlpha',0.8)


%% Test 
handle.a = axes;
handle.x = nodes(1,:);
handle.y = nodes(2,:);
handle.z = nodes(3,:);
% plot in 3D
%handle.p = pdemesh(msd,'FaceAlpha',0.8);
handle.p = pdemesh(msd);

hold on
% handle.dcm=datacursormode;
% handle.dcm.Enable = 'on';

%handle.dt=datatip(handle.p);

%dcm=datacursormode(handle.a);


% add callback when point on plot object 'handle.p' is selected
% 'click' is the callback function being called when user clicks a point on plot
handle.p.ButtonDownFcn= {@click,handle,gm,msh,nodes};



% definition of click
function click(obj,eventData,handle,gm,msh,nodes)
    % coordinates of the current selected point
    userSelectedPoint = handle.a.CurrentPoint(1,:);
    %dataTip=getCursorInfo(handle.dcm);
    %dataTip=dcm.Content;
    %dataTip=[handle.dt.X,handle.dt.Y,handle.dt.Z];
    %dataTip2=handle.p.
    %disp(dataTip);
    nearUserSelectionNodeID=findNodes(msh,'nearest',userSelectedPoint');
    
    
     nearFaceID=nearestFace(gm,userSelectedPoint);
%     nearFaceNodesID=findNodes(msh,'region','Face',nearFaceID);
%     
     
    nodesInFaceID=findNodes(msh,'region','Face',nearFaceID);
    nearUserSelectionNodeID =intersect(nodesInFaceID,nearUserSelectionNodeID);
    nearUserSelectionNode=nodes(:,nearUserSelectionNodeID);
    
        disp(nearFaceID);
     plot3(  nodes(1,nodesInFaceID),...
                         nodes(2,nodesInFaceID),...
                         nodes(3,nodesInFaceID),...
                         'r*','MarkerSize',10);
%      plot3(  nearUserSelectionNode(1,1),...
%                          nearUserSelectionNode(2,1),...
%                          nearUserSelectionNode(3,1),...
%                          'r*','MarkerSize',10);
    writematrix(nearUserSelectionNodeID,'puntos.csv','WriteMode', 'append','Delimiter','comma');

end



%clear unitConvertionConstant_mm2m
% It could be that the mesh can be graphed and the user selects the nodes it wants in the trajectory