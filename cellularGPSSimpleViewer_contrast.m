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
        histogramEdges;
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
            fwidth = 68.3; %683/ppChar(3);
            fheight = 35; %910/ppChar(4);
            fx = Char_SS(3) - (Char_SS(3)*.1 + fwidth);
            fy = Char_SS(4) - (Char_SS(4)*.1 + fheight);
            f = figure('Visible','off','Units','characters','MenuBar','none','Position',[fx fy fwidth fheight],...
                'CloseRequestFcn',{@fDeleteFcn},'Name','Scan6 Main');
            
            %% Create the axes that will show the contrast histogram
            % and the plot that will show the histogram
            hwidth = 52;
            hheight = 20;
            hx = (fwidth-hwidth)*0.6;
            hy = 8;
            Contrast_axesContrast = axes('Parent',f,'Units','characters',...
                'Position',[hx hy hwidth hheight]);
            Contrast_axesContrast.NextPlot = 'add';
            Contrast_axesContrast.ButtonDownFcn = @obj.Contrast_axesContrast_ButtonDownFcn;
            %%% semilogy plot
            %
            Contrast_plot = semilogy(Contrast_axesContrast,(0:255),rand(256,1),...
                'Color',[0 0 0]/255,...
                'LineWidth',3);
            Contrast_axesContrast.YScale = 'log';
            Contrast_axesContrast.XLim = [0,255];
            Contrast_axesContrast.YLim(1) = 0;
            Contrast_axesContrast.FontSize = 8;
            Contrast_axesContrast.XLabel.String = 'Intensity';
            Contrast_axesContrast.YLabel.String = 'Pixel Count';
            %% Create controls
            %  two slider bars
            hwidth = 56;
            hheight = 1.5;
            hx = (fwidth-hwidth)/2;
            hy = 3.25;
            %%% sliderMax
            %
            sliderStep = 1/(256 - 1);
            Contrast_sliderMax = uicontrol('Parent',f,'Style','slider','Units','characters',...
                'Min',0,'Max',1,'BackgroundColor',[255 255 255]/255,...
                'Value',1,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
                'Callback',{@obj.Contrast_sliderMax_Callback});
            
            hx = (fwidth-hwidth)/2;
            hy = 1;
            %%% sliderMin
            %
            sliderStep = 1/(256 - 1);
            Contrast_sliderMin= uicontrol('Parent',f,'Style','slider','Units','characters',...
                'Min',0,'Max',1,'BackgroundColor',[255 255 255]/255,...
                'Value',0,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
                'Callback',{@obj.Contrast_sliderMin_Callback});
            %% Lines for the min and max contrast levels
            %
            hwidth = 52;
            hheight = 20;
            hx = (fwidth-hwidth)*0.6;
            hy = 8;
            Contrast_haxesLine = axes('Parent',f,'Units','characters',...
                'Position',[hx hy hwidth hheight]);
            Contrast_haxesLine.NextPlot = 'add';
            Contrast_haxesLine.Visible = 'off';
            Contrast_haxesLine.YLim = [0,1];
            Contrast_haxesLine.XLim = [0,1];
            Contrast_lineMin = line;
            Contrast_lineMin.Parent = Contrast_haxesLine;
            Contrast_lineMin.Color = [29 97 175]/255;
            Contrast_lineMin.LineWidth = 3;
            Contrast_lineMin.LineStyle = ':';
            Contrast_lineMin.YData = [0,1];
            Contrast_lineMax = line;
            Contrast_lineMax.Parent = Contrast_haxesLine;
            Contrast_lineMax.Color = [255 103 97]/255;
            Contrast_lineMax.LineWidth = 3;
            Contrast_lineMax.LineStyle = ':';
            Contrast_lineMax.YData = [0,1];
            %%
            % make the gui visible
            set(f,'Visible','on');
            obj.gui_main = f;
            
            handles.Contrast_haxesLine = Contrast_haxesLine;
            handles.Contrast_lineMin = Contrast_lineMin;
            handles.Contrast_lineMax = Contrast_lineMax;
            handles.Contrast_plot = Contrast_plot;
            handles.Contrast_axesContrast = Contrast_axesContrast;
            handles.Contrast_sliderMax = Contrast_sliderMax;
            handles.Contrast_sliderMin = Contrast_sliderMin;
            guidata(obj.gui_main,handles);
        end
        %%
        % set the viewer object for this to work
        function obj = initialize(obj)
            obj.imag3 = reshape(obj.viewer.imag3,1,[]);
            obj.autoEdges;
            %%%
            % create the contrast histogram to be displayed in the axes
            handles = guidata(obj.gui_main);
            obj.Contrast_findImageHistogram;
            handles.Contrast_plot.YData = obj.contrastHistogram;
            obj.ContrastLineUpdate;
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = refresh(obj)
            
        end
        %%
        % A simple way to determine the edges of the histogram
        function obj = autoEdges(obj)
            mymax = double(quantile(obj.imag3,0.95));
            mymin = double(quantile(obj.imag3,0.05));
            obj.histogramEdges = mymin-0.5:(mymax-mymin)/256:mymax+0.5;
        end
        %%
        %
        function obj = Contrast_findImageHistogram(obj)
            [obj.contrastHistogram,~] = histcounts(obj.imag3,obj.histogramEdges);
        end
        %%
        %
        function obj = Contrast_axesContrast_ButtonDownFcn(obj,~,~)
            %%%
            % create the contrast histogram to be displayed in the axes
            handles = guidata(obj.gui_main);
            obj.Contrast_findImageHistogram;
            handles.Contrast_plot.YData = obj.contrastHistogram/max(obj.contrastHistogram);
            obj.ContrastLineUpdate;
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = Contrast_sliderMax_Callback(obj,~,~)
            handles = guidata(obj.gui_main);
            sstep = handles.Contrast_sliderMax.SliderStep;
            mymax = handles.Contrast_sliderMax.Value;
            mymin = handles.Contrast_sliderMin.Value;
            if mymax == 0
                handles.Contrast_sliderMax.Value = sstep(1);
                handles.Contrast_sliderMin.Value = 0;
            elseif mymax <= mymin
                handles.Contrast_sliderMin.Value = mymax-sstep(1);
            end
            obj.Contrast_newColormapFromContrastHistogram;
            obj.ContrastLineUpdate;
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = Contrast_sliderMin_Callback(obj,~,~)
            handles = guidata(obj.gui_main);
            sstep = handles.Contrast_sliderMax.SliderStep;
            mymax = handles.Contrast_sliderMax.Value;
            mymin = handles.Contrast_sliderMin.Value;
            if mymin == 1
                handles.Contrast_sliderMax.Value = 1;
                handles.Contrast_sliderMin.Value = 1-sstep(1);
            elseif mymin >= mymax
                handles.Contrast_sliderMax.Value = mymin+sstep(1);
            end
            obj.Contrast_newColormapFromContrastHistogram;
            obj.ContrastLineUpdate;
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = ContrastLineUpdate(obj)
            handles = guidata(obj.gui_main);
            handles.Contrast_lineMin.XData = [handles.Contrast_sliderMin.Value,handles.Contrast_sliderMin.Value];
            handles.Contrast_lineMax.XData = [handles.Contrast_sliderMax.Value,handles.Contrast_sliderMax.Value];
            guidata(obj.gui_main,handles);
        end
        %% newColormapFromContrastHistogram
        % Assumes image is uint8 0-255.
        function obj = Contrast_newColormapFromContrastHistogram(obj)
            handles = guidata(obj.gui_main);
            sstep = handles.Contrast_sliderMin.SliderStep;
            mymin = ceil(handles.Contrast_sliderMin.Value/sstep(1));
            mymax = ceil(handles.Contrast_sliderMax.Value/sstep(1));
            cmap = colormap(gray(mymax-mymin+1));
            cmap = vertcat(zeros(mymin,3),cmap,ones(255-mymax,3));
            obj.viewer.gui_main.Colormap = cmap;
        end
    end
end