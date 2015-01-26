%% cellularGPSMeasurement_fromCentroid
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
function [] = cellularGPSMeasurement_fromCentroid(moviePath)
%% Verify the path is valid
%
if ~isdir(moviePath)
    error('cGPS_mFC:badPath1','The ''moviePath'' does not exist');
end
if ~isdir(fullfile(moviePath,'SEGMENT_DATA'))
    error('cGPS_mFC:badPath2','The centroid data could not be located. Has it been created yet? Make sure the folder structure within ''moviePath'' is correct.');
end
if ~isdir(fullfile(moviePath,'CENTROID_DATA'))
    mkdir(fullfile(moviePath,'CENTROID_DATA'));
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
master_smda_database = readtable(fullfile(moviePath,'smda_database.txt'),'Delimiter','\t');
cenTable = readtable(fullfile(moviePath,'SEGMENT_DATA','segmentation.txt'),'Delimiter','\t');
cenFilenameTable = readtable(fullfile(moviePath,'SEGMENT_DATA','segmentation_filename.txt'),'Delimiter','\t');
toc
%%%
%
myPosNumber = transpose(unique(master_smda_database.position_number));
for v = myPosNumber
    smda_database = master_smda_database(master_smda_database.position_number == v,:);
    %%%
    % find the channel Name and corresponding numbers
    channelNumber = unique(smda_database.channel_number);
    channelName = cell(size(channelNumber));
    for i = 1:length(channelNumber) %floop 1
        myind = find(smda_database.channel_number == channelNumber(i),1,'first');
        channelName{i} = smda_database.channel_name{myind};
    end
    %%%
    % create arrays for the salient image file metadata
    myPosNumberCenFilename = cenFilenameTable.position_number;
    myTimepointCenFilename = cenFilenameTable.timepoint;
    SegFilesLogical = false(height(smda_database),1);
    myPosNumber = smda_database.position_number;
    myTimepoint = smda_database.timepoint;
    for i = 1:length(myPosNumberCenFilename)
        SegFilesLogical = SegFilesLogical | (myPosNumber == myPosNumberCenFilename(i) & myTimepoint == myTimepointCenFilename(i));
    end
    smda_database = smda_database(SegFilesLogical,:);
    %%%
    % only take measurements from images that have segmentation files
    
    %%%
    %
    myFileName = smda_database.filename;
    myChanNumber = smda_database.channel_number;
    myChanName = smda_database.channel_name;
    myPosNumber = smda_database.position_number;
    myTimepoint = smda_database.timepoint;
    tic
    fprintf('taking intensity measurements\n');
    %% Determine which measurement to take
    % The measurement are specified in a JSON object called
    % |cGPS_measurementProfile.txt|. Look at the list of measurement types for
    % more information. Each measurment type is found for every settings.
    measurementParameter = cellularGPSMeasurement_fromCentroid_intensityParameter(moviePath);
    %% measurments for intensity parameters
    % create a container to hold the intensity measurement information
    fileNum = height(smda_database);
    myMeasurement = cell(fileNum,1);
    myMeasurementName = cell(fileNum,1);
    parfor i = 1:fileNum
        fprintf('%s\n',myFileName{i});
        cenTableLogical = cenTable.timepoint == myTimepoint(i) & cenTable.position_number == myPosNumber(i); %#ok<PFBNS>
        cen2EachFile = cenTable(cenTableLogical,1:2);
        [myMeasurement{i},myMeasurementName{i}] = cellularGPSMeasurement_fromCentroid_getIntensityMeasurement(measurementParameter,moviePath,myFileName{i},cen2EachFile,myChanNumber(i),myChanName{i},myPosNumber(i),myTimepoint(i));
    end
    %%%
    % rearrange the measurements to reflect the number of positions and
    % timepoints, i.e. collapse the channel, and any other, information.
    myIntensityMeasurement = cell(height(cenFilenameTable),1);
    for i = 1:length(myIntensityMeasurement) %floop 3
        floop3Logical = myPosNumber == myPosNumberCenFilename(i) & myTimepoint == myTimepointCenFilename(i);
        floop3Measurement = myMeasurement(floop3Logical);
        floop3MeasurementName = myMeasurementName(floop3Logical);
        floop3Table = table;
        for j = 1:length(floop3Measurement)
            floop3JMeasurement = floop3Measurement{j};
            floop3JMeasurementName = floop3MeasurementName{j};
            floop3JMeasurementName = regexprep(floop3JMeasurementName,'\s','');
            floop3JTable = table(floop3JMeasurement{:},'VariableNames',floop3JMeasurementName);
            floop3Table = horzcat(floop3Table,floop3JTable); %#ok<AGROW>
        end
        myIntensityMeasurement{i} = floop3Table;
    end
    toc
    %% measurements for shape parameters
    %
    tic
    fprintf('taking shape measurements\n');
    measurementParameter = cellularGPSMeasurement_fromCentroid_shapeParameter(moviePath);
    myShapeMeasurement = cell(size(myIntensityMeasurement));
    segfileNum = length(myShapeMeasurement);
    cenFilename = cenFilenameTable.filename;
    parfor i = 1:segfileNum
        fprintf('%s\n',cenFilename{i});
        [data] = cellularGPSMeasurement_fromCentroid_getShapeMeasurement(measurementParameter,moviePath,cenFilename{i});
        myShapeMeasurement{i} = table(data{:},'VariableNames',{measurementParameter.name});
    end
    toc
    %% measurements from meta-data
    % add the relative time information
    tic
    fprintf('taking meta measurements\n');
    firstTimepoint = min(smda_database.matlab_serial_date_number);
    myMetaMeasurement = cell(size(myShapeMeasurement));
    for i = 1:length(myIntensityMeasurement) %floop 4
        floop4Logical = myPosNumber == myPosNumberCenFilename(i) & myTimepoint == myTimepointCenFilename(i);
        floop4Times = smda_database.matlab_serial_date_number(floop4Logical);
        floop4GroupNumber = smda_database.group_number(floop4Logical);
        floop4RelTime = (floop4Times(1) - firstTimepoint)*24*60*60; % convert the units from days to seconds
        myMetaMeasurement{i} = table(repmat(floop4GroupNumber(1),height(myShapeMeasurement{i}),1),repmat(floop4RelTime,height(myShapeMeasurement{i}),1),'VariableNames',{'group_number','relative_time'});
    end
    toc
    %% consolidate all of the centroid information
    %
    tic
    masterIntensityMeasurement = vertcat(myIntensityMeasurement{:});
    masterShapeMeasurement = vertcat(myShapeMeasurement{:});
    masterMetaMeasurement = vertcat(myMetaMeasurement{:});
    masterTable = horzcat(cenTable,masterIntensityMeasurement,masterShapeMeasurement,masterMetaMeasurement);
    toc
    gInd = smda_database.group_number(1);
    writetable(masterTable,fullfile(moviePath,'CENTROID_DATA',sprintf('centroid_measurements_g%d_s%d.txt',gInd,v)), 'Delimiter', '\t');
end
end