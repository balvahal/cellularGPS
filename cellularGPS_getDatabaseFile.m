%% cellularGPS_measurementsFromCentroids
% Obtain measurments using centroids without worrying about linking.
% Without further processing this data will yield something that resembles
% immunofluorescence with a time component.
%
%   filename = cellularGPS_getDatabaseFile(database, group, channel, position, timepoint)
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
function filename = cellularGPS_getDatabaseFile(database, group, channel, position, timepoint)
fileIndex = strcmp(database.channel_name, channel) & database.position_number == position & database.timepoint == timepoint & strcmp(database.group_label, group);

if(sum(fileIndex) > 0)
    filename = database.filename{fileIndex};
else
    filename = [];
end