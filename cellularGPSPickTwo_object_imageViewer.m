classdef cellularGPSPickTwo_object_imageViewer < handle
    %% Properties
    %   ___                       _   _
    %  | _ \_ _ ___ _ __  ___ _ _| |_(_)___ ___
    %  |  _/ '_/ _ \ '_ \/ -_) '_|  _| / -_|_-<
    %  |_| |_| \___/ .__/\___|_|  \__|_\___/__/
    %              |_|
    %
    properties
        pkTwo; %the cellularGPSTrackingManual_object
        imag3;
        imag3path;
        image_width;
        image_height;
        gui_main;
        
        trackCircle
        trackCenRow
        trackCenCol
        trackCenLogical
        trackCircleSize
        trackColorHighlight2 = [0.301,0.745,0.933];
        trackLineWidthHighlight = 3;
        trackCenLogicalDiff
        trackColor = [0.85,0.325,0.098;0.494,0.184,0.556;0.466,0.674,0.188];
        trackColorHighlight = [0.929,0.694,0.125];
        trackText
        trackTextBackgroundColor = [240 255 240]/255;
        trackTextColor = [47 79 79]/255;
        trackTextFontSize = 9;
        trackTextMargin = 1;
        
        kybrd_period
        kybrd_comma
          
        connectBool = false;
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
        function obj = cellularGPSPickTwo_object_imageViewer(pkTwo)
            %%%
            % parse the input
            q = inputParser;
            addRequired(q, 'pkTwo', @(x) isa(x,'cellularGPSPickTwo_object'));
            parse(q,pkTwo);
            %%
            %
            obj.pkTwo = q.Results.pkTwo;

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

            
            f = figure('Visible','off','Units','characters','MenuBar','none',...
                'Resize','off','Name','Image Viewer',...
                'Renderer','OpenGL',...
                'CloseRequestFcn',{@obj.delete},...
                'KeyPressFcn',{@obj.fKeyPressFcn});
            
            axesImageViewer = axes('Parent',f,...
                'Units','characters',...
                'YDir','reverse',...
                'Visible','on'); %when displaying images the center of the pixels are located at the position on the axis. Therefore, the limits must account for the half pixel border.
            
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
            % cmapHighlight = colormap(haxesImageViewer,jet(16)); %63 matches the number of elements in an
            
            axesText = axes('Parent',f,'Units','characters');
            axesText.NextPlot = 'add';
            axesText.Visible = 'off';
            axesText.YDir = 'reverse';
            
            axesCircles = axes('Parent',f,'Units','characters');
            axesCircles.NextPlot = 'add';
            axesCircles.Visible = 'off';
            axesCircles.YDir = 'reverse';
            
            obj.trackCircle = {};
            obj.trackText = {};
            obj.trackCircleSize = 11; %must be an odd number
            
            displayedImage = image('Parent',axesImageViewer);
            %% Handles
            %   _  _              _ _
            %  | || |__ _ _ _  __| | |___ ___
            %  | __ / _` | ' \/ _` | / -_|_-<
            %  |_||_\__,_|_||_\__,_|_\___/__/
            %
            % store the uicontrol handles in the figure handles via guidata()
            handles.axesCircles = axesCircles;
            handles.axesText = axesText;
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
                    obj.kybrd_period();
                case 'comma'
                    obj.kybrd_comma();
                case 'hyphen'
                    %% delete a track
                    %
                    obj.pkTwo.makecell_mode = 'delete';
                    handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                    handlesControl.tabMakeCell_togglebuttonDelete.Value = 1;
                    obj.pkTwo.gui_control.tabMakeCell_buttongroup_SelectionChangedFcn;
                    guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
                case 'rightarrow'
                    
                case 'leftarrow'
                    
                case 'downarrow'
                    
                case 'uparrow'
                    
                case 'backspace'
                    
                case 'd'
                    %% timepoint at end of track
                    %
                    oldIndImage = obj.pkTwo.indImage;
                    obj.pkTwo.indImage = find(obj.trackCenLogical(obj.pkTwo.mcl.pointer_track,:),1,'last');
                    firstInd =  find(obj.trackCenLogical(obj.pkTwo.mcl.pointer_track,:),1,'first');
                    if oldIndImage >= obj.pkTwo.indImage
                        obj.pkTwo.indImage = oldIndImage + 1;
                        if obj.pkTwo.indImage > height(obj.pkTwo.smda_databaseSubset)
                            obj.pkTwo.indImage = height(obj.pkTwo.smda_databaseSubset);
                            return
                        end
                        handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                        handlesControl.infoBk_editTimepoint.String = num2str(obj.pkTwo.indImage);
                        guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
                        obj.loop_stepRight;
                    elseif oldIndImage < firstInd
                        obj.pkTwo.indImage = firstInd;
                        handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                        handlesControl.infoBk_editTimepoint.String = num2str(obj.pkTwo.indImage);
                        guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
                        obj.loop_stepX;
                    else
                        handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                        handlesControl.infoBk_editTimepoint.String = num2str(obj.pkTwo.indImage);
                        guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
                        obj.loop_stepX;
                    end
                case 'a'
                    %% timepoint at start of track
                    %
                    oldIndImage = obj.pkTwo.indImage;
                    obj.pkTwo.indImage = find(obj.trackCenLogical(obj.pkTwo.mcl.pointer_track,:),1,'first');
                    lastInd = find(obj.trackCenLogical(obj.pkTwo.mcl.pointer_track,:),1,'last');
                    if oldIndImage <= obj.pkTwo.indImage
                        obj.pkTwo.indImage = oldIndImage - 1;
                        if obj.pkTwo.indImage < 1
                            obj.pkTwo.indImage = 1;
                            return
                        end
                        handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                        handlesControl.infoBk_editTimepoint.String = num2str(obj.pkTwo.indImage);
                        guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
                        obj.loop_stepLeft;
                    elseif oldIndImage > lastInd
                        obj.pkTwo.indImage = lastInd;
                        handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                        handlesControl.infoBk_editTimepoint.String = num2str(obj.pkTwo.indImage);
                        guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
                        obj.loop_stepX;
                    else
                        handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                        handlesControl.infoBk_editTimepoint.String = num2str(obj.pkTwo.indImage);
                        guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
                        obj.loop_stepX;
                    end
                case 'b'
                    %% break a track into two tracks
                    %
                    obj.pkTwo.makecell_mode = 'break';
                    handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                    handlesControl.tabMakeCell_togglebuttonBreak.Value = 1;
                    obj.pkTwo.gui_control.tabMakeCell_buttongroup_SelectionChangedFcn;
                    guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
                case 'c'
                    %% create a new cell
                    %
                    obj.pkTwo.gui_control.tabMakeCell_pushbuttonNewCell_Callback;
                    obj.pkTwo.mcl.pointer_makecell3 = obj.pkTwo.mcl.pointer_makecell;
                case 'j'
                    %% join two tracks
                    %
                    obj.pkTwo.makecell_mode = 'join';
                    handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                    handlesControl.tabMakeCell_togglebuttonJoin.Value = 1;
                    obj.pkTwo.gui_control.tabMakeCell_buttongroup_SelectionChangedFcn;
                    guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
                case 'n'
                    %% do nothing
                    %
                    obj.pkTwo.makecell_mode = 'none';
                    handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                    handlesControl.tabMakeCell_togglebuttonNone.Value = 1;
                    obj.pkTwo.gui_control.tabMakeCell_buttongroup_SelectionChangedFcn;
                    guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
                case 'm'
                    %% chose mother cell
                    %
                    obj.pkTwo.makecell_mode = 'mother';
                    handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                    handlesControl.tabMakeCell_togglebuttonMother.Value = 1;
                    obj.pkTwo.gui_control.tabMakeCell_buttongroup_SelectionChangedFcn;
                    guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
                case 't'
                    %% add a track to a cell
                    %
                    obj.pkTwo.makecell_mode = 'track 2 cell';
                    handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                    handlesControl.tabMakeCell_togglebuttonAddTrack2Cell.Value = 1;
                    obj.pkTwo.gui_control.tabMakeCell_buttongroup_SelectionChangedFcn;
                    guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
                case 'escape'
                    %% reset conditional properties
                    %
                    obj.trackJoinBool = false;
                    obj.makecellMotherBool = false;
                    obj.pkTwo.makecell_mode = 'none';
                    handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                    handlesControl.tabMakeCell_togglebuttonNone.Value = 1;
                    obj.pkTwo.gui_control.tabMakeCell_buttongroup_SelectionChangedFcn;
                    handlesControl.infoBk_textMessage.String = sprintf('Aborted! System is reset.');
                    guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
            end
        end
        %%
        %
        function obj = updateLimits(obj)
            handles = guidata(obj.gui_main);
            
            handles.axesTracks.YLim = [1,obj.pkTwo.ityA.imageHeightNoBin/...
                obj.pkTwo.ityA.settings_binning(obj.pkTwo.indAS)];
            handles.axesTracks.XLim = [1,obj.pkTwo.ityA.imageWidthNoBin/...
                obj.pkTwo.ityA.settings_binning(obj.pkTwo.indAS)];
            
            handles.axesCircles.YLim = [1,obj.pkTwo.ityA.imageHeightNoBin/...
                obj.pkTwo.ityA.settings_binning(obj.pkTwo.indAS)];
            handles.axesCircles.XLim = [1,obj.pkTwo.ityA.imageWidthNoBin/...
                obj.pkTwo.ityA.settings_binning(obj.pkTwo.indAS)];
            
            handles.axesText.YLim = [1,obj.pkTwo.ityA.imageHeightNoBin/...
                obj.pkTwo.ityA.settings_binning(obj.pkTwo.indAS)];
            handles.axesText.XLim = [1,obj.pkTwo.ityA.imageWidthNoBin/...
                obj.pkTwo.ityA.settings_binning(obj.pkTwo.indAS)];
            
            guidata(obj.gui_main,handles);
        end
        
        %%
        %
        function obj = initialize(obj)
            handles = guidata(obj.gui_main);
            
            obj.imag3 = imread(obj.imag3path); %fullfile(pkTwo.moviePathA,'RAW_DATA',pkTwo.smda_databaseSubsetA.filename{pkTwo.indImage})
            obj.image_width = size(obj.imag3,2);
            obj.image_height = size(obj.imag3,1);
            
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
            
            obj.gui_main.Position = [(Char_SS(3)-fwidth)/2 (Char_SS(4)-fheight)/2 fwidth fheight];
            handles.axesImageViewer.Position = [0 0 fwidth  fheight];
            handles.axesImageViewer.XLim = [0.5,obj.image_width+0.5];
            handles.axesImageViewer.YLim = [0.5,obj.image_height+0.5];
            
            handles.axesText.Position = [0 0 fwidth  fheight];
            handles.axesCircles.Position = [0 0 fwidth  fheight];
            
            handles.displayedImage.CData = obj.imag3;
            
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = loadNewTracks(obj)
            handles = guidata(obj.gui_main);
            handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
            handlesControl.infoBk_textMessage.String = sprintf('Loading new tracks...');
            drawnow;
            %%
            % process centroid data
            obj.pkTwo.mcl.import(obj.pkTwo.indP);
            obj.pkTwo.mcl.moviePath = obj.pkTwo.moviePath;
            mydatabase = obj.pkTwo.mcl.track_database;
            numOfT = obj.pkTwo.ity.number_of_timepoints;
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
            for i = 1:length(obj.trackCircle)
                if isa(obj.trackCircle{i},'matlab.graphics.primitive.Rectangle')
                    delete(obj.trackCircle{i});
                end
                if isa(obj.trackText{i},'matlab.graphics.primitive.Text')
                    delete(obj.trackText{i});
                end
            end
            mydatabase1 = obj.pkTwo.track_database{obj.pkTwo.indP};
            obj.trackCircle = cell(max(mydatabase1.trackID),1);
            obj.trackText = cell(max(mydatabase1.trackID),1);
            handlesControl.infoBk_textMessage.String = sprintf('Importing Tracks...');
            drawnow;
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
                myrec.FaceColor = obj.trackColor(mod(i,3)+1,:);
                myrec.Position = [obj.trackCenCol(i,obj.trackCenLogical(i,:)).XData(1)-(obj.trackCircleSize-1)/2,obj.trackCenRow(i,obj.trackCenLogical(i,:)).YData(1)-(obj.trackCircleSize-1)/2,obj.trackCircleSize,obj.trackCircleSize];
                mclID = obj.pkTwo.mcl.track_makecell(i);
                if mclID ~= 0
                    myrec.EdgeColor = obj.trackColorHighlight2;
                    myrec.LineWidth = 2;
                else
                    myrec.EdgeColor = [0,0,0];
                    myrec.LineWidth = 0.5;
                end
                obj.trackCircle{i} = myrec;
            end
            handlesControl.infoBk_textMessage.String = sprintf('Transcribing Text...');
            drawnow;
            for i = 1:length(obj.trackText)
                if ~any(obj.trackCenLogical(i,:))
                    continue
                end
                obj.trackText{i} = text('Parent',handles.axesText);
                obj.updateTrackText(i);
            end
            handlesControl.infoBk_textMessage.String = sprintf('Position %d',obj.pkTwo.indP);
            drawnow;
            obj.loop_stepX;
            obj.pkTwo.gui_control.tabGPS_loop;
            obj.pkTwo.gui_control.tabMakeCell_loop;
            guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
        end
        %%
        %
        function obj = visualizeTracks(obj)
            handles = guidata(obj.gui_main);
            handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
            %% Recalculate tracks
            % Assumes image size remains the same for this settings
            cellfun(@delete,obj.trackCircle);
            obj.trackCircle = cell(max(obj.pkTwo.mcl.track_database.trackID),1);
            handlesControl.infoBk_textMessage.String = sprintf('Importing Tracks...');
            drawnow;
            handlesControl.infoBk_textMessage.String = sprintf('Importing Circles...');
            drawnow;
            for i = 1:length(obj.trackCircle)
                if ~obj.pkTwo.mcl.track_logical(i)
                    continue
                end
                myrec = rectangle('Parent',handles.axesCircles);
                myrec.ButtonDownFcn = @obj.clickLoop;
                myrec.UserData = i;
                myrec.Curvature = [1,1];
                myrec.FaceColor = obj.trackColor(mod(i,3)+1,:);
                myrec.Position = [obj.trackCenCol(i,obj.trackCenLogical(i,:)).XData(1)-(obj.trackCircleSize-1)/2,obj.trackCenRow(i,obj.trackCenLogical(i,:)).YData(1)-(obj.trackCircleSize-1)/2,obj.trackCircleSize,obj.trackCircleSize];
                obj.trackCircle{i} = myrec;
            end
            handlesControl.infoBk_textMessage.String = sprintf('Position %d',obj.pkTwo.indP);
            drawnow;
            guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
            obj.loop_stepX;
        end
        %%
        %
        function obj = loop_stepX(obj)
            handles = guidata(obj.gui_main);
            obj.imag3 = imread(fullfile(obj.pkTwo.moviePath,'.thumb',obj.pkTwo.smda_databaseSubset.filename{obj.pkTwo.indImage}));
            handles.displayedImage.CData = obj.imag3;
            obj.updateLimits;
            guidata(obj.gui_main,handles);
            
            %%%
            %   _____            _    __   ___
            %  |_   _| _ __ _ __| |__ \ \ / (_)___
            %    | || '_/ _` / _| / /  \ V /| (_-<
            %    |_||_| \__,_\__|_\_\   \_/ |_/__/
            %
            if obj.pkTwo.gui_control.menu_viewTrackBool
                switch obj.pkTwo.gui_control.menu_viewTime
                    case 'all'
                        trackCircleHalfSize = (obj.trackCircleSize-1)/2;
                        for i = 1:length(obj.trackCircle)
                            if ~obj.pkTwo.mcl.track_logical(i)
                                continue
                            end
                            if obj.trackCenLogical(i,obj.pkTwo.indImage)
                                obj.trackText{i}.Visible = 'on';
                                obj.trackText{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)+trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)+trackCircleHalfSize];
                                obj.trackCircle{i}.Visible = 'on';
                                obj.trackCircle{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCircleSize,obj.trackCircleSize];
                            else
                                obj.trackText{i}.Visible = 'off';
                                obj.trackCircle{i}.Visible = 'off';
                            end
                        end
                    case 'now'
                        trackCircleHalfSize = (obj.trackCircleSize-1)/2;
                        for i = 1:length(obj.trackCircle)
                            if ~obj.pkTwo.mcl.track_logical(i)
                                continue
                            end
                            if obj.trackCenLogical(i,obj.pkTwo.indImage)
                                obj.trackText{i}.Visible = 'on';
                                obj.trackText{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)+trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)+trackCircleHalfSize];
                                obj.trackCircle{i}.Visible = 'on';
                                obj.trackCircle{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCircleSize,obj.trackCircleSize];
                            else
                                obj.trackText{i}.Visible = 'off';
                                obj.trackCircle{i}.Visible = 'off';
                            end
                        end
                end
            end
        end
        %%
        %
        function obj = loop_stepRight(obj)
            handles = guidata(obj.gui_main);
            obj.imag3 = imread(fullfile(obj.pkTwo.moviePath,'.thumb',obj.pkTwo.smda_databaseSubset.filename{obj.pkTwo.indImage}));
            handles.displayedImage.CData = obj.imag3;
            obj.updateLimits;
            guidata(obj.gui_main,handles);
            
            %%%
            %   _____            _    __   ___
            %  |_   _| _ __ _ __| |__ \ \ / (_)___
            %    | || '_/ _` / _| / /  \ V /| (_-<
            %    |_||_| \__,_\__|_\_\   \_/ |_/__/
            %
            if obj.pkTwo.gui_control.menu_viewTrackBool
                switch obj.pkTwo.gui_control.menu_viewTime
                    case 'all'
                        trackCircleHalfSize = (obj.trackCircleSize-1)/2;
                        for i = 1:length(obj.trackCircle)
                            if obj.trackCenLogicalDiff(i,obj.pkTwo.indImage-1) == 0 && ~obj.trackCenLogical(i,obj.pkTwo.indImage)
                                % do nothing
                            elseif obj.trackCenLogical(i,obj.pkTwo.indImage) && obj.trackCenLogicalDiff(i,obj.pkTwo.indImage-1) == 0
                                
                                obj.trackText{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)+trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)+trackCircleHalfSize];
                                obj.trackCircle{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCircleSize,obj.trackCircleSize];
                            elseif obj.trackCenLogicalDiff(i,obj.pkTwo.indImage-1) == -1
                                obj.trackText{i}.Visible = 'off';
                                obj.trackCircle{i}.Visible = 'off';
                            else
                                obj.trackText{i}.Visible = 'on';
                                obj.trackText{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)+trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)+trackCircleHalfSize];
                                obj.trackCircle{i}.Visible = 'on';
                                obj.trackCircle{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCircleSize,obj.trackCircleSize];
                            end
                        end
                    case 'now'
                        trackCircleHalfSize = (obj.trackCircleSize-1)/2;
                        for i = 1:length(obj.trackCircle)
                            if obj.trackCenLogicalDiff(i,obj.pkTwo.indImage-1) == 0 && ~obj.trackCenLogical(i,obj.pkTwo.indImage)
                                % do nothing
                            elseif obj.trackCenLogical(i,obj.pkTwo.indImage) && obj.trackCenLogicalDiff(i,obj.pkTwo.indImage-1) == 0
                                obj.trackText{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)+trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)+trackCircleHalfSize];
                                obj.trackCircle{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCircleSize,obj.trackCircleSize];
                            elseif obj.trackCenLogicalDiff(i,obj.pkTwo.indImage-1) == -1
                                obj.trackText{i}.Visible = 'off';
                                obj.trackCircle{i}.Visible = 'off';
                            else
                                obj.trackText{i}.Visible = 'on';
                                obj.trackText{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)+trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)+trackCircleHalfSize];
                                obj.trackCircle{i}.Visible = 'on';
                                obj.trackCircle{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCircleSize,obj.trackCircleSize];
                            end
                        end
                end
            end
        end
        %%
        %
        function obj = loop_stepLeft(obj)
            handles = guidata(obj.gui_main);
            obj.imag3 = imread(fullfile(obj.pkTwo.moviePath,'.thumb',obj.pkTwo.smda_databaseSubset.filename{obj.pkTwo.indImage}));
            handles.displayedImage.CData = obj.imag3;
            obj.updateLimits;
            guidata(obj.gui_main,handles);
            
            %%%
            %   _____            _    __   ___
            %  |_   _| _ __ _ __| |__ \ \ / (_)___
            %    | || '_/ _` / _| / /  \ V /| (_-<
            %    |_||_| \__,_\__|_\_\   \_/ |_/__/
            %
            if obj.pkTwo.gui_control.menu_viewTrackBool
                switch obj.pkTwo.gui_control.menu_viewTime
                    case 'all'
                        trackCircleHalfSize = (obj.trackCircleSize-1)/2;
                        for i = 1:length(obj.trackCircle)
                            if obj.trackCenLogicalDiff(i,obj.pkTwo.indImage) == 0 && ~obj.trackCenLogical(i,obj.pkTwo.indImage)
                                %do nothing
                            elseif obj.trackCenLogical(i,obj.pkTwo.indImage) && obj.trackCenLogicalDiff(i,obj.pkTwo.indImage) == 0
                                obj.trackText{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)+trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)+trackCircleHalfSize];
                                obj.trackCircle{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCircleSize,obj.trackCircleSize];
                            elseif obj.trackCenLogicalDiff(i,obj.pkTwo.indImage) == 1
                                obj.trackText{i}.Visible = 'off';
                                obj.trackCircle{i}.Visible = 'off';
                            else
                                obj.trackText{i}.Visible = 'on';
                                obj.trackText{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)+trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)+trackCircleHalfSize];
                                obj.trackCircle{i}.Visible = 'on';
                                obj.trackCircle{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCircleSize,obj.trackCircleSize];
                            end
                        end
                    case 'now'
                        trackCircleHalfSize = (obj.trackCircleSize-1)/2;
                        for i = 1:length(obj.trackCircle)
                            if obj.trackCenLogicalDiff(i,obj.pkTwo.indImage) == 0 && ~obj.trackCenLogical(i,obj.pkTwo.indImage)
                                %do nothing
                            elseif obj.trackCenLogical(i,obj.pkTwo.indImage) && obj.trackCenLogicalDiff(i,obj.pkTwo.indImage) == 0
                                obj.trackText{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)+trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)+trackCircleHalfSize];
                                obj.trackCircle{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCircleSize,obj.trackCircleSize];
                            elseif obj.trackCenLogicalDiff(i,obj.pkTwo.indImage) == 1
                                obj.trackText{i}.Visible = 'off';
                                obj.trackCircle{i}.Visible = 'off';
                            else
                                obj.trackText{i}.Visible = 'on';
                                obj.trackText{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)+trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)+trackCircleHalfSize];
                                obj.trackCircle{i}.Visible = 'on';
                                obj.trackCircle{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCircleSize,obj.trackCircleSize];
                            end
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
            if obj.pkTwo.gui_control.menu_viewTrackBool
                %%%
                % if the menu_viewTrackBool is true, then tracks are
                % displayed
                obj.pkTwo.mcl.pointer_track2 = obj.pkTwo.mcl.pointer_track;
                obj.pkTwo.mcl.pointer_track = myrec.UserData;
                obj.pkTwo.mcl.pointer_makecell2 = obj.pkTwo.mcl.pointer_makecell;
                obj.pkTwo.mcl.pointer_makecell = obj.pkTwo.mcl.track_makecell(obj.pkTwo.mcl.pointer_track);
                %% highlight
                obj.highlightTrack;
                handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                %% track edits
                %
                switch obj.pkTwo.makecell_mode
                    case 'none'
                        handlesControl.infoBk_textMessage.String = sprintf('track ID %d\nmakecell ID %d',obj.pkTwo.mcl.pointer_track,obj.pkTwo.mcl.pointer_makecell);
                    case 'join'
                        if obj.trackJoinBool
                            if obj.pkTwo.mcl.pointer_track2 > obj.pkTwo.mcl.pointer_track
                                keepTrack = obj.pkTwo.mcl.pointer_track;
                                replaceTrack = obj.pkTwo.mcl.pointer_track2;
                            else
                                keepTrack = obj.pkTwo.mcl.pointer_track2;
                                replaceTrack = obj.pkTwo.mcl.pointer_track;
                            end
                            obj.pkTwo.mcl.joinTrack(keepTrack,replaceTrack);
                            obj.trackJoinBool = false;
                            myLogical = ismember(obj.pkTwo.mcl.track_database.trackID,[keepTrack,replaceTrack]);
                            myArray = 1:numel(myLogical);
                            myArray = myArray(myLogical);
                            obj.trackCenRow(keepTrack,:) = 0;
                            obj.trackCenCol(keepTrack,:) = 0;
                            obj.trackCenLogical(keepTrack,:) = false;
                            obj.trackCenRow(replaceTrack,:) = 0;
                            obj.trackCenCol(replaceTrack,:) = 0;
                            obj.trackCenLogical(replaceTrack,:) = false;
                            for v = myArray
                                mytimepoint = obj.pkTwo.mcl.track_database.timepoint(v);
                                mytrackID = obj.pkTwo.mcl.track_database.trackID(v);
                                obj.trackCenRow(mytrackID,mytimepoint) = obj.pkTwo.mcl.track_database.centroid_row(v);
                                obj.trackCenCol(mytrackID,mytimepoint) = obj.pkTwo.mcl.track_database.centroid_col(v);
                                obj.trackCenLogical(mytrackID,mytimepoint) = true;
                            end
                            obj.trackCenLogicalDiff = diff(obj.trackCenLogical,1,2);
                            
                            obj.trackLine{replaceTrack}.Visible = 'off';
                            obj.trackCircle{replaceTrack}.Visible = 'off';
                            obj.trackText{replaceTrack}.Visible = 'off';
                            
                            obj.trackLine{keepTrack}.YData = obj.trackCenRow(keepTrack,obj.trackCenLogical(keepTrack,:));
                            obj.trackLine{keepTrack}.XData = obj.trackCenCol(keepTrack,obj.trackCenLogical(keepTrack,:));
                            obj.trackCircle{keepTrack}.Position = [obj.trackLine{keepTrack}.XData(1)-(obj.trackCircleSize-1)/2,obj.trackLine{keepTrack}.YData(1)-(obj.trackCircleSize-1)/2,obj.trackCircleSize,obj.trackCircleSize];
                            obj.trackText{keepTrack}.Position = [obj.trackLine{keepTrack}.XData(1)+(obj.trackCircleSize-1)/2,obj.trackLine{keepTrack}.YData(1)+(obj.trackCircleSize-1)/2];
                            handlesControl.infoBk_textMessage.String = sprintf('Joined track %d with\ntrack %d.',keepTrack,replaceTrack);
                            %%
                            % return to 'none' mode
                            handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                            handlesControl.tabMakeCell_togglebuttonNone.Value = 1;
                            obj.pkTwo.gui_control.tabMakeCell_buttongroup_SelectionChangedFcn;
                            guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
                        else
                            handlesControl.infoBk_textMessage.String = sprintf('Join track %d with...',obj.pkTwo.mcl.pointer_track);
                            obj.trackJoinBool = true;
                        end
                        obj.pkTwo.gui_control.tabMakeCell_loop;
                        obj.loop_stepX;
                    case 'break'
                        oldTrack = obj.pkTwo.mcl.pointer_track;
                        obj.pkTwo.mcl.breakTrack(obj.pkTwo.mcl.pointer_track,obj.pkTwo.indImage);
                        newTrack = obj.pkTwo.mcl.pointer_track;
                        obj.pkTwo.mcl.pointer_track = oldTrack;
                        
                        myLogical = ismember(obj.pkTwo.mcl.track_database.trackID,[oldTrack,newTrack]);
                        myArray = 1:numel(myLogical);
                        myArray = myArray(myLogical);
                        obj.trackCenRow(oldTrack,:) = 0;
                        obj.trackCenCol(oldTrack,:) = 0;
                        obj.trackCenLogical(oldTrack,:) = false;
                        obj.trackCenRow(newTrack,:) = 0;
                        obj.trackCenCol(newTrack,:) = 0;
                        obj.trackCenLogical(newTrack,:) = false;
                        for v = myArray
                            mytimepoint = obj.pkTwo.mcl.track_database.timepoint(v);
                            mytrackID = obj.pkTwo.mcl.track_database.trackID(v);
                            obj.trackCenRow(mytrackID,mytimepoint) = obj.pkTwo.mcl.track_database.centroid_row(v);
                            obj.trackCenCol(mytrackID,mytimepoint) = obj.pkTwo.mcl.track_database.centroid_col(v);
                            obj.trackCenLogical(mytrackID,mytimepoint) = true;
                        end
                        obj.trackCenLogicalDiff = diff(obj.trackCenLogical,1,2);
                        
                        handles = guidata(obj.gui_main);
                        if newTrack > numel(obj.trackLine)
                            myline = line('Parent',handles.axesTracks);
                            myline.Color = obj.trackColor(mod(newTrack,3)+1,:);
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
                            
                            obj.trackText{newTrack} = text('Parent',handles.axesText);
                            obj.updateTrackText(newTrack);
                            obj.trackText{newTrack}.Position = [obj.trackLine{newTrack}.XData(1)+(obj.trackCircleSize-1)/2,obj.trackLine{newTrack}.YData(1)+(obj.trackCircleSize-1)/2];
                        else
                            if isa(obj.trackLine{newTrack},'matlab.graphics.primitive.Line');
                                obj.trackLine{newTrack}.YData = obj.trackCenRow(newTrack,obj.trackCenLogical(newTrack,:));
                                obj.trackLine{newTrack}.XData = obj.trackCenCol(newTrack,obj.trackCenLogical(newTrack,:));
                            else
                                myline = line('Parent',handles.axesTracks);
                                myline.Color = obj.trackColor(mod(newTrack,3)+1,:);
                                myline.LineWidth = 1;
                                myline.YData = obj.trackCenRow(newTrack,obj.trackCenLogical(newTrack,:));
                                myline.XData = obj.trackCenCol(newTrack,obj.trackCenLogical(newTrack,:));
                                obj.trackLine{newTrack} = myline;
                            end
                            if isa(obj.trackCircle{newTrack},'matlab.graphics.primitive.Rectangle')
                                obj.trackCircle{newTrack}.Position = [obj.trackLine{newTrack}.XData(1)-(obj.trackCircleSize-1)/2,obj.trackLine{newTrack}.YData(1)-(obj.trackCircleSize-1)/2,obj.trackCircleSize,obj.trackCircleSize];
                            else
                                myrec = rectangle('Parent',handles.axesCircles);
                                myrec.ButtonDownFcn = @obj.clickLoop;
                                myrec.UserData = newTrack;
                                myrec.Curvature = [1,1];
                                myrec.FaceColor = obj.trackLine{newTrack}.Color;
                                myrec.Position = [obj.trackLine{newTrack}.XData(1)-(obj.trackCircleSize-1)/2,obj.trackLine{newTrack}.YData(1)-(obj.trackCircleSize-1)/2,obj.trackCircleSize,obj.trackCircleSize];
                                obj.trackCircle{newTrack} = myrec;
                            end
                            if isa(obj.trackLine{newTrack},'matlab.graphics.primitive.Text');
                                obj.trackText{newTrack}.Position = [obj.trackLine{newTrack}.XData(1)+(obj.trackCircleSize-1)/2,obj.trackLine{newTrack}.YData(1)+(obj.trackCircleSize-1)/2];
                                
                            else
                                obj.trackText{newTrack} = text('Parent',handles.axesText);
                                obj.trackText{newTrack}.Position = [obj.trackLine{newTrack}.XData(1)+(obj.trackCircleSize-1)/2,obj.trackLine{newTrack}.YData(1)+(obj.trackCircleSize-1)/2];
                            end
                            obj.updateTrackText(newTrack);
                            obj.trackLine{newTrack}.Visible = 'on';
                            obj.trackCircle{newTrack}.Visible = 'on';
                            obj.trackText{newTrack}.Visible = 'on';
                        end
                        obj.trackLine{oldTrack}.YData = obj.trackCenRow(oldTrack,obj.trackCenLogical(oldTrack,:));
                        obj.trackLine{oldTrack}.XData = obj.trackCenCol(oldTrack,obj.trackCenLogical(oldTrack,:));
                        obj.trackCircle{oldTrack}.Position = [obj.trackLine{oldTrack}.XData(1)-(obj.trackCircleSize-1)/2,obj.trackLine{oldTrack}.YData(1)-(obj.trackCircleSize-1)/2,obj.trackCircleSize,obj.trackCircleSize];
                        obj.trackText{oldTrack}.Position = [obj.trackLine{oldTrack}.XData(1)+(obj.trackCircleSize-1)/2,obj.trackLine{oldTrack}.YData(1)+(obj.trackCircleSize-1)/2];
                        obj.pkTwo.gui_control.tabMakeCell_loop;
                        obj.loop_stepX;
                        %%
                        % return to 'none' mode
                        handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                        handlesControl.tabMakeCell_togglebuttonNone.Value = 1;
                        obj.pkTwo.gui_control.tabMakeCell_buttongroup_SelectionChangedFcn;
                        guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
                    case 'delete'
                        replaceTrack = obj.pkTwo.mcl.pointer_track;
                        obj.pkTwo.mcl.deleteTrack(replaceTrack);
                        
                        obj.trackCenRow(replaceTrack,:) = 0;
                        obj.trackCenCol(replaceTrack,:) = 0;
                        obj.trackCenLogical(replaceTrack,:) = false;
                        obj.trackCenLogicalDiff = diff(obj.trackCenLogical,1,2);
                        
                        obj.trackLine{replaceTrack}.Visible = 'off';
                        obj.trackCircle{replaceTrack}.Visible = 'off';
                        obj.trackText{replaceTrack}.Visible = 'off';
                        
                        handlesControl.infoBk_textMessage.String = sprintf('Deleted track %d.',replaceTrack);
                        obj.pkTwo.gui_control.tabMakeCell_loop;
                        obj.loop_stepX;
                        
                        obj.pkTwo.gui_control.tabMakeCell_loop;
                        %%
                        % return to 'none' mode
                        handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                        handlesControl.tabMakeCell_togglebuttonNone.Value = 1;
                        obj.pkTwo.gui_control.tabMakeCell_buttongroup_SelectionChangedFcn;
                        guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
                    case 'mother'
                        if obj.makecellMotherBool
                            obj.makecellMotherBool = false;
                            [mom,dau] = obj.pkTwo.mcl.identifyMother(obj.pkTwo.mcl.pointer_makecell2,obj.pkTwo.mcl.pointer_makecell);
                            handlesControl.infoBk_textMessage.String = sprintf('Cell %d is the mother of\ncell %d.',mom,dau);
                            %%
                            % return to 'none' mode
                            handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                            handlesControl.tabMakeCell_togglebuttonNone.Value = 1;
                            obj.pkTwo.gui_control.tabMakeCell_buttongroup_SelectionChangedFcn;
                            obj.updateTrackText;
                            guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
                        else
                            handlesControl.infoBk_textMessage.String = sprintf('Cell %d will be the mother of...',obj.pkTwo.mcl.pointer_makecell);
                            obj.makecellMotherBool = true;
                        end
                        obj.pkTwo.gui_control.tabMakeCell_loop;
                        obj.loop_stepX;
                    case 'track 2 cell'
                        obj.pkTwo.mcl.addTrack2Cell(obj.pkTwo.mcl.pointer_track,obj.pkTwo.mcl.pointer_makecell3);
                        obj.pkTwo.gui_control.tabMakeCell_loop;
                        obj.updateTrackText;
                        obj.highlightTrack;
                        %%
                        % return to 'none' mode
                        handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
                        handlesControl.tabMakeCell_togglebuttonNone.Value = 1;
                        obj.pkTwo.gui_control.tabMakeCell_buttongroup_SelectionChangedFcn;
                        guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
                    otherwise
                        fprintf('trackID %d\n',obj.pkTwo.mcl.pointer_track);
                end
                guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
            end
        end
        %%
        %
        function obj = highlightTrack(obj)
            if obj.pkTwo.mcl.pointer_track2~=obj.pkTwo.mcl.pointer_track
                myrec = obj.trackCircle{obj.pkTwo.mcl.pointer_track};
                myrec.FaceColor = obj.trackColorHighlight;
                
                myrec2 = obj.trackCircle{obj.pkTwo.mcl.pointer_track2};
                myrec2.FaceColor = obj.trackColor(mod(obj.pkTwo.mcl.pointer_track2,3)+1,:);
            else
                myrec = obj.trackCircle{obj.pkTwo.mcl.pointer_track};
                myrec.FaceColor = obj.trackColorHighlight;
            end
            mclID = obj.pkTwo.mcl.track_makecell(obj.pkTwo.mcl.pointer_track);
            if mclID ~= 0
                myrec.EdgeColor = obj.trackColorHighlight2;
                myrec.LineWidth = 2;
            else
                myrec.EdgeColor = [0,0,0];
                myrec.LineWidth = 0.5;
            end
        end
        %%
        %
        function obj = updateTrackText(obj,varargin)
            %%%
            % parse the input
            q = inputParser;
            addRequired(q, 'obj', @(x) isa(x,'cellularGPSTrackingManual_object_imageViewer'));
            addOptional(q, 'trackID',obj.pkTwo.mcl.pointer_track, @(x)isnumeric(x));
            parse(q,obj,varargin{:});
            trackID = q.Results.trackID;
            obj.trackText{trackID}.Color = obj.trackTextColor;
            obj.trackText{trackID}.BackgroundColor = obj.trackTextBackgroundColor;
            obj.trackText{trackID}.FontSize = obj.trackTextFontSize;
            obj.trackText{trackID}.Margin = obj.trackTextMargin;
            obj.trackText{trackID}.UserData = trackID;
            obj.trackText{trackID}.Position = [obj.trackLine{trackID}.XData(1)+(obj.trackCircleSize-1)/2,obj.trackLine{trackID}.YData(1)+(obj.trackCircleSize-1)/2];
            myString = sprintf('trck#: %d',trackID);
            mclID = obj.pkTwo.mcl.track_makecell(trackID);
            if mclID ~= 0
                myString = strcat(myString,sprintf('\nmkcl#: %d',mclID));
                if obj.pkTwo.mcl.makecell_mother(mclID) ~= 0
                    myString = strcat(myString,sprintf('\nmthr: %d',obj.pkTwo.mcl.makecell_mother(mclID)));
                end
                if obj.pkTwo.mcl.makecell_divisionStart(mclID) ~= 0
                    myString = strcat(myString,sprintf('\ndvSt: %d',obj.pkTwo.mcl.makecell_divisionStart(mclID)));
                elseif obj.pkTwo.mcl.makecell_apoptosisStart(mclID) ~= 0
                    myString = strcat(myString,sprintf('\napSt: %d',obj.pkTwo.mcl.makecell_apoptosisStart(mclID)));
                end
            end
            obj.trackText{trackID}.String = myString;
        end
    end
end