%% cellularGPSSimpleViewer_gps
%
classdef cellularGPSSimpleViewer_gps < handle
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
        kybrd_flag = false; %to prevent repeat entry into the keyboard callbacks when a key is held down.
                
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
        
        panningActiveBool = false;
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
        function obj = cellularGPSSimpleViewer_gps()
            myunits = get(0,'units');
            set(0,'units','pixels');
            Pix_SS = get(0,'screensize');
            set(0,'units','characters');
            Char_SS = get(0,'screensize');
            ppChar = Pix_SS./Char_SS;
            ppChar = ppChar([3,4]);
            set(0,'units',myunits);
            fwidth = 136.6; %683/ppChar(3);
            fheight = 70; %910/ppChar(4);
            fx = Char_SS(3) - (Char_SS(3)*.1 + fwidth);
            fy = Char_SS(4) - (Char_SS(4)*.1 + fheight);
            
            f = figure;
            f.Visible = 'off';
            f.Units = 'characters';
            f.MenuBar = 'none';
            f.Name = 'Zoom';
            f.Renderer = 'OpenGL';
            f.Resize = 'off';
            f.CloseRequestFcn = {@obj.fCloseRequestFcn};
            f.Position = [fx fy fwidth fheight];
            %% Create the axes that will show the contrast histogram
            % and the plot that will show the histogram
            region1 = [0 56.1538]; %[0 730/ppChar(4)]; %180 pixels
            region2 = [0 42.3077]; %[0 550/ppChar(4)]; %180 pixels
            region3 = [0 13.8462]; %[0 180/ppChar(4)]; %370 pixels
            region4 = [0 0]; %180 pixels
            
            hwidth = 104;
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
            %% The group table
            %
            tableGroup = uitable;
            tableGroup.Parent = f;
            tableGroup.Units = 'characters';
            tableGroup.BackgroundColor = [textBackgroundColorRegion2;buttonBackgroundColorRegion2];
            tableGroup.ColumnName = {'label','group #','# of positions'};
            tableGroup.ColumnEditable = logical([0,0,0]);
            tableGroup.ColumnFormat = {'char','numeric','numeric'};
            tableGroup.ColumnWidth = {'auto' 'auto' 'auto'};
            tableGroup.FontSize = 8;
            tableGroup.FontName = 'Verdana';
            tableGroup.CellSelectionCallback = @obj.tableGroup_CellSelectionCallback;
            tableGroup.Position = [hx, region2(2)+0.7692, hwidth, 13.0769];
            
            %% The position table
            %
            tablePosition = uitable;
            tablePosition.Parent = f;
            tablePosition.Units = 'characters';
            tablePosition.BackgroundColor = [textBackgroundColorRegion3;buttonBackgroundColorRegion3];
            tablePosition.ColumnName = {'label','position #','X','Y','Z','# of settings'};
            tablePosition.ColumnEditable = logical([0,0,0,0,0,0]);
            tablePosition.ColumnFormat = {'char','numeric','numeric','numeric','numeric','numeric'};
            tablePosition.ColumnWidth = {'auto' 'auto' 'auto' 'auto' 'auto' 'auto'};
            tablePosition.FontSize = 8;
            tablePosition.FontName = 'Verdana';
            tablePosition.CellSelectionCallback = @obj.tablePosition_CellSelectionCallback;
            tablePosition.Position = [hx, region3(2)+0.7692, hwidth, 28.1538];
            %% The settings table
            %
            tableSettings = uitable;
            tableSettings.Parent = f;
            tableSettings.Units = 'characters';
            tableSettings.BackgroundColor = [textBackgroundColorRegion4;buttonBackgroundColorRegion4];
            tableSettings.ColumnName = {'channel','exposure','settings #'};
            tableSettings.ColumnEditable = logical([0,0,0]);
            %tableSettings.ColumnFormat = {obj.smda_itinerary.channel_names(1),'numeric','numeric'};
            tableSettings.ColumnWidth = {'auto' 'auto' 'auto'};
            tableSettings.FontSize = 8;
            tableSettings.FontName = 'Verdana';
            tableSettings.CellSelectionCallback = @obj.tableSettings_CellSelectionCallback;
            tableSettings.Position = [hx, region4(2)+0.7692, hwidth, 13.0769];
            
            %%
            % make the gui visible
            f.Visible = 'on';
            obj.gui_main = f;
            handles.tableSettings = tableSettings;
            handles.tablePosition = tablePosition;
            handles.tableGroup = tableGroup;
            guidata(obj.gui_main,handles);
        end
        %%
        % set the viewer object for this to work
        function obj = initialize(obj)
            handles = guidata(obj.gui_main);
            obj.smda_itinerary = obj.viewer.smda_itinerary;
            obj.smda_database = obj.viewer.smda_database;
            handles.tableSettings.ColumnFormat = {obj.smda_itinerary.channel_names(1),'numeric','numeric'};
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = refresh(obj)
            obj.loop;
        end
        %%
        %
        function fCloseRequestFcn(obj,~,~)
            %do nothing. This means only the master object can close this
            %window.
        end
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
            obj.tmn.gui_imageViewer.loop_stepX;
            handles.infoBk_editTimepoint.String = num2str(obj.tmn.indImage);
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = tableGroup_CellSelectionCallback(obj,~,eventdata)
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
                if any(obj.tmn.pointerGroup > obj.smda_itinerary.number_group)
                    % move pointer to last entry
                    obj.tmn.pointerGroup = obj.smda_itinerary.number_group;
                end
                return
            else
                obj.tmn.pointerGroup = sort(unique(eventdata.Indices(:,1)));
            end
            
            myGroupOrder = obj.smda_itinerary.order_group;
            gInd = myGroupOrder(obj.tmn.pointerGroup(1));
            if any(obj.tmn.pointerPosition > obj.smda_itinerary.number_position(gInd))
                % move pointer to first entry
                obj.tmn.pointerPosition = 1;
            end
            
            obj.loop;
            %%
            % save changes made to the previous position
            obj.tmn.mcl.export;
            
            obj.tmn.gui_imageViewer.loadNewTracks;
            obj.tmn.gui_imageViewer.loop_stepX;
        end
        %%
        %
        function obj = tablePosition_CellSelectionCallback(obj,~,eventdata)
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
            myGroupOrder = obj.smda_itinerary.order_group;
            gInd = myGroupOrder(obj.tmn.pointerGroup(1));
            if isempty(eventdata.Indices)
                % if nothing is selected, which triggers after deleting data,
                % make sure the pointer is still valid
                if any(obj.tmn.pointerPosition > obj.smda_itinerary.number_position(gInd))
                    % move pointer to last entry
                    obj.tmn.pointerPosition = obj.smda_itinerary.number_position(gInd);
                end
                return
            else
                obj.tmn.pointerPosition = sort(unique(eventdata.Indices(:,1)));
            end
            obj.loop;
            %%
            % save changes made to the previous position
            obj.tmn.mcl.export;
            
            obj.tmn.gui_imageViewer.loadNewTracks;
            obj.tmn.gui_imageViewer.loop_stepX;
        end
        %%
        %
        function obj = tableSettings_CellSelectionCallback(obj,~,eventdata)
            %%%
            % The |Travel Agent| aims to recreate the experience that
            % microscope users expect from a multi-dimensional acquistion tool.
            % Therefore, most of the customizability is masked by the
            % |TravelAgent| to provide a streamlined presentation and simple
            % manipulation of the |Itinerary|. Unlike the group and position
            % tables, which edit the itinerary directly, the settings table
            % will modify the the prototype, which will then be pushed to all
            % positions in a group.
            myGroupOrder = obj.smda_itinerary.order_group;
            gInd = myGroupOrder(obj.tmn.pointerGroup(1));
            pInd = obj.smda_itinerary.ind_position{gInd};
            pInd = pInd(1);
            if isempty(eventdata.Indices)
                % if nothing is selected, which triggers after deleting data,
                % make sure the pointer is still valid
                if any(obj.tmn.pointerSettings > obj.smda_itinerary.number_settings{pInd})
                    % move pointer to last entry
                    obj.tmn.pointerSettings = obj.smda_itinerary.number_settings(pInd);
                end
                return
            else
                obj.tmn.pointerSettings = sort(unique(eventdata.Indices(:,1)));
            end
            obj.loop;
            obj.tmn.gui_imageViewer.loop_stepX;
        end
        %%
        %
        function obj = loop(obj)
            %%%
            % a good snippet of code to update the table register and pull
            % the referenced GPS from the pointer indices.
            G = obj.smda_itinerary.order_group(obj.viewer.indG);
            P = obj.smda_itinerary.order_position{G};
            P = P(obj.viewer.indP);
            S = obj.smda_itinerary.order_settings{P};
            S = S(obj.viewer.indS);
