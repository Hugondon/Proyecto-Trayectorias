function listVectors = calculateVectorBetween2Nodes(nodes,nodeList1ID,nodeList2ID)
%CALCULATEVECTORBETWEEN2NODES Summary of this function goes here
%   Detailed explanation goes here
listVectors=nodes(:,nodeList2ID)-nodes(:,nodeList1ID);
end

