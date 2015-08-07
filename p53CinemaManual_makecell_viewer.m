%% cellularGPSSimpleViewer_gps
%
classdef p53CinemaManual_makecell_viewer < handle
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
        gui_main; %the main viewer figure handle
        
        makecell;
        viewer;
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
        function obj = p53CinemaManual_makecell_viewer()
            myunits = get(0,'units');
            set(0,'units','pixels');
            Pix_SS = get(0,'screensize');
            set(0,'units','characters');
            Char_SS = get(0,'screensize');
            ppChar = Pix_SS./Char_SS;
            ppChar = ppChar([3,4]);
            set(0,'units',myunits);
            fwidth = 91; %455/ppChar(3);
            fheight = 35; %455/ppChar(4);
            fx = Char_SS(3) - (Char_SS(3)*.1 + fwidth);
            fy = Char_SS(4) - (Char_SS(4)*.1 + fheight);
            
            f = figure;
            f.Visible = 'off';
            f.Units = 'characters';
            f.MenuBar = 'none';
            f.Name = 'Makecell';
            f.Renderer = 'OpenGL';
            f.Resize = 'off';
            f.CloseRequestFcn = {@obj.fCloseRequestFcn};
            f.Position = [fx fy fwidth fheight];
            %% Create the axes that will show the contrast histogram
            % and the plot that will show the histogram
            region1 = [0 25]; %[0 730/ppChar(4)]; %180 pixels
            region2 = [0 27.6924]; %[0 550/ppChar(4)]; %180 pixels
            region3 = [0 9.2308]; %[0 180/ppChar(4)]; %370 pixels
            region4 = [0 0]; %180 pixels
            
            hwidth = 91;
            hx = (fwidth-hwidth)/2;
            textBackgroundColorRegion1 = [37 124 224]/255; %tendoBlueLight
            buttonBackgroundColorRegion1 = [29 97 175]/255; %tendoBlueDark
            textBackgroundColorRegion2 = [56 165 95]/255; %tendoGreenLight
            buttonBackgroundColorRegion2 = [44 129 74]/255; %tendoGreenDark
            textBackgroundColorRegion3 = [255 214 95]/255; %tendoYellowLight
            buttonBackgroundColorRegion3 = [199 164 74]/255; %tendoYellowDark
            textBackgroundColorRegion4 = [255 103 97]/255; %tendoRedLight
            buttonBackgroundColorRegion4 = [199 80 76]/255; %tendoRedDark
            buttonSize = [20 3.0769]; %[100/ppChar(3) 40/ppChar(4)];
            textColor = [255 235 205]/255;
            %%
            %
