%% cellularGPS_measurementsFromCentroids
% Obtain measurments using centroids without worrying about linking.
% Without further processing this data will yield something that resembles
% immunofluorescence with a time component.
%
%   [] = cellularGPS_segmentDataset(database, rawDataPath, segmentDataPath, channel)
%
%%% Input
% * moviePath: there is some structure assumed in storage of data. Images
% acquired from SuperMDA are stored in a folder named _'RAW_DATA'_.
% Segmentation data and the centroid tables are stored within
% folders_'segmentation_images'_ and _'tables'_, which are themselves
% nested in the _'SEGMENT_DATA'_ directory at the same level as
% _'RAW_DATA'_. The database file has to be named _'smda_database.txt'_.
%
%%% Output:
% A file is created that contains centroid and measurment information.
%
%%% Detailed Description
% There is no detailed description.
%
%%% Other Notes
%
function [] = cellularGPS_measurementsFromCentroids(moviePath)
%% Initialize variables and allocate memory
%
dir(fullfile(moviePath,'SEGMENT_DATA','tables'));
centroidMegaTable = repmat({'centroid_row','centroid_col','timepoint'},2^20,1); %anticipating fewer than 1,000,000 centroids
end