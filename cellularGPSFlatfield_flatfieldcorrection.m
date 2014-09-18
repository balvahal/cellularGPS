%% flatfieldcorrection
% Using dark field and flat field images collected prior to or after the
% time-lapse fluorescent images, biases created by a spatial heterogenity
% in light source intensity and light path absorbance, and the bias added
% to the image by the camera during acquisition, are removed in a precise,
% quantitative fashion.
%
%   [] = flatfieldcorrection(path,ffpath)
%
%%% Input:
% * path: the location of outpath created by |importFromMetamorphMDA|. The
% image images within will be flat field corrected. The function
% |importFromMetamorphMDA| should be run beforehand.
% * ffpath: the location of the correction images
%
%%% Output:
% There is no direct argument output. Existing image images in the _path_ are
% flatfield corrected.
%
%%% Description:
% The light measured by the camera is proportionally related to the length
% of time exposed to the incident light. Then there is an offset created by
% the measurement device that must also be accounted for. This describes a
% linear relationship.
%
% $$y = \beta t + C$$
%
% Here, $y$ is the pixel measurement; $\beta$ is a combination of flux,
% photons per pixel area per time, and light path absorbance, unitless
% measure between 0 an 1; $t$ is time; $C$ is the dark field offset. The
% two parameters $\beta$ and $C$ can be found by fitting a line for each
% pixel using images taken at several different exposures.
%
% Other Notes:
% It is assumed that the input images were created by a camera with a
% bit-depth of 12 and that these images were stretched to fill a bit-depth
% of 16 when converted to image. Therefore, the offset image which accounts
% for darkfield noise is also stretch from 12-bit to 16-bit.
function [] = cellularGPSFlatfield_flatfieldcorrection(moviePath)

p = inputParser;
p.addRequired('moviePath', @(x) isdir(x));
p.parse(moviePath);

if ~isdir(fullfile(moviePath,'flatfield'))
    error('cGPSFF:noImages','The flatfield directory could not be found. Were flatfield correction images acquired by the SuperMDA?');
end
%% Import image paths
% The image paths are stored in the image metadata. Import this data file
% into the MATLAB workspace.
ffTable = readtable(fullfile(moviePath,'flatfield','smda_database.txt'),'Delimiter','\t');
% Check if the computer is a mac (for fun).
if ismac
    fprintf(1,'Isn''t owning a Mac wonderful?\r\n');
end
%%
% only the channels with flat field images can be corrected. Identify those
% channels by looking at the first word of the flatfield image filenames.
% Every file in the _ffpath_ will be looked at and the unique channel names
% will be saved.
channelNumber = unique(ffTable.channel_number);
channelName = cell(size(channelNumber));
for i = 1:length(channelNumber) %floop 1
    myind = find(ffTable.channel_number == channelNumber(i),1,'first');
    channelName{i} = ffTable.channel_name{myind};
end

%% Create channelTruthTable variable.
% The channelTruthTable variable is two columns with a row for each
% channel. The first column is the offset column, 1 if offset image exists
% 0 otherwise. The second column is the gain column, 1 if gain image exists
% 0 otherwise.
channelTruthTable = zeros(length(channelNumber),2);
%%
% Check for existence of correction images. First, identify offset and gain
% images and their channel
for k=1:length(channelNumber)
    if exist(fullfile(moviePath,'flatfield',sprintf('flatfield_w%d%s_offset.tiff',channelNumber(k),channelName{k})),'file')
        channelTruthTable(k,1) = 1;
    end
end
dirCon_ff = dir(fullfile(moviePath,'flatfield'));
expr='.+(?=_gain\d+.tif)';
for j=1:length(dirCon_ff) %floop 2
    floop2Filename=regexp(dirCon_ff(j).name,expr,'match','once','ignorecase');
    if floop2Filename
        for k=1:length(channelNumber)
            if strcmpi(Temp2,sprintf('_w%d%s',channelNumber(k),channelName{k}))
                channelTruthTable(k,2) = 1;
            end
        end
    end
end
%%
% create offset and gain images according to the truth table
for i=1:length(channelNumber)
    outcome = channelTruthTable(i,1)*2 + channelTruthTable(i,2);
    switch outcome
        case 0 %No offset or gain image
            cellularGPSFlatfield_makeoffset(channelNumber(i),moviePath,channelName{i});
            cellularGPSFlatfield_makegain(channelNumber(i),moviePath,channelName{i});
        case 1 %just a gain image
            cellularGPSFlatfield_makeoffset(channelNumber(i),moviePath,channelName{i});
        case 2 %just an offset image
            cellularGPSFlatfield_makegain(channelNumber(i),moviePath,channelName{i});
        case 3 %both gain and offset exist
    end
end

%% Correct image images using gain and offset images
%
dirCon_ff = dir(ffpath);
for j=1:length(channels_stacks)
    %%
    % Import the gain and offset image for a given fluorescent channel
    fname = fullfile(ffpath,strcat(channels_stacks{j},'_offset'));
    info = imfinfo(fname,'tif');
    offset = double(imread(fname,'tif','Info',info));
    for k=1:length(dirCon_ff)
        temp = regexp(dirCon_ff(k).name,[channels_stacks{j} '_gain\d+'],'match','once','ignorecase');
        if ~isempty(temp)
            gainname = temp;
            break
        end
    end
    info = imfinfo(fullfile(ffpath,gainname),'tif');
    gain = double(imread(fullfile(ffpath,gainname),'tif','Info',info));
    expr='(?<=_gain)\d+';
    max_temp=regexp(gainname,expr,'match','once');
    max_temp=str2double(max_temp)/1000;
    gain=gain*max_temp/65536;
    %%
    % Loop through all the input images for a given fluorescent channel and
    % flat field correct them.
    %
    % First match the name of the flat field images with the name of the
    % input images
    %
    indlogical = strcmpi(channels_stacks{j},imageMetadata.wavelengthInfo(2:end,2));
    indarray = imageMetadata.wavelengthInfo(2:end,1);
    indarray = indarray(indlogical);
    indarray = transpose(cell2mat(indarray));
    for s=1:imageMetadata.numbers.howManyS
        for w=indarray
            for t=1:imageMetadata.numbers.howManyT
                for z=1:imageMetadata.numbers.howManyZ
                    if ~isempty(imageMetadata.filenames{s,w,t,z})
                        disp(['Flatfield correcting ',imageMetadata.filenames{s,w,t,z}])
                        Name = fullfile(path,'image',imageMetadata.filenames{s,w,t,z});
                        IM = double(imread(Name));
                        %verify that the input image is the correct size, otherwise no
                        %output image will be created.
                        if size(IM)~=size(offset)
                            continue
                        end
                        %%
                        % Here is where the actual correction takes place.
                        IM = IM-offset; %subtract the offset
                        IM(IM<0) = 0; %remove negative values
                        IM = IM./gain; %compensate for biases
                        IM = uint16(IM); %convert back to 16-bit image
                        imwrite(IM,Name,'image','bitdepth',16); %overwrite uncorrected file
                    end
                end
            end
        end
    end
end
%% Create or append a log file
%
fid = fopen(fullfile(path,'log.txt'),'a+');
fprintf(fid,'%s: flatfieldcorrection: image images from the folder ''%s'' were flatfield corrected for the following channels:\r\n',date,path);
for i=1:length(channels_stacks)
    fprintf(fid,'%s\r\n',channels_stacks{i});
end
fprintf(fid,'\r\n');
fclose(fid);
end




