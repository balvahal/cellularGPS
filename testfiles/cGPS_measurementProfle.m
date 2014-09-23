[mfilepath,~,~] = fileparts(mfilename('fullpath')); %finds the path to this script
%% parameters
%
intensityParameters = {'centroidNibble',...
    'meanIntensity',...
    'totalIntensity'};

jsonStrings = {};
n = 1;
jsonStrings{n} = micrographIOT_cellStringArray2json('intensityParameters',intensityParameters); n = n + 1;
%% parameters
%
shapeParameters = {'area',...
    'solidity'};
jsonStrings{n} = micrographIOT_cellStringArray2json('shapeParameters',shapeParameters); n = n + 1;
%% area
%
jsonStrings2 = {};
jsonStrings2{1} = micrographIOT_string2json('comment','This function has no parameters.');
jsonStrings2 = micrographIOT_jsonStrings2Object(jsonStrings2);
jsonStrings{n} = micrographIOT_nestedObject2json('area',jsonStrings2); n = n + 1;
%% centroidNibble
%
jsonStrings2 = {};
jsonStrings2{1} = micrographIOT_array2json('radius',5);
jsonStrings2 = micrographIOT_jsonStrings2Object(jsonStrings2);
jsonStrings{n} = micrographIOT_nestedObject2json('centroidNibble',jsonStrings2); n = n + 1;
%% meanIntensity
%
jsonStrings2 = {};
jsonStrings2{1} = micrographIOT_string2json('comment','This function has no parameters.');
jsonStrings2 = micrographIOT_jsonStrings2Object(jsonStrings2);
jsonStrings{n} = micrographIOT_nestedObject2json('meanIntensity',jsonStrings2); n = n + 1;
%% solidity
%
jsonStrings2 = {};
jsonStrings2{1} = micrographIOT_string2json('comment','This function has no parameters.');
jsonStrings2 = micrographIOT_jsonStrings2Object(jsonStrings2);
jsonStrings{n} = micrographIOT_nestedObject2json('solidity',jsonStrings2); n = n + 1;
%% totalIntensity
%
jsonStrings2 = {};
jsonStrings2{1} = micrographIOT_string2json('comment','This function has no parameters.');
jsonStrings2 = micrographIOT_jsonStrings2Object(jsonStrings2);
jsonStrings{n} = micrographIOT_nestedObject2json('totalIntensity',jsonStrings2); n = n + 1;
%%
%
myjson = micrographIOT_jsonStrings2Object(jsonStrings);
fid = fopen(fullfile(mfilepath,'cGPS_measurementProfile.txt'),'w');
if fid == -1
    error('smdaITF:badfile','Cannot open the file, preventing the export of the cGPS_measurementsProfile.');
end
fprintf(fid,myjson);
fclose(fid);
%%
%
myjson = micrographIOT_autoIndentJson(fullfile(mfilepath,'cGPS_measurementProfile.txt'));
fid = fopen(fullfile(mfilepath,'cGPS_measurementProfile.txt'),'w');
if fid == -1
    error('smdaITF:badfile','Cannot open the file, preventing the export of the cGPS_measurementsProfile.');
end
fprintf(fid,myjson);
fclose(fid);