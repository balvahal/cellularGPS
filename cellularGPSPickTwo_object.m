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
        connect_database = {};
        connect_database_template_struct
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
        pointerConnectDatabase = 1;
        pointerConnectDatabase1 = 1;
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
            obj.gui_imageViewerA.kybrd_comma = @obj.loop_stepLeft;
            obj.gui_imageViewerA.initialize;
            obj.gui_imageViewerB = cellularGPSPickTwo_object_imageViewer(obj);
            obj.gui_imageViewerB.imag3path = fullfile(obj.moviePathB,'RAW_DATA',obj.smda_databaseSubsetB.filename{obj.indImage});
            obj.gui_imageViewerB.kybrd_period = @obj.loop_stepRight;
            obj.gui_imageViewerB.kybrd_comma = @obj.loop_stepLeft;
            obj.gui_imageViewerB.initialize;
            %obj.gui_control = cellularGPSPickTwo_object_control(obj);
            %obj.gui_control.tabContrast_axesContrast_ButtonDownFcn;
            %obj.gui_control.tabContrast_sliderMax_Callback
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
            obj.smda_databaseLogicalA = obj.smda_databaseA.timepoint == obj.indAT;
            mytable = obj.smda_databaseA(obj.smda_databaseLogicalA,:);
            obj.smda_databaseSubsetA = sortrows(mytable,{'timepoint'});
            
            obj.smda_databaseLogicalB = obj.smda_databaseB.group_number == obj.indBT;
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
            %handlesControl = guidata(obj.gui_control.gui_main);
            %handlesControl.infoBk_editTimepoint.String = num2str(obj.indImage);
            %guidata(obj.gui_control.gui_main,handlesControl);
            obj.loop_stepX;
        end
        %%
        %
        function obj = loop_stepLeft(obj)
            obj.indImage = obj.indImage - obj.stepSize;
            if obj.indImage < 1
                obj.indImage = 1;
            end
            %                     handlesControl = guidata(obj.pkTwo.gui_control.gui_main);
            %                     handlesControl.infoBk_editTimepoint.String = num2str(obj.pkTwo.indImage);
            %                     guidata(obj.pkTwo.gui_control.gui_main,handlesControl);
            obj.loop_stepX;
        end
        %%
        %
        function obj = loop_stepX(obj)
            handlesA = guidata(obj.gui_imageViewerA.gui_main);
            obj.gui_imageViewerA.imag3path = fullfile(obj.moviePathA,'RAW_DATA',obj.smda_databaseSubsetA.filename{obj.indImage});
            obj.gui_imageViewerA.imag3 = imread(obj.gui_imageViewerA.imag3path);
            handlesA.displayedImage.CData = obj.gui_imageViewerA.imag3;
            obj.gui_imageViewerA.updateLimits;
            guidata(obj.gui_imageViewerA.gui_main,handlesA);
            
            handlesB = guidata(obj.gui_imageViewerB.gui_main);
            obj.gui_imageViewerB.imag3path = fullfile(obj.moviePathB,'RAW_DATA',obj.smda_databaseSubsetB.filename{obj.indImage});
            obj.gui_imageViewerB.imag3 = imread(obj.gui_imageViewerB.imag3path);
            handlesB.displayedImage.CData = obj.gui_imageViewerB.imag3;
            obj.gui_imageViewerB.updateLimits;
            guidata(obj.gui_imageViewerB.gui_main,handlesB);
        end
        %%
        %
        function obj = connectCheck(obj)
            if obj.gui_imageViewerA.connectBool && obj.gui_imageViewerB.connectBool
                str = sprintf('conncetion success %d',obj.pointerConnectDatabase);
                disp(str);
                
                obj.connect_database_template_struct(obj.pointerConnectDatabase).rowB = obj.gui_imageViewerB.rowcol(1);
                obj.connect_database_template_struct(obj.pointerConnectDatabase).colB = obj.gui_imageViewerB.rowcol(2);
                obj.connect_database_template_struct(obj.pointerConnectDatabase).rowA = obj.gui_imageViewerA.rowcol(1);
                obj.connect_database_template_struct(obj.pointerConnectDatabase).colA = obj.gui_imageViewerA.rowcol(2);
                
                obj.gui_imageViewerB.connectBool = false;
                obj.gui_imageViewerA.connectBool = false;

                
                myrec = obj.gui_imageViewerB.trackCircle{obj.pointerConnectDatabase};
                myrec.FaceColor = obj.gui_imageViewerB.circleColor2;
                myrec = obj.gui_imageViewerA.trackCircle{obj.pointerConnectDatabase};
                myrec.FaceColor = obj.gui_imageViewerA.circleColor2;
                
                obj.pointerConnectDatabase = length(obj.connect_database_template_struct) + 1;
            else
                
            end
        end
        %%
        %
        function obj = clickme_rec(obj,src,evt)
            if evt.Button == 1
                if xor(src.UserData > length(obj.gui_imageViewerB.trackCircle),src.UserData > length(obj.gui_imageViewerA.trackCircle)) || xor(isempty(obj.gui_imageViewerB.trackCircle{src.UserData}),isempty(obj.gui_imageViewerA.trackCircle{src.UserData}))
                    %do nothing
                    disp('do nothing');
                elseif xor(obj.pointerConnectDatabase > length(obj.gui_imageViewerB.trackCircle),obj.pointerConnectDatabase > length(obj.gui_imageViewerA.trackCircle)) || xor(isempty(obj.gui_imageViewerB.trackCircle{obj.pointerConnectDatabase}),isempty(obj.gui_imageViewerA.trackCircle{obj.pointerConnectDatabase}))
                    %do nothing
                    disp('do nothing');
                elseif obj.pointerConnectDatabase == src.UserData;
                    str = sprintf('connection %d is unselected',src.UserData);
                    disp(str)
                    myrec = obj.gui_imageViewerB.trackCircle{src.UserData};
                    myrec.FaceColor = obj.gui_imageViewerB.circleColor2;
                    myrec = obj.gui_imageViewerA.trackCircle{src.UserData};
                    myrec.FaceColor = obj.gui_imageViewerA.circleColor2;
                    obj.pointerConnectDatabase = length(obj.connect_database_template_struct) + 1;
                    obj.gui_imageViewerB.connectBool = false;
                    obj.gui_imageViewerA.connectBool = false;
                else
                    str = sprintf('connection %d is selected',src.UserData);
                    disp(str)
                    obj.pointerConnectDatabase = src.UserData;
                    obj.gui_imageViewerB.connectBool = false;
                    obj.gui_imageViewerA.connectBool = false;
                    
                    myrec = obj.gui_imageViewerB.trackCircle{obj.pointerConnectDatabase1};
                    myrec.FaceColor = obj.gui_imageViewerB.circleColor2;
                    myrec = obj.gui_imageViewerA.trackCircle{obj.pointerConnectDatabase1};
                    myrec.FaceColor = obj.gui_imageViewerA.circleColor2;
                    
                    myrec = obj.gui_imageViewerB.trackCircle{obj.pointerConnectDatabase};
                    myrec.FaceColor = obj.gui_imageViewerB.circleColor1;
                    myrec = obj.gui_imageViewerA.trackCircle{obj.pointerConnectDatabase};
                    myrec.FaceColor = obj.gui_imageViewerA.circleColor1;
                    
                    obj.pointerConnectDatabase1 = obj.pointerConnectDatabase;
                end
            elseif evt.Button == 3
               maybenumber = src.UserData;
               if length(obj.gui_imageViewerB.trackCircle) < src.UserData
                   %do nothing
               elseif ~isempty(obj.gui_imageViewerB.trackCircle{src.UserData})
                    delete(obj.gui_imageViewerB.trackCircle{src.UserData});
                    obj.pointerConnectDatabase = maybenumber;
                    if length(obj.gui_imageViewerB.trackCircle) == maybenumber
                        obj.gui_imageViewerB.trackCircle(end) = [];
                    end
               end
               if length(obj.gui_imageViewerA.trackCircle) < src.UserData
                   %do nothing
               elseif~isempty(obj.gui_imageViewerA.trackCircle{src.UserData})
                   delete(obj.gui_imageViewerA.trackCircle{src.UserData})
                   obj.pointerConnectDatabase = maybenumber;
                   if length(obj.gui_imageViewerA.trackCircle) == maybenumber
                       obj.gui_imageViewerA.trackCircle(end) = [];
                   end
               end
            end
        end
        %%
        %
        function obj = exportTable(obj)
            str = sprintf('data%d.mat',obj.indImage);
            mytable = obj.connect_database_template_struct; %#ok<NASGU>
            save(fullfile(obj.moviePathA,str),'mytable');
        end
        %%
        %
        function obj = importTable(obj)
            str = sprintf('data%d.mat',obj.indImage);
            S = load(fullfile(obj.moviePathA,str),'mytable');
            obj.connect_database_template_struct = S.mytable;
            obj.refreshSpots;
        end
        %%
        %
        function obj = refreshSpots(obj)
            %%
            % A
            handles = guidata(obj.gui_imageViewerA.gui_main);
            cellfun(@delete,obj.gui_imageViewerA.trackCircle);
            obj.gui_imageViewerA.trackCircle = {};
            for i = 1:length(obj.connect_database_template_struct)
                myrec = rectangle('Parent',handles.axesCircles);
                myrec.UserData = i;
                myrec.Curvature = [1,1];
                myrec.FaceColor = obj.gui_imageViewerA.circleColor2;
                myrec.Position = [obj.connect_database_template_struct(i).rowA - (obj.gui_imageViewerA.trackCircleSize-1)/2, obj.connect_database_template_struct(i).colA - (obj.gui_imageViewerA.trackCircleSize-1)/2, obj.gui_imageViewerA.trackCircleSize, obj.gui_imageViewerA.trackCircleSize];
                myrec.ButtonDownFcn = @(src,evt) obj.clickme_rec(src,evt);
                obj.gui_imageViewerA.trackCircle{i} = myrec;
            end
            %%
            % B
            handles = guidata(obj.gui_imageViewerB.gui_main);
            cellfun(@delete,obj.gui_imageViewerB.trackCircle);
            obj.gui_imageViewerB.trackCircle = {};
            for i = 1:length(obj.connect_database_template_struct)
                myrec = rectangle('Parent',handles.axesCircles);
                myrec.UserData = i;
                myrec.Curvature = [1,1];
                myrec.FaceColor = obj.gui_imageViewerB.circleColor2;
                myrec.Position = [obj.connect_database_template_struct(i).rowB - (obj.gui_imageViewerB.trackCircleSize-1)/2, obj.connect_database_template_struct(i).colB - (obj.gui_imageViewerB.trackCircleSize-1)/2, obj.gui_imageViewerB.trackCircleSize, obj.gui_imageViewerB.trackCircleSize];
                myrec.ButtonDownFcn = @(src,evt) obj.clickme_rec(src,evt);
                obj.gui_imageViewerB.trackCircle{i} = myrec;
            end
            
            obj.pointerConnectDatabase1 = 1;
            obj.pointerConnectDatabase = length(obj.connect_database_template_struct) + 1;
        end
    end
end