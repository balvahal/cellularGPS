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
myDirectory = dir(fullfile(moviePath,'SEGMENT_DATA','tables'));
filenamesInDirectory = {myDirectory(:).name};
centroidsTableInDirectoryLogical = cellfun(@(x) ~isempty(regexp(x,'centroidsTable.txt$','ONCE')),filenamesInDirectory);
centroidsTableFilenames = filenamesInDirectory(centroidsTableInDirectoryLogical);
centroidsTables = cell(length(centroidsTableFilenames));
for i = 1:length(centroidsTables) %floop 1
    centroidsTables{i} = readtable(fullfile(moviePath,'SEGMENT_DATA','tables',centroidsTableFilenames{i}),'Delimiter','\t');
    %%%
    % The centroidsTable metadata is parsed from the filename using named
    % tokens and regular expressions.
    floop1p1 = '(?<position>\d+)';
    floop1expr = ['.*_s' floop1p1 '.*'];
    floop1GPS = regexp(centroidsTableFilenames{i},floop1expr,'names');
    floop1GPS.position = str2double(floop1GPS.position);
    %%%
    % The metadata is converted into a tabular format and appeneded to the
    % centroid data.
    floop1numberOfCentroids = height(centroidsTables{i});
    floop1table = table(repmat({floop1GPS.group},floop1numberOfCentroids,1),repmat(floop1GPS.position,floop1numberOfCentroids,1),repmat(floop1GPS.settings,floop1numberOfCentroids,1),'VariableNames',{'group_label','position_number','settings_number'});
    centroidsTables{i} = horzcat(centroidsTables{i},floop1table);
end
%%%
% The centroidsTables were stored as individual files for each position,
% which is inconvenient from a programming perspective. Therefore, all this
% data is consolidated into one large "MEGA" table.
centroidMegaTable = centroidsTables;
%% Determine which measurements to take
% The measurements are specified in a JSON object called
% |cGPS_measurementsProfile.txt|. Look at the list of measurement types for
% more information. Each measurment type is found for every settings.
%%
% check for the function _loadjson_ from the MATLAB File Exchange
if ~exist('loadjson','file')
    error('smdaITFimport:missLoadJson','The function "loadjson()" is not in the MATLAB path or has not been downloaded from the MATLAB File Exchange. Visit http://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files-in-matlab-octave');
end
measurementsProfile = loadjson(fullfile(moviePath,'cGPS_measurementsProfile.txt'));
measurementsParameters = measurementsProfile.parameters;
myMeasurements = cell(size(measurementsParameters));
%%%
% find _channelNames_
for i = 1:length(channelNames)
for j = 1:length(myMeasurements)
    myMeasurements{i} = cellularGPS_getMeasurementForAGivenParameter(measurementsParameters{i},moviePath,centroidMegaTable);
end
end
end