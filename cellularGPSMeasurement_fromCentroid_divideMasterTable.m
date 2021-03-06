function [] = cellularGPSMeasurement_fromCentroid_divideMasterTable(moviePath)
masterTable = readtable(fullfile(moviePath,'centroid_measurements.txt'),'Delimiter','\t');
if ~isdir(fullfile(moviePath,'CENTROID_DATA'))
    mkdir(fullfile(moviePath,'CENTROID_DATA'));
end
uniqueGroups = unique(masterTable.group_number);
for i=1:length(uniqueGroups)
    uniquePositions = unique(masterTable.position_number(masterTable.group_number == uniqueGroups(i)));
    for j=1:length(uniquePositions)
        subTable = masterTable(masterTable.group_number == uniqueGroups(i) & masterTable.position_number == uniquePositions(j),:);
        tableName = sprintf('centroid_measurements_g%d_s%d.txt', uniqueGroups(i), uniquePositions(j));
        writetable(subTable, fullfile(moviePath,'CENTROID_DATA',tableName), 'Delimiter', '\t');
    end
end
end