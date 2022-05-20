function listVectors = calculateVectorBetween2Nodes(nodes,nodeList1ID,nodeList2ID)
    %CALCULATEVECTORBETWEEN2NODES Calculates vectors between two arrays of points
    %{
        Input:
            nodes:          List that connects NodeID and its cartitioan coordinates.
            nodeList1ID:    First list of points.
            nodeList2ID:    Second list of points.
        Output:
            listVectors:    Result of the substractions.
    %}
    % Substraction of the two list of points
    listVectors=nodes(:,nodeList2ID)-nodes(:,nodeList1ID);
end

