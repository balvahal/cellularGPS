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
        kybrd_flag = false; %to prevent repeat entry into the keyboard callbacks when a key is held down.
        
        indT = 1;
        indG = 1;
        indP = 1;
        indS = 1;
        
        T = 0;
        G = 0;
        P = 0;
        S = 0;
        
        tblRegister;
                
        smda_itinerary;
        smda_database;
        moviePath;
        
        gps;
        contrast;
        zoom;
        rgbBool = false;
        
        zoomArray = [1, 0.8, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1];
        zoomIndex = 1;
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
            f.BusyAction = 'cancel';
            axesImageViewer = axes('Parent',f,...
                'Units','characters',...
                'YDir','reverse',...
                'Visible','on'); %when displaying images the center of the pixels are located at the position on the axis. Therefore, the limits must account for the half pixel border.
            
            displayedImage = image;
            displayedImage.Parent = axesImageViewer;
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
            obj.gps = cellularGPSSimpleViewer_gps;
            obj.contrast = cellularGPSSimpleViewer_contrast;
            obj.zoom = cellularGPSSimpleViewer_zoom;
        end
        %% delete
        % for a clean delete make sure the objects that are stored as
        % properties are also deleted.
        function delete(obj,~,~)
            delete(obj.gui_main);
            delete(obj.gps.gui_main);
            delete(obj.zoom.gui_main);
            delete(obj.contrast.gui_main);
        end
        %%
        %
        function obj = fKeyPressFcn(obj,~,keyInfo)
            if obj.kybrd_flag
                return
            else
                obj.kybrd_flag = true;
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
                obj.kybrd_flag = false;
            end
        end
        %%
        %
        function obj = update_Image(obj)
            handles = guidata(obj.gui_main);
            obj.imag3path = fullfile(obj.imag3dir,obj.tblRegister.filename{obj.indT});
            obj.imag3 = imread(obj.imag3path);
            mydims = ndims(obj.imag3);
            if mydims == 3
                obj.rgbBool = true;
                handlesContrast = guidata(obj.contrast.gui_main);
                mymin = handlesContrast.sliderMin.Value;
                mymax = handlesContrast.sliderMax.Value;
                if mymin ~= 0 || mymax ~= 1
                    obj.imag3 = imadjust(obj.imag3,[mymin mymin mymin; mymax mymax mymax],[]);
                end
            else
                obj.rgbBool = false;
            end
            handles.displayedImage.CData = obj.imag3;
            guidata(obj.gui_main,handles);
                                               
            handlesZoom = guidata(obj.zoom.gui_main);
            handlesZoom.displayedImage.CData = obj.imag3;
            guidata(obj.zoom.gui_main,handlesZoom);
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
            obj.consistencyCheckGPS;
            obj.update_Image;
            %%%
            %
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
            
            handles = guidata(obj.gui_main);
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
            %% update other windows
            % # The GPS
            % # The zoom
            % # The contrast
            obj.gps.viewer = obj;
            obj.gps.initialize;
            obj.gps.refresh;
            
            obj.zoom.viewer = obj;
            obj.zoom.initialize;
            obj.zoom.refresh;
            
            obj.contrast.viewer = obj;
            obj.contrast.initialize;
            obj.contrast.refresh;
        end
        %%
        %
        function obj = refresh(obj)
            obj.consistencyCheckGPS;
            obj.update_Image;
            obj.gps.refresh;
            obj.zoom.refresh;
            %obj.contrast.refresh; %This is super slow...
        end
        %%
        %
        function consistencyCheckGPS(obj)
            %%%
            % enforces consistency between the indices of the GPS and the
            % values they reference. It operates under the assumption that
            % the indices reflect the true state. However, if the *true
            % state* is not valid, then correct the true state to the
            % nearest valid GPS. The hope is this method will make changing
            % the GPS easy from other functions or methods.
            %
            % Save the GPS already set
            oldG = obj.G;
            oldP = obj.P;
            oldS = obj.S;
            %%%
            % Is the group index in range of the itinerary group list?
            if obj.indG > obj.smda_itinerary.number_group
                obj.indG = obj.smda_itinerary.number_group;
            elseif obj.indG < 1
                obj.indG = 1;
            end
            obj.G = obj.smda_itinerary.order_group(obj.indG);
            %%%
            % Is the position index in range of the itinerary position list?           
            if obj.indP > obj.smda_itinerary.number_position(obj.G)
                obj.indP = obj.smda_itinerary.number_position(obj.G);
            elseif obj.indP < 1
                obj.indP = 1;
            end
            obj.P = obj.smda_itinerary.order_position{obj.G}(obj.indP);
            %%%
            % Is the settings index in range of the itinerary settings list?
            if obj.indS > obj.smda_itinerary.number_settings(obj.P)
                obj.indS = obj.smda_itinerary.number_settings(obj.P);
            elseif obj.indS < 1
                obj.indS = 1;
            end
            obj.S = obj.smda_itinerary.order_settings{obj.P}(obj.indS);
            %%%
            % check to see if the table register needs to be updated. This
            % is time consuming, so only update the table if the group,
            % position, or settings has changed.
            if (oldG ~= obj.G) || (oldP ~= obj.P) || (oldS ~= obj.S)
                smda_databaseLogical = obj.smda_database.group_number == obj.G...
                    & obj.smda_database.position_number == obj.P...
                    & obj.smda_database.settings_number == obj.S;
                mytable = obj.smda_database(smda_databaseLogical,:);
                obj.tblRegister = sortrows(mytable,{'timepoint'});
            end
            %%%
            % Make sure the time index reflects an actual timepoint.
            if obj.indT > height(obj.tblRegister)
                obj.indT = height(obj.tblRegister);
            elseif obj.indT < 1
                obj.indT = 1;
            end
            obj.T = obj.tblRegister.timepoint(obj.indT);
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
        function obj = clickLoop(obj,~,~)

        end
        %%
        %
        function obj = zoomIn(obj)
            if obj.zoomIndex < length(obj.zoomArray)
                obj.zoomIndex = obj.zoomIndex + 1;
            else
                return
            end
            %%
            % get the patch position
            newHalfWidth = obj.image_width*obj.zoomArray(obj.zoomIndex)/2;
            newHalfHeight = obj.image_height*obj.zoomArray(obj.zoomIndex)/2;
            handles = guidata(obj.zoom.gui_main);
            handles.zoomMapRect.Visible = 'off';
            myVertices = handles.zoomMapRect.Vertices;
            myCenter = (myVertices(3,:) - myVertices(1,:))/2 + myVertices(1,:);
            myVertices(1,:) = round(myCenter + [-newHalfWidth,-newHalfHeight]);
            myVertices(2,:) = round(myCenter + [newHalfWidth,-newHalfHeight]);
            myVertices(3,:) = round(myCenter + [newHalfWidth,newHalfHeight]);
            myVertices(4,:) = round(myCenter + [-newHalfWidth,newHalfHeight]);
            handles.zoomMapRect.Vertices = myVertices;
            handles.zoomMapRect.Visible = 'on';
            guidata(obj.zoom.gui_main,handles);
            obj.zoomPan;
        end
        %%
        %
        function obj = zoomOut(obj)
            if obj.zoomIndex > 2
                obj.zoomIndex = obj.zoomIndex - 1;
            elseif obj.zoomIndex == 2
                obj.zoomTop;
                return
            else
                return
            end
            %%
            % get the patch position
            newHalfWidth = obj.image_width*obj.zoomArray(obj.zoomIndex)/2;
            newHalfHeight = obj.image_height*obj.zoomArray(obj.zoomIndex)/2;
            handles = guidata(obj.zoom.gui_main);
            handles.zoomMapRect.Visible = 'off';
            myVertices = handles.zoomMapRect.Vertices;
            myCenter = (myVertices(3,:)-myVertices(1,:))/2+myVertices(1,:);
            %%
            % make sure the center does not move the rectangle |off screen|
            if myCenter(1) - newHalfWidth < 1
                myCenter(1) = newHalfWidth + 1;
            elseif myCenter(1) + newHalfWidth > obj.image_width
                myCenter(1) = obj.image_width - newHalfWidth;
            end
            
            if myCenter(2) - newHalfHeight < 1
                myCenter(2) = newHalfHeight + 1;
            elseif myCenter(2) + newHalfHeight > obj.image_height
                myCenter(2) = obj.image_height - newHalfHeight;
            end
            
            myVertices(1,:) = round(myCenter + [-newHalfWidth,-newHalfHeight]);
            myVertices(2,:) = round(myCenter + [newHalfWidth,-newHalfHeight]);
            myVertices(3,:) = round(myCenter + [newHalfWidth,newHalfHeight]);
            myVertices(4,:) = round(myCenter + [-newHalfWidth,newHalfHeight]);
            handles.zoomMapRect.Vertices = myVertices;
            handles.zoomMapRect.Visible = 'on';
            guidata(obj.zoom.gui_main,handles);
            obj.zoomPan;
        end
        %%
        %
        function obj = zoomTop(obj)
            obj.zoomIndex = 1;
            handles = guidata(obj.zoom.gui_main);
            handles.zoomMapRect.Visible = 'off';
            handles.zoomMapRect.Vertices = [1, 1;obj.image_width, 1;obj.image_width, obj.image_height;1, obj.image_height];
            guidata(obj.zoom.gui_main,handles);
            obj.zoomPan;
        end
        %%
        %
        function obj = zoomPan(obj)
            % Adjust the imageViewer limits to reflect the zoomMapRect
            % position
            handlesZoom = guidata(obj.zoom.gui_main);
            myVertices = handlesZoom.zoomMapRect.Vertices;
            handles = guidata(obj.gui_main);
            handles.axesImageViewer.XLim = [myVertices(1,1)-0.5,myVertices(3,1)+0.5];
            handles.axesImageViewer.YLim = [myVertices(1,2)-0.5,myVertices(3,2)+0.5];
            guidata(obj.zoom.gui_main,handlesZoom);
            guidata(obj.gui_main,handles);
        end
    end
end