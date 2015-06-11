%% cellularGPSPickTwo_object
% How does one go about identifying the same cell in two sets imaging data?
% The images may look distinctly different. They may contain the cells
% before and after immunofluorescence staining. They may be capture on
% different microscopes using different cameras, which may result in images
% of different sizes. Some cells may appear in one set, but not the other.
% It is tempting to automate this process relying on well established
% "matching filter" type methods. However, a manual approach is more
% expedient if the dataset is appropriately small. A manual approach does
% not require optimization of parameters or worrying about image quality
% issues that might present information the algorithm was not trained on.
% The _cellularGPSPickTwo_object_ is a tool to manually map one set of data
% into the other.

classdef cellularGPSPickTwo_object < handle
    properties
        %%% DATA
        %
        ityA % itinerary
        ityB % itinerary
        moviePathA
        moviePathB
        smda_databaseA
        smda_databaseLogicalA
        smda_databaseSubsetA
        smda_databaseB
        smda_databaseLogicalB
        smda_databaseSubsetB
        %%% GUIS
        %
        gui_imageViewerA
        gui_imageViewerB
        gui_control
        %%% INDICES AND POINTERS AND MODES
        % state information about the gui and the information being
        % displayed
        indAG = 1;
        indAP = 1;
        indAS = 1;
        indAT = 1;
        indAZ = 1;
        indBG = 1;
        indBP = 1;
        indBS = 1;
        indBT = 1;
        indBZ = 1;
        pointerGroupA = 1;
        pointerPositionA = 1;
        pointerSettingsA = 1;
        pointerGroupB = 1;
        pointerPositionB = 1;
        pointerSettingsB = 1;
        indImage = 1;
        stepSize = 1;
    end
