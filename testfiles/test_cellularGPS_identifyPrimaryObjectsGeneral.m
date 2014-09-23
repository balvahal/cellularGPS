[mfilepath,~,~] = fileparts(mfilename('fullpath')); %finds the path to this script
I = imread(fullfile(mfilepath,'PROCESSED_DATA','group1_pos4_x4_y1USA_s4_w7YFP_t50_z1.tiff'));
cellularGPS_identifyPrimaryObjectsGeneral(I);