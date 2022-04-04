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
%handle.a = axes;
handle.x = nodes(1,:);
handle.y = nodes(2,:);
handle.z = nodes(3,:);



boton.a=figure;
figure
% plot in 3D
%handle.f = figure;
handle.p = pdemesh(msd,'FaceAlpha',1);
%handle.btn=uibutton(handle.f);
%handle.p.VertexNormalsMode='manual';
%handle.p = pdemesh(msd);


hold on
handle.dcm=datacursormode;
%handle.dcm.Enable = 'off';
handle.dcm.SnaptoDataVertex = 'on';
handle.dcm.DisplayStyle = 'window';
%handle.dt=datatip(handle.p);
%dcm=datacursormode(handle.a);


% add callback when point on plot object 'handle.p' is selected
% 'click' is the callback function being called when user clicks a point on plot

boton.a.ButtonDownFcn = {@click,handle,gm,msh,nodes};
%handle.p.Parent.Parent.KeyPressFcn= {@click,handle,gm,msh,nodes};
%handle.p.Parent.ButtonDownFcn= {@click,handle,gm,msh,nodes};
%handle.p.ButtonDownFcn= {@click,handle,gm,msh,nodes};

%handle.dt.ButtonDownFcn= {@click,handle,gm,msh,nodes};




%Callback to define the click
function click(~,~,handle,gm,msh,nodes)
    
    % Coordinates of the user selected point
    %userSelectedPoint = handle.a.CurrentPoint(1,:)';
    cursorInfo=getCursorInfo(handle.dcm);
    userSelectedPoint=cursorInfo.Position';
%     % Find the nearest Face from the user selected point
%     nearFaceID=nearestFace(gm,userSelectedPoint');
%     % Get nodes from nearest Face from the user selected point 
%     %nodesInFaceID=findNodes(msh,'region','Face',nearFaceID);
%     nodesInFaceID=findNodes(msh,'region','Face',1:gm.NumFaces);
%     
%     % Find the ID of the nearest node from the user selected point
%     nearUserSelectionNodeID=findNodes(msh,'nearest',userSelectedPoint);
%     % Find the nearest node
%     nearUserSelectionNode=nodes(:,nearUserSelectionNodeID);
%     % Get the distance fromthe user selected point to the nearest node
%     radiusSearchSphere=norm(userSelectedPoint-nearUserSelectionNode);
%     %Find the ID of the nodes within the search sphere
%     nodesWithinSearchSphereID=findNodes(msh,'radius',userSelectedPoint,radiusSearchSphere);
%     % Get the ID of the intersection of the nodes within search sphere and the nodes in face
%     nodesInFaceWithinSearchSphereID=intersect(nodesWithinSearchSphereID,nodesInFaceID);
%     %Find the nodes within the search sphere
%     nodesInFaceWithinSearchSphere=nodes(:,nodesInFaceWithinSearchSphereID);
%     %Get the index of the nearest node in face
%     [~,indexNearestNode]=min(norm(userSelectedPoint-nodesInFaceWithinSearchSphere));
%     %Get ID of the nearest node
%     nearestNodeInFaceID=nodesInFaceWithinSearchSphereID(:,indexNearestNode);
    
    
    

    
    
    %Print ID of the neares Face
%     disp(nearFaceID);
    %Plot nodes of the nearest Face
%     plot3(  nodes(1,nodesInFaceID),...
%             nodes(2,nodesInFaceID),...
%             nodes(3,nodesInFaceID),...
%             'r*','MarkerSize',10);

%     disp(nearestNodeInFaceID)
%             %Plot nodes of the nearest Face
%     plot3(  nodes(1,nearestNodeInFaceID),...
%             nodes(2,nearestNodeInFaceID),...
%             nodes(3,nearestNodeInFaceID),...
%             'r*','MarkerSize',10);

    disp(userSelectedPoint)
            %Plot nodes of the nearest Face
            %set(handle.p, 'currentaxes', handle.a);
            figure(2);
            plot3( userSelectedPoint(1,1),...
            userSelectedPoint(2,1),...
            userSelectedPoint(3,1),...
            'r*','MarkerSize',15);
    writematrix(userSelectedPoint,'puntos.csv','WriteMode', 'append','Delimiter','comma');

end



%clear unitConvertionConstant_mm2m
% It could be that the mesh can be graphed and the user selects the nodes it wants in the trajectory