%% import test data into MATLAB workspace
%
[mfilepath,~,~] = fileparts(mfilename('fullpath')); %finds the path to this script
I = imread(fullfile(mfilepath,'RAW_DATA','group1_pos4_x4_y1USA_s4_w7YFP_t50_z1.tiff'));
ISeg = imread(fullfile(mfilepath,'SEGMENT_DATA','segmentation_images','iseg_s4_t50.tiff'));
centroidTableAll = readtable(fullfile(mfilepath,'SEGMENT_DATA','segmentation.txt'),'Delimiter','\t');
centroidTableLogic = centroidTableAll.timepoint == 50 & centroidTableAll.position_number == 4;
centroidTable = centroidTableAll(centroidTableLogic,1:2);
%% create the parameterized functions
% centroidNibble
p.radius = 5;
cGPSM_centroidNibble = cellularGPSMeasurement_centroidNibble(p);
%%%
%
%cGPSM_meanIntensity= cellularGPSMeasurement_meanIntensity(I,centroidTable,ISeg);
%%%
%
%cGPSM_totalIntensity = cellularGPSMeasurement_totalIntensity(I,centroidTable,ISeg);
%%
% a file to test
myMeasurement1 = cGPSM_centroidNibble(I,centroidTable,ISeg);
%myMeasurement2 = cGPSM_meanIntensity(I,centroidTable,ISeg);
%myMeasurement3 = cGPSM_totalIntensity(I,centroidTable,ISeg);