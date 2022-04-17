function listNodesInPathID = getSurfacePath(gm,msh,surfaceInfo,edgeLenght,nodes,listNodesInPathID)
%GETSURFACEPATH Summary of this function goes here
%   Detailed explanation goes here

    %% Function handles
    getMiddleSurfaceNode = @getMiddleSurfaceNode;

    % Node Counter
    cont=1;
    while (cont<size(listNodesInPathID,2))
        % Get the Id of the middle node in the surface
        middleNodeInSurfaceID=getMiddleSurfaceNode(gm,msh,surfaceInfo,edgeLenght,nodes,listNodesInPathID(cont:cont+1));
        %Check if the middle node is a reference node
        isMiddleSurfaceNodeAReferenceNode=...
                middleNodeInSurfaceID==listNodesInPathID(:,cont)...
                ||...
                middleNodeInSurfaceID==listNodesInPathID(:,cont+1);

        % If the middle node is a reference node the counter goes up
        if (isMiddleSurfaceNodeAReferenceNode)
            cont=cont+1;
        % If the middle node is not a reference node the middle node is inserted to the list between
        % the two reference nodes
        elseif(isMiddleSurfaceNodeAReferenceNode==false)
            listNodesInPathID=[ listNodesInPathID(1:cont),...
                                middleNodeInSurfaceID,...
                                listNodesInPathID(cont+1:end)];
        end
    end

end

