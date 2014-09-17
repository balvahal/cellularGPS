function [Centroids] = table2centroids(matrixData, varargin)
p = inputParser;
p.addRequired('matrixData', @istable);
addOptional(p,'maxrows', size(matrixData,1), @isnumeric);
p.parse(matrixData, varargin{:});

maxrows = p.Results.maxrows;
Centroids = CentroidTimeseries(max(matrixData{:,3}), maxrows);

uniqueTimepoints = unique(matrixData{:,3});
for i=1:length(uniqueTimepoints)
    subMatrix = matrixData{matrixData{:,3} == uniqueTimepoints(i),1:2};
    Centroids.insertCentroids(uniqueTimepoints(i), subMatrix);
end

end