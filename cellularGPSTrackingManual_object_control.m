classdef cellularGPSTrackingManual_object_control < handle
    %% Properties
    %   ___                       _   _
    %  | _ \_ _ ___ _ __  ___ _ _| |_(_)___ ___
    %  |  _/ '_/ _ \ '_ \/ -_) '_|  _| / -_|_-<
    %  |_| |_| \___/ .__/\___|_|  \__|_\___/__/
    %              |_|
    %
    properties
        tmn; %the cellularGPSTrackingManual_object
        imag3;
        image_width;
        image_height;
        gui_main;
        
        contrastHistogram
        
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
        function obj = cellularGPSTrackingManual_object_control(tmn)
            %%%
            % parse the input
            q = inputParser;
            addRequired(q, 'tmn', @(x) isa(x,'cellularGPSTrackingManual_object'));
            parse(q,tmn);
            %%
            %
            obj.tmn = q.Results.tmn;
            obj.imag3 = imread(fullfile(tmn.moviePath,'.thumb',tmn.smda_databaseSubset.filename{tmn.indImage}));
            obj.image_width = size(obj.imag3,2);
            obj.image_height = size(obj.imag3,1);
            %% Create a gui to enable pausing and stopping
            %    ___ _   _ ___    ___              _   _
            %   / __| | | |_ _|  / __|_ _ ___ __ _| |_(_)___ _ _
            %  | (_ | |_| || |  | (__| '_/ -_) _` |  _| / _ \ ' \
            %   \___|\___/|___|  \___|_| \___\__,_|\__|_\___/_||_|
            %   / _|___ _ _
            %  |  _/ _ \ '_|  __  __      _
            %  |_| \___/_(_) |  \/  |__ _(_)_ _
            %  / _` | || | | | |\/| / _` | | ' \
            %  \__, |\_,_|_|_|_|  |_\__,_|_|_||_|
            %  |___/      |___|
            % Create the figure
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
                'CloseRequestFcn',{@delete},'Name','Travel Agent Main');
            tabgp = uitabgroup(f,'Position',[0,0,1,1]);
            tabGPS = uitab(tabgp,'Title','GPS');
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
            %% Contrast Tab: gui
            %    ___         _               _     _____     _
            %   / __|___ _ _| |_ _ _ __ _ __| |_  |_   _|_ _| |__
            %  | (__/ _ \ ' \  _| '_/ _` (_-<  _|   | |/ _` | '_ \
            %   \___\___/_||_\__|_| \__,_/__/\__|   |_|\__,_|_.__/
            %
            %% Create the axes that will show the contrast histogram
            % and the plot that will show the histogram
            hwidth = 104;
            hheight = 40;
            hx = (fwidth-hwidth)/2;
            hy = 20;
            tabContrast_axesContrast = axes('Parent',tabContrast,'Units','characters',...
                'Position',[hx hy hwidth hheight]);
            tabContrast_axesContrast.NextPlot = 'add';
            tabContrast_axesContrast.ButtonDownFcn = @obj.tabContrast_axesContrast_ButtonDownFcn;
            %%% semilogy plot
            %
            obj.tabContrast_findImageHistogram;
            tabContrast_plot = semilogy(tabContrast_axesContrast,(0:255),obj.contrastHistogram,...
                'Color',[0 0 0]/255,...
                'LineWidth',3);
            tabContrast_axesContrast.YScale = 'log';
            tabContrast_axesContrast.XLim = [0,255];
            tabContrast_axesContrast.YLim(1) = 0;
            xlabel('Intensity');
            ylabel('Pixel Count');
            %% Create controls
            %  two slider bars
            hwidth = 104;
            hheight = 2;
            hx = (fwidth-hwidth)/2;
            hy = 10;
            %%% sliderMax
            %
            sliderStep = 1/(256 - 1);
            tabContrast_sliderMax = uicontrol('Parent',tabContrast,'Style','slider','Units','characters',...
                'Min',0,'Max',1,'BackgroundColor',[255 255 255]/255,...
                'Value',1,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
                'Callback',{@obj.tabContrast_sliderMax_Callback});
            
            hx = (fwidth-hwidth)/2;
            hy = 5;
            %%% sliderMin
            %
            sliderStep = 1/(256 - 1);
            tabContrast_sliderMin= uicontrol('Parent',tabContrast,'Style','slider','Units','characters',...
                'Min',0,'Max',1,'BackgroundColor',[255 255 255]/255,...
                'Value',0,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
                'Callback',{@obj.tabContrast_sliderMin_Callback});
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
            tabContrast_lineMin.YData = [0,1];
            tabContrast_lineMax = line;
            tabContrast_lineMax.Parent = tabContrast_haxesLine;
            tabContrast_lineMax.Color = [255 103 97]/255;
            tabContrast_lineMax.LineWidth = 3;
            tabContrast_lineMax.LineStyle = ':';
            tabContrast_lineMax.YData = [0,1];
            
            %% SMDA Tab: gui
            %    ___ ___  ___   _____     _
            %   / __| _ \/ __| |_   _|_ _| |__
            %  | (_ |  _/\__ \   | |/ _` | '_ \
            %   \___|_|  |___/   |_|\__,_|_.__/
            %
            region1 = [0 56.1538]; %[0 730/ppChar(4)]; %180 pixels
            region2 = [0 42.3077]; %[0 550/ppChar(4)]; %180 pixels
            region3 = [0 13.8462]; %[0 180/ppChar(4)]; %370 pixels
            region4 = [0 0]; %180 pixels
            
            hwidth = 104;
            hx = (fwidth-hwidth)/2;
            %% The group table
            %
            tabGPS_tableGroup = uitable('Parent',tabGPS,'Units','characters',...
                'BackgroundColor',[textBackgroundColorRegion2;buttonBackgroundColorRegion2],...
                'ColumnName',{'label','group #','# of positions'},...
                'ColumnEditable',logical([0,0,0]),...
                'ColumnFormat',{'char','numeric','numeric'},...
                'ColumnWidth',{'auto' 'auto' 'auto'},...
                'FontSize',8,'FontName','Verdana',...
                'CellSelectionCallback',@obj.tabGPS_tableGroup_CellSelectionCallback,...
                'Position',[hx, region2(2)+0.7692, hwidth, 13.0769]);
            
            %% The position table
            %
            tabGPS_tablePosition = uitable('Parent',tabGPS,'Units','characters',...
                'BackgroundColor',[textBackgroundColorRegion3;buttonBackgroundColorRegion3],...
                'ColumnName',{'label','position #','X','Y','Z','# of settings'},...
                'ColumnEditable',logical([0,0,0,0,0,0]),...
                'ColumnFormat',{'char','numeric','numeric','numeric','numeric','numeric'},...
                'ColumnWidth',{'auto' 'auto' 'auto' 'auto' 'auto' 'auto'},...
                'FontSize',8,'FontName','Verdana',...
                'CellSelectionCallback',@obj.tabGPS_tablePosition_CellSelectionCallback,...
                'Position',[hx, region3(2)+0.7692, hwidth, 28.1538]);
            %% The settings table
            %
            
            tabGPS_tableSettings = uitable('Parent',tabGPS,'Units','characters',...
                'BackgroundColor',[textBackgroundColorRegion4;buttonBackgroundColorRegion4],...
                'ColumnName',{'channel','exposure','settings #'},...
                'ColumnEditable',logical([0,0,0]),...
                'ColumnFormat',{obj.tmn.ity.channel_names(1),'numeric','numeric'},...
                'ColumnWidth',{'auto' 'auto' 'auto'},...
                'FontSize',8,'FontName','Verdana',...
                'CellSelectionCallback',@obj.tabGPS_tableSettings_CellSelectionCallback,...
                'Position',[hx, region4(2)+0.7692, hwidth, 13.0769]);
            %% Handles
            %   _  _              _ _
            %  | || |__ _ _ _  __| | |___ ___
            %  | __ / _` | ' \/ _` | / -_|_-<
            %  |_||_\__,_|_||_\__,_|_\___/__/
            %
            % store the uicontrol handles in the figure handles via guidata()
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
            
            handles.tabGPS_tableGroup = tabGPS_tableGroup;
            handles.tabGPS_tablePosition = tabGPS_tablePosition;
            handles.tabGPS_tableSettings = tabGPS_tableSettings;
            
            obj.gui_main = f;
            guidata(f,handles);
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
            obj.tabContrast_axesContrast_ButtonDownFcn;
            obj.tabGPS_refresh
            %%%
            % make the gui visible
            set(f,'Visible','on');
        end
        %% delete
        % for a clean delete make sure the objects that are stored as
        % properties are also deleted.
        function delete(obj)
            delete(obj.gui_main);
        end
        %% Contrast Tab: callbacks and functions
        %    ___         _               _     _____     _
        %   / __|___ _ _| |_ _ _ __ _ __| |_  |_   _|_ _| |__
        %  | (__/ _ \ ' \  _| '_/ _` (_-<  _|   | |/ _` | '_ \
        %   \___\___/_||_\__|_| \__,_/__/\__|   |_|\__,_|_.__/
        %
        %%
        %
        function obj = tabContrast_findImageHistogram(obj)
            [obj.contrastHistogram,~] = histcounts(reshape(obj.tmn.gui_imageViewer.imag3,1,[]),-0.5:1:255.5);
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
        %% GPS Tab: callbacks
        %    ___ ___  ___   _____     _
        %   / __| _ \/ __| |_   _|_ _| |__
        %  | (_ |  _/\__ \   | |/ _` | '_ \
        %   \___|_|  |___/   |_|\__,_|_.__/
        %
        %%
        %
        function obj = tabGPS_tableGroup_CellSelectionCallback(obj,~,eventdata)
            %%%
            % The main purpose of this function is to keep the information
            % displayed in the table consistent with the Itinerary object.
            % Changes to the object either through the command line or the gui
            % can affect the information that is displayed in the gui and this
            % function will keep the gui information consistent with the
            % Itinerary information.
            %
            % The pointer of the TravelAgent should always point to a valid
            % group from the the group_order.
            if isempty(eventdata.Indices)
                % if nothing is selected, which triggers after deleting data,
                % make sure the pointer is still valid
                if any(obj.tmn.pointerGroup > obj.tmn.ity.number_group)
                    % move pointer to last entry
                    obj.tmn.pointerGroup = obj.tmn.ity.number_group;
                end
                return
            else
                obj.tmn.pointerGroup = sort(unique(eventdata.Indices(:,1)));
            end
            
            myGroupOrder = obj.ity.order_group;
            gInd = myGroupOrder(obj.pointerGroup(1));
            if any(obj.pointerPosition > obj.ity.number_position(gInd))
                % move pointer to first entry
                obj.pointerPosition = 1;
            end
            
            obj.tabGPS_refresh;
            obj.tmn.gui_imageViewer.loadNewTracks;
            obj.tmn.gui_imageViewer.refresh;
        end
        %%
        %
        function obj = tabGPS_tablePosition_CellSelectionCallback(obj,~,eventdata)
            %%%
            % The main purpose of this function is to keep the information
            % displayed in the table consistent with the Itinerary object.
            % Changes to the object either through the command line or the gui
            % can affect the information that is displayed in the gui and this
            % function will keep the gui information consistent with the
            % Itinerary information.
            %
            % The pointer of the TravelAgent should always point to a valid
            % position from the the position_order in a given group.
            myGroupOrder = obj.tmn.ity.order_group;
            gInd = myGroupOrder(obj.tmn.pointerGroup(1));
            if isempty(eventdata.Indices)
                % if nothing is selected, which triggers after deleting data,
                % make sure the pointer is still valid
                if any(obj.tmn.pointerPosition > obj.tmn.ity.number_position(gInd))
                    % move pointer to last entry
                    obj.tmn.pointerPosition = obj.tmn.ity.number_position(gInd);
                end
                return
            else
                obj.tmn.pointerPosition = sort(unique(eventdata.Indices(:,1)));
            end
            obj.tabGPS_refresh;
            obj.tmn.gui_imageViewer.loadNewTracks;
            obj.tmn.gui_imageViewer.refresh;
        end
        %%
        %
        function obj = tabGPS_tableSettings_CellSelectionCallback(obj,~,eventdata)
            %%%
            % The |Travel Agent| aims to recreate the experience that
            % microscope users expect from a multi-dimensional acquistion tool.
            % Therefore, most of the customizability is masked by the
            % |TravelAgent| to provide a streamlined presentation and simple
            % manipulation of the |Itinerary|. Unlike the group and position
            % tables, which edit the itinerary directly, the settings table
            % will modify the the prototype, which will then be pushed to all
            % positions in a group.
            myGroupOrder = obj.tmn.ity.order_group;
            gInd = myGroupOrder(obj.tmn.pointerGroup(1));
            pInd = obj.tmn.ity.ind_position{gInd};
            pInd = pInd(1);
            if isempty(eventdata.Indices)
                % if nothing is selected, which triggers after deleting data,
                % make sure the pointer is still valid
                if any(obj.tmn.pointerSettings > obj.tmn.ity.number_settings{pInd})
                    % move pointer to last entry
                    obj.tmn.pointerSettings = obj.tmn.ity.number_settings(pInd);
                end
                return
            else
                obj.tmn.pointerSettings = sort(unique(eventdata.Indices(:,1)));
            end
            obj.tabGPS_refresh;
            obj.tmn.gui_imageViewer.refresh;
        end
        %%
        %
        function obj = tabGPS_refresh(obj)
            handles = guidata(obj.gui_main);
            %% Group Table
            % Show the data in the itinerary |group_order| property
            tableGroupData = cell(obj.tmn.ity.number_group,...
                length(get(handles.tabGPS_tableGroup,'ColumnName')));
            n=0;
            for i = obj.tmn.ity.order_group
                n = n + 1;
                tableGroupData{n,1} = obj.tmn.ity.group_label{i};
                tableGroupData{n,2} = i;
                tableGroupData{n,3} = obj.tmn.ity.number_position(i);
            end
            set(handles.tabGPS_tableGroup,'Data',tableGroupData);
            %% Region 3
            %
            %% Position Table
            % Show the data in the itinerary |position_order| property for a given
            % group
            myGroupOrder = obj.tmn.ity.order_group;
            gInd = myGroupOrder(obj.tmn.pointerGroup(1));
            myPositionOrder = obj.tmn.ity.order_position{gInd};
            tablePositionData = cell(length(myPositionOrder),...
                length(get(handles.tabGPS_tablePosition,'ColumnName')));
            n=0;
            for i = myPositionOrder
                n = n + 1;
                tablePositionData{n,1} = obj.tmn.ity.position_label{i};
                tablePositionData{n,2} = i;
                tablePositionData{n,3} = obj.tmn.ity.position_xyz(i,1);
                tablePositionData{n,4} = obj.tmn.ity.position_xyz(i,2);
                tablePositionData{n,5} = obj.tmn.ity.position_xyz(i,3);
                tablePositionData{n,6} = obj.tmn.ity.number_settings(i);
            end
            set(handles.tabGPS_tablePosition,'Data',tablePositionData);
            %% Region 4
            %
            %% Settings Table
            % Show the prototype_settings
            pInd = obj.tmn.ity.ind_position{gInd};
            pInd = pInd(1);
            mySettingsOrder = obj.tmn.ity.order_settings{pInd};
            tableSettingsData = cell(length(mySettingsOrder),...
                length(get(handles.tabGPS_tableSettings,'ColumnName')));
            n=1;
            for i = mySettingsOrder
                tableSettingsData{n,1} = obj.tmn.ity.channel_names{obj.tmn.ity.settings_channel(i)};
                tableSettingsData{n,2} = obj.tmn.ity.settings_exposure(i);
                tableSettingsData{n,3} = i;
                n = n + 1;
            end
            set(handles.tabGPS_tableSettings,'Data',tableSettingsData);
            %% obj.tmn indices
            myGroupOrder = obj.tmn.ity.order_group;
            obj.tmn.indG = myGroupOrder(obj.tmn.pointerGroup(1));
            myPositionOrder = obj.tmn.ity.ind_position{gInd};
            obj.tmn.indP = myPositionOrder(obj.tmn.pointerPosition(1));
            mySettingsOrder = obj.tmn.ity.ind_settings{pInd};
            obj.tmn.indS = mySettingsOrder(obj.tmn.pointerSettings(1));
            obj.tmn.updateFilenameListImage;
        end
    end
end