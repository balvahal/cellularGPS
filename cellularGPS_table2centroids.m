function [Centroids] = cellularGPS_table2centroids(matrixData, varargin)
p = inputParser;
p.addRequired('matrixData', @istable);
addOptional(p,'maxrows', size(matrixData,1), @isnumeric);
p.parse(matrixData, varargin{:});

maxrows = p.Results.maxrows;
Centroids = CentroidTimeseries(max(matrixData.timepoint), maxrows);

uniqueTimepoints = unique(matrixData.timepoint);
for i=1:length(uniqueTimepoints)
    subMatrix = matrixData{matrixData.timepoint == uniqueTimepoints(i),1:2};
    Centroids.insertCentroids(uniqueTimepoints(i), subMatrix);
end

end