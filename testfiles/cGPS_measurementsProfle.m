[mfilepath,~,~] = fileparts(mfilename('fullpath')); %finds the path to this script

parameters = {'meanIntensity',...
    'totalIntensity'};
%%
%
jsonStrings = {};
n = 1;
jsonStrings{n} = micrographIOT_cellStringArray2json('parameters',parameters); n = n + 1;
%%
%
myjson = micrographIOT_jsonStrings2Object(jsonStrings);
fid = fopen(fullfile(mfilepath,'cGPS_measurementsProfile.txt'),'w');
if fid == -1
    error('smdaITF:badfile','Cannot open the file, preventing the export of the cGPS_measurementsProfile.');
end
fprintf(fid,myjson);
fclose(fid);
%%
%
myjson = micrographIOT_autoIndentJson(fullfile(mfilepath,'cGPS_measurementsProfile.txt'));
fid = fopen(fullfile(mfilepath,'cGPS_measurementsProfile.txt'),'w');
if fid == -1
    error('smdaITF:badfile','Cannot open the file, preventing the export of the cGPS_measurementsProfile.');
end
fprintf(fid,myjson);
fclose(fid);