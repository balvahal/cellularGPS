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
% * moviePath: 
%
%%% Output:
% There is no direct argument output.
%
%%% Description:
% 
%
% Other Notes:
%
function [] = cellularGPSBackground_subtraction(moviePath,varargin)
%% Parse Input
%
p = inputParser;
p.addRequired('moviePath', @(x)isdir(x));
p.addParamValue('method','Jared',@(x) any(strcmpi(x,{'Jared','Alex','Uri'})));
p.addParamValue('magnification',20,@(x)any(bsxfun(@eq,x,[10,20,40,60])));
p.addParamValue('binning',1,@(x)any(bsxfun(@eq,x,[1,2])));
p.addParamValue('channelNumber',0,@(x)isnumeric(x));
p.parse(moviePath, varargin{:});
p2.met = p.Results.method;
p2.mag = p.Results.magnification;
p2.bin = p.Results.binning;
channelNumber = p.Results.channelNumber;
if p.Results.channelNumber == 0
    warning('cGPSBkgd:noChan','No channel for background subtraction was selected, so the process was aborted.');
    return;
end
smdaDatabase = readtable(fullfile(moviePath,'smda_database.txt'),'Delimiter','\t');
channelName = cell(size(channelNumber));
for i = 1:length(channelNumber) %floop 1
    myind = find(smdaDatabase.channel_number == channelNumber(i),1,'first');
    channelName{i} = smdaDatabase.channel_name{myind};
end
%% read smda_database.txt
% and prepare input and output paths. Only process the files specified by
% channelNumber parameter
imagePathOut = fullfile(moviePath,'PROCESSED_DATA');
if ~isdir(imagePathOut)
    mkdir(imagePathOut);
    imagePathIn = fullfile(moviePath,'RAW_DATA');
else
    imagePathIn = imagePathOut;
end
%%%
% Choose only the files that are specified by the channelNumber parameter.
smdaDatabaseLogical = false(height(smdaDatabase),1);
for i = 1:length(channelNumber) %floop 1
    smdaDatabaseLogical = smdaDatabase.channel_number == channelNumber(i) | smdaDatabaseLogical;
end
myFilenames = smdaDatabase.filename(smdaDatabaseLogical);
myFilenamesOfUncorrected = smdaDatabase.filename(~smdaDatabaseLogical);

%% Configure the background subtraction method
%
bkgdFun = bkgdmethods(p2);
%% subtract background from each image
%
parfor i = 1:length(myFilenames)
    fprintf('%s\n', myFilenames{i});
    imageIn = double(imread(fullfile(imagePathIn,myFilenames{i})));
    imageOut = bkgdFun(imageIn); %#ok<PFBNS>
    imwrite(uint16(imageOut),fullfile(imagePathOut,myFilenames{i}),'tiff');
end
%% copy uncorrected files from _RAW_DATA_ (if reading from _RAW_DATA_)
% if RAW_DATA is the source file then the uncorrected images need to be
% copied over
if ~isempty(myFilenamesOfUncorrected) && strcmp(imagePathIn,fullfile(moviePath,'RAW_DATA'))
    for i = 1:length(myFilenamesOfUncorrected)
        copyfile(fullfile(imagePathIn,myFilenamesOfUncorrected{i}),fullfile(imagePathOut,myFilenamesOfUncorrected{i}));
    end
end
%% Save a badge to the _moviePath_
%
jsonStrings = {};
n = 1;
jsonStrings{n} = micrographIOT_cellStringArray2json('channel_name',channelName); n = n + 1;
jsonStrings{n} = micrographIOT_array2json('channel_number',channelNumber); n = n + 1;
mydate = datestr(now,31);
jsonStrings{n} = micrographIOT_string2json('date',mydate);
myjson = micrographIOT_jsonStrings2Object(jsonStrings);
fid = fopen(fullfile(moviePath,'BADGE_bkgdSubtraction.txt'),'w');
if fid == -1
    error('cGPSFF:badfile','Cannot open the file, preventing the export of the background subtraction badge badge.');