%                         tabMakeCell_pushbuttonNewCell = uicontrol('Parent',tabMakeCell_panel,'Style','pushbutton','Units','characters',...
%                 'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion2,...
%                 'String','New Cell',...
%                 'Position',[hx, 0.5, buttonSize(1),buttonSize(2)],...
%                 'ForegroundColor',textColor,...
%                 'Callback',{@obj.tabMakeCell_pushbuttonNewCell_Callback});
            
            pushbuttonMake = uicontrol;
            pushbuttonMake.Parent = f;
            pushbuttonMake.Style = 'pushbutton';
            pushbuttonMake.Units = 'characters';
            pushbuttonMake.FontSize = 14;
            pushbuttonMake.FontName = 'Verdana';
            pushbuttonMake.BackgroundColor = buttonBackgroundColorRegion2;
            pushbuttonMake.String = 'Make Cell';
            pushbuttonMake.Position = [4, region1(2)+5, buttonSize(1),buttonSize(2)];
            pushbuttonMake.ForegroundColor = textColor;
            pushbuttonMake.Callback = {@obj.pushbuttonMake_Callback};

            textMake = uicontrol;
            textMake.Parent = f;
            textMake.Style = 'text';
            textMake.Units = 'characters';
            textMake.String = 'makecell:';
            textMake.FontSize = 10;
            textMake.FontName = 'Verdana';
            textMake.HorizontalAlignment = 'left';
            textMake.Position = [buttonSize(1) + 8, region1(2)+5, buttonSize(1),2.6923];
            %textMake.ForegroundColor = textColor;

            togglebuttonMake = uicontrol;
            togglebuttonMake.Parent = f;
            togglebuttonMake.Style = 'togglebutton';
            togglebuttonMake.Units = 'characters';
            togglebuttonMake.BackgroundColor = [1 0.3 0];
            togglebuttonMake.FontSize = 14;
            togglebuttonMake.FontName = 'Verdana';
            togglebuttonMake.String = 'OFF';
            togglebuttonMake.Callback = {@obj.togglebuttonMake_Callback};
            togglebuttonMake.Position = [2*(buttonSize(1)+8), region1(2)+5, buttonSize(1),buttonSize(2)];
            %% The makecell table
            %
            tableMakeCell = uitable;
            tableMakeCell.Parent = f;
            tableMakeCell.Units = 'characters';
            tableMakeCell.BackgroundColor = [textBackgroundColorRegion3;buttonBackgroundColorRegion3];
            tableMakeCell.ColumnName = {'id #','mother','division'};
            tableMakeCell.ColumnEditable = logical([0,0,0]);
            %tableSettings.ColumnFormat = {obj.smda_itinerary.channel_names(1),'numeric','numeric'};
            tableMakeCell.ColumnWidth = {'auto' 'auto' 'auto'};
            tableMakeCell.FontSize = 8;
            tableMakeCell.FontName = 'Verdana';
            tableMakeCell.CellSelectionCallback = @obj.tableMakeCell_SelectionCallback;
            tableMakeCell.Position = [hx, region4(2), hwidth, 25];
            %%
            % make the gui visible
            f.Visible = 'on';
            obj.gui_main = f;
            handles.textMake = textMake;
            handles.tableMakeCell = tableMakeCell;
            handles.togglebuttonMake = togglebuttonMake;
            guidata(obj.gui_main,handles);
        end
        %%
        % set the makecell object for this to work
        function obj = initialize(obj)
            obj.loop;
        end
        %%
        %
        function obj = refresh(obj)
            obj.loop;
        end
        %%
        %
        function obj = pushbuttonMake_Callback(obj,~,~)
            obj.makecell.make;
            obj.loop;
        end
        %%
        %
        function fCloseRequestFcn(obj,~,~)
            %do nothing. This means only the master object can close this
            %window.
        end
        %%
        %
        function obj = loop(obj)
            handles = guidata(obj.gui_main);
            %% Cell Table
            %
            existingCells = 1:length(obj.makecell.makecell_logical);
            existingCells = existingCells(obj.makecell.makecell_logical);
            makeCellData = cell(length(obj.makecell.makecell_logical),...
                length(handles.tableMakeCell.ColumnName));
            n=0;
            for i = existingCells
                n = n + 1;
                makeCellData{n,1} = i;
                %makeCellData{n,2} = num2str(obj.makecell_ind{i});
                %makeCellData{n,3} = obj.makecell_mother(i);
            end
            handles.tableMakeCell.Data = makeCellData;
            handles.textMake.String = sprintf('makecell:%d',obj.makecell.pointer_makecell);
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = tableMakeCell_SelectionCallback(obj,~,eventdata)
            if isempty(eventdata.Indices)
                % if nothing is selected, which triggers after deleting data,
                % make sure the pointer is still valid
                obj.makecell.find_pointer_next_makecell;
                return
            else
                handles = guidata(obj.gui_main);
                obj.makecell.pointer_makecell3 = handles.tableMakeCell.Data{eventdata.Indices(1,1),1};
                obj.makecell.pointer_makecell = handles.tableMakeCell.Data{eventdata.Indices(1,1),1};
                if isempty(obj.makecell.pointer_makecell3)
                    obj.makecell.pointer_makecell3 = obj.makecell.pointer_next_makecell;
                    obj.makecell.pointer_makecell = obj.makecell.pointer_next_makecell;
                end
%                if ~isempty(obj.makecell.makecell_ind{obj.makecell.pointer_makecell3})

                %end
            end
            obj.loop;
        end
        %%
        %
        function obj = togglebuttonMake_Callback(obj,src,~)
            if src.Value == 1
                obj.viewer.makecellBool = true;
            else
                obj.viewer.makecellBool = false;
            end
        end
    end
end