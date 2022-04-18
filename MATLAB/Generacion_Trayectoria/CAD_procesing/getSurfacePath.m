function listNodesInPathID = getSurfacePath(gm,msh,surfaceInfo,edgeLenght,nodes,listNodesInPathID)
% Plans a path in the surface of the mesh using reference points input by the user.

%{
Plans the surface path in using the surface nodes in the mesh.
1-Declares a counter "cont"
2-Enters a while loop
3-Extract two reference nodes from the "listNodesInPathID" variable. It extracts the nodes with 
    the indexes "cont" and "cont+1".
4-Get the middle surface node(MSN) ID using the two reference points and the function 
    "getMiddleSurfaceNode".
5-If the ID of the MSN is one of the reference nodes the counter goes up by 1 and the ID is not
    added to "listNodesInPathID".
6-If the ID of the MSN is not one of the reference nodes the counter stays the same and the 
    ID is added to "listNodesInPathID".
7-The while loop loops until the counter is no longer smaller than the size of "listNodesInPathID",
    which indicates that all the nodes in "listNodesInPathID" are connected to neighbor nodes.

    Inputs:
        gm:                         Discrete Geometric Model.
        msh:                        Mesh obtain from the Discrete Geometric Model.
        surfaceInfo:                Contains important information about the surface, such as
                                    vertices of the discrete geometric model and the nodes of 
                                    each face of the mesh.
        edgeLenght:                 Parameters of minimum and maximum edge lenght on the mesh.
        nodes:                      List of spatial coordinate of the nodes. 
                                    The ID of the node is also column index.
        listNodesInPathID:          List of nodes input by the user to generate a surface path.
    Outputs:
        listNodesInPathID:          List connecting nodes input by the user using surface 
                                    neighbor nodes.
%}


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

