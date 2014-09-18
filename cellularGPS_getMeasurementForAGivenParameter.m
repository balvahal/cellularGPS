function [myMeasurements] = cellularGPS_getMeasurementForAGivenParameter(measurementName,moviePath,centroidMegaTable,channelName)
switch lower(measurementName)
    case 'meanintensity'
        measFun = @cellularGPSMeasurement_meanIntensity;
    case 'totalintensity'
        measFun = @cellularGPSMeasurement_totalIntensity;
    otherwise
        warning('cGPS:getMeas','Unknown measurement parameter or type, ''%s'', was found in measurement profile.',measurementName);
        myMeasurements = zeros(height(centroidMegaTable,1));
        return
end
myMeasurements = centroidFun(measFun,moviePath,centroidMegaTable,channelName);
end

function [myMeasurements] = centroidFun(measFun,moviePath,centroidMegaTable,channelName)
myMeasurements = cell(numberOfPositions,1);
database = readtable(fullfile(moviePath,'smda_database.txt'));
myFilenames
myFilenamesIndices = cell(size(myFilenames));
    indStart = 1;
    indEnd = 2;
parfor i = 1:length(myFilenames)
    filename2 = regexprep(myFilenames(i),'');

    IM = imread(fullfile(moviePath,'RAW_DATA',myFilenames(i)));
    ISeg = imread(fullfile(moviePath,'SEGMENT_DATA','segmentation_images',filename2));
    
    myMeasurements{i} = measFun(IM,centriodMegaTable(indStart:indEnd),ISeg); %#ok<PFBNS>
end
myMeasurements = vertcat(myMeasurements{:});
end