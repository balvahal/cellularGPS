%% cellularGPSSimpleViewer_zoom
%
classdef cellularGPSSimpleViewer_zoom < handle
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
        windowMotionBool = false;
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
        function obj = cellularGPSSimpleViewer_zoom()
            myunits = get(0,'units');
            set(0,'units','pixels');
            Pix_SS = get(0,'screensize');
            set(0,'units','characters');
            Char_SS = get(0,'screensize');
            ppChar = Pix_SS./Char_SS; %#ok<NASGU>
            set(0,'units',myunits);
            
            f = figure;
            f.Visible = 'off';
            f.Units = 'characters';
            f.MenuBar = 'none';
            f.Name = 'Zoom';
            f.Renderer = 'OpenGL';
            f.Resize = 'off';
            f.CloseRequestFcn = {@obj.fCloseRequestFcn};
            f.KeyPressFcn = {@obj.fKeyPressFcn};
            f.WindowButtonDownFcn = {@obj.fWindowButtonDownFcn};
            f.WindowButtonMotionFcn = {@obj.fWindowButtonMotionFcn};
            f.WindowButtonUpFcn = {@obj.fWindowButtonUpFcn};
            %% Create the axes that will show the contrast histogram
            % and the plot that will show the histogram
            axesZoomMap = axes;
            axesZoomMap.Parent = f;
            axesZoomMap.Units = 'characters';
            axesZoomMap.YDir = 'reverse';
            
            displayedImage = image;
            displayedImage.Parent = axesZoomMap;
            %% Add the rectangle that will be used to control the zoom and pan
            %
            zoomMapRect = patch;
            zoomMapRect.Parent = axesZoomMap;
            zoomMapRect.Visible = 'off';
            
            
            %%
            % make the gui visible
            obj.gui_main = f;
            handles.axesZoomMap = axesZoomMap;
            handles.displayedImage = displayedImage;
            handles.zoomMapRect = zoomMapRect;
            guidata(obj.gui_main,handles);
        end
        %%
        % set the viewer object for this to work
        function obj = initialize(obj)
            myunits = get(0,'units');
            set(0,'units','pixels');
            Pix_SS = get(0,'screensize');
            set(0,'units','characters');
            Char_SS = get(0,'screensize');
            ppChar = Pix_SS./Char_SS;
            ppChar = ppChar([3,4]);
            set(0,'units',myunits);
            
            %% Create the axes that will show the contrast histogram
            %
            windowMeasure = 35*ppChar(2); %35 height characters, just like the contrast window
            if obj.viewer.image_width/obj.viewer.image_height > 1
                % then maximize the width
                widthaxes = windowMeasure/ppChar(1);
                heightaxes = windowMeasure*obj.viewer.image_height/obj.viewer.image_width/ppChar(2);
            else
                % then maximize the height
                heightaxes  = windowMeasure/ppChar(2);
                widthaxes  = windowMeasure*obj.viewer.image_width/obj.viewer.image_height/ppChar(1);
            end
            fx = Char_SS(3) - (Char_SS(3)*.1 + widthaxes);
            fy = Char_SS(4) - (Char_SS(4)*.1 + heightaxes);
            
            handles = guidata(obj.gui_main);
            
            obj.gui_main.Position = [fx fy widthaxes heightaxes];
            obj.gui_main.Visible = 'on';
            obj.gui_main.Colormap = colormap(gray(1024));
            
            
            handles.axesZoomMap.Position = [0 0 widthaxes heightaxes];
            handles.axesZoomMap.XLim = [0.5,obj.viewer.image_width+0.5];
            handles.axesZoomMap.YLim = [0.5,obj.viewer.image_height+0.5];
            
            handles.displayedImage.CData = obj.viewer.imag3;
            handles.displayedImage.CDataMapping = 'scaled';
            
            handles.zoomMapRect.Vertices = [1, 1;obj.viewer.image_width, 1;obj.viewer.image_width, obj.viewer.image_height;1, obj.viewer.image_height];
            handles.zoomMapRect.Faces = [1,2,3,4];
            handles.zoomMapRect.LineStyle = 'none';
            handles.zoomMapRect.FaceColor = [255 215 0]/255;
            handles.zoomMapRect.FaceAlpha = 0.2;
            
            guidata(obj.gui_main,handles);
        end
        %%
        %
        function obj = refresh(obj)

        end
        %%
        %
        function fCloseRequestFcn(obj,~,~)
            %do nothing. This means only the master object can close this
            %window.
        end
        %%
        %
        function fKeyPressFcn(obj,~,keyInfo)
            if obj.kybrd_flag
                return
            else
                
                switch keyInfo.Key
                    case 'equal' %or |plus|
                        %%
                        % Zoom in
                        obj.viewer.zoomIn;
                    case 'hyphen' % or |minus|
                        %%
                        % Zoom out
                        obj.viewer.zoomOut;
                    case '0'
                        %%
                        % Return to top level zoom
                        obj.viewer.zoomTop;
                end
                obj.kybrd_flag = false;
            end
        end
        %%
        %
        function fWindowButtonDownFcn(obj,~,~)
            handles = guidata(obj.gui_main);
            if obj.viewer.zoomIndex == 1
                return
            end
            
            obj.panningActiveBool = true;
            handles.zoomMapRect.Visible = 'off';
            myCurrentPoint = obj.gui_main.CurrentPoint;
            figureSize = obj.gui_main.Position;
            
            myVertices = obj.evaluateNewCenter(myCurrentPoint, figureSize);
            
            handles.zoomMapRect.Vertices = myVertices;
            obj.viewer.zoomPan;
            handles.zoomMapRect.Visible = 'on';
            guidata(obj.gui_main,handles)
        end
        
        function fWindowButtonMotionFcn(obj,~,~)
            if obj.windowMotionBool
                return
            end
            obj.windowMotionBool = true;
            handles = guidata(obj.gui_main);
            if obj.viewer.zoomIndex == 1 || ~obj.panningActiveBool
                obj.windowMotionBool = false;
                return
            end
            handles.zoomMapRect.Visible = 'off';
            myCurrentPoint = obj.gui_main.CurrentPoint;
            figureSize = obj.gui_main.Position;
            
            myVertices = obj.evaluateNewCenter(myCurrentPoint, figureSize);
            
            handles.zoomMapRect.Vertices = myVertices;
            obj.viewer.zoomPan;
            handles.zoomMapRect.Visible = 'on';
            guidata(obj.gui_main,handles)
            obj.windowMotionBool = false;
        end
        
        function fWindowButtonUpFcn(obj,~,~)
            obj.panningActiveBool = false;
        end
        
        function myVertices = evaluateNewCenter(obj,myCurrentPoint, figureSize)
            myCurrentPoint = [myCurrentPoint(1),figureSize(4)-myCurrentPoint(2)];
            myCurrentPoint(1) = myCurrentPoint(1)/figureSize(3)*obj.viewer.image_width;
            myCurrentPoint(2) = myCurrentPoint(2)/figureSize(4)*obj.viewer.image_height;
            newHalfWidth = obj.viewer.image_width*obj.viewer.zoomArray(obj.viewer.zoomIndex)/2;
            newHalfHeight = obj.viewer.image_height*obj.viewer.zoomArray(obj.viewer.zoomIndex)/2;
            %%
            % make sure the center does not move the rectangle |off screen|
            if myCurrentPoint(1) - newHalfWidth < 1
                myCurrentPoint(1) = newHalfWidth + 1;
            elseif myCurrentPoint(1) + newHalfWidth > obj.viewer.image_width
                myCurrentPoint(1) = obj.viewer.image_width - newHalfWidth;
            end
            
            if myCurrentPoint(2) - newHalfHeight < 1
                myCurrentPoint(2) = newHalfHeight + 1;
            elseif myCurrentPoint(2) + newHalfHeight > obj.viewer.image_height
                myCurrentPoint(2) = obj.viewer.image_height - newHalfHeight;
            end
            
            myVertices(1,:) = round(myCurrentPoint + [-newHalfWidth,-newHalfHeight]);
            myVertices(2,:) = round(myCurrentPoint + [newHalfWidth,-newHalfHeight]);
            myVertices(3,:) = round(myCurrentPoint + [newHalfWidth,newHalfHeight]);
            myVertices(4,:) = round(myCurrentPoint + [-newHalfWidth,newHalfHeight]);
        end
    end
end