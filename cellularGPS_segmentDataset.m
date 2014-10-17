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
function [] = cellularGPS_segmentDataset(moviePath, channel_number)
if ~isdir(fullfile(moviePath,'SEGMENT_DATA','tables'))
    mkdir(fullfile(moviePath,'SEGMENT_DATA','tables'));
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
smdaDatabase = smdaDatabase(smdaDatabase.channel_number == channel_number,:);
uniquePosition = unique(smdaDatabase.position_number);
timepointsAtPosition = cell(size(uniquePosition));
for i=1:length(uniquePosition)
    timepointsAtPosition{i} = unique(smdaDatabase.timepoint(smdaDatabase.position_number == uniquePosition(i)));
end
tic
for i=1:length(uniquePosition);
fprintf('Analyzing position %d\n', uniquePosition(i));
    for j=1:length(timepointsAtPosition{i})
        s = uniquePosition(j);
        t = timepointsAtPosition{i}(j);
        filenameIndex = find(smdaDatabase.position_number == s & smdaDatabase.timepoint == t);
        filename = smdaDatabase.filename(filenameIndex(1));
        centroidTable = zeros(2^8,3);
            IM = imread(fullfile(imagePath, smdaDatabase.filename{files(k)}));
            IM = imbackground(IM, 10, 100);
            [Objects, Centroids] = cellularGPS_identifyPrimaryObjectsGeneral(IM, 'MinimumThreshold', 0.01);
            centroidNumber(k) = size(Centroids,1);
            centroidTable{k}(1:centroidNumber(k),1:2) = Centroids;
            centroidTable{k}(1:centroidNumber(k),3) = timepoint;
            outputFilename = regexprep(smdaDatabase.filename(files(k)), '\.tiff', '_segment.tiff', 'ignorecase');
            imwrite(Objects, fullfile(segmentDataPath,'segmentation_images',outputFilename{1}), 'tif');
        allCentroids = zeros(sum(centroidNumber),3);
        numberOfCentroidsCounter = 1;
        for k=1:length(files)
            allCentroids(numberOfCentroidsCounter:(numberOfCentroidsCounter+centroidNumber(k)-1),:) = centroidTable{k}(1:centroidNumber(k),:);
            numberOfCentroidsCounter = numberOfCentroidsCounter + centroidNumber(k);
        end
        allCentroids = array2table(allCentroids, 'VariableNames', {'centroid_col', 'centroid_row', 'timepoint'});
        tableFilename = sprintf('%s_s%d_w%d%s_centroidsTable.txt', selectedGroup, selectedPosition, smdaDatabase.channel_number(k), channel);
        writetable(allCentroids, fullfile(segmentDataPath,'tables',tableFilename), 'Delimiter', '\t');
    end
end
toc
end