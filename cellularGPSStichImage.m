%%
% It is assumed that a field of images was acquired using the scan6 app.
% This implies that the filenames of the images contain X and Y information
% that describes the relative positioning of each image.
function [] = cellularGPSStichImage(moviePath,varargin)
%% Parse Input
%
p = inputParser;
p.addRequired('moviePath', @(x)isdir(x));
p.addParameter('overlap',0,@(x)isnumeric(x));
p.addParameter('scale',8,@(x)isnumeric(x));
p.parse(moviePath, varargin{:});
myoverlap = round(p.Results.overlap/p.Results.scale);
%%
% import filenames and parse x and y information
mytable = readtable(fullfile(moviePath,'smda_database.txt'),'Delimiter','\t');
xposition = zeros(height(mytable),1);
for i = 1:height(mytable)
    mystr = mytable.position_label(i);
    mynum = regexp(mystr,'_x(\d+)','tokens');
    xposition(i) = str2double(mynum{1}{1});
end
yposition = zeros(height(mytable),1);
for i = 1:height(mytable)
    mystr = mytable.position_label(i);
    mynum = regexp(mystr,'_y(\d+)','tokens');
    yposition(i) = str2double(mynum{1}{1});
end
mytable.colgrid = xposition;
mytable.rowgrid = yposition;
%%
% for each settings in each group create a stitched image
mygroup = unique(mytable.group_number);
for i = 1:length(mygroup)
    mysettings = unique(mytable.settings_number(mytable.group_number == mygroup(i)));
    for j = 1:length(mysettings)
        mylogical = mytable.group_number == mygroup(i) & mytable.settings_number == mysettings(j);
        mytable2 = mytable(mylogical,:);
        rownum = max(mytable2.rowgrid);
        colnum = max(mytable2.colgrid);
        mystitch = cell(rownum,colnum);
        for s = 1:rownum
            for t = 1:colnum
                if exist(fullfile(moviePath,'PROCESSED_DATA',mytable2.filename{mytable2.rowgrid == s & mytable2.colgrid == t}),'file')
                    I = imread(fullfile(moviePath,'PROCESSED_DATA',mytable2.filename{mytable2.rowgrid == s & mytable2.colgrid == t}));
                    mystitch{s,t} = imresize(I,1/p.Results.scale);
                    mystitch{s,t} = mystitch{s,t}(1:end-myoverlap,1:end-myoverlap);
                end
            end
        end
        mystitch = cell2mat(mystitch);
        imwrite(mystitch,fullfile(moviePath,sprintf('g%ds%d_stitched.png',i,j)),'png');
    end
end

end