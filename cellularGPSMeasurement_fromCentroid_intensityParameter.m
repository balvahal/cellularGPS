
function [myMeasurement] = cellularGPSMeasurement_fromCentroid_intensityParameter(moviePath)
%%
%
measurementProfile = loadjson(fullfile(moviePath,'cGPS_measurementProfile.txt'));
numberOfParameter = length(measurementProfile.intensityParameters);
myMeasurement(numberOfParameter).name = '';
myMeasurement(numberOfParameter).fun = @rand;

for i = 1:numberOfParameter
    switch lower(measurementProfile.intensityParameters{i})
        case 'centroidnibble'
            myMeasurement(i).name = measurementProfile.intensityParameters{i};
            myMeasurement(i).fun = cellularGPSMeasurement_centroidNibble(measurementProfile.centroidNibble);
        case 'meanintensity'
            myMeasurement(i).name = measurementProfile.intensityParameters{i};
            myMeasurement(i).fun = cellularGPSMeasurement_meanIntensity;
        case 'totalintensity'
            myMeasurement(i).name = measurementProfile.intensityParameters{i};
            myMeasurement(i).fun = cellularGPSMeasurement_totalIntensity;
        otherwise
            error('cGPS:badParam','unspecified parameter: %s',measurementProfile.parameters{i});
    end
end