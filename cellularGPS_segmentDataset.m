function [] = cellularGPS_segmentDataset(database, rawDataPath, segmentDataPath, channel)
    database = database(strcmp(database.channel_name, channel));
    for i=1:size(database,1);
        IM = imread(fullfile(rawDataPath, database.filename(i)));
        IM = imbackground(IM, 10, 100);
        Objects = cellularGPS_identifyPrimaryObjectsGeneral(IM);
        outputFilename = regexprep(database.filename(i), '\.TIF', '_segment.TIF', 'ignorecase');
        imwrite(logical(Objects), fullfile(segmentDataPath, outputFilename), 'tif');
    end
end