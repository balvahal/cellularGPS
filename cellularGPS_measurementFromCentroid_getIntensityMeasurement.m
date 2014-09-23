
function [myMeasurement,myMeasurementName] = cellularGPS_measurementFromCentroid_getIntensityMeasurement(measurementParameter,moviePath,myFileName,cen2EachFile,myChanNumber,myChanName,myPosNumber,myTimepoint)
%%
%
myMeasurement = cell(length(measurementParameter),1);
myMeasurementName = cell(length(measurementParameter),1);
%%
%
if ~isdir(fullfile(moviePath,'PROCESSED_DATA'))
    imagePath = fullfile(moviePath,'RAW_DATA');
else
    imagePath = fullfile(moviePath,'PROCESSED_DATA');
end
IM = imread(fullfile(imagePath,myFileName));
myFileNameSegment = sprintf('iseg_s%d_t%d.tiff',myPosNumber,myTimepoint);
ISeg = imread(fullfile(moviePath,'SEGMENT_DATA','segmentation_images',myFileNameSegment));
%%
%
for i = 1:length(measurementParameter)
    myMeasurement{i} = measurementParameter(i).fun(IM,cen2EachFile,ISeg);
    myMeasurementName{i} = sprintf('%s_w%d%s',measurementParameter(i).name,myChanNumber,myChanName);
end
end