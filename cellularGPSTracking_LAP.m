function [winningMatrix, cost] = cellularGPSTracking_LAP(costMatrix, i, LAPmatrix)
validColumns = find(costMatrix(i,:) > -1);
winningMatrix = LAPmatrix;
cost = Inf;
for j=1:length(validColumns)
    tempLAPMatrix = LAPmatrix;
    tempLAPMatrix(i,validColumns(j)) = 1;
    if(i==50)
        %fprintf('%d\t%d\n', i, length(validColumns));
        competingMatrix = tempLAPMatrix;
        competingCost = sum(costMatrix(logical(competingMatrix)));
    else
        tempCostMatrix = costMatrix;
        tempCostMatrix((i+1):end,validColumns(j)) = -1;
        [competingMatrix, competingCost] = cellularGPSTracking_LAP(tempCostMatrix, i+1, tempLAPMatrix);
    end
    if(competingCost < cost)
        winningMatrix = competingMatrix;
        cost = competingCost;
    end
end
end