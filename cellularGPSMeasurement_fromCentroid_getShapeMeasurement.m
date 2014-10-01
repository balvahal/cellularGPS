
function [myMeasurement] = cellularGPSMeasurement_fromCentroid_getShapeMeasurement(measurementParameter,moviePath,myFileName)
%%
%
myMeasurement = cell(length(measurementParameter),1);
%%
%
ISeg = imread(fullfile(moviePath,'SEGMENT_DATA','segmentation_images',myFileName));
%%
%
for i = 1:length(measurementParameter)
    myMeasurement{i} = measurementParameter(i).fun(0,0,ISeg);
end
end