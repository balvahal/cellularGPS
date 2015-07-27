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
        rgbBool = false;
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
            ppChar = ppChar([3,4]); %#ok<NASGU>
            set(0,'units',myunits);
            fwidth = 68.3; %683/ppChar(3);
            fheight = 35; %910/ppChar(4);
            fx = Char_SS(3) - (Char_SS(3)*.1 + fwidth);
            fy = Char_SS(4) - (Char_SS(4)*.1 + fheight);
            
            f = figure;
            f.Visible = 'off';
            f.Units = 'characters';
            f.MenuBar = 'none';
            f.Position = [fx fy fwidth fheight];
            f.CloseRequestFcn = {@fDeleteFcn};
            f.Name = 'Contrast';
            f.Resize = 'off';
            f.WindowButtonDownFcn = {@obj.fWindowButtonDownFcn};
            %% Create the axes that will show the contrast histogram
            % and the plot that will show the histogram
            hwidth = 52;
            hheight = 20;
            hx = (fwidth-hwidth)*0.6;
            hy = 8;
            axesContrast = axes;
            axesContrast.Parent = f;
            axesContrast.Units = 'characters';
            axesContrast.Position = [hx hy hwidth hheight];
            axesContrast.NextPlot = 'add';
            axesContrast.ButtonDownFcn = @obj.axesContrast_ButtonDownFcn;
            %%% semilogy plot
            %
            plot = semilogy(axesContrast,(0:255),rand(256,1),...
                'Color',[0 0 0]/255,...
                'LineWidth',3);
            axesContrast.YScale = 'log';
            axesContrast.XLim = [0,255];
            axesContrast.YLim(1) = 0;
            axesContrast.FontSize = 8;
            axesContrast.XLabel.String = 'Intensity';
            axesContrast.YLabel.String = 'Pixel Count';
            %% Create controls
            %  two slider bars
            hwidth = 60;
            hheight = 1.5;
            hx = (fwidth-hwidth)*0.7;
            hy = 3.25;
            %%% sliderMax
            %
            sliderStep = 1/(256 - 1);
            
            sliderMax = uicontrol;
            sliderMax.Parent = f;
            sliderMax.Style = 'slider';
            sliderMax.Units = 'characters';
            sliderMax.Min = 0;
            sliderMax.Max = 1;
            sliderMax.BackgroundColor = [255 255 255]/255;
            sliderMax.Value = 1;
            sliderMax.SliderStep = [sliderStep sliderStep];
            sliderMax.Position = [hx hy hwidth hheight];
            sliderMax.Callback = {@obj.sliderMax_Callback};
            hy = 1;
            %%% sliderMin
            %
            sliderStep = 1/(256 - 1);
            
            sliderMin = uicontrol;
            sliderMin.Parent = f;
            sliderMin.Style = 'slider';
            sliderMin.Units = 'characters';
            sliderMin.Min = 0;
            sliderMin.Max = 1;
            sliderMin.BackgroundColor = [255 255 255]/255;
            sliderMin.Value = 0;
            sliderMin.SliderStep = [sliderStep sliderStep];
            sliderMin.Position = [hx hy hwidth hheight];
            sliderMin.Callback = {@obj.sliderMin_Callback};
            %%
            %
            editMin = uicontrol;
            editMin.Parent = f;
            editMin.Style = 'edit';
            editMin.Units = 'characters';
            editMin.FontSize = 12;
            editMin.FontName = 'Verdana';
            editMin.String = num2str(1);
            editMin.Position = [10, 30, 20, 2];
            editMin.Callback = {@obj.editMin_Callback};
            
            textMin = uicontrol;
            textMin.Parent = f;
            textMin.Style = 'text';
            textMin.Units = 'characters';
            textMin.String = 'Min';
            textMin.FontSize = 10;
            textMin.FontName = 'Verdana';
            textMin.HorizontalAlignment = 'left';
            textMin.Position = [10, 32, 20, 1.5];
            
            editMax = uicontrol;
            editMax.Parent = f;
            editMax.Style = 'edit';
            editMax.Units = 'characters';
            editMax.FontSize = 12;
            editMax.FontName = 'Verdana';
            editMax.String = num2str(1);
            editMax.Position = [38.3, 30, 20, 2];
            editMax.Callback = {@obj.editMax_Callback};
            
            textMax = uicontrol;
            textMax.Parent = f;
            textMax.Style = 'text';
            textMax.Units = 'characters';
            textMax.String = 'Max';
            textMax.FontSize = 10;
            textMax.FontName = 'Verdana';
            textMax.HorizontalAlignment = 'left';
            textMax.Position = [38.3, 32, 20, 1.5];
            %% Lines for the min and max contrast levels
            %
            hwidth = 52;
            hheight = 20;
            hx = (fwidth-hwidth)*0.6;
            hy = 8;
            
            haxesLine = axes;
            haxesLine.Parent = f;
            haxesLine.Units = 'characters';
            haxesLine.Position = [hx hy hwidth hheight];
            haxesLine.NextPlot = 'add';
            haxesLine.Visible = 'off';
            haxesLine.YLim = [0,1];
            haxesLine.XLim = [0,1];
            
            lineMin = line;
            lineMin.Parent = haxesLine;
            lineMin.Color = [29 97 175]/255;
            lineMin.LineWidth = 3;
            lineMin.LineStyle = ':';
            lineMin.YData = [0,1];
            lineMax = line;
            lineMax.Parent = haxesLine;
            lineMax.Color = [255 103 97]/255;
            lineMax.LineWidth = 3;
            lineMax.LineStyle = ':';
            lineMax.YData = [0,1];
            %%
            % make the gui visible
            set(f,'Visible','on');
            obj.gui_main = f;
            
            handles.editMin = editMin;
            handles.editMax = editMax;
            handles.haxesLine = haxesLine;
            handles.lineMin = lineMin;
            handles.lineMax = lineMax;
            handles.plot = plot;
            handles.axesContrast = axesContrast;
            handles.sliderMax = sliderMax;
            handles.sliderMin = sliderMin;
            guidata(obj.gui_main,handles);
        end
        %%
        % set the viewer object for this to work
        function obj = initialize(obj)
            handles = guidata(obj.gui_main);
            obj.imag3 = reshape(obj.viewer.imag3,1,[]);
            obj.refresh;
            handles.sliderMin.Value = 0;
            handles.sliderMax.Value = 1;
            obj.ContrastLineUpdate;
            obj.newColormapFromContrastHistogram;
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = refresh(obj)
            obj.autoEdges;
            %%%
            % create the contrast histogram to be displayed in the axes
            obj.findImageHistogram;
            obj.ContrastLineUpdate;
        end
        %%
        % A simple way to determine the edges of the histogram
        function obj = autoEdges(obj)
            if isa(obj.imag3,'uint8')
                mymax = quantile(obj.imag3,0.98);
                mymin = quantile(obj.imag3,0.02);
                obj.histogramEdges = mymin:1:mymax;
            elseif isa(obj.imag3,'uint16') || isa(obj.imag3,'uint32') ||...
                    isa(obj.imag3,'uint64')
                mymax = double(quantile(obj.imag3,0.99));
                mymin = double(quantile(obj.imag3,0.01));
                if mymax - mymin < 100
                    binspan = 1;
                else
                    binspan = round((mymax-mymin)/100);
                end
                obj.histogramEdges = mymin:binspan:mymax;
            elseif isa(obj.imag3,'double')
                mymax = double(quantile(obj.imag3,0.98));
                mymin = double(quantile(obj.imag3,0.02));
                obj.histogramEdges = mymin:(mymax-mymin)/100:mymax;
            end
        end
        %%
        %
        function obj = findImageHistogram(obj)
            [obj.contrastHistogram,~] = histcounts(obj.imag3,obj.histogramEdges);
            handles = guidata(obj.gui_main);
            handles.plot.YData = obj.contrastHistogram/max(obj.contrastHistogram);
            handles.plot.XData = diff(obj.histogramEdges)/2+obj.histogramEdges(1:end-1);
            handles.axesContrast.XLim = [handles.plot.XData(1) handles.plot.XData(end)];
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = axesContrast_ButtonDownFcn(obj,~,~)
            obj.refresh;
        end
        %%
        %
        function obj = sliderMax_Callback(obj,~,~)
            handles = guidata(obj.gui_main);
            sstep = handles.sliderMax.SliderStep;
            mymax = handles.sliderMax.Value;
            mymin = handles.sliderMin.Value;
            if mymax == 0
                handles.sliderMax.Value = sstep(1);
                handles.sliderMin.Value = 0;
            elseif mymax <= mymin
                handles.sliderMin.Value = mymax-sstep(1);
            end
            obj.newColormapFromContrastHistogram;
            obj.ContrastLineUpdate;
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = sliderMin_Callback(obj,~,~)
            handles = guidata(obj.gui_main);
            sstep = handles.sliderMax.SliderStep;
            mymax = handles.sliderMax.Value;
            mymin = handles.sliderMin.Value;
            if mymin == 1
                handles.sliderMax.Value = 1;
                handles.sliderMin.Value = 1-sstep(1);
            elseif mymin >= mymax
                handles.sliderMax.Value = mymin+sstep(1);
            end
            obj.newColormapFromContrastHistogram;
            obj.ContrastLineUpdate;
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = ContrastLineUpdate(obj)
            handles = guidata(obj.gui_main);
            handles.lineMin.XData = [handles.sliderMin.Value,handles.sliderMin.Value];
            handles.lineMax.XData = [handles.sliderMax.Value,handles.sliderMax.Value];
            guidata(obj.gui_main,handles);
        end
        %% newColormapFromContrastHistogram
        %
        function obj = newColormapFromContrastHistogram(obj)
            if obj.viewer.rgbBool
                obj.viewer.update_Image;
            else
                handles = guidata(obj.gui_main);
                indexMin = floor((length(handles.plot.XData)-1)*handles.sliderMin.Value)+1;
                indexMax = floor((length(handles.plot.XData)-1)*handles.sliderMax.Value)+1;
                if indexMin == indexMax
                    indexMax = indexMin + 1;
                end
                myminValue = handles.plot.XData(indexMin);
                mymaxValue = handles.plot.XData(indexMax);
                handles.editMin.String = num2str(myminValue);
                handles.editMax.String = num2str(mymaxValue);
                
                handlesViewer = guidata(obj.viewer.gui_main);
                handlesViewer.axesImageViewer.CLim = [myminValue mymaxValue];
                guidata(obj.viewer.gui_main,handlesViewer);
                
                handlesZoom = guidata(obj.viewer.zoom.gui_main);
                handlesZoom.axesZoomMap.CLim = [myminValue mymaxValue];
                guidata(obj.viewer.zoom.gui_main,handlesZoom);
            end
        end
        %%
        %
        function obj = editMin_Callback(obj)
            
        end
        %%
        %
        function obj = editMax_Callback(obj)
            
        end
        %%
        %
        function obj = fWindowButtonDownFcn(obj,~,~)
           obj.refresh; 
        end
    end
end