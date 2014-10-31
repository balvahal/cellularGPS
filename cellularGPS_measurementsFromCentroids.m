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
%%% Detailed Description=
% There is no detailed description.
%
%%% Other Notes
%
function [] = cellularGPS_measurementsFromCentroids(moviePath)
%% Verify the path is valid
%
if ~isdir(moviePath)
    error('cGPS_mFC:badPath1','The ''moviePath'' does not exist');
end
if ~isdir(fullfile(fullfile(moviePath,'SEGMENT_DATA','tables')))
    error('cGPS_mFC:badPath2','The centroid data could not be located. Has it been created yet? Make sure the folder structure within ''moviePath'' is correct.');
end
%% Initialize variables, allocate memory, and consolidate centroid tables
% Read in the centroids tables and parse the metadata stored in the file
% name. These metadata are important for locating the image files to take
% measurements from. One major assumption made here is that there is no
% z-stack data, or, in otherwords, there is only a single image plane. Only
% a single image from a group, position, and settings (GPS) will be
% analyzed. z-stack data must be collapsed into a single image file to be
% analyzed.
%
% The positions from the SuperMDA are always independent of the group, so
% the group can be ignored. From the measurement perspective we want to
% find measurements across all settings, so again the position becomes the
% pivot point.
myDirectory = dir(fullfile(moviePath,'SEGMENT_DATA','tables'));
filenamesInDirectory = {myDirectory(:).name};
centroidsTableInDirectoryLogical = cellfun(@(x) ~isempty(regexp(x,'centroidsTable.txt$','ONCE')),filenamesInDirectory);
centroidsTableFilenames = filenamesInDirectory(centroidsTableInDirectoryLogical);
centroidsTables = cell(length(centroidsTableFilenames),1);
positionArray = zeros(length(centroidsTableFilenames),1);
for i = 1:length(centroidsTables) %floop 1
    centroidsTables{i} = readtable(fullfile(moviePath,'SEGMENT_DATA','tables',centroidsTableFilenames{i}),'Delimiter','\t');
    %%%
    % The centroidsTable metadata is parsed from the filename using named
    % tokens and regular expressions.
    floop1p1 = '(?<position>\d+)';
    floop1expr = ['.*_s' floop1p1 '.*'];
    floop1GPS = regexp(centroidsTableFilenames{i},floop1expr,'names');
    positionArray(i) = str2double(floop1GPS.position);
end
%%%
% Find the all the channel numbers for each position and the channel names.
smdaDatabase = readtable(fullfile(moviePath,'smda_database.txt'),'Delimiter','\t');
channelNumbers = cell(size(positionArray));
for i = 1:length(positionArray)
    channelNumbers{i} = unique(smdaDatabase.channel_number(smdaDatabase.position_number==positionArray(i)));
end
channelNumbersUnique = unique(vertcat(channelNumbers{:}));
channelNames = cell(size(channelNumbersUnique));
for i = 1:length(channelNumbersUnique)
    myind = find(smdaDatabase.channel_number == channelNumbersUnique(i),1,'first');
    channelNames{i} = sprintf('%s_w%d',smdaDatabase.channel_name{myind},channelNumbersUnique(i));
end
%% Determine which measurements to take
% The measurements are specified in a JSON object called
% |cGPS_measurementsProfile.txt|. Look at the list of measurement types for
% more information. Each measurment type is found for every settings.
measurementsProfile = loadjson(fullfile(moviePath,'cGPS_measurementsProfile.txt'));
measurementsParameters = measurementsProfile.parameters;
numberOfGPS = sum(cellfun(@numel,channelNumbers));
measurement = cell(numberOfGPS*length(measurementsParameters),1);
measurementName = cell(size(measurement));
%%%
%
measCounter = 0;
for i = 1:length(measurementsParameters)
    for j = 1:length(positionArray)
        for k = 1:length(channelNumbers{j})
            measCounter = measCounter + 1;
            measurement{measCounter} = cellularGPS_getMeasurementForAGivenParameter(measurementsParameters{i},moviePath,centroidsTables{j},channelNumbers{j}(k));
            measurementName{measCounter} = sprintf('%s_%s',measurementsParameters{i},channelNames{channelNumbers{j}(k)});
        end
    end
end
end