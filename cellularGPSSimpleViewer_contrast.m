%% cellularGPSSimpleViewer_object
%
classdef cellularGPSSimpleViewer_contrast < handle
    %% cellularGPSSimpleViewer_object
    % # Create object
    % # Specify movie directory. The movie directory should already have a
    % database file and itinerary
    % # Check for thumb images. Reading images from a spinning disk or network
    % is slow. Keeping images small minimizes this effect. Also, check for
    % _PROCESSED_DATA_ or _RAW_DATA_. Update image path accordingly.
    % # Launch the image viewer.
    %% Properties
    %   ___                       _   _
    %  | _ \_ _ ___ _ __  ___ _ _| |_(_)___ ___
    %  |  _/ '_/ _ \ '_ \/ -_) '_|  _| / -_|_-<
    %  |_| |_| \___/ .__/\___|_|  \__|_\___/__/
    %              |_|
    %
    properties
        imag3; %named with a number so it doesn't interfere with the built-in _image_ command.
        imag3dir;
        imag3path;
        image_width;
        image_height;
        gui_main; %the main viewer figure handle
        kybrd_cmd; %a struct of function handles for keyboard commands
        
        indT = 1;
        indG = 1;
        indP = 1;
        indS = 1;
        
        tblG;
        tblP;
        tblS;
        tblRegister;
        
        stepSize = 1;
        
        smda_itinerary;
        smda_database;
        moviePath;

        viewer;
        
        contrastHistogram;
    end
    %% Methods
    %   __  __     _   _            _
    %  |  \/  |___| |_| |_  ___  __| |___
    %  | |\/| / -_)  _| ' \/ _ \/ _` (_-<
    %  |_|  |_\___|\__|_||_\___/\__,_/__/
    %
    methods
        %% The first method is the constructor
        %    ___             _               _
        %   / __|___ _ _  __| |_ _ _ _  _ __| |_ ___ _ _
        %  | (__/ _ \ ' \(_-<  _| '_| || / _|  _/ _ \ '_|
        %   \___\___/_||_/__/\__|_|  \_,_\__|\__\___/_|
        %
        %
        function obj = cellularGPSSimpleViewer_contrast()
            myunits = get(0,'units');
            set(0,'units','pixels');
            Pix_SS = get(0,'screensize');
            set(0,'units','characters');
            Char_SS = get(0,'screensize');
            ppChar = Pix_SS./Char_SS;
            set(0,'units',myunits);
            fwidth = 136.6; %683/ppChar(3);
            fheight = 70; %910/ppChar(4);
            fx = Char_SS(3) - (Char_SS(3)*.1 + fwidth);
            fy = Char_SS(4) - (Char_SS(4)*.1 + fheight);
            f = figure('Visible','off','Units','characters','MenuBar','none','Position',[fx fy fwidth fheight],...
                'CloseRequestFcn',{@fDeleteFcn},'Name','Scan6 Main');
            
            %% Create the axes that will show the contrast histogram
            % and the plot that will show the histogram
            hwidth = 104;
            hheight = 40;
            hx = (fwidth-hwidth)/2;
            hy = 10;
            tabContrast_axesContrast = axes('Parent',f,'Units','characters',...
                'Position',[hx hy hwidth hheight]);
            tabContrast_axesContrast.NextPlot = 'add';
            tabContrast_axesContrast.ButtonDownFcn = @obj.tabContrast_axesContrast_ButtonDownFcn;
            %%% semilogy plot
            %
            obj.tabContrast_findImageHistogram;
%             tabContrast_plot = semilogy(tabContrast_axesContrast,(0:255),obj.contrastHistogram,...
%                 'Color',[0 0 0]/255,...
%                 'LineWidth',3);
            tabContrast_axesContrast.YScale = 'log';
            tabContrast_axesContrast.XLim = [0,255];
            tabContrast_axesContrast.YLim(1) = 0;
            xlabel('Intensity');
            ylabel('Pixel Count');
            %% Create controls
            %  two slider bars
            hwidth = 112;
            hheight = 2;
            hx = (fwidth-hwidth)/2;
            hy = 5;
            %%% sliderMax
            %
            sliderStep = 1/(256 - 1);
            tabContrast_sliderMax = uicontrol('Parent',f,'Style','slider','Units','characters',...
                'Min',0,'Max',1,'BackgroundColor',[255 255 255]/255,...
                'Value',1,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
                'Callback',{@obj.tabContrast_sliderMax_Callback});
            
            hx = (fwidth-hwidth)/2;
            hy = 2;
            %%% sliderMin
            %
            sliderStep = 1/(256 - 1);
            tabContrast_sliderMin= uicontrol('Parent',f,'Style','slider','Units','characters',...
                'Min',0,'Max',1,'BackgroundColor',[255 255 255]/255,...
                'Value',0,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
                'Callback',{@obj.tabContrast_sliderMin_Callback});
            %% Lines for the min and max contrast levels
            %
            hwidth = 104;
            hheight = 40;
            hx = (fwidth-hwidth)/2;
            hy = 10;
            tabContrast_haxesLine = axes('Parent',f,'Units','characters',...
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
            tabContrast_lineMin.YData = [0,1];
            tabContrast_lineMax = line;
            tabContrast_lineMax.Parent = tabContrast_haxesLine;
            tabContrast_lineMax.Color = [255 103 97]/255;
            tabContrast_lineMax.LineWidth = 3;
            tabContrast_lineMax.LineStyle = ':';
            tabContrast_lineMax.YData = [0,1];
            %%
            % make the gui visible
            set(f,'Visible','on');
        end
        %%
        % set the viewer object for this to work
        function obj = initialize(obj)
        %%
        %
        function obj = refresh(obj)
            
        end
        %%
        %
        function obj = tabContrast_findImageHistogram(obj)
            [obj.contrastHistogram,~] = histcounts(reshape(obj.imag3,1,[]),-0.5:1:255.5);
        end
        %%
        %
        function obj = tabContrast_axesContrast_ButtonDownFcn(obj,~,~)
            %%%
            % create the contrast histogram to be displayed in the axes
            handles = guidata(obj.gui_main);
            obj.tabContrast_findImageHistogram;
            handles.tabContrast_plot.YData = obj.contrastHistogram;
            obj.tabContrastLineUpdate;
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = tabContrast_sliderMax_Callback(obj,~,~)
            handles = guidata(obj.gui_main);
            sstep = handles.tabContrast_sliderMax.SliderStep;
            mymax = handles.tabContrast_sliderMax.Value;
            mymin = handles.tabContrast_sliderMin.Value;
            if mymax == 0
                handles.tabContrast_sliderMax.Value = sstep(1);
                handles.tabContrast_sliderMin.Value = 0;
            elseif mymax <= mymin
                handles.tabContrast_sliderMin.Value = mymax-sstep(1);
            end
            obj.tabContrast_newColormapFromContrastHistogram;
            obj.tabContrastLineUpdate;
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = tabContrast_sliderMin_Callback(obj,~,~)
            handles = guidata(obj.gui_main);
            sstep = handles.tabContrast_sliderMax.SliderStep;
            mymax = handles.tabContrast_sliderMax.Value;
            mymin = handles.tabContrast_sliderMin.Value;
            if mymin == 1
                handles.tabContrast_sliderMax.Value = 1;
                handles.tabContrast_sliderMin.Value = 1-sstep(1);
            elseif mymin >= mymax
                handles.tabContrast_sliderMax.Value = mymin+sstep(1);
            end
            obj.tabContrast_newColormapFromContrastHistogram;
            obj.tabContrastLineUpdate;
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = tabContrastLineUpdate(obj)
            handles = guidata(obj.gui_main);
            handles.tabContrast_lineMin.XData = [handles.tabContrast_sliderMin.Value,handles.tabContrast_sliderMin.Value];
            handles.tabContrast_lineMax.XData = [handles.tabContrast_sliderMax.Value,handles.tabContrast_sliderMax.Value];
            guidata(obj.gui_main,handles);
        end
        %% newColormapFromContrastHistogram
        % Assumes image is uint8 0-255.
        function obj = tabContrast_newColormapFromContrastHistogram(obj)
            handles = guidata(obj.gui_main);
            sstep = handles.tabContrast_sliderMin.SliderStep;
            mymin = ceil(handles.tabContrast_sliderMin.Value/sstep(1));
            mymax = ceil(handles.tabContrast_sliderMax.Value/sstep(1));
            cmap = colormap(gray(mymax-mymin+1));
            cmap = vertcat(zeros(mymin,3),cmap,ones(255-mymax,3));
            obj.tmn.gui_imageViewer.gui_main.Colormap = cmap;
        end
    end
end