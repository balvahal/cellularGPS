classdef cellularGPSTrackingManual_object_imageViewer < handle
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
        
        trackLine
        trackCircle
        trackCenRow
        trackCenCol
        trackCenLogical
        trackCircleSize
        trackLineWidthHighlight = 3;
        trackCenLogicalDiff
        trackColor
        trackColorHighlight = [255 255 102]/255;
        
        trackJoinBool = false;
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
        function obj = cellularGPSTrackingManual_object_imageViewer(tmn)
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
            ppChar = ppChar([3,4]);
            set(0,'units',myunits);
            
            if obj.image_width > obj.image_height
                if obj.image_width/obj.image_height >= Pix_SS(3)/Pix_SS(4)
                    fwidth = 0.9*Pix_SS(3);
                    fheight = fwidth*obj.image_height/obj.image_width;
                else
                    fheight = 0.9*Pix_SS(4);
                    fwidth = fheight*obj.image_width/obj.image_height;
                end
            else
                if obj.image_height/obj.image_width >= Pix_SS(4)/Pix_SS(3)
                    fheight = 0.9*Pix_SS(4);
                    fwidth = fheight*obj.image_width/obj.image_height;
                else
                    fwidth = 0.9*Pix_SS(3);
                    fheight = fwidth*obj.image_height/obj.image_width;
                    
                end
            end
            
            fwidth = fwidth/ppChar(1);
            fheight = fheight/ppChar(2);
            
            f = figure('Visible','off','Units','characters','MenuBar','none',...
                'Resize','off','Name','Image Viewer',...
                'Renderer','OpenGL','Position',[(Char_SS(3)-fwidth)/2 (Char_SS(4)-fheight)/2 fwidth fheight],...
                'CloseRequestFcn',{@obj.delete},...
                'KeyPressFcn',{@obj.fKeyPressFcn});
            
            axesImageViewer = axes('Parent',f,...
                'Units','characters',...
                'Position',[0 0 fwidth  fheight],...
                'YDir','reverse',...
                'Visible','on',...
                'XLim',[0.5,obj.image_width+0.5],...
                'YLim',[0.5,obj.image_height+0.5]); %when displaying images the center of the pixels are located at the position on the axis. Therefore, the limits must account for the half pixel border.
            
            %% Visuals for Tracks
            %  __   ___              _      _ _
            %  \ \ / (_)____  _ __ _| |___ | | |
            %   \ V /| (_-< || / _` | (_-< |_  _|
            %   _\_/_|_/__/\_,_\__,_|_/__/   |_|
            %  |_   _| _ __ _ __| |__ ___
            %    | || '_/ _` / _| / /(_-<
            %    |_||_| \__,_\__|_\_\/__/
            %
            %% Create an axes to hold these visuals
            % highlighted cell with hover haxesHighlight =
            % axes('Units','characters','DrawMode','fast','color','none',...
            %     'Position',[hx hy hwidth hheight],...
            %     'XLim',[1,master.image_width],'YLim',[1,master.image_height]);
            % cmapHighlight = colormap(haxesImageViewer,jet(16)); %63 matches the number of elements in ang
            axesTracks = axes('Parent',f,'Units','characters',...
                'Position',[0 0 fwidth  fheight]);
            axesTracks.NextPlot = 'add';
            axesTracks.Visible = 'off';
            axesTracks.YDir = 'reverse';
            
            
            axesCircles = axes('Parent',f,'Units','characters',...
                'Position',[0 0 fwidth  fheight]);
            axesCircles.NextPlot = 'add';
            axesCircles.Visible = 'off';
            axesCircles.YDir = 'reverse';
            
            numOfPosition = sum(tmn.ity.number_position);
            positionInd = horzcat(tmn.ity.ind_position{:});
            %             kCenRow = cell(numOfPosition,1);
            %             kCenCol = cell(numOfPosition,1);
            %             kCenLogical = cell(numOfPosition,1);
            %             alldatabase = tmn.track_database;
            %             numOfT = tmn.ity.number_of_timepoints;
            %             %%%
            %             % this loop takes a long time to execute
            %             parfor u = positionInd
            %                 tic
            %                 mydatabase = alldatabase{u};
            %                 myCenRow = zeros(max(mydatabase.trackID),numOfT);
            %                 myCenCol = zeros(max(mydatabase.trackID),numOfT);
            %                 myCenLogical = false(size(myCenRow));
            %                 disp(u)
            %                 for v = 1:height(mydatabase)
            %                     mytimepoint = mydatabase.timepoint(v);
            %                     mytrackID = mydatabase.trackID(v);
            %                     myCenRow(mytrackID,mytimepoint) = mydatabase.centroid_row(v);
            %                     myCenCol(mytrackID,mytimepoint) = mydatabase.centroid_col(v);
            %                     myCenLogical(mytrackID,mytimepoint) = true;
            %                 end
            %                 kCenRow{u} = myCenRow;
            %                 kCenCol{u} = myCenCol;
            %                 kCenLogical{u} = myCenLogical;
            %                 toc
            %             end
            %             %%%
            %             % Assignment to the object was required to be after the parfor.
            %             obj.trackCenRow = kCenRow;
            %             obj.trackCenCol = kCenCol;
            %             obj.trackCenLogical = kCenLogical;
            %
            %             obj.trackCenLogicalDiff = cell(size(obj.trackCenLogical));
            %             for i = 1:length(obj.trackCenLogical)
            %                 obj.trackCenLogicalDiff{i} = diff(obj.trackCenLogical{i},1,2);
            %             end
            obj.trackLine = {};
            obj.trackCircle = {};
            obj.trackCircleSize = 11; %must be an odd number
            obj.trackColor = colormap(lines(7));
            
            displayedImage = image('Parent',axesImageViewer,...
                'CData',obj.imag3);
            %% Handles
            %   _  _              _ _
            %  | || |__ _ _ _  __| | |___ ___
            %  | __ / _` | ' \/ _` | / -_|_-<
            %  |_||_\__,_|_||_\__,_|_\___/__/
            %
            % store the uicontrol handles in the figure handles via guidata()
            handles.axesTracks = axesTracks;
            handles.axesCircles = axesCircles;
            handles.axesImageViewer = axesImageViewer;
            handles.displayedImage = displayedImage;
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
            obj.updateLimits;
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
        %%
        %
        function obj = fKeyPressFcn(obj,~,keyInfo)
            switch keyInfo.Key
                case 'period'
                    obj.tmn.indImage = obj.tmn.indImage + 1;
                    if obj.tmn.indImage > height(obj.tmn.smda_databaseSubset)
                        obj.tmn.indImage = height(obj.tmn.smda_databaseSubset);
                        return
                    end
                    handlesControl = guidata(obj.tmn.gui_control.gui_main);
                    handlesControl.infoBk_editTimepoint.String = num2str(obj.tmn.indImage);
                    guidata(obj.tmn.gui_control.gui_main,handlesControl);
                    obj.loop_stepRight;
                case 'comma'
                    obj.tmn.indImage = obj.tmn.indImage - 1;
                    if obj.tmn.indImage < 1
                        obj.tmn.indImage = 1;
                        return
                    end
                    handlesControl = guidata(obj.tmn.gui_control.gui_main);
                    handlesControl.infoBk_editTimepoint.String = num2str(obj.tmn.indImage);
                    guidata(obj.tmn.gui_control.gui_main,handlesControl);
                    obj.loop_stepLeft;
                case 'rightarrow'
                    
                case 'leftarrow'
                    
                case 'downarrow'
                    
                case 'uparrow'
                    
                case 'backspace'
                    
                case 'd'
                    %% timepoint at end of track
                    %
                    obj.tmn.indImage = find(obj.trackCenLogical(obj.tmn.mcl.pointer_track,:),1,'last');
                    handlesControl = guidata(obj.tmn.gui_control.gui_main);
                    handlesControl.infoBk_editTimepoint.String = num2str(obj.tmn.indImage);
                    guidata(obj.tmn.gui_control.gui_main,handlesControl);
                    obj.loop;
                case 'a'
                    %% timepoint at start of track
                    %
                    obj.tmn.indImage = find(obj.trackCenLogical(obj.tmn.mcl.pointer_track,:),1,'first');
                    handlesControl = guidata(obj.tmn.gui_control.gui_main);
                    handlesControl.infoBk_editTimepoint.String = num2str(obj.tmn.indImage);
                    guidata(obj.tmn.gui_control.gui_main,handlesControl);
                    obj.loop;
                case 'escape'
                    %% reset conditional properties
                    %
                    obj.trackJoinBool = false;
                    handlesControl = guidata(obj.tmn.gui_control.gui_main);
                    handlesControl.infoBk_textMessage.String = sprintf('Aborted! System is reset.');
                    guidata(obj.tmn.gui_control.gui_main,handlesControl);
            end
        end
        %%
        %
        function obj = updateLimits(obj)
            handles = guidata(obj.gui_main);
            
            handles.axesTracks.YLim = [1,obj.tmn.ity.imageHeightNoBin/...
                obj.tmn.ity.settings_binning(obj.tmn.indS)];
            handles.axesTracks.XLim = [1,obj.tmn.ity.imageWidthNoBin/...
                obj.tmn.ity.settings_binning(obj.tmn.indS)];
            
            handles.axesCircles.YLim = [1,obj.tmn.ity.imageHeightNoBin/...
                obj.tmn.ity.settings_binning(obj.tmn.indS)];
            handles.axesCircles.XLim = [1,obj.tmn.ity.imageWidthNoBin/...
                obj.tmn.ity.settings_binning(obj.tmn.indS)];
            
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = loadNewTracks(obj)
            handles = guidata(obj.gui_main);
            handlesControl = guidata(obj.tmn.gui_control.gui_main);
            handlesControl.infoBk_textMessage.String = sprintf('Loading new tracks...');
            drawnow;
            %%
            % process centroid data
            mydatabase = obj.tmn.track_database{obj.tmn.indP};
            obj.tmn.mcl.import(obj.tmn.indP);
            numOfT = obj.tmn.ity.number_of_timepoints;
            myCenRow = zeros(max(mydatabase.trackID),numOfT);
            myCenCol = zeros(max(mydatabase.trackID),numOfT);
            myCenLogical = false(size(myCenRow));
            handlesControl.infoBk_textMessage.String = sprintf('Tracks identified with\n%d centroids',height(mydatabase));
            drawnow;
            for v = 1:height(mydatabase)
                mytimepoint = mydatabase.timepoint(v);
                mytrackID = mydatabase.trackID(v);
                myCenRow(mytrackID,mytimepoint) = mydatabase.centroid_row(v);
                myCenCol(mytrackID,mytimepoint) = mydatabase.centroid_col(v);
                myCenLogical(mytrackID,mytimepoint) = true;
            end
            %%%
            % Assignment to the object was required to be after the parfor.
            obj.trackCenRow = myCenRow;
            obj.trackCenCol = myCenCol;
            obj.trackCenLogical = myCenLogical;
            
            obj.trackCenLogicalDiff = diff(obj.trackCenLogical,1,2);
            
            %% Recalculate tracks
            % Assumes image size remains the same for this settings
            cellfun(@delete,obj.trackCircle);
            cellfun(@delete,obj.trackLine);
            mydatabase1 = obj.tmn.track_database{obj.tmn.indP};
            obj.trackLine = cell(max(mydatabase1.trackID),1);
            obj.trackCircle = cell(max(mydatabase1.trackID),1);
            handlesControl.infoBk_textMessage.String = sprintf('Importing Tracks...');
            drawnow;
            for i = 1:length(obj.trackLine)
                if ~any(obj.trackCenLogical(i,:))
                    continue
                end
                myline = line('Parent',handles.axesTracks);
                myline.Color = obj.trackColor(mod(i,7)+1,:);
                myline.LineWidth = 1;
                myline.YData = obj.trackCenRow(i,obj.trackCenLogical(i,:));
                myline.XData = obj.trackCenCol(i,obj.trackCenLogical(i,:));
                obj.trackLine{i} = myline;
            end
            handlesControl.infoBk_textMessage.String = sprintf('Importing Circles...');
            drawnow;
            for i = 1:length(obj.trackCircle)
                if ~any(obj.trackCenLogical(i,:))
                    continue
                end
                myrec = rectangle('Parent',handles.axesCircles);
                myrec.ButtonDownFcn = @obj.clickLoop;
                myrec.UserData = i;
                myrec.Curvature = [1,1];
                myrec.FaceColor = obj.trackLine{i}.Color;
                myrec.Position = [obj.trackLine{i}.XData(1)-(obj.trackCircleSize-1)/2,obj.trackLine{i}.YData(1)-(obj.trackCircleSize-1)/2,obj.trackCircleSize,obj.trackCircleSize];
                obj.trackCircle{i} = myrec;
            end
            handlesControl.infoBk_textMessage.String = sprintf('Position %d',obj.tmn.indP);
            drawnow;
            obj.loop;
            guidata(obj.tmn.gui_control.gui_main,handlesControl);
        end
        %%
        %
        function obj = visualizeTracks(obj)
            handles = guidata(obj.gui_main);
            handlesControl = guidata(obj.tmn.gui_control.gui_main);
            %% Recalculate tracks
            % Assumes image size remains the same for this settings
            cellfun(@delete,obj.trackCircle);
            cellfun(@delete,obj.trackLine);
            obj.trackLine = cell(max(obj.tmn.mcl.track_database.trackID),1);
            obj.trackCircle = cell(max(obj.tmn.mcl.track_database.trackID),1);
            handlesControl.infoBk_textMessage.String = sprintf('Importing Tracks...');
            drawnow;
            for i = 1:length(obj.trackLine)
                if ~obj.tmn.mcl.track_logical(i)
                    continue
                end
                myline = line('Parent',handles.axesTracks);
                myline.Color = obj.trackColor(mod(i,7)+1,:);
                myline.LineWidth = 1;
                myline.YData = obj.trackCenRow(i,obj.trackCenLogical(i,:));
                myline.XData = obj.trackCenCol(i,obj.trackCenLogical(i,:));
                obj.trackLine{i} = myline;
            end
            handlesControl.infoBk_textMessage.String = sprintf('Importing Circles...');
            drawnow;
            for i = 1:length(obj.trackCircle)
                if ~obj.tmn.mcl.track_logical(i)
                    continue
                end
                myrec = rectangle('Parent',handles.axesCircles);
                myrec.ButtonDownFcn = @obj.clickLoop;
                myrec.UserData = i;
                myrec.Curvature = [1,1];
                myrec.FaceColor = obj.trackLine{i}.Color;
                myrec.Position = [obj.trackLine{i}.XData(1)-(obj.trackCircleSize-1)/2,obj.trackLine{i}.YData(1)-(obj.trackCircleSize-1)/2,obj.trackCircleSize,obj.trackCircleSize];
                obj.trackCircle{i} = myrec;
            end
            handlesControl.infoBk_textMessage.String = sprintf('Position %d',obj.tmn.indP);
            drawnow;
            guidata(obj.tmn.gui_control.gui_main,handlesControl);
        end
        %%
        %
        function obj = loop(obj)
            handles = guidata(obj.gui_main);
            obj.imag3 = imread(fullfile(obj.tmn.moviePath,'.thumb',obj.tmn.smda_databaseSubset.filename{obj.tmn.indImage}));
            handles.displayedImage.CData = obj.imag3;
            obj.updateLimits;
            guidata(obj.gui_main,handles);
            
            %%%
            %   _____            _    __   ___
            %  |_   _| _ __ _ __| |__ \ \ / (_)___
            %    | || '_/ _` / _| / /  \ V /| (_-<
            %    |_||_| \__,_\__|_\_\   \_/ |_/__/
            %
            if obj.tmn.gui_control.menu_viewTrackBool
                trackCircleHalfSize = (obj.trackCircleSize-1)/2;
                for i = 1:length(obj.trackCircle)
                    if ~obj.tmn.mcl.track_logical(i)
                        continue
                    end
                    obj.trackLine{i}.Visible = 'on';
                    if obj.trackCenLogical(i,obj.tmn.indImage)
                        obj.trackCircle{i}.Visible = 'on';
                        obj.trackCircle{i}.Position = [obj.trackCenCol(i,obj.tmn.indImage)-trackCircleHalfSize,...
                            obj.trackCenRow(i,obj.tmn.indImage)-trackCircleHalfSize,...
                            obj.trackCircleSize,obj.trackCircleSize];
                    else
                        obj.trackCircle{i}.Visible = 'off';
                    end
                end
            end
        end
        %%
        %
        function obj = loop_stepRight(obj)
            handles = guidata(obj.gui_main);
            obj.imag3 = imread(fullfile(obj.tmn.moviePath,'.thumb',obj.tmn.smda_databaseSubset.filename{obj.tmn.indImage}));
            handles.displayedImage.CData = obj.imag3;
            obj.updateLimits;
            guidata(obj.gui_main,handles);
            
            %%%
            %   _____            _    __   ___
            %  |_   _| _ __ _ __| |__ \ \ / (_)___
            %    | || '_/ _` / _| / /  \ V /| (_-<
            %    |_||_| \__,_\__|_\_\   \_/ |_/__/
            %
            if obj.tmn.gui_control.menu_viewTrackBool
                trackCircleHalfSize = (obj.trackCircleSize-1)/2;
                for i = 1:length(obj.trackCircle)
                    
                    if obj.trackCenLogicalDiff(i,obj.tmn.indImage-1) == 0 && ~obj.trackCenLogical(i,obj.tmn.indImage)
                        % do nothing
                    elseif obj.trackCenLogical(i,obj.tmn.indImage) && obj.trackCenLogicalDiff(i,obj.tmn.indImage-1) == 0
                        obj.trackCircle{i}.Position = [obj.trackCenCol(i,obj.tmn.indImage)-trackCircleHalfSize,...
                            obj.trackCenRow(i,obj.tmn.indImage)-trackCircleHalfSize,...
                            obj.trackCircleSize,obj.trackCircleSize];
                    elseif obj.trackCenLogicalDiff(i,obj.tmn.indImage-1) == -1
                        obj.trackCircle{i}.Visible = 'off';
                    else
                        obj.trackCircle{i}.Visible = 'on';
                        obj.trackCircle{i}.Position = [obj.trackCenCol(i,obj.tmn.indImage)-trackCircleHalfSize,...
                            obj.trackCenRow(i,obj.tmn.indImage)-trackCircleHalfSize,...
                            obj.trackCircleSize,obj.trackCircleSize];
                    end
                end
            end
        end
        %%
        %
        function obj = loop_stepLeft(obj)
            handles = guidata(obj.gui_main);
            obj.imag3 = imread(fullfile(obj.tmn.moviePath,'.thumb',obj.tmn.smda_databaseSubset.filename{obj.tmn.indImage}));
            handles.displayedImage.CData = obj.imag3;
            obj.updateLimits;
            guidata(obj.gui_main,handles);
            
            %%%
            %   _____            _    __   ___
            %  |_   _| _ __ _ __| |__ \ \ / (_)___
            %    | || '_/ _` / _| / /  \ V /| (_-<
            %    |_||_| \__,_\__|_\_\   \_/ |_/__/
            %
            if obj.tmn.gui_control.menu_viewTrackBool
                trackCircleHalfSize = (obj.trackCircleSize-1)/2;
                for i = 1:length(obj.trackCircle)
                    if obj.trackCenLogicalDiff(i,obj.tmn.indImage) == 0 && ~obj.trackCenLogical(i,obj.tmn.indImage)
                        %do nothing
                    elseif obj.trackCenLogical(i,obj.tmn.indImage) && obj.trackCenLogicalDiff(i,obj.tmn.indImage) == 0
                        obj.trackCircle{i}.Position = [obj.trackCenCol(i,obj.tmn.indImage)-trackCircleHalfSize,...
                            obj.trackCenRow(i,obj.tmn.indImage)-trackCircleHalfSize,...
                            obj.trackCircleSize,obj.trackCircleSize];
                    elseif obj.trackCenLogicalDiff(i,obj.tmn.indImage) == 1
                        obj.trackCircle{i}.Visible = 'off';
                    else
                        obj.trackCircle{i}.Visible = 'on';
                        obj.trackCircle{i}.Position = [obj.trackCenCol(i,obj.tmn.indImage)-trackCircleHalfSize,...
                            obj.trackCenRow(i,obj.tmn.indImage)-trackCircleHalfSize,...
                            obj.trackCircleSize,obj.trackCircleSize];
                    end
                end
            end
        end
        %%
        %
        function obj = clickLoop(obj,myrec,~)
            %%%
            %   _____            _    __   ___
            %  |_   _| _ __ _ __| |__ \ \ / (_)___
            %    | || '_/ _` / _| / /  \ V /| (_-<
            %    |_||_| \__,_\__|_\_\   \_/ |_/__/
            %
            if obj.tmn.gui_control.menu_viewTrackBool
                %%%
                % if the menu_viewTrackBool is true, then tracks are
                % displayed
                obj.tmn.mcl.pointer_track2 = obj.tmn.mcl.pointer_track;
                obj.tmn.mcl.pointer_track = myrec.UserData;
                
                if obj.tmn.mcl.pointer_track2~=obj.tmn.mcl.pointer_track
                    myrec2 = obj.trackCircle{obj.tmn.mcl.pointer_track2};
                    myline = obj.trackLine{obj.tmn.mcl.pointer_track};
                    myline2 = obj.trackLine{obj.tmn.mcl.pointer_track2};
                    myrec.FaceColor = obj.trackColorHighlight;
                    myline.Color = obj.trackColorHighlight;
                    myrec2.FaceColor = obj.trackColor(mod(obj.tmn.mcl.pointer_track2,7)+1,:);
                    myline2.Color = obj.trackColor(mod(obj.tmn.mcl.pointer_track2,7)+1,:);
                    myline.LineWidth = 3;
                    myline2.LineWidth = 1;
                end
                handlesControl = guidata(obj.tmn.gui_control.gui_main);
                switch obj.tmn.makecell_mode
                    case 'none'
                        fprintf('trackID %d\n',obj.tmn.mcl.pointer_track);
                    case 'join'
                        if obj.trackJoinBool
                            if obj.tmn.mcl.pointer_track2 > obj.tmn.mcl.pointer_track
                                keepTrack = obj.tmn.mcl.pointer_track;
                                replaceTrack = obj.tmn.mcl.pointer_track2;
                            else
                                keepTrack = obj.tmn.mcl.pointer_track2;
                                replaceTrack = obj.tmn.mcl.pointer_track;
                            end
                            obj.tmn.mcl.joinTrack(keepTrack,replaceTrack);
                            obj.trackJoinBool = false;
                            myLogical = ismember(obj.tmn.mcl.track_database.trackID,[keepTrack,replaceTrack]);
                            myArray = 1:numel(myLogical);
                            myArray = myArray(myLogical);
                            obj.trackCenRow(keepTrack,:) = 0;
                            obj.trackCenCol(keepTrack,:) = 0;
                            obj.trackCenLogical(keepTrack,:) = false;
                            obj.trackCenRow(replaceTrack,:) = 0;
                            obj.trackCenCol(replaceTrack,:) = 0;
                            obj.trackCenLogical(replaceTrack,:) = false;
                            for v = myArray
                                mytimepoint = obj.tmn.mcl.track_database.timepoint(v);
                                mytrackID = obj.tmn.mcl.track_database.trackID(v);
                                obj.trackCenRow(mytrackID,mytimepoint) = obj.tmn.mcl.track_database.centroid_row(v);
                                obj.trackCenCol(mytrackID,mytimepoint) = obj.tmn.mcl.track_database.centroid_col(v);
                                obj.trackCenLogical(mytrackID,mytimepoint) = true;
                            end
                            obj.trackCenLogicalDiff = diff(obj.trackCenLogical,1,2);
                            
                            obj.trackLine{replaceTrack}.delete;
                            obj.trackCircle{replaceTrack}.delete;
                            
                            obj.trackLine{keepTrack}.YData = obj.trackCenRow(keepTrack,obj.trackCenLogical(keepTrack,:));
                            obj.trackLine{keepTrack}.XData = obj.trackCenCol(keepTrack,obj.trackCenLogical(keepTrack,:));
                            obj.trackCircle{keepTrack}.Position = [obj.trackLine{keepTrack}.XData(1)-(obj.trackCircleSize-1)/2,obj.trackLine{keepTrack}.YData(1)-(obj.trackCircleSize-1)/2,obj.trackCircleSize,obj.trackCircleSize];
                            
                            handlesControl.infoBk_textMessage.String = sprintf('Joined track %d with\ntrack %d.',keepTrack,replaceTrack);
                        else
                            handlesControl.infoBk_textMessage.String = sprintf('Join track %d with...',obj.tmn.mcl.pointer_track);
                            obj.trackJoinBool = true;
                        end
                        obj.tmn.gui_control.tabMakeCell_loop;
                        obj.loop;
                    case 'break'
                        oldTrack = obj.tmn.mcl.pointer_track;
                        obj.tmn.mcl.breakTrack(obj.tmn.mcl.pointer_track,obj.tmn.indImage);
                        newTrack = obj.tmn.mcl.pointer_track;
                        obj.tmn.mcl.pointer_track = oldTrack;
                        
                        myLogical = ismember(obj.tmn.mcl.track_database.trackID,[oldTrack,newTrack]);
                        myArray = 1:numel(myLogical);
                        myArray = myArray(myLogical);
                        obj.trackCenRow(oldTrack,:) = 0;
                        obj.trackCenCol(oldTrack,:) = 0;
                        obj.trackCenLogical(oldTrack,:) = false;
                        obj.trackCenRow(newTrack,:) = 0;
                        obj.trackCenCol(newTrack,:) = 0;
                        obj.trackCenLogical(newTrack,:) = false;
                        for v = myArray
                            mytimepoint = obj.tmn.mcl.track_database.timepoint(v);
                            mytrackID = obj.tmn.mcl.track_database.trackID(v);
                            obj.trackCenRow(mytrackID,mytimepoint) = obj.tmn.mcl.track_database.centroid_row(v);
                            obj.trackCenCol(mytrackID,mytimepoint) = obj.tmn.mcl.track_database.centroid_col(v);
                            obj.trackCenLogical(mytrackID,mytimepoint) = true;
                        end
                        obj.trackCenLogicalDiff = diff(obj.trackCenLogical,1,2);
                        
                        handles = guidata(obj.gui_main);
                        myline = line('Parent',handles.axesTracks);
                        myline.Color = obj.trackColor(mod(newTrack,7)+1,:);
                        myline.LineWidth = 1;
                        myline.YData = obj.trackCenRow(newTrack,obj.trackCenLogical(newTrack,:));
                        myline.XData = obj.trackCenCol(newTrack,obj.trackCenLogical(newTrack,:));
                        obj.trackLine{newTrack} = myline;
                        
                        myrec = rectangle('Parent',handles.axesCircles);
                        myrec.ButtonDownFcn = @obj.clickLoop;
                        myrec.UserData = newTrack;
                        myrec.Curvature = [1,1];
                        myrec.FaceColor = obj.trackLine{newTrack}.Color;
                        myrec.Position = [obj.trackLine{newTrack}.XData(1)-(obj.trackCircleSize-1)/2,obj.trackLine{newTrack}.YData(1)-(obj.trackCircleSize-1)/2,obj.trackCircleSize,obj.trackCircleSize];
                        obj.trackCircle{newTrack} = myrec;
                        
                        obj.trackLine{oldTrack}.YData = obj.trackCenRow(oldTrack,obj.trackCenLogical(oldTrack,:));
                        obj.trackLine{oldTrack}.XData = obj.trackCenCol(oldTrack,obj.trackCenLogical(oldTrack,:));
                        obj.trackCircle{oldTrack}.Position = [obj.trackLine{oldTrack}.XData(1)-(obj.trackCircleSize-1)/2,obj.trackLine{oldTrack}.YData(1)-(obj.trackCircleSize-1)/2,obj.trackCircleSize,obj.trackCircleSize];
                        
                        %obj.visualizeTracks;
                        obj.tmn.gui_control.tabMakeCell_loop;
                        obj.loop;
                    case 'delete'
                        obj.tmn.mcl.deleteTrack;
                        obj.tmn.gui_control.tabMakeCell_loop;
                    otherwise
                        fprintf('trackID %d\n',obj.tmn.mcl.pointer_track);
                end
                guidata(obj.tmn.gui_control.gui_main,handlesControl);
            end
        end
    end
end