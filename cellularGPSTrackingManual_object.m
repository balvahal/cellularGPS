classdef cellularGPSTrackingManual_object < handle
    properties
        centroid_measurements
        gui_imageViewer
        gui_smda
        itinerary
        moviePath
        pointerGroup = 1;
        pointerPosition = 1;
        pointerSettings = 1;
        smda_database
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
            obj.refresh_gui_smda;
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
            delete(obj.gui_imageViewer);
        end
        %%
        %
        function obj = refresh_gui_smda(obj)
            cellularGPSTrackingManual_method_refresh_gui_smda(obj);
        end
    end
end