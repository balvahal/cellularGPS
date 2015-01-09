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
        
        %%% menu
        %
        menu_viewTrackBool = true;
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
            f = figure('Visible','off','Units','characters','MenuBar','None','Position',[fx fy fwidth fheight],...
                'CloseRequestFcn',{@obj.delete},'Name','Travel Agent Main');
            muView = uimenu(f,'Label','View');
            muViewHT = uimenu(muView,'Label','Hide Tracks',...
                'Callback',@obj.menu_viewTracks);
            
            
            
            textBackgroundColorRegion1 = [37 124 224]/255; %tendoBlueLight
            buttonBackgroundColorRegion1 = [29 97 175]/255; %tendoBlueDark
            textBackgroundColorRegion2 = [56 165 95]/255; %tendoGreenLight
            buttonBackgroundColorRegion2 = [44 129 74]/255; %tendoGreenDark
            textBackgroundColorRegion3 = [255 214 95]/255; %tendoYellowLight
            buttonBackgroundColorRegion3 = [199 164 74]/255; %tendoYellowDark
            textBackgroundColorRegion4 = [255 103 97]/255; %tendoRedLight
            buttonBackgroundColorRegion4 = [199 80 76]/255; %tendoRedDark
            buttonSize = [20 3.0769]; %[100/ppChar(3) 40/ppChar(4)];
            %% Info Brick
            % The section of the gui that contains useful information and messages.
            %   ___       __       ___     _    _
            %  |_ _|_ _  / _|___  | _ )_ _(_)__| |__
            %   | || ' \|  _/ _ \ | _ \ '_| / _| / /
            %  |___|_||_|_| \___/ |___/_| |_\__|_\_\
            %
            infoBk_panelMessage = uipanel('Title','Message','Units','characters','Parent',f,...
                'Position',[0,65,fwidth,5]);
            infoBk_textMessage = uicontrol('Parent',infoBk_panelMessage,'Style','text','Units','characters','String','Happy Tracking!',...
                'FontSize',10,'FontName','Verdana','HorizontalAlignment','left',...
                'Position',[1, 0.5, fwidth-2, 3]);
            infoBk_panelInfo = uipanel('Title','Info','Units','characters','Parent',f,...
                'Position',[0,60,fwidth,5]);
            %% timepoint
            %
            infoBk_editTimepoint = uicontrol('Parent',infoBk_panelInfo,'Style','edit','Units','characters',...
                'FontSize',14,'FontName','Verdana',...
                'String',num2str(1),...
                'Position',[1, 0.5, 15,2.6923],...
                'Callback',{@obj.infoBk_editTimepoint_Callback});
            
            infoBk_textTimepoint = uicontrol('Parent',infoBk_panelInfo,'Style','text','Units','characters','String','timepoint',...
                'FontSize',10,'FontName','Verdana','HorizontalAlignment','left',...
                'Position',[17, 0.5, 20, 2.6923]);
            
            %% Tabs
            %   _____     _
            %  |_   _|_ _| |__ ___
            %    | |/ _` | '_ (_-<
            %    |_|\__,_|_.__/__/
            %
            tab_panel = uipanel('Title','Tabs','Units','characters','Parent',f,...
                'Position',[0,0,fwidth,60]);
            tabgp = uitabgroup(tab_panel,'Units','characters','Position',[0,0,fwidth,58.5]);
            tabGPS = uitab(tabgp,'Title','GPS');
            tabMakeCell = uitab(tabgp,'Title','MakeCell');
            tabContrast = uitab(tabgp,'Title','Contrast');
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
            hy = 10;
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
            hwidth = 112;
            hheight = 2;
            hx = (fwidth-hwidth)/2;
            hy = 5;
            %%% sliderMax
            %
            sliderStep = 1/(256 - 1);
            tabContrast_sliderMax = uicontrol('Parent',tabContrast,'Style','slider','Units','characters',...
                'Min',0,'Max',1,'BackgroundColor',[255 255 255]/255,...
                'Value',1,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
                'Callback',{@obj.tabContrast_sliderMax_Callback});
            
            hx = (fwidth-hwidth)/2;
            hy = 2;
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
            hy = 10;
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
            %%
            %   __  __      _        ___     _ _   _____     _
            %  |  \/  |__ _| |_____ / __|___| | | |_   _|_ _| |__
            %  | |\/| / _` | / / -_) (__/ -_) | |   | |/ _` | '_ \
            %  |_|  |_\__,_|_\_\___|\___\___|_|_|   |_|\__,_|_.__/
            %
            textBackgroundColorRegion1 = [37 124 224]/255; %tendoBlueLight
            buttonBackgroundColorRegion1 = [29 97 175]/255; %tendoBlueDark
            textBackgroundColorRegion2 = [56 165 95]/255; %tendoGreenLight
            buttonBackgroundColorRegion2 = [44 129 74]/255; %tendoGreenDark
            textBackgroundColorRegion3 = [255 214 95]/255; %tendoYellowLight
            buttonBackgroundColorRegion3 = [199 164 74]/255; %tendoYellowDark
            textBackgroundColorRegion4 = [255 103 97]/255; %tendoRedLight
            buttonBackgroundColorRegion4 = [199 80 76]/255; %tendoRedDark
            region1 = [0 46]; %[0 730/ppChar(4)]; %180 pixels
            region2 = [0 36]; %[0 550/ppChar(4)]; %180 pixels
            region3 = [0 13.8462]; %[0 180/ppChar(4)]; %370 pixels
            region4 = [0 0]; %180 pixels
            
            buttonSize = [20 3.0769]; %[100/ppChar(3) 40/ppChar(4)];
            buttongap = 2;
            hx = (fwidth-4*buttonSize(1)-4*buttongap)/2;
            %%
            %
            tabMakeCell_panelTrack = uipanel('Title','Track','Units','characters','Parent',tabMakeCell,...
                'Position',[0,region1(2),fwidth,10]);
            textColor = [255 235 205]/255;
            
            
            tabMakeCell_buttongroupTrack = uibuttongroup('Parent',tabMakeCell_panelTrack);
            tabMakeCell_buttongroupTrack.SelectionChangedFcn = @obj.tabMakeCell_buttongroupTrack_SelectionChangedFcn;
            
            tabMakeCell_togglebuttonNone = uicontrol('Parent',tabMakeCell_buttongroupTrack,'Style','togglebutton','Units','characters',...
                'FontSize',14,'FontName','Verdana','BackgroundColor',[139  69  19]/255,...
                'String','None',...
                'Position',[hx, 0.5, buttonSize(1),buttonSize(2)],...
                'ForegroundColor',textColor);
            
            uicontrol('Parent',tabMakeCell_panelTrack,'Style','text','Units','characters','String','do nothing',...
                'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion1,...
                'Position',[hx, buttonSize(2)+1, buttonSize(1),2.6923],...
                'ForegroundColor',textColor);
            
            tabMakeCell_togglebuttonJoin = uicontrol('Parent',tabMakeCell_buttongroupTrack,'Style','togglebutton','Units','characters',...
                'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion1,...
                'String','Join',...
                'Position',[hx + buttongap + buttonSize(1), 0.5, buttonSize(1),buttonSize(2)],...
                'ForegroundColor',textColor);
            
            uicontrol('Parent',tabMakeCell_panelTrack,'Style','text','Units','characters','String','Join two tracks',...
                'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion1,...
                'Position',[hx + buttongap + buttonSize(1),buttonSize(2)+1, buttonSize(1),2.6923],...
                'ForegroundColor',textColor);
            
            tabMakeCell_togglebuttonBreak = uicontrol('Parent',tabMakeCell_buttongroupTrack,'Style','togglebutton','Units','characters',...
                'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion1,...
                'String','Break',...
                'Position',[hx + buttongap*2 + buttonSize(1)*2,0.5, buttonSize(1),buttonSize(2)],...
                'ForegroundColor',textColor);
            
            uicontrol('Parent',tabMakeCell_panelTrack,'Style','text','Units','characters','String','divide a track into two',...
                'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion1,...
                'Position',[hx + buttongap*2 + buttonSize(1)*2, buttonSize(2)+1, buttonSize(1),2.6923],...
                'ForegroundColor',textColor);
            
            tabMakeCell_togglebuttonDelete = uicontrol('Parent',tabMakeCell_buttongroupTrack,'Style','togglebutton','Units','characters',...
                'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion1,...
                'String','Delete',...
                'Position',[hx + buttongap*3 + buttonSize(1)*3,0.5, buttonSize(1),buttonSize(2)],...
                'ForegroundColor',textColor);
            
            uicontrol('Parent',tabMakeCell_panelTrack,'Style','text','Units','characters','String','delete a track',...
                'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion1,...
                'Position',[hx + buttongap*3 + buttonSize(1)*3, buttonSize(2)+1, buttonSize(1),2.6923],...
                'ForegroundColor',textColor);
            %%
            %
            buttonSize = [20 3.0769]; %[100/ppChar(3) 40/ppChar(4)];
            buttongap = 2;
            hx = (fwidth-4*buttonSize(1)-4*buttongap)/2;
            %%
            %
            tabMakeCell_panelMakeCell = uipanel('Title','MakeCell','Units','characters','Parent',tabMakeCell,...
                'Position',[0,region2(2),fwidth,10]);
            textColor = [255 192 203]/255;
            
            
            tabMakeCell_buttongroupMakeCell = uibuttongroup('Parent',tabMakeCell_panelMakeCell);
            tabMakeCell_buttongroupMakeCell.SelectionChangedFcn = @obj.tabMakeCell_buttongroupMakeCell_SelectionChangedFcn;
            
            tabMakeCell_pushbuttonNewCell = uicontrol('Parent',tabMakeCell_panelMakeCell,'Style','pushbutton','Units','characters',...
                'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion2,...
                'String','New Cell',...
                'Position',[hx, 0.5, buttonSize(1),buttonSize(2)],...
                'ForegroundColor',textColor,...
                'Callback',{@obj.tabMakeCell_pushbuttonNewCell_Callback});
            
            uicontrol('Parent',tabMakeCell_panelMakeCell,'Style','text','Units','characters','String','Create a new cell',...
                'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion2,...
                'Position',[hx, buttonSize(2)+1, buttonSize(1),2.6923],...
                'ForegroundColor',textColor);
            
            tabMakeCell_pushbuttonAddTrack2Cell = uicontrol('Parent',tabMakeCell_panelMakeCell,'Style','pushbutton','Units','characters',...
                'FontSize',10,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion2,...
                'String','Track 2 Cell',...
                'Position',[hx + buttongap + buttonSize(1), 0.5, buttonSize(1),buttonSize(2)],...
                'ForegroundColor',textColor,...
                'Callback',{@obj.tabMakeCell_pushbuttonAddTrack2Cell_Callback});
            
            uicontrol('Parent',tabMakeCell_panelMakeCell,'Style','text','Units','characters','String','Add a track to a cell',...
                'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion2,...
                'Position',[hx + buttongap + buttonSize(1),buttonSize(2)+1, buttonSize(1),2.6923],...
                'ForegroundColor',textColor);
            
            tabMakeCell_togglebuttonMother = uicontrol('Parent',tabMakeCell_buttongroupMakeCell,'Style','togglebutton','Units','characters',...
                'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion2,...
                'String','Mother',...
                'Position',[hx + buttongap*2 + buttonSize(1)*2,0.5, buttonSize(1),buttonSize(2)],...
                'ForegroundColor',textColor,...
                'Callback',{@obj.tabMakeCell_pushbuttonMother_Callback});
            
            uicontrol('Parent',tabMakeCell_panelMakeCell,'Style','text','Units','characters','String','choose mother cell',...
                'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion2,...
                'Position',[hx + buttongap*2 + buttonSize(1)*2, buttonSize(2)+1, buttonSize(1),2.6923],...
                'ForegroundColor',textColor);
%             
%             tabMakeCell_togglebuttonDelete = uicontrol('Parent',tabMakeCell_buttongroupTrack,'Style','togglebutton','Units','characters',...
%                 'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion1,...
%                 'String','Delete',...
%                 'Position',[hx + buttongap*3 + buttonSize(1)*3,0.5, buttonSize(1),buttonSize(2)],...
%                 'ForegroundColor',textColor);
%             
%             uicontrol('Parent',tabMakeCell_panelTrack,'Style','text','Units','characters','String','delete a track',...
%                 'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion1,...
%                 'Position',[hx + buttongap*3 + buttonSize(1)*3, buttonSize(2)+1, buttonSize(1),2.6923],...
%                 'ForegroundColor',textColor);
            %%
            %
            tabMakeCell_table = uitable('Parent',tabMakeCell,'Units','characters',...
                'BackgroundColor',[textBackgroundColorRegion3;buttonBackgroundColorRegion3],...
                'ColumnName',{'cell #','trackIDS','mother'},...
                'ColumnEditable',logical([0,0,0]),...
                'ColumnFormat',{'numeric','char','numeric'},...
                'ColumnWidth',{'auto' 'auto' 'auto'},...
                'FontSize',8,'FontName','Verdana',...
                'CellSelectionCallback',@obj.tabMakeCell_table_CellSelectionCallback,...
                'Position',[hx, region3(2)+0.7692, hwidth, 13.0769]);
            %% Handles
            %   _  _              _ _
            %  | || |__ _ _ _  __| | |___ ___
            %  | __ / _` | ' \/ _` | / -_|_-<
            %  |_||_\__,_|_||_\__,_|_\___/__/
            %
            % store the uicontrol handles in the figure handles via guidata()
            % store the uicontrol handles in the figure handles via guidata()
            handles.muView = muView;
            handles.muViewHT = muViewHT;
            
            handles.infoBk_textMessage = infoBk_textMessage;
            handles.infoBk_editTimepoint = infoBk_editTimepoint;
            handles.infoBk_textTimepoint = infoBk_textTimepoint;
            
            handles.tabgp = tabgp;
            handles.tabGPS = tabGPS;
            handles.tabMakeCell = tabMakeCell;
            handles.tabContrast = tabContrast;
            
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
            
            handles.tabMakeCell_buttongroupTrack = tabMakeCell_buttongroupTrack;
            handles.tabMakeCell_table = tabMakeCell_table;
            handles.tabMakeCell_togglebuttonNone = tabMakeCell_togglebuttonNone;
            handles.tabMakeCell_togglebuttonJoin = tabMakeCell_togglebuttonJoin;
            handles.tabMakeCell_togglebuttonBreak = tabMakeCell_togglebuttonBreak;
            handles.tabMakeCell_togglebuttonDelete = tabMakeCell_togglebuttonDelete;
            
            handles.tabMakeCell_pushbuttonNewCell = tabMakeCell_pushbuttonNewCell;
            handles.tabMakeCell_pushbuttonAddTrack2Cell = tabMakeCell_pushbuttonAddTrack2Cell;
            handles.tabMakeCell_togglebuttonMother = tabMakeCell_togglebuttonMother;
            
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
            obj.tabGPS_loop
            %%%
            % make the gui visible
            set(f,'Visible','on');
        end
        %% delete
        % for a clean delete make sure the objects that are stored as
        % properties are also deleted.
        function delete(obj,~,~)
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
        %% GPS Tab: callbacks and functions
        %    ___ ___  ___   _____     _
        %   / __| _ \/ __| |_   _|_ _| |__
        %  | (_ |  _/\__ \   | |/ _` | '_ \
        %   \___|_|  |___/   |_|\__,_|_.__/
        %
        %%
        %
        function obj = infoBk_editTimepoint_Callback(obj,~,~)
            handles = guidata(obj.gui_main);
            indImage = str2double(handles.infoBk_editTimepoint.String);
            indImage = round(indImage);
            if indImage < 1
                obj.tmn.indImage = 1;
            elseif indImage > height(obj.tmn.smda_databaseSubset)
                obj.tmn.indImage = height(obj.tmn.smda_databaseSubset);
            else
                obj.tmn.indImage = indImage;
            end
            obj.tmn.gui_imageViewer.loop;
            handles.infoBk_editTimepoint.String = num2str(obj.tmn.indImage);
            guidata(obj.gui_main,handles);
        end
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
            
            obj.tabGPS_loop;
            %%
            % save changes made to the previous position
            obj.tmn.mcl.export;
            
            obj.tmn.gui_imageViewer.loadNewTracks;
            obj.tmn.gui_imageViewer.loop;
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
            obj.tabGPS_loop;
            %%
            % save changes made to the previous position
            obj.tmn.mcl.export;
            
            obj.tmn.gui_imageViewer.loadNewTracks;
            obj.tmn.gui_imageViewer.loop;
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
            obj.tabGPS_loop;
            obj.tmn.gui_imageViewer.loop;
        end
        %%
        %
        function obj = tabGPS_loop(obj)
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
            %
            myGroupOrder = obj.tmn.ity.order_group;
            obj.tmn.indG = myGroupOrder(obj.tmn.pointerGroup(1));
            myPositionOrder = obj.tmn.ity.ind_position{gInd};
            obj.tmn.indP = myPositionOrder(obj.tmn.pointerPosition(1));
            mySettingsOrder = obj.tmn.ity.ind_settings{pInd};
            obj.tmn.indS = mySettingsOrder(obj.tmn.pointerSettings(1));
            obj.tmn.updateFilenameListImage;
            %%
            %
            handles.infoBk_textTimepoint.String = sprintf('of %d\ntimepoint(s)',height(obj.tmn.smda_databaseSubset));
            guidata(obj.gui_main,handles);
        end
        %% MakeCell Tab: callbacks and functions
        %   __  __      _        ___     _ _   _____     _
        %  |  \/  |__ _| |_____ / __|___| | | |_   _|_ _| |__
        %  | |\/| / _` | / / -_) (__/ -_) | |   | |/ _` | '_ \
        %  |_|  |_\__,_|_\_\___|\___\___|_|_|   |_|\__,_|_.__/
        %
        %%
        %
        function obj = tabMakeCell_buttongroupTrack_SelectionChangedFcn(obj,~,eventdata)
            handles = guidata(obj.gui_main);
            activeColor = [139  69  19]/255;
            inactiveColor = [29 97 175]/255;
            switch lower(eventdata.NewValue.String)
                case 'none'
                    obj.tmn.makecell_mode = 'none';
                    handles.tabMakeCell_togglebuttonNone.BackgroundColor = activeColor;
                case 'join'
                    obj.tmn.makecell_mode = 'join';
                    handles.tabMakeCell_togglebuttonJoin.BackgroundColor = activeColor;
                case 'break'
                    obj.tmn.makecell_mode = 'break';
                    handles.tabMakeCell_togglebuttonBreak.BackgroundColor = activeColor;
                case 'delete'
                    obj.tmn.makecell_mode = 'delete';
                    handles.tabMakeCell_togglebuttonDelete.BackgroundColor = activeColor;
            end
            switch lower(eventdata.OldValue.String)
                case 'none'
                    handles.tabMakeCell_togglebuttonNone.BackgroundColor = inactiveColor;
                case 'join'
                    handles.tabMakeCell_togglebuttonJoin.BackgroundColor = inactiveColor;
                case 'break'
                    handles.tabMakeCell_togglebuttonBreak.BackgroundColor = inactiveColor;
                case 'delete'
                    handles.tabMakeCell_togglebuttonDelete.BackgroundColor = inactiveColor;
            end
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = tabMakeCell_buttongroupMakeCell_SelectionChangedFcn(obj,~,eventdata)
            handles = guidata(obj.gui_main);
            activeColor = [139  69  19]/255;
            inactiveColor = [44 129 74]/255;
            switch lower(eventdata.NewValue.String)
                case 'none'
                    obj.tmn.makecell_mode2 = 'none';
                    handles.tabMakeCell_togglebuttonNone.BackgroundColor = activeColor;
                case 'mother'
                    obj.tmn.makecell_mode2 = 'mother';
                    handles.tabMakeCell_togglebuttonAddTrack2Cell.BackgroundColor = activeColor;
                case 'break'
                    obj.tmn.makecell_mode2 = 'break';
                    handles.tabMakeCell_togglebuttonBreak.BackgroundColor = activeColor;
                case 'delete'
                    obj.tmn.makecell_mode2 = 'delete';
                    handles.tabMakeCell_togglebuttonDelete.BackgroundColor = activeColor;
            end
            switch lower(eventdata.OldValue.String)
                case 'none'
                    handles.tabMakeCell_togglebuttonNone.BackgroundColor = inactiveColor;
                case 'mother'
                    handles.tabMakeCell_togglebuttonAddTrack2Cell.BackgroundColor = inactiveColor;
                case 'break'
                    handles.tabMakeCell_togglebuttonBreak.BackgroundColor = inactiveColor;
                case 'delete'
                    handles.tabMakeCell_togglebuttonDelete.BackgroundColor = inactiveColor;
            end
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = tabMakeCell_loop(obj)
            handles = guidata(obj.gui_main);
            %% Cell Table
            %
            existingCells = 1:length(obj.tmn.mcl.makecell_logical);
            existingCells = existingCells(obj.tmn.mcl.makecell_logical);
            makeCellData = cell(length(obj.tmn.mcl.makecell_logical),...
                length(handles.tabMakeCell_table.ColumnName));
            n=0;
            for i = existingCells
                n = n + 1;
                makeCellData{n,1} = i;
                makeCellData{n,2} = num2str(obj.tmn.mcl.makecell_ind{i});
                makeCellData{n,3} = obj.tmn.mcl.makecell_mother(i);
            end
            handles.tabMakeCell_table.Data = makeCellData;
        end
        %%
        %
        function obj = tabMakeCell_table_CellSelectionCallback(obj,~,eventdata)
            if isempty(eventdata.Indices)
                % if nothing is selected, which triggers after deleting data,
                % make sure the pointer is still valid
                obj.tmn.mcl.find_pointer_next_makecell;
                return
            else
                obj.tmn.mcl.pointer_makecell = eventdata.Indices(1,1);
            end
        end
        %%
        %
        function obj = menu_viewTracks(obj,~,~)
            handles = guidata(obj.gui_main);
            if obj.menu_viewTrackBool
                obj.menu_viewTrackBool = false;
                handles.muViewHT.Label = 'Show Tracks';
                for i = 1:length(obj.tmn.gui_imageViewer.trackCircle)
                    obj.tmn.gui_imageViewer.trackCircle{i}.Visible = 'off';
                    obj.tmn.gui_imageViewer.trackLine{i}.Visible = 'off';
                end
            else
                obj.menu_viewTrackBool = true;
                handles.muViewHT.Label = 'Hide Tracks';
                obj.tmn.gui_imageViewer.loop;
            end
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = tabMakeCell_pushbuttonNewCell_Callback(obj,~,~)
            obj.tmn.mcl.newCell;
            obj.tabMakeCell_loop;
        end
        %%
        %
        function obj = tabMakeCell_pushbuttonAddTrack2Cell_Callback(obj,~,~)
            obj.tmn.mcl.addTrack2Cell;
            obj.tabMakeCell_loop;
        end
        %%
        %
        function obj = tabMakeCell_pushbuttonMother_Callback(obj,~,~)
            
        end
    end
end