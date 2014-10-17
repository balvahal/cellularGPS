function [Centroids] = cellularGPS_table2centroids(matrixData, varargin)
p = inputParser;
p.addRequired('matrixData', @istable);
addOptional(p,'maxrows', size(matrixData,1), @isnumeric);
p.parse(matrixData, varargin{:});

maxrows = p.Results.maxrows;
Centroids = CentroidTimeseries(max(matrixData.timepoint), maxrows);

uniqueTimepoints = unique(matrixData.timepoint);
[~,indexes] = ismember({'centroid_col', 'centroid_row'}, matrixData.Properties.VariableNames);
if(sum(indexes > 0) < 2)
    fprintf('The table does not contain centroid_col and centroid_row fields. Centroids will not be allocated\n');
    return;
end
for i=1:length(uniqueTimepoints)
    subMatrix = matrixData{matrixData.timepoint == uniqueTimepoints(i),indexes};
    Centroids.insertCentroids(uniqueTimepoints(i), subMatrix);
end

end