[mfilepath,~,~] = fileparts(mfilename('fullpath')); %finds the path to this script
cellularGPSMeasurement_fromCentroid(mfilepath);
cenTable = readtable(fullfile(mfilepath,'centroid_measurements.txt'),'Delimiter','\t');