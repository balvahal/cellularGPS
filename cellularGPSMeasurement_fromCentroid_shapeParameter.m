
function [myMeasurement] = cellularGPSMeasurement_fromCentroid_shapeParameter(moviePath)
%%
%
%%%
% check for the function _loadjson_ from the MATLAB File Exchange
if ~exist('loadjson','file')
    error('smdaITFimport:missLoadJson','The function "loadjson()" is not in the MATLAB path or has not been downloaded from the MATLAB File Exchange. Visit http://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files-in-matlab-octave');
end
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