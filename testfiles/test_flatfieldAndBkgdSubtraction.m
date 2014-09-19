%% import test data into MATLAB workspace
%
[moviePath,~,~] = fileparts(mfilename('fullpath')); %finds the path to this script
cellularGPSFlatfield_flatfieldcorrection(moviePath);
cellularGPSBackground_subtraction(moviePath,'channelNumber',[2,7],'binning',2);
