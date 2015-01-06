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
        trackCenLogicalDiff
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
            numOfPosition = sum(tmn.ity.number_position);
            positionInd = horzcat(tmn.ity.ind_position{:});
            kCenRow = cell(numOfPosition,1);
            kCenCol = cell(numOfPosition,1);
            kCenLogical = cell(numOfPosition,1);
            alldatabase = tmn.track_database;
            numOfT = tmn.ity.number_of_timepoints;
            %%%
            % this loop takes a long time to execute
            parfor u = positionInd
                mydatabase = alldatabase{u};
                myCenRow = zeros(max(mydatabase.trackID),numOfT);
                myCenCol = zeros(max(mydatabase.trackID),numOfT);
                myCenLogical = false(size(myCenRow));
                disp(u)
                for v = 1:height(mydatabase)
                    mytimepoint = mydatabase.timepoint(v);
                    mytrackID = mydatabase.trackID(v);
                    myCenRow(mytrackID,mytimepoint) = mydatabase.centroid_row(v);
                    myCenCol(mytrackID,mytimepoint) = mydatabase.centroid_col(v);
                    myCenLogical(mytrackID,mytimepoint) = true;
                end
                kCenRow{u} = myCenRow;
                kCenCol{u} = myCenCol;
                kCenLogical{u} = myCenLogical;
            end
            %%%
            % Assignment to the object was required to be after the parfor.
            obj.trackCenRow = kCenRow;
            obj.trackCenCol = kCenCol;
            obj.trackCenLogical = kCenLogical;
            
            obj.trackCenLogicalDiff = cell(size(obj.trackCenLogical));
            for i = 1:length(obj.trackCenLogical)
                obj.trackCenLogicalDiff{i} = diff(obj.trackCenLogical{i},1,2);
            end
            obj.trackLine = {};
            obj.trackCircle = {};
            obj.trackCircleSize = 11; %must be an odd number
            
            
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
            obj.updateLimits();
            obj.loadNewTracks();
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
                    handlesControl.tabGPS_editTimepoint.String = num2str(obj.tmn.indImage);
                    guidata(obj.tmn.gui_control.gui_main,handlesControl);
                    obj.loop_stepRight;
                case 'comma'
                    obj.tmn.indImage = obj.tmn.indImage - 1;
                    if obj.tmn.indImage < 1
                        obj.tmn.indImage = 1;
                        return
                    end
                    handlesControl = guidata(obj.tmn.gui_control.gui_main);
                    handlesControl.tabGPS_editTimepoint.String = num2str(obj.tmn.indImage);
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
                    obj.tmn.indImage = find(obj.trackCenLogical{obj.tmn.indP}(obj.tmn.mcl.pointer_track,:),1,'last');
                    handlesControl = guidata(obj.tmn.gui_control.gui_main);
                    handlesControl.tabGPS_editTimepoint.String = num2str(obj.tmn.indImage);
                    guidata(obj.tmn.gui_control.gui_main,handlesControl);
                    obj.loop;
                case 'a'
                    %% timepoint at start of track
                    %
                    obj.tmn.indImage = find(obj.trackCenLogical{obj.tmn.indP}(obj.tmn.mcl.pointer_track,:),1,'first');
                    handlesControl = guidata(obj.tmn.gui_control.gui_main);
                    handlesControl.tabGPS_editTimepoint.String = num2str(obj.tmn.indImage);
                    guidata(obj.tmn.gui_control.gui_main,handlesControl);
                    obj.loop;
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
            
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = loadNewTracks(obj)
            handles = guidata(obj.gui_main);
            %% Recalculate tracks
            % Assumes image size remains the same for this settings
            cellfun(@delete,obj.trackCircle);
            cellfun(@delete,obj.trackLine);
            mydatabase1 = obj.tmn.track_database{obj.tmn.indP};
            %obj.tmn.track_database = readtable(fullfile(obj.tmn.moviePath,'TRACKING_DATA',sprintf('trackingPosition_%d.txt',obj.tmn.indP)),'Delimiter','\t');
            obj.trackLine = cell(max(mydatabase1.trackID),1);
            obj.trackCircle = cell(max(mydatabase1.trackID),1);
            %myCenRow = obj.trackCenRow{obj.tmn.indP};
            %myCenCol = obj.trackCenCol{obj.tmn.indP};
            %myCenLogical = obj.trackCenLogical{obj.tmn.indP};
            for i = 1:length(obj.trackLine)
                myline = line('Parent',handles.axesTracks);
                myline.Color = [rand rand rand];
                myline.LineWidth = 1;
                %mylogical = myCenLogical(i,:);
                myline.YData = obj.trackCenRow{obj.tmn.indP}(i,obj.trackCenLogical{obj.tmn.indP}(i,:));
                myline.XData = obj.trackCenCol{obj.tmn.indP}(i,obj.trackCenLogical{obj.tmn.indP}(i,:));
                obj.trackLine{i} = myline;
                
                myrec = rectangle('Parent',handles.axesTracks);
                myrec.ButtonDownFcn = @obj.clickLoop;
                myrec.UserData = i;
                myrec.Curvature = [1,1];
                myrec.FaceColor = myline.Color;
                myrec.Position = [myline.XData(1)-(obj.trackCircleSize-1)/2,myline.YData(1)-(obj.trackCircleSize-1)/2,obj.trackCircleSize,obj.trackCircleSize];
                obj.trackCircle{i} = myrec;
            end
            obj.loop;
        end
        %%
        %
        function obj = loop(obj)
            handles = guidata(obj.gui_main);
            obj.imag3 = imread(fullfile(obj.tmn.moviePath,'.thumb',obj.tmn.smda_databaseSubset.filename{obj.tmn.indImage}));
            handles.displayedImage.CData = obj.imag3;
            obj.updateLimits;
            guidata(obj.gui_main,handles);
            
            %% tracks
            %
            trackCircleHalfSize = (obj.trackCircleSize-1)/2;
            for i = 1:length(obj.trackCircle)
                if obj.trackCenLogical{obj.tmn.indP}(i,obj.tmn.indImage)
                    obj.trackCircle{i}.Visible = 'on';
                    obj.trackCircle{i}.Position = [obj.trackCenCol{obj.tmn.indP}(i,obj.tmn.indImage)-trackCircleHalfSize,...
                        obj.trackCenRow{obj.tmn.indP}(i,obj.tmn.indImage)-trackCircleHalfSize,...
                        obj.trackCircleSize,obj.trackCircleSize];
                else
                    obj.trackCircle{i}.Visible = 'off';
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
            
            %% tracks
            %
            trackCircleHalfSize = (obj.trackCircleSize-1)/2;
            for i = 1:length(obj.trackCircle)
                
                if obj.trackCenLogicalDiff{obj.tmn.indP}(i,obj.tmn.indImage-1) == 0 && ~obj.trackCenLogical{obj.tmn.indP}(i,obj.tmn.indImage)
                    % do nothing
                elseif obj.trackCenLogical{obj.tmn.indP}(i,obj.tmn.indImage) && obj.trackCenLogicalDiff{obj.tmn.indP}(i,obj.tmn.indImage-1) == 0
                    obj.trackCircle{i}.Position = [obj.trackCenCol{obj.tmn.indP}(i,obj.tmn.indImage)-trackCircleHalfSize,...
                        obj.trackCenRow{obj.tmn.indP}(i,obj.tmn.indImage)-trackCircleHalfSize,...
                        obj.trackCircleSize,obj.trackCircleSize];
                elseif obj.trackCenLogicalDiff{obj.tmn.indP}(i,obj.tmn.indImage-1) == -1
                    obj.trackCircle{i}.Visible = 'off';
                else
                    obj.trackCircle{i}.Visible = 'on';
                    obj.trackCircle{i}.Position = [obj.trackCenCol{obj.tmn.indP}(i,obj.tmn.indImage)-trackCircleHalfSize,...
                        obj.trackCenRow{obj.tmn.indP}(i,obj.tmn.indImage)-trackCircleHalfSize,...
                        obj.trackCircleSize,obj.trackCircleSize];
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
            
            %% tracks
            %
            trackCircleHalfSize = (obj.trackCircleSize-1)/2;
            for i = 1:length(obj.trackCircle)
                if obj.trackCenLogicalDiff{obj.tmn.indP}(i,obj.tmn.indImage) == 0 && ~obj.trackCenLogical{obj.tmn.indP}(i,obj.tmn.indImage)
                    %do nothing
                elseif obj.trackCenLogical{obj.tmn.indP}(i,obj.tmn.indImage) && obj.trackCenLogicalDiff{obj.tmn.indP}(i,obj.tmn.indImage) == 0
                    obj.trackCircle{i}.Position = [obj.trackCenCol{obj.tmn.indP}(i,obj.tmn.indImage)-trackCircleHalfSize,...
                        obj.trackCenRow{obj.tmn.indP}(i,obj.tmn.indImage)-trackCircleHalfSize,...
                        obj.trackCircleSize,obj.trackCircleSize];
                elseif obj.trackCenLogicalDiff{obj.tmn.indP}(i,obj.tmn.indImage) == 1
                    obj.trackCircle{i}.Visible = 'off';
                else
                    obj.trackCircle{i}.Visible = 'on';
                    obj.trackCircle{i}.Position = [obj.trackCenCol{obj.tmn.indP}(i,obj.tmn.indImage)-trackCircleHalfSize,...
                        obj.trackCenRow{obj.tmn.indP}(i,obj.tmn.indImage)-trackCircleHalfSize,...
                        obj.trackCircleSize,obj.trackCircleSize];
                end
            end
        end
        %%
        %
        function obj = clickLoop(obj,myrec,~)
            obj.tmn.mcl.pointer_track = myrec.UserData;
            switch obj.tmn.makecell_mode
                case 'none'
                    fprintf('trackID %d\n',obj.tmn.mcl.pointer_track);
                case 'link'
                    obj.tmn.mcl.addTrack;
                    obj.tmn.gui_control.tabMakeCell_loop;
                case 'break'
                    obj.tmn.mcl.breakTrack;
                    obj.tmn.gui_control.tabMakeCell_loop;
                otherwise
                    fprintf('trackID %d\n',obj.tmn.mcl.pointer_track);
            end
        end
    end
end