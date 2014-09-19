%% makegain
% The gain image contains weights to counter the natural bias found in
% every pixel of the image. It is assumed that the measurement of light at
% each pixel is related to the true incident light proportionally through
% an absorbance constant.
%
%   [] = makeoffset(path,ffpath)
%
%%% Input:
% * path: the location of outpath created by |importFromMetamorphMDA|. The
% PNG images within will be flat field corrected. The function
% |importFromMetamorphMDA| should be run beforehand.
% * ffpath: the location of the correction images
%
%%% Output:
% There is no direct argument output. Existing PNG images in the _path_ are
% flatfield corrected.
%
%%% Description:
%
%
% Other Notes:
% Assumes the image files have been converted to the PNG format
function []=cellularGPSFlatfield_makegain(channelNumber,moviePath,channelName)
fprintf('making gain image for the number %d or %s channel...\n',channelNumber,channelName);
ffTable = readtable(fullfile(moviePath,'flatfield','smda_database.txt'),'Delimiter','\t');
%%%
% identify all the exposure images
filename = ffTable.filename(ffTable.channel_number == channelNumber);
%%%
% identify the length of exposure for each image
expr=sprintf('(\\d+)_w%d',channelNumber);
exposure = zeros(size(filename));
flatfieldIM = cell(size(filename));
for i=1:length(filename) %floop 1
    [~, floop1num] = regexp(filename{i},expr,'match','once','tokens');
    exposure(i) = str2double(floop1num);
    flatfieldIM{i}=double(imread(fullfile(moviePath,'flatfield','RAW_DATA',filename{i})));
end
%% weight the dark image
% We have a high confidence in the dark field image and want the line to
% pass through this point more than any other. Therefore it is weighted.
zeroInd = find(exposure == 0,1,'first');
extraZeroNumbers = zeros(4,1);
exposure = vertcat(exposure, extraZeroNumbers);
extraZeroImages = repmat(flatfieldIM(zeroInd),4,1);
flatfieldIM = vertcat(flatfieldIM, extraZeroImages);
%% calculate the gain image
tic
[hei,wid]=size(flatfieldIM{1});
gainIM=zeros(size(flatfieldIM{1}));
parfor i = 1:numel(gainIM)
    [x,y]=deal(zeros(length(exposure),1));
    for j=1:length(exposure)
        y(j)=flatfieldIM{j}(i); %#ok<PFBNS>
        x(j)=exposure(j);
    end
    [~,b,r2]=cellularGPSFlatfield_leastsquaresfit(x,y);
    if r2<0.8
        fprintf('Pixel number %d in the %s channel is not a good fit.\n',i,channelName);
    end
    gainIM(i)=b;
end
gainIM=gainIM/mean(mean(gainIM));
toc
%% smooth the image
% Images from the lab typically end up being 1344 x 1024 or 672 x 512,
% depending on whether or not there is binning. The size of the image will
% influence the size of the filters used to smooth the image.
if hei >= 1344 || wid >= 1344
    h = fspecial('average',[31 31]);
    gainIM=imfilter(gainIM,h,'replicate');
else
    h = fspecial('average',[15 15]);
    gainIM=imfilter(gainIM,h,'replicate');
end
%%
% The image is normalized by the mean. But numbers between 0 and 1 cannot
% be directly stored in an 16-bit image. Therefore, the weights are scaled
% and that scaling factor is saved in the filename, so that it can be
% inverted later on.
max_temp=max(max(gainIM));
max_temp=round(max_temp*1000)/1000;
im_temp=gainIM*65536/max_temp;
im_temp=uint16(im_temp);
max_temp=sprintf('%d',max_temp*1000);
imwrite(im_temp,fullfile(moviePath,'flatfield',sprintf('flatfield_w%d%s_gain%s.tiff',channelNumber,channelName,max_temp)),'tif','Compression','none');
end