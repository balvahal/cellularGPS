classdef cellularGPSTrackingManual_object < handle
    properties
        %%% DATA
        %
        centroid_measurements
        itinerary
        moviePath
        smda_database
        filenameListImage
        %%% GUIS
        %
        gui_imageViewer
        gui_smda
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
            obj.smda_database = readtable(fullfile(moviePath,'smda_database.txt'),'Delimiter','\t');
            obj.centroid_measurements = readtable(fullfile(moviePath,'centroid_measurements.txt'),'Delimiter','\t');
            obj.itinerary = cellularGPSTrackingManual_object_itinerary;
            obj.itinerary.import(fullfile(moviePath,'smdaITF.txt'));
            %% Launch gui
            %
            obj.gui_smda = cellularGPSTrackingManual_gui_smda(obj);
            obj.gui_smda_refresh;
            obj.gui_imageViewer = cellularGPSTrackingManual_gui_imageViewer(obj);
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
        end
        %%
        %
        function obj = gui_smda_refresh(obj)
            cellularGPSTrackingManual_method_gui_smda_refresh(obj);
        end
        %%
        %
        function obj = updateFilenameListImage(obj)
            cellularGPSTrackingManual_method_updateFilenameListImage(obj);
        end
    end
end