%             smda_databaseLogical = obj.smda_database.group_number == G...
%                 & obj.smda_database.position_number == P...
%                 & obj.smda_database.settings_number == S;
%             mytable = obj.smda_database(smda_databaseLogical,:);
%             obj.viewer.tblRegister = sortrows(mytable,{'timepoint'});
%             if obj.viewer.indT > height(obj.tblRegister)
%                 obj.viewer.indT = height(obj.tblRegister);
%             end
            %%%
            %
            
            handles = guidata(obj.gui_main);
            
            %% Group Table
            % Show the data in the itinerary |group_order| property
            tableGroupData = cell(obj.smda_itinerary.number_group,...
                length(handles.tableGroup.ColumnName));
            n=0;
            for i = obj.smda_itinerary.order_group
                n = n + 1;
                tableGroupData{n,1} = obj.smda_itinerary.group_label{i};
                tableGroupData{n,2} = i;
                tableGroupData{n,3} = obj.smda_itinerary.number_position(i);
            end
            handles.tableGroup.Data = tableGroupData;
            %% Region 3
            %
            %% Position Table
            % Show the data in the itinerary |position_order| property for a given
            % group
            myPositionOrder = obj.smda_itinerary.order_position{G};
            tablePositionData = cell(length(myPositionOrder),...
                length(get(handles.tablePosition,'ColumnName')));
            n=0;
            for i = myPositionOrder
                n = n + 1;
                tablePositionData{n,1} = obj.smda_itinerary.position_label{i};
                tablePositionData{n,2} = i;
                tablePositionData{n,3} = obj.smda_itinerary.position_xyz(i,1);
                tablePositionData{n,4} = obj.smda_itinerary.position_xyz(i,2);
                tablePositionData{n,5} = obj.smda_itinerary.position_xyz(i,3);
                tablePositionData{n,6} = obj.smda_itinerary.number_settings(i);
            end
            set(handles.tablePosition,'Data',tablePositionData);
            %% Region 4
            %
            %% Settings Table
            %
            mySettingsOrder = obj.smda_itinerary.order_settings{P};
            tableSettingsData = cell(length(mySettingsOrder),...
                length(get(handles.tableSettings,'ColumnName')));
            n=1;
            for i = mySettingsOrder
                tableSettingsData{n,1} = obj.smda_itinerary.channel_names{obj.smda_itinerary.settings_channel(i)};
                tableSettingsData{n,2} = obj.smda_itinerary.settings_exposure(i);
                tableSettingsData{n,3} = i;
                n = n + 1;
            end
            set(handles.tableSettings,'Data',tableSettingsData);
            %% obj.tmn indices
            %
%             myGroupOrder = obj.smda_itinerary.order_group;
%             obj.tmn.indG = myGroupOrder(obj.tmn.pointerGroup(1));
%             myPositionOrder = obj.smda_itinerary.ind_position{gInd};
%             obj.tmn.indP = myPositionOrder(obj.tmn.pointerPosition(1));
%             mySettingsOrder = obj.smda_itinerary.ind_settings{pInd};
%             obj.tmn.indS = mySettingsOrder(obj.tmn.pointerSettings(1));
%             obj.tmn.updateFilenameListImage;
            %%
            %
            %handles.infoBk_textTimepoint.String = sprintf('of %d\ntimepoint(s)',height(obj.tmn.smda_databaseSubset));
            guidata(obj.gui_main,handles);
        end
    end
end