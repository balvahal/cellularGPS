%% Load centroids
%
[mfilepath,~,~] = fileparts(mfilename('fullpath')); %finds the path to this script
cenTable = readtable(fullfile(mfilepath,'centroid_measurements.txt'),'Delimiter','\t');
%% parse apart the centroid table
% currently this is not necessaryNum = unique(cenTable.position_number);