end
fprintf(fid,myjson);
fclose(fid);
%%
%
myjson = micrographIOT_autoIndentJson(fullfile(moviePath,'BADGE_bkgdSubtraction.txt'));
fid = fopen(fullfile(moviePath,'BADGE_bkgdSubtraction.txt'),'w');
if fid == -1
    error('cGPSFF:badfile','Cannot open the file, preventing the export of the background subtraction badge.');
end
fprintf(fid,myjson);
fclose(fid);
end

function [bkgd]=gridscan(S,funfcn,sel)
%The pass over the inner grid
ho=size(S,1); %original height of the input image (usually 512)
wo=size(S,2); %original width of the input image (usually 672)

%ensure the image size is divisible by the grid size
xtrah=mod(ho,sel);
if xtrah
    h=ho+(sel-xtrah);
    S=padarray(S,[(sel-xtrah) 0],'symmetric','post');
else
    h=ho;
end
xtraw=mod(wo,sel);
if xtraw
    w=wo+(sel-xtraw);
    S=padarray(S,[0 (sel-xtraw)],'symmetric','post');
else
    w=wo;
end

gridh=h/sel;
gridw=w/sel;
bkgdgridcenter=zeros(gridh,gridw); %Holds the "center" background intensity value for each grid space

%Pass over the inner-grid
jarray=(sel:sel:h);
karray=(sel:sel:w);
for j=jarray
    for k=karray
        A=S(j-sel+1:j,k-sel+1:k);
        bkgdgridcenter((j)/sel,(k)/sel)=funfcn(A);
    end
end

%Create background image using interpolation with the bkgdgridcenter
bkgd=floor(imresize(bkgdgridcenter,sel));
%Remove padding if there was any
bkgd=bkgd(1:ho,1:wo);
end

function [B]=rankfilter(A)
B=reshape(A,[],1);
B=sort(B); %Sort values in the grid in ascending order. In other words rank the pixels by intensity.
%The percentile can be tweaked and adjusted to improve results
B=B(floor(length(B)*(0.1))); %Find the 10th percentile. The idea is that the 10th percentile is always representative of the background.
end

function [B]=gaussianthreshold(A)
%This function will attempt to fit up to three Gaussians. The mean of the
%first Guassian is taken to be the background threshold
%As of writing this code the documentation for the fitting toolbox is
%awful. I find trying to fit more than two guassians leads to funny fits,
%so I recommend not fitting more than two. Each Gaussian has three
%parameters: a=amplitude, b=mean, c=variance.
ftype = fittype('gauss1');
opts = fitoptions('gauss1');
A=reshape(A,[],1);
s=min(A);
r=max(A);
x = (s:floor((r-s)/40):r)';
h = hist(A,x)';
[FitModel, Goodness] = fit(x,h,ftype,opts);
if Goodness.rsquare>0.96
    B=floor(FitModel.b1);
else
    ftype = fittype('gauss2');
    opts = fitoptions('gauss2');
    [FitModel, ~] = fit(x,h,ftype,opts);
    B=floor(FitModel.b1);
end
end

