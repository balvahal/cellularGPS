
function [myMeasurement] = cellularGPS_getMeasurementForAGivenParameter(measurementName,moviePath,myFileName,centroidTable,myChanNumber,myPosNumber,myTimepoint)
%%
%
switch lower(measurementName)
    case 'centroidnibble'
        measFun = @cellularGPSMeasurement_centroidNibble;
    case 'meanintensity'
        measFun = @cellularGPSMeasurement_meanIntensity;
    case 'totalintensity'
        measFun = @cellularGPSMeasurement_totalIntensity;
    otherwise
        warning('cGPS:getMeas','Unknown measurement parameter or type, ''%s'', was found in measurement profile.',measurementName);
        myMeasurement = zeros(height(centroidTable,1));
        return
end
%%
%
if ~isdir(fullfile(moviePath,'PROCESSED_DATA'))
    imagePath = fullfile(moviePath,'RAW_DATA');
else
    imagePath = fullfile(moviePath,'PROCESSED_DATA');
end
IM = imread(fullfile(imagePath,myFileName));
myFileNameSegment = regexprep(myFileName,'.tiff$','_segment.tiff');
ISeg = imread(fullfile(moviePath,'SEGMENT_DATA','segmentation_images',myFileNameSegment));
%%%
%
myMeasurement = measFun(IM,centriodMegaTable(indStart:indEnd),ISeg);
end