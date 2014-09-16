function [] = cellularGPS_segmentDataset(database, rawDataPath, segmentDataPath, channel)
    database = database(strcmp(database.channel_name, channel),:);
    progressCounter = 10;
    for i=1:size(database,1);
        if(i/size(database,1) * 100 >= progressCounter)
            fprintf('%d ',progressCounter);
            progressCounter = progressCounter + 10;
        end
        IM = imread(fullfile(rawDataPath, database.filename{i}));
        IM = imbackground(IM, 10, 100);
        Objects = cellularGPS_identifyPrimaryObjectsGeneral(IM, 'MinimumThreshold', 15);
        outputFilename = regexprep(database.filename(i), '\.TIFf', '_segment.TIF', 'ignorecase');
        imwrite(Objects, fullfile(segmentDataPath, outputFilename{1}), 'tif');
    end
    fprintf('\n');
end