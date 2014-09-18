%% import test data into MATLAB workspace
%
[mfilepath,~,~] = fileparts(mfilename('fullpath')); %finds the path to this script
I = imread(fullfile(mfilepath,'RAW_DATA','group1_pos4_x4_y1USA_s4_w7YFP_t50_z1.tiff'));
ISeg = imread(fullfile(mfilepath,'SEGMENT_DATA','segmentation_images','group1_pos4_x4_y1USA_s4_w2Cy5_5_t50_z1_segment.TIF'));
centroidsTable = readtable(fullfile(mfilepath,'SEGMENT_DATA','tables','group1_s4_w2Cy5_5_centroidsTable.txt'),'Delimiter','\t');
centroidsLogical = centroidsTable.timepoint == 50;
centroids = centroidsTable(centroidsLogical,:);

%%
% a file to test
myMeasurements = cellularGPSMeasurement_meanIntensity(I,centroids,ISeg);
