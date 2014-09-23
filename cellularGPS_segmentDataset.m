%% cellularGPS_segmentDataset
% Find centroids for cells based upon a nuclear marker or signal.
%
%   [] = cellularGPS_segmentDataset(database, rawDataPath, segmentDataPath, channel)
%
%%% Input
% * smdaDatabase: database table of SuperMDA format.
% * rawDataPath: path to the folder of images.
% * segmentDataPath: output folder for segmented images
% * channel: a string. The name of the channel used for segmentation.
%
%%% Output:
% For each position from the dataset a table of centroid information is
% created. For each image of a particular _channel_, a segmentation file is
% created.
%
%%% Detailed Description
% There is no detailed description.
%
%%% Other Notes
% z-stack information is ignored.
function [] = cellularGPS_segmentDataset(moviePath, channelNumber)
if ~isdir(fullfile(moviePath,'SEGMENT_DATA'))
    mkdir(fullfile(moviePath,'SEGMENT_DATA'));
end
if ~isdir(fullfile(moviePath,'SEGMENT_DATA','segmentation_images'))
    mkdir(fullfile(moviePath,'SEGMENT_DATA','segmentation_images'));
end
if ~isdir(fullfile(moviePath,'PROCESSED_DATA'))
    imagePath = fullfile(moviePath,'RAW_DATA');
else
    imagePath = fullfile(moviePath,'PROCESSED_DATA');
end
smdaDatabase = readtable(fullfile(moviePath,'smda_database.txt'),'Delimiter','\t');
channelName = cell(size(channelNumber));
for i = 1:length(channelNumber) %floop 1
    myind = find(smdaDatabase.channel_number == channelNumber(i),1,'first');
    channelName{i} = smdaDatabase.channel_name{myind};
end
myFilename = smdaDatabase.filename(smdaDatabase.channel_number == channelNumber);
myPositionNumber = smdaDatabase.position_number(smdaDatabase.channel_number == channelNumber);
myTimepoint = smdaDatabase.timepoint(smdaDatabase.channel_number == channelNumber);
centroids4AllFiles = cell(size(myFilename));
%%%
% create a table for the segmentation filenames
segFilename = cell(size(myFilename));
tic
parfor i=1:length(myFilename)
    fprintf('%s\n',myFilename{i});
    IM = imread(fullfile(imagePath,myFilename{i}));
    [Objects, Centroids] = cellularGPS_identifyPrimaryObjectsGeneral(IM, 'MinimumThreshold', 0.05);
    centroidTableCell = cell(1,4);
    centroidTableCell{1} = Centroids(:,1);
    centroidTableCell{2} = Centroids(:,2);
    centroidTableCell{3} = repmat(myTimepoint(i),size(Centroids,1),1);
    centroidTableCell{4} = repmat(myPositionNumber(i),size(Centroids,1),1); 
    segFilename{i} = sprintf('iseg_s%d_t%d.tiff',myPositionNumber(i),myTimepoint(i));
    imwrite(Objects,fullfile(moviePath,'SEGMENT_DATA','segmentation_images',segFilename{i}),'tiff');
    centroids4AllFiles{i} = table(centroidTableCell{:}, 'VariableNames', {'centroid_col', 'centroid_row', 'timepoint','position_number'});
end
toc
allCentroids = vertcat(centroids4AllFiles{:});
writetable(allCentroids, fullfile(moviePath,'SEGMENT_DATA','segmentation.txt'), 'Delimiter', '\t');
segTable = table(segFilename,myTimepoint,myPositionNumber,'VariableNames',{'filename','timepoint','position_number'});
writetable(segTable, fullfile(moviePath,'SEGMENT_DATA','segmentation_filename.txt'), 'Delimiter', '\t');
%% Save a badge to the _moviePath_
%
jsonStrings = {};
n = 1;
jsonStrings{n} = micrographIOT_cellStringArray2json('channel_name',channelName); n = n + 1;
jsonStrings{n} = micrographIOT_array2json('channel_number',channelNumber); n = n + 1;
mydate = datestr(now,31);
jsonStrings{n} = micrographIOT_string2json('date',mydate);
myjson = micrographIOT_jsonStrings2Object(jsonStrings);
fid = fopen(fullfile(moviePath,'BADGE_segmentation.txt'),'w');
if fid == -1
    error('cGPSSD:badfile','Cannot open the file, preventing the export of the segmentation badge.');
end
fprintf(fid,myjson);
fclose(fid);
%%
%
myjson = micrographIOT_autoIndentJson(fullfile(moviePath,'BADGE_segmentation.txt'));
fid = fopen(fullfile(moviePath,'BADGE_segmentation.txt'),'w');
if fid == -1
    error('cGPSSD:badfile','Cannot open the file, preventing the export of the segmentation badge.');
end
fprintf(fid,myjson);
fclose(fid);
end