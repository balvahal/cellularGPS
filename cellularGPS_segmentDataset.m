%% cellularGPS_segmentDataset
%
%   [] = cellularGPS_segmentDataset(database, rawDataPath, segmentDataPath, channel)
%
%%% Input
% * database: database table of SuperMDA format.
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
%
function [] = cellularGPS_segmentDataset(database, rawDataPath, segmentDataPath, channel)
if ~isdir(fullfile(segmentDataPath,'tables'))
    mkdir(fullfile(segmentDataPath,'tables'));
end
if ~isdir(fullfile(segmentDataPath,'segmentation_images'))
    mkdir(fullfile(segmentDataPath,'segmentation_images'));
end

tic
database = database(strcmp(database.channel_name, channel),:);
uniqueGroups = unique(database.group_label);
for i=1:length(uniqueGroups);
    selectedGroup = uniqueGroups{i};
    uniquePositions = unique(database.position_number(strcmp(database.group_label, selectedGroup)));
    for j=1:length(uniquePositions)
        selectedPosition = uniquePositions(j);
        fprintf('Analyzing position %d\n', selectedPosition);
        files = find(strcmp(database.group_label, selectedGroup) & database.position_number == selectedPosition);
        centroidTable = repmat({zeros(500,3)},length(files),1);
        centroidNumber = zeros(length(files),1);
        parfor k=1:length(files) %#ok<PFUIX>
            timepoint = database.timepoint(files(k)); %#ok<PFBNS>
            IM = imread(fullfile(rawDataPath, database.filename{files(k)}));
            IM = imbackground(IM, 10, 100);
            [Objects, Centroids] = cellularGPS_identifyPrimaryObjectsGeneral(IM, 'MinimumThreshold', 0.05);
            centroidNumber(k) = size(Centroids,1);
            centroidTable{k}(1:centroidNumber(k),1:2) = Centroids;
            centroidTable{k}(1:centroidNumber(k),3) = timepoint;
            outputFilename = regexprep(database.filename(files(k)), '\.TIFf', '_segment.TIF', 'ignorecase');
            imwrite(Objects, fullfile(segmentDataPath,'segmentation_images',outputFilename{1}), 'tif');
        end
        allCentroids = zeros(sum(centroidNumber),3);
        counter = 1;
        for k=1:length(files)
            allCentroids(counter:(counter+centroidNumber(k)-1),:) = centroidTable{k}(1:centroidNumber(k),:);
            counter = counter + centroidNumber(k);
        end
        allCentroids = array2table(allCentroids, 'VariableNames', {'centroid_row', 'centroid_col', 'timepoint'});
        tableFilename = sprintf('%s_s%d_w%d%s_centroidsTable.txt', selectedGroup, selectedPosition, database.channel_number(k), channel);
        writetable(allCentroids, fullfile(segmentDataPath,'tables',tableFilename), 'Delimiter', '\t');
    end
end
toc
end