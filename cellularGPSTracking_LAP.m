function [winningMatrix, cost] = cellularGPSTracking_LAP(costMatrix, i, LAPmatrix)
validColumns = find(costMatrix(i,:) > -1);
winningMatrix = LAPmatrix;
cost = Inf;
for j=1:length(validColumns)
    tempLAPMatrix = LAPmatrix;
    tempLAPMatrix(i,j) = 1;
    
    tempCostMatrix = costMatrix;
    tempCostMatrix(:,j) = -1;
    
    if(i==size(costMatrix,1))
        competingMatrix = tempLAPMatrix;
        competingCost = sum(tempCostMatrix(competingMatrix));
    else
        [competingMatrix, competingCost] = cellularGPSTracking_LAP(tempCostMatrix, i+1, tempLAPMatrix);
    end
    if(competingCost < cost)
        winningMatrix = competingMatrix;
        cost = competingCost;
    end
end
end