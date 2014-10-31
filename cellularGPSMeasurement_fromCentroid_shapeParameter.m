
function [myMeasurement] = cellularGPSMeasurement_fromCentroid_shapeParameter(moviePath)
%%
%
measurementProfile = loadjson(fullfile(moviePath,'cGPS_measurementProfile.txt'));
numberOfParameter = length(measurementProfile.shapeParameters);
myMeasurement(numberOfParameter).name = '';
myMeasurement(numberOfParameter).fun = @rand;

for i = 1:numberOfParameter
    switch lower(measurementProfile.shapeParameters{i})
        case 'area'
            myMeasurement(i).name = measurementProfile.shapeParameters{i};
            myMeasurement(i).fun = cellularGPSMeasurement_area;
        case 'solidity'
            myMeasurement(i).name = measurementProfile.shapeParameters{i};
            myMeasurement(i).fun = cellularGPSMeasurement_solidity;
        otherwise
            error('cGPS:badParam','unspecified parameter: %s',measurementProfile.shapeParameters{i});
    end
end