function [myHandle]=bkgdmethods(p)
%S is a stack, method chooses between several different background
%subtraction methods
%Jared's method is a morphological approach to find the background. An
%opening and closing procedure is performed. The key is choosing
%appropriate structing element sizes. By default they are (16,close) and
%(320,open). These are chosen to be approximately the size of intracellular
%noise and clumps of cells respectively. Using (96,open) gives results
%closer to the other methods using a 32 pixel grid.
%
%Alex's method uses Gaussian fitting to identify local thresholds. The
%assumption here is that the background is well approximated by a Gaussian
%distribution and the signal of interest is significantly higher than this
%distribution, i.e. 2 to 3 sigma away. A local area is defined roughly 1 to
%2 times the size of a nucleus (in this case 96 pixels is chosen).
%
%Uri's method is based upon background subtraction perfromed by Sigal et
%al., Nature Methods 2006. The image is broken up into a grid and from each
%grid space the 10th percentile pixel value is chosen to as the background.
%The size of the grid must be roughly 1 to 2 times the size of a nucleus if
%measuring a nuclear localized protein (in this case 96 pixels is chosen).
switch lower(p.met)
    %Depending on the se2Size this method is similar to the 'uri' method.
    %It is the most conservative of all the methods. It is roughly 50 times
    %slower than the 'uri' method.
    case 'jared'
        switch p.mag
            %The values below have been heuristically chosen.
            case 10
                se1Size = 2^3;
                se2Size = 2^7;
            case 20
                se1Size = 2^4;
                se2Size = 2^8;
            case 40
                se1Size = 2^5;           % intracellular features in pixels, such as the nucleolus
                se2Size = 2^9;          % cells/cell clumps in pixels '' '' '
            case 60
                se1Size = 2^5+2^3;
                se2Size = 2^9+2^7;
            otherwise
                error('bkgd:Whatever','How did you get here?');
        end
        switch p.bin
            case 1
                
            case 2
                se1Size = se1Size/2;
                se2Size = se2Size/2;
            otherwise
                error('bkgd:Whatever','How did you get here?');
        end
        
        resizeMultiplier = 1/2; % Downsampling scale factor makes image processing go faster and smooths image
        se1 = strel('disk', round(se1Size*resizeMultiplier));  %Structing elements are necessary for using MATLABS image processing functions
        se2 = strel('disk',round(se2Size*resizeMultiplier));
        myHandle = @jared;
    case 'alex'
        %This algorithm is more aggressive than the 'uri' algorithm. It
        %also takes approximately 100 times longer to run then the 'uri'
        %algorithm. I do not think this works well at large grid
        %sizes/high-magnification
        
        switch p.mag
            %The values below have been heuristically chosen.
            case 10
                sel=2^7;
            case 20
                sel=2^8;
            case 40
                sel=2^9;
            case 60
                sel=2^9+2^7;
            otherwise
                error('bkgd:Whatever','How did you get here?');
        end
        switch p.bin
            case 1
                
            case 2
                sel = sel/2;
            otherwise
                error('bkgd:Whatever','How did you get here?');
        end
        myHandle = @alex;
    case 'uri'
        %This algorithm seems to work well when the sel value is about the
        %size of a large nucleus. Larger senescent nuclei might prove
        %troublesome if the sel is based on large nuclei at the start of
        %the movie, which would be considerably smaller. The larger the sel
        %the more conservative the estimate of the background. Between the
        %'jared', 'alex', and 'uri' methods the 'uri' method is the fastest
        %by at least 2 orders of magnitude.
        %I do not think this works well at large-grid-sizes/high-magnification
        switch p.mag
            %The values below have been heuristically chosen for MCF7 nuclei.
            case 10
                sel=2^7;
            case 20
                sel=2^8;
            case 40
                sel=2^9;
            case 60
                sel=2^9+2^7;
            otherwise
                error('bkgd:Whatever','How did you get here?');
        end
        switch p.bin
            case 1
                
            case 2
                sel = sel/2;
            otherwise
                error('bkgd:Whatever','How did you get here?');
        end
        myHandle = @uri;
    otherwise
        error('Unknown method of background subtraction specified')
end
    function S = jared(S)
        origSize  = size(S);
        % Rescale image and compute background using closing/opening.
        I    = imresize(S, resizeMultiplier);
        % Pad image with a reflection so that borders don't introduce artifacts
        pad   = round(se2Size*resizeMultiplier);
        I    = padarray(I, [pad,pad], 'symmetric', 'both');
        % Perform opening/closing to get background
        I     = imclose(I, se1);   % ignore small low-intensity features (inside cells)
        I     = imopen(I, se2);     % ignore large high-intensity features (that are cells)
        % Remove padding and resize
        I     = floor(imresize(I(pad+1:end-pad, pad+1:end-pad), origSize));
        % Subtract background!
        S = S - I;
        S(S<0)=0;
    end
    function S = alex(S)
        bkgd=gridscan(S,@gaussianthreshold,round(sel));
        S=S-bkgd;
        S(S<0)=0;
    end
    function S = uri(S)
        bkgd=gridscan(S,@rankfilter,sel);
        S=S-bkgd;
        S(S<0)=0;
    end
end