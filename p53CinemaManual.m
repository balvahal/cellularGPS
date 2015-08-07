classdef p53CinemaManual < cellularGPSSimpleViewer_object
    properties
        listenImag3RowCol;
        listenMakecellBool;
        scrollTimerArray = [0.05 0.1 0.2 0.4 0.8 1.6 Inf 1.6 0.8 0.4 0.2 0.1 0.05];
        scrollTimerIndex = 7;
        scrollTimer;
        
        makecell;
        makecell_viewer;
        
        patchMakecell;
    end
    properties (SetObservable = true)
        makecellBool = false;
    end
    events
        
    end
    methods
        function obj = p53CinemaManual()
            obj@cellularGPSSimpleViewer_object;
            
            handles = guidata(obj.gui_main);
            obj.patchMakecell = patch;
            obj.patchMakecell.Parent = handles.axesImageViewer;
            obj.patchMakecell.MarkerFaceColor = 'flat';
            obj.patchMakecell.Marker = 'o';
            obj.patchMakecell.EdgeColor = 'none';
            obj.patchMakecell.FaceColor = 'none';
            guidata(obj.gui_main,handles);
            
            obj.kybrd_cmd.o = @p53CinemaManual_kybrd_o;
            obj.kybrd_cmd.p = @p53CinemaManual_kybrd_p;
            obj.kybrd_cmd.e = @p53CinemaManual_kybrd_e;
            obj.kybrd_cmd.q = @p53CinemaManual_kybrd_q;
            obj.kybrd_cmd.w = @p53CinemaManual_kybrd_w;
            obj.kybrd_cmd.a = @p53CinemaManual_kybrd_a;
            obj.kybrd_cmd.s = @p53CinemaManual_kybrd_s;
            obj.kybrd_cmd.zero = @p53CinemaManual_kybrd_zero;
            obj.kybrd_cmd.backslash = @p53CinemaManual_kybrd_backslash;
            obj.kybrd_cmd.comma = @p53CinemaManual_kybrd_comma;
            obj.kybrd_cmd.period = @p53CinemaManual_kybrd_period;

      
            obj.scrollTimer = timer;
            obj.scrollTimer.ExecutionMode = 'fixedRate';
            obj.scrollTimer.BusyMode = 'drop';
            obj.scrollTimer.TimerFcn = @(~,~) obj.timer_scrollTimerFcn;
            obj.scrollTimer.Period = 1;
            
            obj.makecell = p53CinemaManual_makecell;
            obj.makecell.viewer = obj;
                        
            obj.makecell_viewer = p53CinemaManual_makecell_viewer;
            obj.makecell_viewer.viewer = obj;
            obj.makecell_viewer.makecell = obj.makecell;
                       
            obj.listenImag3RowCol = addlistener(obj,'imag3RowCol','PostSet',@obj.listenerImag3RowCol);
            obj.listenMakecellBool = addlistener(obj,'makecellBool','PostSet',@obj.listenerMakecellBool);
        end
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
            obj.smda_database = readtable(fullfile(obj.moviePath,'smda_database.txt'),'Delimiter','\t');
            if exist(fullfile(obj.moviePath,'thumb'),'dir')
                obj.imag3dir = fullfile(obj.moviePath,'thumb');
                obj.smda_database = readtable(fullfile(obj.moviePath,'thumb_database.txt'),'Delimiter','\t');
            elseif exist(fullfile(obj.moviePath,'PROCESSED_DATA'),'dir')
                obj.imag3dir = fullfile(obj.moviePath,'PROCESSED_DATA');
            elseif exist(fullfile(obj.moviePath,'RAW_DATA'),'dir')
                obj.imag3dir = fullfile(obj.moviePath,'RAW_DATA');
            else
                error('imView:badimgdir','Could not find a vaild directory for the image data. ''thumb'', ''PROCESSED_DATA'', ''RAW_DATA''');
            end
            %%%
            %
            
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
            
            obj.makecell.initialize;
            obj.makecell_viewer.initialize;
            %%
            %
            handles = guidata(obj.gui_main);
            obj.patchMakecell.MarkerSize = round(obj.image_width*0.03);
            guidata(obj.gui_main,handles);
        end
        function obj = timer_scrollTimerFcn(obj,~,~)
            %% identify location of the mouse and save to cell
            %
            if obj.makecellBool
                obj.getImag3RowCol;
                obj.makecell.makecell_ind{obj.makecell.pointer_makecell}(obj.indT) = sub2ind([obj.smda_itinerary.imageHeightNoBin/obj.smda_itinerary.settings_binning(obj.S),obj.smda_itinerary.imageWidthNoBin/obj.smda_itinerary.settings_binning(obj.S)],obj.imag3RowCol(1),obj.imag3RowCol(2));
            end
            %% update the image and move it forward or backward
            %
            if obj.scrollTimerIndex > 7
                obj.indT = obj.indT + 1;
                if obj.indT == obj.smda_itinerary.number_of_timepoints+1
                    obj.kybrd_cmd.zero(obj);
                end
            elseif obj.scrollTimerIndex < 7
                obj.indT = obj.indT - 1;
                if obj.indT == 0
                    obj.kybrd_cmd.zero(obj);
                end
            end
                
            obj.refresh;
        end
        %%
        %
        function obj = refresh(obj)
            obj.consistencyCheckGPS;
            obj.update_Image;
            obj.gps.refresh;
            obj.zoom.refresh;
            obj.refreshPatch;
            %obj.contrast.refresh; %This is super slow...
        end
        %% delete
        % for a clean delete make sure the objects that are stored as
        % properties are also deleted.
        function delete(obj,~,~)
            stop(obj.scrollTimer);
            delete(obj.scrollTimer);
            delete(obj.gui_main);
            delete(obj.gps.gui_main);
            delete(obj.zoom.gui_main);
            delete(obj.contrast.gui_main);
            delete(obj.makecell_viewer.gui_main);
        end
        %%
        %
        function obj = refreshPatch(obj)
            if ~any(obj.makecell.makecell_logical)
                obj.patchMakecell.Visible = 'off';
            else
                makecellColors = [106, 90, 205;255, 215, 0]/255;
                obj.patchMakecell.Visible = 'off';
                makecellValidArray = 1:length(obj.makecell.makecell_logical);
                makecellValidArray = makecellValidArray(obj.makecell.makecell_logical);
                makecellMatrix = vertcat(obj.makecell.makecell_ind{:});
                makecellLocationArray = makecellMatrix(makecellValidArray,obj.indT);
                siz = [obj.smda_itinerary.imageHeightNoBin/obj.smda_itinerary.settings_binning(obj.S),obj.smda_itinerary.imageWidthNoBin/obj.smda_itinerary.settings_binning(obj.S)];
                [myY,myX] = ind2sub(siz,makecellLocationArray);
                scalefactor = obj.smda_itinerary.imageWidthNoBin/obj.image_width/obj.smda_itinerary.settings_binning(obj.S); %this should be the same for both X and Y direction, so using the width is arbitrary.
                obj.patchMakecell.XData = myX/scalefactor;
                obj.patchMakecell.YData = myY/scalefactor;
                makecellColorArray = ones(size(makecellValidArray));
                makecellColorArray(makecellValidArray == obj.makecell.pointer_makecell) = 2;
                obj.patchMakecell.FaceVertexCData = makecellColors(makecellColorArray,:);
                obj.patchMakecell.Visible = 'on';
            end
        end
    end
    methods (Static)
        function listenerImag3RowCol(~,evt)
            str = sprintf('row = %d, col = %d, intensity = %d',evt.AffectedObject.imag3RowCol,evt.AffectedObject.imag3RowColIntensity);
            disp(str);
        end
        function listenerMakecellBool(~,evt)
            handles = guidata(evt.AffectedObject.makecell_viewer.gui_main);
            if evt.AffectedObject.makecellBool
                disp('Tracking ON');
                handles.togglebuttonMake.BackgroundColor = [0.3 1 0];
                handles.togglebuttonMake.String = 'ON';
            else
                disp('Tracking OFF');
                handles.togglebuttonMake.BackgroundColor = [1 0.3 0];
                handles.togglebuttonMake.String = 'OFF';
            end
            guidata(evt.AffectedObject.makecell_viewer.gui_main,handles);
        end
    end
end