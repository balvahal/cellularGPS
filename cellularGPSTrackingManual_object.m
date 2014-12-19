classdef cellularGPSTrackingManual_object < handle
    properties
        %%% DATA
        %
        centroid_measurements
        itinerary
        moviePath
        smda_database
        smda_databaseLogical
        smda_databaseSubset
        track_database
        %%% GUIS
        %
        gui_imageViewer
        gui_smda
        gui_control
        %%% INDICES AND POINTERS
        % state information about the gui and the information being
        % displayed
        indG = 1;
        indP = 1;
        indS = 1;
        indT = 1;
        indZ = 1;
        pointerGroup = 1;
        pointerPosition = 1;
        pointerSettings = 1;
        indImage = 1;
    end
%     properties (SetAccess = private)
%     end
%     events
%     end
    methods
        %%
        %
        function obj = cellularGPSTrackingManual_object(moviePath)
            obj.moviePath = moviePath;           
            %% Load settings
            %
            obj.smda_database = readtable(fullfile(moviePath,'thumb_database.txt'),'Delimiter','\t');
            obj.centroid_measurements = readtable(fullfile(moviePath,'centroid_measurements.txt'),'Delimiter','\t');
            obj.itinerary = cellularGPSTrackingManual_object_itinerary;
            obj.itinerary.import(fullfile(moviePath,'smdaITF.txt'));
            obj.loadTrackData;
            %% Launch gui
            %
            obj.gui_smda = cellularGPSTrackingManual_gui_smda(obj);
            obj.gui_imageViewer = cellularGPSTrackingManual_gui_imageViewer(obj);
            obj.gui_control = cellularGPSTrackingManual_gui_control(obj);
        end
        %%
        %
        function initializeImageViewer(obj)
            if(~isempty(obj.gui_imageViewer))
                obj.gui_imageViewer.delete;
            end
            obj.gui_imageViewer = cellularGPSTrackingManual_gui_imageViewer(obj);
            obj.gui_imageViewer.launchImageViewer;
        end
        %%
        %
        function delete(obj)
            delete(obj.gui_smda);
            delete(obj.gui_imageViewer);
            delete(obj.gui_control);
        end

        %%
        %
        function obj = updateFilenameListImage(obj)
            cellularGPSTrackingManual_method_updateFilenameListImage(obj);
        end
        %%
        %
        function obj = loadTrackData(obj)
            numOfPosition = sum(obj.itinerary.number_position);
            obj.track_database = cell(numOfPosition,1);
            positionInd = horzcat(obj.itinerary.ind_position{:});
            for i = positionInd
                obj.track_database{i} = readtable(fullfile(obj.moviePath,'TRACKING_DATA',...
                    sprintf('trackingPosition_%d.txt',i)),...
                    'Delimiter','\t');
            end
        end
        %% GUI_IMAGEVIEWER
        % Methods specific to the *GUI_SMDA*
        %%
        %
        function obj = gui_imageViewer_nextImage(obj)
            obj.indImage = obj.indImage + 1;
            if obj.indImage > height(obj.smda_databaseSubset)
                obj.indImage = height(obj.smda_databaseSubset);
            end
            obj.gui_imageViewer_refresh;
        end
        %%
        %
        function obj = gui_imageViewer_previousImage(obj)
            obj.indImage = obj.indImage - 1;
            if obj.indImage < 1
                obj.indImage = 1;
            end
            obj.gui_imageViewer_refresh;
        end
        %%
        %
        function obj = gui_imageViewer_refresh(obj)
            cellularGPSTrackingManual_method_gui_imageViewer_refresh(obj);
        end
        %% GUI_SMDA
        % Methods specific to the *GUI_SMDA*
        %%
        %
        function obj = gui_smda_refresh(obj)
            cellularGPSTrackingManual_method_gui_smda_refresh(obj);
        end
    end
end