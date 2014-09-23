
function [myMeasurement] = cellularGPS_measurementFromCentroid_intensityParameter(moviePath)
%%
%
%%%
% check for the function _loadjson_ from the MATLAB File Exchange
if ~exist('loadjson','file')
    error('smdaITFimport:missLoadJson','The function "loadjson()" is not in the MATLAB path or has not been downloaded from the MATLAB File Exchange. Visit http://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files-in-matlab-octave');
end
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