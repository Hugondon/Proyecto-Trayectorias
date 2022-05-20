function unitVector = unitVectorOfSum(listVectors)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
sumVectors=sum(listVectors,2);
unitVector=sumVectors/vecnorm(sumVectors);
end

