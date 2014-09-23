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
tic
fprintf('reading centroid info\n');
smda_database = readtable(fullfile(moviePath,'smda_database.txt'),'Delimiter','\t');
cenTable = readtable(fullfile(moviePath,'SEGMENT_DATA','segmentation.txt'),'Delimiter','\t');
toc
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
tic
fprintf('expanding centroids for measurement\n');
cen2EachFile = cell(height(smda_database),1);
for i = 1:height(smda_database) %floop 2
    cenTableLogical = cenTable.timepoint == smda_database.timepoint(i) & cenTable.position_number == smda_database.position_number(i);
    cen2EachFile{i} = cenTable(cenTableLogical,1:2); %the row and column information of each centroid
end
toc
%%%
% create arrays for the salient image file metadata
myFileName = smda_database.filename;
myChanNumber = smda_database.channel_number;
myChanName = smda_database.channel_name;
myPosNumber = smda_database.position_number;
myTimepoint = smda_database.timepoint;
tic
fprintf('taking measurements\n');
%% Determine which measurement to take
% The measurement are specified in a JSON object called
% |cGPS_measurementProfile.txt|. Look at the list of measurement types for
% more information. Each measurment type is found for every settings.
measurementParameter = cellularGPS_measurementFromCentroid_intensityParameter(moviePath);
%% measurments for intensity parameters
% create a container to hold the intensity measurement information
fileNum = height(smda_database);
myMeasurement = cell(fileNum,1);
myMeasurementName = cell(fileNum,1);
parfor i = 1:fileNum
        [myMeasurement{i},myMeasurementName{i}] = cellularGPS_measurementFromCentroid_getIntensityMeasurement(measurementParameter,moviePath,myFileName{i},cen2EachFile{i},myChanNumber(i),myChanName{i},myPosNumber(i),myTimepoint(i));
end
%%%
% rearrange the measurements to reflect the number of positions and
% timepoints, i.e. collapse the channel, and any other, information.
cenFilenameTable = readtable(fullfile(moviePath,'SEGMENT_DATA','segmentation_filename.txt'),'Delimiter','\t');
myPosNumberCenFilename = cenFilenameTable.position_number;
myTimepointCenFilename = cenFilenameTable.timepoint;
myIntensityMeasurement = cell(height(cenFilenameTable),1);
for i = 1:length(myIntensityMeasurement) %floop 3
    floop3Logical = myPosNumber == myPosNumberCenFilename(i) & myTimepoint == myTimepointCenFilename(i);
    floop3Measurement = myMeasurement(floop3Logical);
    floop3MeasurementName = myMeasurementName(floop3Logical);
    floop3Table = table;
    for j = 1:length(floop3Measurement)
       floop3JMeasurement = floop3Measurement{j};
       floop3JMeasurementName = floop3MeasurementName{j};
       floop3JTable = table(floop3JMeasurement{:},'VariableNames',floop3JMeasurementName);
       floop3Table = horzcat(floop3Table,floop3JTable); %#ok<AGROW>
    end
    myIntensityMeasurement{i} = floop3Table;
end
%% measurements for shape parameters
%
measurementParameter = cellularGPS_measurementFromCentroid_shapeParameter(moviePath);
myShapeMeasurement = cell(size(myIntensityMeasurement));
segfileNum = length(myShapeMeasurement);
cenFilename = cenFilenameTable.filename;
parfor i = 1:segfileNum
    [data] = cellularGPS_measurementFromCentroid_getShapeMeasurement(measurementParameter,moviePath,cenFilename{i});
    myShapeMeasurement{i} = table(data{:},'VariableNames',{measurementParameter.name});
end
%% measurements from meta-data
% add the relative time information
firstTimepoint = min(smda_database.matlab_serial_date_number);
myMetaMeasurement = cell(size(myShapeMeasurement));
for i = 1:length(myIntensityMeasurement) %floop 4
    floop4Logical = myPosNumber == myPosNumberCenFilename(i) & myTimepoint == myTimepointCenFilename(i);
    floop4Times = smda_database.matlab_serial_date_number(floop4Logical);
    floop4RelTime = (floop4Times(1) - firstTimepoint)*24*60*60; % convert the units from days to seconds
    myMetaMeasurement{i} = table(repmat(floop4RelTime,height(myShapeMeasurement{i}),1),'VariableNames',{'relative_time'});
end
%% consolidate all of the centroid information
%
masterIntensityMeasurement = vertcat(myIntensityMeasurement{:});
masterShapeMeasurement = vertcat(myShapeMeasurement{:});
masterMetaMeasurement = vertcat(myMetaMeasurement{:});
masterTable = horzcat(cenTable,masterIntensityMeasurement,masterShapeMeasurement,masterMetaMeasurement);
toc
writetable(masterTable,fullfile(moviePath,'centroid_measurements.txt'), 'Delimiter', '\t');
end