function = getNodesSharedByFaces(gm,nodes,surfaceInfo)
%GETNODESSHAREDBYFACES Summary of this function goes here
%   Detailed explanation goes here
    % Get the number of faces
    numFaces=gm.NumFaces;
    % Preallocate memory for the shared nodes
    sharedNodes=cell(numFaces,3);
    
    for contFaces=1:numFaces
        % Number the faces
        sharedNodes{contFaces,1}=contFaces;


        
    end

end