%     properties (SetAccess = private)
%     end
%     events
%     end
    methods
        %%
        %
        function obj = cellularGPSPickTwo_object(moviePathA,moviePathB)
            obj.moviePathA = moviePathA;
            obj.moviePathB = moviePathB;   
            %% Load settings
            %
            obj.smda_databaseA = readtable(fullfile(moviePathA,'smda_database.txt'),'Delimiter','\t');
            obj.indAG = min(obj.smda_databaseA.group_number);
            obj.indAP = min(obj.smda_databaseA.position_number);
            obj.indAS = min(obj.smda_databaseA.settings_number);
            
            obj.ityA = cellularGPSTrackingManual_object_itinerary;
            obj.ityA.import(fullfile(moviePathA,'smdaITF.txt'));
            
            obj.smda_databaseB = readtable(fullfile(moviePathB,'smda_database.txt'),'Delimiter','\t');
            obj.indBG = min(obj.smda_databaseB.group_number);
            obj.indBP = min(obj.smda_databaseB.position_number);
            obj.indBS = min(obj.smda_databaseB.settings_number);
            
            obj.ityB = cellularGPSTrackingManual_object_itinerary;
            obj.ityB.import(fullfile(moviePathB,'smdaITF.txt'));

            obj.updateFilenameListImage;
            %% Launch gui
            %
            obj.gui_imageViewerA = cellularGPSPickTwo_object_imageViewer(obj);
            obj.gui_imageViewerA.imag3path = fullfile(obj.moviePathA,'RAW_DATA',obj.smda_databaseSubsetA.filename{obj.indImage});
            obj.gui_imageViewerA.kybrd_period = @obj.loop_stepRight;
            obj.gui_imageViewerA.initialize;
            obj.gui_imageViewerB = cellularGPSPickTwo_object_imageViewer(obj);
                        obj.gui_imageViewerB.imag3path = fullfile(obj.moviePathB,'RAW_DATA',obj.smda_databaseSubsetB.filename{obj.indImage});
            obj.gui_imageViewerB.initialize;
            obj.gui_control = cellularGPSPickTwo_object_control(obj);
            obj.gui_control.tabContrast_axesContrast_ButtonDownFcn;
            obj.gui_control.tabContrast_sliderMax_Callback
        end
        %%
        %
        function initializeImageViewer(obj)
            if(~isempty(obj.gui_imageViewerA))
                obj.gui_imageViewerA.delete;
            end
            obj.gui_imageViewerA = cellularGPSTrackingManual_gui_imageViewer(obj);
            obj.gui_imageViewerA.launchImageViewer;
            
            if(~isempty(obj.gui_imageViewerB))
                obj.gui_imageViewerB.delete;
            end
            obj.gui_imageViewerB = cellularGPSTrackingManual_gui_imageViewer(obj);
            obj.gui_imageViewerB.launchImageViewer;
        end
        %%
        %
        function delete(obj)
            delete(obj.gui_imageViewerA);
            delete(obj.gui_imageViewerB);
            delete(obj.gui_control);
        end
        %%
        %
        function obj = updateFilenameListImage(obj)
            obj.smda_databaseLogicalA = obj.smda_databaseA.group_number == obj.indAG &...
                obj.smda_databaseA.position_number == obj.indAP &...
                obj.smda_databaseA.settings_number == obj.indAS;
            mytable = obj.smda_databaseA(obj.smda_databaseLogicalA,:);
            obj.smda_databaseSubsetA = sortrows(mytable,{'timepoint'});
            
            obj.smda_databaseLogicalB = obj.smda_databaseB.group_number == obj.indBG &...
                obj.smda_databaseB.position_number == obj.indBP &...
                obj.smda_databaseB.settings_number == obj.indBS;
            mytable = obj.smda_databaseB(obj.smda_databaseLogicalB,:);
            obj.smda_databaseSubsetB = sortrows(mytable,{'timepoint'});
        end
        %%
        %
        function obj = loop_stepRight(obj)
                                obj.indImage = obj.indImage + obj.stepSize;
                    if obj.indImage > height(obj.smda_databaseSubsetA)
                        obj.indImage = height(obj.smda_databaseSubsetA);
                    end
                    handlesControl = guidata(obj.gui_control.gui_main);
                    handlesControl.infoBk_editTimepoint.String = num2str(obj.indImage);
                    guidata(obj.gui_control.gui_main,handlesControl);
                    obj.loop_stepX;
        end
        function obj = loop_stepX(obj)
            handles = guidata(obj.gui_main);
            obj.imag3 = imread(fullfile(obj.pkTwo.moviePath,'.thumb',obj.pkTwo.smda_databaseSubset.filename{obj.pkTwo.indImage}));
            handles.displayedImage.CData = obj.imag3;
            obj.updateLimits;
            guidata(obj.gui_main,handles);
            
            %%%
            %   _____            _    __   ___
            %  |_   _| _ __ _ __| |__ \ \ / (_)___
            %    | || '_/ _` / _| / /  \ V /| (_-<
            %    |_||_| \__,_\__|_\_\   \_/ |_/__/
            %
            if obj.pkTwo.gui_control.menu_viewTrackBool
                switch obj.pkTwo.gui_control.menu_viewTime
                    case 'all'
                        trackCircleHalfSize = (obj.trackCircleSize-1)/2;
                        for i = 1:length(obj.trackCircle)
                            if ~obj.pkTwo.mcl.track_logical(i)
                                continue
                            end
                            if obj.trackCenLogical(i,obj.pkTwo.indImage)
                                obj.trackText{i}.Visible = 'on';
                                obj.trackText{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)+trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)+trackCircleHalfSize];
                                obj.trackCircle{i}.Visible = 'on';
                                obj.trackCircle{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCircleSize,obj.trackCircleSize];
                            else
                                obj.trackText{i}.Visible = 'off';
                                obj.trackCircle{i}.Visible = 'off';
                            end
                        end
                    case 'now'
                        trackCircleHalfSize = (obj.trackCircleSize-1)/2;
                        for i = 1:length(obj.trackCircle)
                            if ~obj.pkTwo.mcl.track_logical(i)
                                continue
                            end
                            if obj.trackCenLogical(i,obj.pkTwo.indImage)
                                obj.trackText{i}.Visible = 'on';
                                obj.trackText{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)+trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)+trackCircleHalfSize];
                                obj.trackCircle{i}.Visible = 'on';
                                obj.trackCircle{i}.Position = [obj.trackCenCol(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCenRow(i,obj.pkTwo.indImage)-trackCircleHalfSize,...
                                    obj.trackCircleSize,obj.trackCircleSize];
                            else
                                obj.trackText{i}.Visible = 'off';
                                obj.trackCircle{i}.Visible = 'off';
                            end
                        end
                end
            end
        end
    end
end