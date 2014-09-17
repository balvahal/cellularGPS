function [] = cellularGPS_segmentDataset(database, rawDataPath, segmentDataPath, channel)
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
            parfor k=1:length(files)
                timepoint = database.timepoint(files(k));
                IM = imread(fullfile(rawDataPath, database.filename{files(k)}));
                IM = imbackground(IM, 10, 100);
                [Objects, Centroids] = cellularGPS_identifyPrimaryObjectsGeneral(IM, 'MinimumThreshold', 0.05);
                centroidNumber(k) = size(Centroids,1);
                centroidTable{k}(1:centroidNumber(k),1:2) = Centroids;
                centroidTable{k}(1:centroidNumber(k),3) = timepoint;
                outputFilename = regexprep(database.filename(files(k)), '\.TIFf', '_segment.TIF', 'ignorecase');
                imwrite(Objects, fullfile(segmentDataPath, outputFilename{1}), 'tif');
            end
            allCentroids = zeros(sum(centroidNumber),3);
            counter = 1;
            for k=1:length(files)
                allCentroids(counter:(counter+centroidNumber(k)-1),:) = centroidTable{k}(1:centroidNumber(k),:);
                counter = counter + centroidNumber(k);
            end
            allCentroids = array2table(allCentroids, 'VariableNames', {'centroid_row', 'centroid_col', 'timepoint'});
            writetable(allCentroids, fullfile(segmentDataPath, sprintf('%s_s%d_w%d%s_centroidsTable.txt', selectedGroup, selectedPosition, database.channel_number(k), channel)), 'Delimiter', '\t');
        end
    end
    
toc
end