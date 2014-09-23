[mfilepath,~,~] = fileparts(mfilename('fullpath')); %finds the path to this script
cellularGPS_measurementFromCentroid(moviePath);
cenTable = readtable(fullfile(mfilepath,'centroid_measurements.txt'),'Delimiter','\t');