[mfilepath,~,~] = fileparts(mfilename('fullpath')); %finds the path to this script
trackman = cellularGPSTrackingManual_object(mfilepath);