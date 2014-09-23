%% cellularGPS_measurementFromCentroids
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
%%% Detailed Description=
% There is no detailed description.
%
%%% Other Notes
%
function [] = cellularGPS_measurementFromCentroid(moviePath)
%% Verify the path is valid
%
if ~isdir(moviePath)
    error('cGPS_mFC:badPath1','The ''moviePath'' does not exist');
end
if ~isdir(fullfile(moviePath,'SEGMENT_DATA'))
    error('cGPS_mFC:badPath2','The centroid data could not be located. Has it been created yet? Make sure the folder structure within ''moviePath'' is correct.');
end

%% Initialize variables, allocate memory, and consolidate centroid tables
% Read in the centroids tables and parse the metadata stored in the file
% name.
%
% The positions from the SuperMDA are always independent of the group, so
% the group can be ignored. From the measurement perspective we want to
% find measurement across all settings, so again the position becomes the
% pivot point.
%
% Load the smda_database and centroid table
smda_database = readtable(fullfile(moviePath,'smda_database.txt'),'Delimiter','\t');
cenTable = readtable(fullfile(moviePath,'SEGMENT_DATA','segmentation.txt'),'Delimiter','\t');
%%%
% find the channel Name and corresponding numbers
channelNumber = unique(smda_database.channel_number);
channelName = cell(size(channelNumber));
for i = 1:length(channelNumber) %floop 1
    myind = find(smda_database.channel_number == channelNumber(i),1,'first');
    channelName{i} = smda_database.channel_name{myind};
end
%%%
% create a cell that holds correct set of centroids for each image
cen2EachFile = cell(height(smda_database),1);
for i = 1:height(smda_database) %floop 1
    cenTableLogical = cenTable.timepoint == smda_database.timepoint(i) & cenTable.position_number == smda_database.position_number(i);
    cen2EachFile{i} = cenTable(cenTableLogical,1:2); %the row and column information of each centroid
end
%%%
% create arrays for the salient image file metadata
myFileName = smda_database.filename;
myChanNumber = smda_database.channel_number;
myPosNumber = smda_database.position_number;
myTimepoint = smda_database.timepoint;
%% Determine which measurement to take
% The measurement are specified in a JSON object called
% |cGPS_measurementProfile.txt|. Look at the list of measurement types for
% more information. Each measurment type is found for every settings.
measurementParameter = cellularGPS_measurementFromCentroid_measurementParameter(moviePath);
%%%
% create a container to hold the measurement information
myMeasurement = cell(height(smda_database),length(measurementParameters));
myMeasurementName = cell(height(smda_database),length(measurementParameters));
fileNum = height(smda_database);
parfor i = 1:fileNum
        [myMeasurement{i},myMeasurementName{i}] = cellularGPS_measurementFromCentroid_getMeasurement(measurementParameter,moviePath,myFileName{i},cen2EachFile{i},myChanNumber(i),myPosNumber(i),myTimepoint(i));
end

%% Create a table that holds centroid information and 
%
end

function [] = centroidRelativeTime()

end