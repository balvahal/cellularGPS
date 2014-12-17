function [f] = cellularGPSTrackingManual_gui_control(trackman)
%% Create the figure
%
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

%% Add contrast histogram to the the _tabContrast_
%
%%% Create the axes that will show the contrast histogram
% 
hwidth = 52;
hheight = 20;
hx = (fwidth-hwidth)/2;
hy = 45;
haxesContrast = axes('Parent',tabContrast,'Units','characters',...
    'Position',[hx hy hwidth hheight]);
%%%
% create the contrast histogram to be displayed in the axes
handles.findImageHistogram = @findImageHistogram;
handles.findImageHistogram();
plot(haxesContrast,handles.contrastHistogram);
xlabel('Intensity');
%%% Create controls
%  two slider bars
hwidth = 52;
hheight = 2;
hx = (fwidth-hwidth)/2;
hy = 40;

sliderStep = 1/(256 - 1);
hsliderMax = uicontrol('Parent',tabContrast,'Style','slider','Units','characters',...
    'Min',0,'Max',1,'BackgroundColor',[255 215 0]/255,...
    'Value',1,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
    'Callback',{@sliderMax_Callback});

hx = (fwidth-hwidth)/2;
hy = 35;

sliderStep = 1/(256 - 1);
hsliderMin= uicontrol('Parent',tabContrast,'Style','slider','Units','characters',...
    'Min',0,'Max',1,'BackgroundColor',[40 215 100]/255,...
    'Value',0,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
    'Callback',{@sliderMin_Callback});
%%%
% store the uicontrol handles in the figure handles via guidata()
handles.axesContrast = haxesContrast;
handles.sliderMax = hsliderMax;
handles.sliderMin = hsliderMin;
guidata(f,handles);

%guidata(f,handles);
%%
% make the gui visible
set(f,'Visible','on');

%% Callbacks
%
%%
%
    function fDeleteFcn(~,~)
        %do nothing. This means only the master object can close this
        %window.
        delete(f);
    end
%% Contrast Tab
%
%%
%
    function [] = findImageHistogram()
        handlesImageViewer = guidata(trackman.gui_imageViewer);
        handles.contrastHistogram = hist(reshape(handlesImageViewer.image,1,[]),-0.5:1:255.5);
    end
%%
%
    function sliderMax_Callback(~,~)
        sstep = hsliderMax.SliderStep;
        mymax = hsliderMax.Value;
        mymin = hsliderMin.Value;
        if mymax == 0
            hsliderMax.Value = sstep(1);
            hsliderMin.Value = 0;
        elseif mymax <= mymin
            hsliderMin.Value = mymax-sstep(1);
        end 
        newColormapFromContrastHistogram;
    end
%%
%
    function sliderMin_Callback(~,~)
        sstep = get(hsliderMax,'SliderStep');
        mymax = get(hsliderMax,'Value');
        mymin = get(hsliderMin,'Value');
        if mymin == 1
            set(hsliderMax,'Value',1);
            set(hsliderMin,'Value',1-sstep(1));
        elseif mymin >= mymax
            set(hsliderMax,'Value',mymin+sstep(1));
        end 
        newColormapFromContrastHistogram;
    end
        %% newColormapFromContrastHistogram
        % Assumes image is uint8 0-255.
        function [] = newColormapFromContrastHistogram()
            sstep = handles.sliderMin.SliderStep;
            mymin = ceil(handles.sliderMin.Value/sstep(1));
            mymax = ceil(handles.sliderMax.Value/sstep(1));
            cmap = colormap(gray(mymax-mymin+1));
            cmap = vertcat(zeros(mymin,3),cmap,ones(255-mymax,3));
            handlesImageViewer = guidata(trackman.gui_imageViewer);
            handlesImageViewer.f.Colormap = cmap;
%             handles3 = guidata(obj.gui_zoomMap);
%             colormap(handles3.axesZoomMap,cmap);
        end
end