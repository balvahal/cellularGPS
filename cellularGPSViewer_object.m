classdef cellularGPSViewer_object < handle
    properties
        %%% DATA
        %
        centroid_measurements
        ity % itinerary
        mcl % makecell
        moviePath
        smda_database
        smda_databaseLogical
        smda_databaseSubset
        track_database
        %%% GUIS
        %
        gui_imageViewer
        gui_control
        %%% INDICES AND POINTERS AND MODES
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
        stepSize = 1;
        makecell_mode = 'none';
    end
%     properties (SetAccess = private)
%     end
%     events
%     end
    methods
        %%
        %
        function obj = cellularGPSViewer_object(moviePath)
            obj.moviePath = moviePath;           
            %% Load settings
            %
            obj.smda_database = readtable(fullfile(moviePath,'thumb_database.txt'),'Delimiter','\t');
            obj.indG = min(obj.smda_database.group_number);
            obj.indP = min(obj.smda_database.position_number);
            obj.indS = min(obj.smda_database.settings_number);
            
            obj.ity = cellularGPSTrackingManual_object_itinerary;
            obj.ity.import(fullfile(moviePath,'smdaITF.txt'));
            obj.mcl = cellularGPSTrackingManual_object_makecell(moviePath);
            obj.updateFilenameListImage;
            %% Launch gui
            %
            obj.gui_imageViewer = cellularGPSViewer_object_imageViewer(obj);
            obj.gui_control = cellularGPSViewer_object_control(obj);
            obj.gui_control.tabContrast_axesContrast_ButtonDownFcn;
            obj.gui_control.tabContrast_sliderMax_Callback
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
            delete(obj.gui_control);
        end
        %%
        %
        function obj = updateFilenameListImage(obj)
            obj.smda_databaseLogical = obj.smda_database.group_number == obj.indG &...
                obj.smda_database.position_number == obj.indP &...
                obj.smda_database.settings_number == obj.indS;
            mytable = obj.smda_database(obj.smda_databaseLogical,:);
            obj.smda_databaseSubset = sortrows(mytable,{'timepoint'});
        end
    end
end