function [f] = cellularGPSTrackingManual_gui_control(trackman)
%% Create the figure
%   ___ _
%  | __(_)__ _ _  _ _ _ ___
%  | _|| / _` | || | '_/ -_)
%  |_| |_\__, |\_,_|_| \___|
%        |___/
myunits = get(0,'units');
set(0,'units','pixels');
Pix_SS = get(0,'screensize');
set(0,'units','characters');
Char_SS = get(0,'screensize');
ppChar = Pix_SS./Char_SS;
set(0,'units',myunits);
fwidth = 136.6; %683/ppChar(3) on a 1920x1080 monitor;
fheight = 70; %910/ppChar(4) on a 1920x1080 monitor;
fx = Char_SS(3) - (Char_SS(3)*.1 + fwidth);
fy = Char_SS(4) - (Char_SS(4)*.1 + fheight);
f = figure('Visible','off','Units','characters','MenuBar','none','Position',[fx fy fwidth fheight],...
    'CloseRequestFcn',{@fDeleteFcn},'Name','Travel Agent Main');
tabgp = uitabgroup(f,'Position',[0,0,1,1]);
tabContrast = uitab(tabgp,'Title','Contrast');

textBackgroundColorRegion1 = [37 124 224]/255; %tendoBlueLight
buttonBackgroundColorRegion1 = [29 97 175]/255; %tendoBlueDark
textBackgroundColorRegion2 = [56 165 95]/255; %tendoGreenLight
buttonBackgroundColorRegion2 = [44 129 74]/255; %tendoGreenDark
textBackgroundColorRegion3 = [255 214 95]/255; %tendoYellowLight
buttonBackgroundColorRegion3 = [199 164 74]/255; %tendoYellowDark
textBackgroundColorRegion4 = [255 103 97]/255; %tendoRedLight
buttonBackgroundColorRegion4 = [199 80 76]/255; %tendoRedDark
buttonSize = [20 3.0769]; %[100/ppChar(3) 40/ppChar(4)];
region1 = [0 56.1538]; %[0 730/ppChar(4)]; %180 pixels
region2 = [0 42.3077]; %[0 550/ppChar(4)]; %180 pixels
region3 = [0 13.8462]; %[0 180/ppChar(4)]; %370 pixels
region4 = [0 0]; %180 pixels

%% Contrast Tab: gui
%    ___         _               _     _____     _
%   / __|___ _ _| |_ _ _ __ _ __| |_  |_   _|_ _| |__
%  | (__/ _ \ ' \  _| '_/ _` (_-<  _|   | |/ _` | '_ \
%   \___\___/_||_\__|_| \__,_/__/\__|   |_|\__,_|_.__/
%
%% functions specific to _tabContrast_
%
handles.tabContrast_findImageHistogram = @tabContrast_findImageHistogram;
%% Create the axes that will show the contrast histogram
% and the plot that will show the histogram
hwidth = 104;
hheight = 40;
hx = (fwidth-hwidth)/2;
hy = 20;
handles.tabContrast_findImageHistogram = @tabContrast_findImageHistogram;
tabContrast_axesContrast = axes('Parent',tabContrast,'Units','characters',...
    'Position',[hx hy hwidth hheight]);
tabContrast_axesContrast.NextPlot = 'add';
tabContrast_axesContrast.ButtonDownFcn = @tabContrast_axesContrast_ButtonDownFcn;
%%% semilogy plot
%
tabContrast_findImageHistogram();
tabContrast_plot = semilogy(tabContrast_axesContrast,(0:255),handles.contrastHistogram,...
    'Color',[0 0 0]/255,...
    'LineWidth',3);
tabContrast_axesContrast.YScale = 'log';
tabContrast_axesContrast.XLim = [0,255];
tabContrast_axesContrast.YLim(1) = 0;
xlabel('Intensity');
ylabel('Pixel Count');
%% Create controls
%  two slider bars
hwidth = 52;
hheight = 2;
hx = (fwidth-hwidth)/2;
hy = 10;
%%% sliderMax
%
sliderStep = 1/(256 - 1);
tabContrast_sliderMax = uicontrol('Parent',tabContrast,'Style','slider','Units','characters',...
    'Min',0,'Max',1,'BackgroundColor',[255 255 255]/255,...
    'Value',1,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
    'Callback',{@sliderMax_Callback});

hx = (fwidth-hwidth)/2;
hy = 5;
%%% sliderMin
%
sliderStep = 1/(256 - 1);
tabContrast_sliderMin= uicontrol('Parent',tabContrast,'Style','slider','Units','characters',...
    'Min',0,'Max',1,'BackgroundColor',[255 255 255]/255,...
    'Value',0,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
    'Callback',{@sliderMin_Callback});
%% Lines for the min and max contrast levels
%
hwidth = 104;
hheight = 40;
hx = (fwidth-hwidth)/2;
hy = 20;
tabContrast_haxesLine = axes('Parent',tabContrast,'Units','characters',...
    'Position',[hx hy hwidth hheight]);
tabContrast_haxesLine.NextPlot = 'add';
tabContrast_haxesLine.Visible = 'off';
tabContrast_haxesLine.YLim = [0,1];
tabContrast_haxesLine.XLim = [0,1];
tabContrast_lineMin = line;
tabContrast_lineMin.Parent = tabContrast_haxesLine;
tabContrast_lineMin.Color = [29 97 175]/255;
tabContrast_lineMin.LineWidth = 3;
tabContrast_lineMin.LineStyle = ':';
tabContrast_lineMax = line;
tabContrast_lineMax.Parent = tabContrast_haxesLine;
tabContrast_lineMax.Color = [255 103 97]/255;
tabContrast_lineMax.LineWidth = 3;
tabContrast_lineMax.LineStyle = ':';
tabContrast_lineMin.YData = [0,1];
tabContrast_lineMax.YData = [0,1];
%% Handles
%   _  _              _ _
%  | || |__ _ _ _  __| | |___ ___
%  | __ / _` | ' \/ _` | / -_|_-<
%  |_||_\__,_|_||_\__,_|_\___/__/
%
% store the uicontrol handles in the figure handles via guidata()
%handles.tabContrast_findImageHistogram = @tabContrast_findImageHistogram;
%handles.contrastHistogram;
handles.tabContrast_haxesLine = tabContrast_haxesLine;
handles.tabContrast_lineMin = tabContrast_lineMin;
handles.tabContrast_lineMax = tabContrast_lineMax;
handles.tabContrast_plot = tabContrast_plot;
handles.tabContrast_axesContrast = tabContrast_axesContrast;
handles.tabContrast_sliderMax = tabContrast_sliderMax;
handles.tabContrast_sliderMin = tabContrast_sliderMin;
handles.f = f;
%% Execute just before the figure becomes visible
%      _         _     ___ _ _
%   _ | |_  _ __| |_  | _ ) | |
%  | || | || (_-<  _| | _ \_  _|
%  _\__/_\_,_/__/\__| |___/ |_|
%  \ \ / (_)__(_) |__| |___
%   \ V /| (_-< | '_ \ / -_)
%    \_/ |_/__/_|_.__/_\___|
%
% The code above organizes and specifies the elements of the figure and
% gui. The code below may simple store these elements into the handles
% struct and make the gui visible for the first time. Other commands or
% functions can also be executed here if certain variables or parameters
% need to be computed and set.
tabContrast_axesContrast.ButtonDownFcn();
%%%
% send the handles struct to the guidata.
guidata(f,handles);
%%%
% make the gui visible
set(f,'Visible','on');

%% Callbacks and functions
%    ___      _ _ _             _
%   / __|__ _| | | |__  __ _ __| |__ ___
%  | (__/ _` | | | '_ \/ _` / _| / /(_-<
%   \___\__,_|_|_|_.__/\__,_\__|_\_\/__/
%    /_\ | \| |   \
%   / _ \| .` | |) |
%  /_/_\_\_|\_|___/ _   _
%  | __|  _ _ _  __| |_(_)___ _ _  ___
%  | _| || | ' \/ _|  _| / _ \ ' \(_-<
%  |_| \_,_|_||_\__|\__|_\___/_||_/__/
%
%%
%
    function fDeleteFcn(~,~)
        %do nothing. This means only the master object can close this
        %window.
        delete(f);
    end
%% Contrast Tab: callbacks and functions
%    ___         _               _     _____     _
%   / __|___ _ _| |_ _ _ __ _ __| |_  |_   _|_ _| |__
%  | (__/ _ \ ' \  _| '_/ _` (_-<  _|   | |/ _` | '_ \
%   \___\___/_||_\__|_| \__,_/__/\__|   |_|\__,_|_.__/
%
%%
%
    function [] = tabContrast_findImageHistogram()
        handlesImageViewer = guidata(trackman.gui_imageViewer);
        [handles.contrastHistogram,~] = histcounts(reshape(handlesImageViewer.image,1,[]),-0.5:1:255.5);
    end
%%
%
    function tabContrast_axesContrast_ButtonDownFcn(~,~)
        %%%
        % create the contrast histogram to be displayed in the axes
        handles.tabContrast_findImageHistogram();
        tabContrast_plot.YData = handles.contrastHistogram;
        tabContrastLineUpdate;
    end
%%
%
    function sliderMax_Callback(~,~)
        sstep = tabContrast_sliderMax.SliderStep;
        mymax = tabContrast_sliderMax.Value;
        mymin = tabContrast_sliderMin.Value;
        if mymax == 0
            tabContrast_sliderMax.Value = sstep(1);
            tabContrast_sliderMin.Value = 0;
        elseif mymax <= mymin
            tabContrast_sliderMin.Value = mymax-sstep(1);
        end
        newColormapFromContrastHistogram;
        tabContrastLineUpdate;
    end
%%
%
    function sliderMin_Callback(~,~)
        sstep = tabContrast_sliderMax.SliderStep;
        mymax = tabContrast_sliderMax.Value;
        mymin = tabContrast_sliderMin.Value;
        if mymin == 1
            tabContrast_sliderMax.Value = 1;
            tabContrast_sliderMin.Value = 1-sstep(1);
        elseif mymin >= mymax
            tabContrast_sliderMax.Value = mymin+sstep(1);
        end
        newColormapFromContrastHistogram;
        tabContrastLineUpdate;
    end
%%
%
    function [] = tabContrastLineUpdate()
        tabContrast_lineMin.XData = [tabContrast_sliderMin.Value,tabContrast_sliderMin.Value];
        tabContrast_lineMax.XData = [tabContrast_sliderMax.Value,tabContrast_sliderMax.Value];
    end
%% newColormapFromContrastHistogram
% Assumes image is uint8 0-255.
    function [] = newColormapFromContrastHistogram()
        sstep = tabContrast_sliderMin.SliderStep;
        mymin = ceil(tabContrast_sliderMin.Value/sstep(1));
        mymax = ceil(tabContrast_sliderMax.Value/sstep(1));
        cmap = colormap(gray(mymax-mymin+1));
        cmap = vertcat(zeros(mymin,3),cmap,ones(255-mymax,3));
        handlesImageViewer = guidata(trackman.gui_imageViewer);
        handlesImageViewer.f.Colormap = cmap;
    end
end