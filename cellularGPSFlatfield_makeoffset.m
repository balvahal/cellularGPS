%% makeoffset
% The offset image is an approximation of the dark field. The dark field
% image is the signal captured by the camera when there is no light on the
% sensor. This function will smooth the image captured with a zero
% exposure.
%
%   [] = makeoffset(path,ffpath)
%
%%% Input:
% * chan: the name of the channel to have an offset image created.
% * ffpath: the location of the correction images
%
%%% Output:
% An offset image is created and written to the directory that contains the
% flat field images.
%
%%% Description:
%
%
% Other Notes:
% 
function []=cellularGPSFlatfield_makeoffset(channelNumber,moviePath,channelName)
fprintf('making offset image for the number %d or %s channel...\n',channelNumber,channelName);
ffTable = readtable(fullfile(moviePath,'flatfield','smda_database.txt'),'Delimiter','\t');
%%%
% identify all the exposure images
filename = ffTable.filename(ffTable.channel_number == channelNumber);
%%%
% identify the length of exposure for each image
expr=sprintf('(\\d+)_w%d',channelNumber);
for i=1:length(filename) %floop 1
    [~, floop1num] = regexp(filename{i},expr,'match','once','tokens');
    if strcmp(floop1num,'0')
        myind = i;
        break
    end
end

IM=double(imread(fullfile(moviePath,'flatfield','RAW_DATA',filename{myind})));
%% smooth the image
% Images from the lab typically end up being 1344 x 1024 or 672 x 512,
% depending on whether or not there is binning. The size of the image will
% influence the size of the filters used to smooth the image.
[hei,wid]=size(IM);
if hei >= 1344 || wid >= 1344
    IM = medfilt2(IM,[17,17],'symmetric'); %median filters are good for salt and pepper noise like that seen in the darkfield image
else
    IM = medfilt2(IM,[9,9],'symmetric');
end
IM=uint16(IM);
imwrite(IM,fullfile(moviePath,'flatfield',sprintf('flatfield_w%d%s_offset.tiff',channelNumber,channelName)),'tif','Compression','none');
end