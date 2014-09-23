
function [myMeasurement] = cellularGPS_measurementFromCentroid_measurementParameter(moviePath)
%%
%
%%%
% check for the function _loadjson_ from the MATLAB File Exchange
if ~exist('loadjson','file')
    error('smdaITFimport:missLoadJson','The function "loadjson()" is not in the MATLAB path or has not been downloaded from the MATLAB File Exchange. Visit http://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files-in-matlab-octave');
end
measurementProfile = loadjson(fullfile(moviePath,'cGPS_measurementProfile.txt'));