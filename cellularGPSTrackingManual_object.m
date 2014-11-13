classdef cellularGPSTrackingManual_object < handle
    properties
        gui_imageViewer
        gui_smda
        smda_database
        centroid_measurements
        itinerary
    end
%     properties (SetAccess = private)
%     end
%     events
%     end
    methods
        function obj = cellularGPSTrackingManual_object(moviePath)
            %%
            % get pixels to character info
            myunits = get(0,'units');
            set(0,'units','pixels');
            Pix_SS = get(0,'screensize');
            set(0,'units','characters');
            Char_SS = get(0,'screensize');
            ppChar = Pix_SS./Char_SS;
            ppChar = ppChar([3,4]);
            set(0,'units',myunits);
            
            %% Load settings
            %
            obj.smda_database = readtable(fullfile(moviePath,'smda_database.txt'),'Delimiter','\t');
            obj.centroid_measurements = readtable(fullfile(moviePath,'centroid_measurements.txt'),'Delimiter','\t');
            obj.itinerary = SuperMDAItineraryTimeFixed_object;
            obj.itinerary.import(fullfile(moviePath,'
            %% Launch gui
            %
            obj.gui_smda = cellularGPSTrackingManual_gui_smda(obj);
        end
        function initializeImageViewer(obj)
            if(~isempty(obj.gui_imageViewer))
                obj.gui_imageViewer.delete;
            end
            obj.gui_imageViewer = cellularGPSTrackingManual_gui_imageViewer(obj);
            obj.gui_imageViewer.launchImageViewer;
        end
        function delete(obj)
            delete(obj.gui_imageViewer);
        end
    end
end