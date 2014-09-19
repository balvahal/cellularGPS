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
myFilename = smdaDatabase.filename(smdaDatabase.channel_number == channelNumber);
myPositionNumber = smdaDatabase.position_number(smdaDatabase.channel_number == channelNumber);
myTimepoint = smdaDatabase.timepoint(smdaDatabase.channel_number == channelNumber);
centroids4AllFiles = cell(size(myFilename));
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
    outputFilename = regexprep(myFilename{i}, '\.tiff', '_segment.tiff', 'ignorecase');
    imwrite(Objects,fullfile(moviePath,'SEGMENT_DATA','segmentation_images',outputFilename),'tiff');
    centroids4AllFiles{i} = table(centroidTableCell{:}, 'VariableNames', {'centroid_col', 'centroid_row', 'timepoint','position_number'});
end
toc
allCentroids = vertcat(centroids4AllFiles{:});
writetable(allCentroids, fullfile(moviePath,'SEGMENT_DATA','segmentation.txt'), 'Delimiter', '\t');
end