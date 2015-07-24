%% cellularGPSSimpleViewer_object
%
classdef cellularGPSSimpleViewer_object < handle
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
        
        contrast;
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
        function obj = cellularGPSSimpleViewer_object()
            %%%
            %
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
            
            displayedImage = image('Parent',axesImageViewer);           
            %% Handles
            %   _  _              _ _
            %  | || |__ _ _ _  __| | |___ ___
            %  | __ / _` | ' \/ _` | / -_|_-<
            %  |_||_\__,_|_||_\__,_|_\___/__/
            %
            % store the uicontrol handles in the figure handles via guidata()
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
            % obj.updateLimits;
            %%%
            % make the gui visible
            set(f,'Visible','on');
            %%
            %
            obj.kybrd_cmd.period = @cellularGPSSimpleViewer_kybrd_period;
            obj.kybrd_cmd.comma = @cellularGPSSimpleViewer_kybrd_comma;
            obj.kybrd_cmd.a = @cellularGPSSimpleViewer_kybrd_a;
            obj.kybrd_cmd.s = @cellularGPSSimpleViewer_kybrd_s;
            obj.kybrd_cmd.q = @cellularGPSSimpleViewer_kybrd_q;
            obj.kybrd_cmd.w = @cellularGPSSimpleViewer_kybrd_w;
            obj.kybrd_cmd.z = @cellularGPSSimpleViewer_kybrd_z;
            obj.kybrd_cmd.x = @cellularGPSSimpleViewer_kybrd_x;
            %%
            %
            obj.contrast = cellularGPSSimpleViewer_contrast;
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
                    obj.kybrd_cmd.period(obj);
                case 'comma'
                    obj.kybrd_cmd.comma(obj);
                case 'a'
                    obj.kybrd_cmd.a(obj);
                case 's'
                    obj.kybrd_cmd.s(obj);
                case 'q'
                    obj.kybrd_cmd.q(obj);
                case 'w'
                    obj.kybrd_cmd.w(obj);
                case 'z'
                    obj.kybrd_cmd.z(obj);
                case 'x'
                    obj.kybrd_cmd.x(obj);
            end
        end
        %%
        %
        function obj = update_mainImage(obj)
            handles = guidata(obj.gui_main);
            obj.imag3path = fullfile(obj.imag3dir,obj.tblRegister.filename{obj.indT});
            obj.imag3 = imread(obj.imag3path);
            mydims = ndims(obj.imag3);
            if mydims == 3
                obj.rgbBool = true;
                handlesContrast = guidata(obj.contrast.gui_main);
                mymin = handlesContrast.sliderMin.Value;
                mymax = handlesContrast.sliderMax.Value;
                obj.imag3 = imadjust(obj.imag3,[mymin mymin mymin; mymax mymax mymax],[]);
            else
                obj.rgbBool = false;
            end
            handles.displayedImage.CData = obj.imag3;
            guidata(obj.gui_main,handles);
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
            
            handles.axesImageViewer.XLim = [0.5,obj.image_width+0.5];
            handles.axesImageViewer.YLim = [0.5,obj.image_height+0.5];
            handles.axesText.XLim = handles.axesImageViewer.XLim;
            handles.axesText.YLim = handles.axesImageViewer.YLim;
            handles.axesCircles.XLim = handles.axesImageViewer.XLim;
            handles.axesCircles.YLim = handles.axesImageViewer.YLim;
            
            guidata(obj.gui_main,handles);
        end
        
        %%
        % after specifying the moviePath, call this function to read the
        % database file, itinerary, and to display images.
        function obj = initialize(obj)
            %%%
            % does the movie path exist?
            if ~exist(obj.moviePath,'dir')
                error('imView:baddir','The movie path does not exist or could not be found.');
            end
            %%%
            % does the database file exist?
            if ~exist(fullfile(obj.moviePath,'smda_database.txt'),'file')
                error('imView:nosmda','The smda_database file does not exist.');
            end
            %%%
            %
            if exist(fullfile(obj.moviePath,'thumb'),'dir')
                obj.imag3dir = fullfile(obj.moviePath,'thumb');
            elseif exist(fullfile(obj.moviePath,'PROCESSED_DATA'),'dir')
                obj.imag3dir = fullfile(obj.moviePath,'PROCESSED_DATA');
            elseif exist(fullfile(obj.moviePath,'RAW_DATA'),'dir')
                obj.imag3dir = fullfile(obj.moviePath,'RAW_DATA');
            else
                error('imView:badimgdir','Could not find a vaild directory for the image data. ''thumb'', ''PROCESSED_DATA'', ''RAW_DATA''');
            end
            %%%
            %
            obj.smda_database = readtable(fullfile(obj.moviePath,'smda_database.txt'),'Delimiter','\t');
            obj.smda_itinerary = SuperMDAItineraryTimeFixed_object;
            obj.smda_itinerary.import(fullfile(obj.moviePath,'smdaITF.txt'));
            %% display image relative to the viewing screen
            %
            handles = guidata(obj.gui_main);
            G = obj.smda_itinerary.order_group(obj.indG);
            P = obj.smda_itinerary.order_position{G};
            P = P(obj.indP);
            S = obj.smda_itinerary.order_settings{P};
            S = S(obj.indS);
            smda_databaseLogical = obj.smda_database.group_number == G...
                & obj.smda_database.position_number == P...
                & obj.smda_database.settings_number == S;
            mytable = obj.smda_database(smda_databaseLogical,:);
            obj.tblRegister = sortrows(mytable,{'timepoint'});
            if obj.indT > height(obj.tblRegister)
                obj.indT = height(obj.tblRegister);
            end
            
            obj.update_mainImage;
            
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
            
            handles.fwidth = fwidth/ppChar(1);
            handles.fheight = fheight/ppChar(2);
            handles.ppChar = ppChar;
            handles.Char_SS = Char_SS;
            handles.Pix_SS = Pix_SS;
            
            obj.gui_main.Position = [(Char_SS(3)-handles.fwidth)/2 (Char_SS(4)-handles.fheight)/2 handles.fwidth handles.fheight];
            handles.axesImageViewer.Position = [0 0 handles.fwidth  handles.fheight];
            handles.axesImageViewer.XLim = [0.5,obj.image_width+0.5];
            handles.axesImageViewer.YLim = [0.5,obj.image_height+0.5];
            
            handles.displayedImage.CDataMapping = 'scaled';
            obj.gui_main.Colormap = colormap(gray(1024));
            
            guidata(obj.gui_main,handles);
            %%
            %
            obj.contrast.viewer = obj;
            obj.contrast.initialize;
            obj.contrast.refresh;
        end
        %%
        %
        function obj = resize_guiMain(obj,fwidth,varargin)
            %%%
            % parse the input
            handles = guidata(obj.gui_main);
            q = inputParser;
            addRequired(q, 'obj', @(x) isa(x,'cellularGPSSimpleViewer_object'));
            addOptional(q, 'fwidth',handles.fwidth, @(x)isnumeric(fwidth));
            addParameter(q, 'scale', 1, @isnumeric);
            addParameter(q, 'units', 'characters', @(x) any(strcmp(x,{'characters', 'pixels'})));
            parse(q,obj,fwidth,varargin{:});
            
            %%%
            % update new height and width
            if strcmp(q.Results.units,'pixels')
                handles.fwidth = handles.fwidth/handles.ppChar(1);
                handles.fheight = handles.fwidth/handles.ppChar(2)*obj.image_height/obj.image_width;
            else
                handles.fwidth = q.Results.fwidth;
                handles.fheight = handles.fwidth*handles.ppChar(1)/handles.ppChar(2)*obj.image_height/obj.image_width;
            end
            
            if q.Results.scale ~= 1
                handles.fwidth = handles.fwidth*q.Results.scale;
                handles.fheight = handles.fheight*q.Results.scale;
            end
            
            %%
            % update main figure
            obj.gui_main.Position = [(handles.Char_SS(3)-handles.fwidth)/2 (handles.Char_SS(4)-handles.fheight)/2 handles.fwidth handles.fheight];
            %%%
            % update the axes in the main figure
            h = findobj(obj.gui_main,'Type','axes');
            if numel(h) == 1
                h.Position = [0 0 handles.fwidth  handles.fheight];
            else
                for i = 1:length(h)
                    h{i}.Position = [0 0 handles.fwidth  handles.fheight];
                end
            end
            guidata(obj.gui_main,handles);
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
    end
end