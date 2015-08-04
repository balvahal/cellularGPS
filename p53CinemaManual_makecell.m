classdef p53CinemaManual_makecell < handle
    properties
        positionIndex;
        
        makecell_logical = false;
        makecell_order = cell(1,1);
        makecell_ind = cell(1,1);
        makecell_mother = 0;
        makecell_divisionStart = 0;
        makecell_divisionEnd = 0;
        makecell_apoptosisStart = 0;
        makecell_apoptosisEnd = 0;
        makecell_offscreenInd = 0;
        
        stack_daughter = 0;
        
        pointer_makecell = 1;
        pointer_makecell2 = 1;
        pointer_makecell3 = 1;
        pointer_next_makecell = 1;
        pointer_timepoint = 1;
        
        viewer;
    end
    properties (SetAccess = private)
        
    end
    events
        
    end
    methods
        function obj = p53CinemaManual_makecell()
            
        end
        %%
        % set the viewer object for this to work
        function obj = initialize(obj)
            if ~isdir(fullfile(obj.viewer.moviePath,'MAKECELL_DATA'))
                mkdir(fullfile(obj.viewer.moviePath,'MAKECELL_DATA'));
            end
            
            obj.positionIndex = obj.viewer.P;
        end
        %%
        %
        %% make
        %
        function obj = make(obj)
            obj.find_pointer_next_makecell;
            obj.pointer_makecell = obj.pointer_next_makecell;
            obj.makecell_logical(obj.pointer_makecell) = true;
            obj.makecell_ind{obj.pointer_makecell} = [];
            obj.makecell_mother(obj.pointer_makecell) = 0;
            obj.makecell_divisionStart(obj.pointer_makecell) = 0;
            obj.makecell_divisionEnd(obj.pointer_makecell) = 0;
            obj.makecell_apoptosisStart(obj.pointer_makecell) = 0;
            obj.makecell_apoptosisEnd(obj.pointer_makecell) = 0;
            obj.makecell_offscreenInd(obj.pointer_makecell) = 0;
        end
        %% find_pointer_next_makecell
        %
        function obj = find_pointer_next_makecell(obj)
            if any(~obj.makecell_logical)
                obj.pointer_next_makecell = find(~obj.makecell_logical,1,'first');
            else
                obj.pointer_next_makecell = numel(obj.makecell_logical) + 1;
            end
        end
        %%
        %
        function obj = deleteCell(obj,varargin)
            %%%
            % parse the input
            q = inputParser;
            addRequired(q, 'obj', @(x) isa(x,'cellularGPSTrackingManual_object_makecell'));
            addOptional(q, 'makecellID',obj.pointer_makecell, @(x)isnumeric(x));
            parse(q,obj,varargin{:});
            
            makecellID = q.Results.makecellID;
            obj.makecell_logical(makecellID) = false;
            obj.makecell_order{makecellID} = [];
            obj.makecell_ind{makecellID} = [];
            obj.makecell_mother(makecellID) = 0;
            obj.makecell_mother(obj.makecell_mother == makecellID) = 0;
            obj.makecell_divisionStart(makecellID) = 0;
            obj.makecell_divisionEnd(makecellID) = 0;
            obj.makecell_apoptosisStart(makecellID) = 0;
            obj.makecell_apoptosisEnd(makecellID) = 0;
            obj.makecell_offscreenInd(makecellID) = 0;
            
            obj.track_makecell(obj.track_makecell == makecellID) = 0;
            
            obj.find_pointer_next_makecell;
        end
        %% import
        %
        function obj = import(obj,varargin)
            %%%
            % parse the input
            q = inputParser;
            addRequired(q, 'obj', @(x) isa(x,'cellularGPSTrackingManual_object_makecell'));
            addOptional(q, 'pInd',obj.positionIndex, @(x)isnumeric(x));
            parse(q,obj,varargin{:});
            obj.positionIndex = q.Results.pInd;
            if exist(fullfile(obj.moviePath,'MAKECELL_DATA',sprintf('trackingPosition_%d.txt',obj.positionIndex)),'file')
                obj.track_database = readtable(fullfile(obj.moviePath,'MAKECELL_DATA',...
                    sprintf('trackingPosition_%d.txt',obj.positionIndex)),...
                    'Delimiter','\t');
            else
                obj.track_database = readtable(fullfile(obj.moviePath,'TRACKING_DATA',...
                    sprintf('trackingPosition_%d.txt',obj.positionIndex)),...
                    'Delimiter','\t');
                obj.track_database = obj.track_database(:,{'trackID','timepoint','centroid_row','centroid_col'});
            end
            trackID = unique(obj.track_database.trackID);
            obj.track_logical = false(max(trackID),1);
            obj.track_makecell = zeros(max(trackID),1);
            obj.track_logical(trackID) = true;
            obj.find_pointer_next_track;
            if ~exist(fullfile(obj.moviePath,'MAKECELL_DATA',sprintf('makeCellPosition_%d.txt',obj.positionIndex)),'file')
                warning('makecell:nofile','The makecell file does not exist for position %d.',obj.positionIndex);
                obj.makecell_logical = false;
                obj.makecell_order = cell(1,1);
                obj.makecell_ind = cell(1,1);
                obj.makecell_mother = 0;
                obj.makecell_divisionStart = 0;
                obj.makecell_divisionEnd = 0;
                obj.makecell_apoptosisStart = 0;
                obj.makecell_apoptosisEnd = 0;
                obj.track_makecell = zeros(size(obj.track_logical));
                obj.pointer_track = 1;
                obj.pointer_track2 = 1;
                obj.pointer_makecell = 1;
                obj.pointer_makecell2 = 1;
                obj.pointer_makecell3 = 1;
                obj.pointer_timepoint = 1;
            else
                %%
                %
                json = fileread(fullfile(obj.moviePath,'MAKECELL_DATA',sprintf('makeCellPosition_%d.txt',obj.positionIndex)));
                data = parse_json(json);
                data = data{1}; %the data struct comes wrapped in a cell.
                obj.positionIndex = data.positionIndex;
                if iscell(data.makecell_logical)
                    obj.makecell_logical = logical(cell2mat(data.makecell_logical));
                else
                    obj.makecell_logical = logical(data.makecell_logical);
                end
                if iscell(data.makecell_order)
                    obj.makecell_order = cell(length(data.makecell_order),1);
                    for i = 1:length(data.makecell_order)
                        obj.makecell_order{i} = cell2mat(data.makecell_order{i});
                    end
                elseif data.makecell_order == 0
                    obj.makecell_order = {};
                else
                    obj.makecell_order = {data.makecell_order};
                end
                if iscell(data.makecell_ind)
                    obj.makecell_ind = cell(length(data.makecell_ind),1);
                    for i = 1:length(data.makecell_ind)
                        obj.makecell_ind{i} = cell2mat(data.makecell_ind{i});
                    end
                elseif data.makecell_ind == 0
                    obj.makecell_ind = {};
                else
                    obj.makecell_ind = {data.makecell_ind};
                end
                if iscell(data.makecell_mother)
                    obj.makecell_mother = cell2mat(data.makecell_mother);
                else
                    obj.makecell_mother = data.makecell_mother;
                end
                if iscell(data.makecell_divisionStart)
                    obj.makecell_divisionStart = cell2mat(data.makecell_divisionStart);
                else
                    obj.makecell_divisionStart = data.makecell_divisionStart;
                end
                if iscell(data.makecell_divisionEnd)
                    obj.makecell_divisionEnd = cell2mat(data.makecell_divisionEnd);
                else
                    obj.makecell_divisionEnd = data.makecell_divisionEnd;
                end
                if iscell(data.makecell_apoptosisStart)
                    obj.makecell_apoptosisStart = cell2mat(data.makecell_apoptosisStart);
                else
                    obj.makecell_apoptosisStart = data.makecell_apoptosisStart;
                end
                if iscell(data.makecell_apoptosisEnd)
                    obj.makecell_apoptosisEnd = cell2mat(data.makecell_apoptosisEnd);
                else
                    obj.makecell_apoptosisEnd = data.makecell_apoptosisEnd;
                end
                if iscell(data.track_logical)
                    obj.track_logical = logical(cell2mat(data.track_logical));
                else
                    obj.track_logical = logical(data.track_logical);
                end
                if iscell(data.track_makecell)
                    obj.track_makecell = cell2mat(data.track_makecell);
                else
                    obj.track_makecell = data.track_makecell;
                end
                obj.pointer_track = data.pointer_track;
                obj.pointer_track2 = data.pointer_track2;
                obj.pointer_next_track = data.pointer_next_track;
                obj.pointer_makecell = data.pointer_makecell;
                obj.pointer_makecell2 = data.pointer_makecell2;
                obj.pointer_makecell3 = data.pointer_makecell3;
                obj.pointer_next_makecell = data.pointer_next_makecell;
                obj.pointer_timepoint = data.pointer_timepoint;
            end
            obj.find_pointer_next_makecell;
        end
        %% export
        %
        function obj = export(obj)
            %% convert data into JSON
            %
            jsonStrings = {};
            n = 1;
            %%%
            %
            jsonStrings{n} = micrographIOT_cellStringArray2json('moviePath',strsplit(obj.viewer.moviePath,filesep)); n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('positionIndex',obj.positionIndex); n = n + 1;
            %%%
            %
            jsonStrings{n} = micrographIOT_array2json('makecell_logical',obj.makecell_logical); n = n + 1;
            jsonStrings{n} = micrographIOT_cellNumericArray2json('makecell_order',obj.makecell_order); n = n + 1;
            jsonStrings{n} = micrographIOT_cellNumericArray2json('makecell_ind',obj.makecell_ind); n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('makecell_mother',obj.makecell_mother); n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('makecell_divisionStart',obj.makecell_divisionStart);  n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('makecell_divisionEnd',obj.makecell_divisionEnd); n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('makecell_apoptosisStart',obj.makecell_apoptosisStart);  n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('makecell_apoptosisEnd',obj.makecell_apoptosisEnd);  n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('makecell_apoptosisEnd',obj.makecell_apoptosisEnd);  n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('makecell_offscreenInd',obj.makecell_offscreenInd);  n = n + 1;
            %%%
            %
            jsonStrings{n} = micrographIOT_array2json('pointer_makecell',obj.pointer_makecell); n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('pointer_makecell2',obj.pointer_makecell2); n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('pointer_makecell3',obj.pointer_makecell3); n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('pointer_next_makecell',obj.pointer_next_makecell); n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('pointer_timepoint',obj.pointer_timepoint);
            %% export the JSON data to a text file
            %
            myjson = micrographIOT_jsonStrings2Object(jsonStrings);
            fid = fopen(fullfile(obj.viewer.moviePath,'MAKECELL_DATA',sprintf('makeCellPosition_%d.txt',obj.positionIndex)),'w');
            if fid == -1
                error('smdaITF:badfile','Cannot open the file, preventing the export of the smdaITF.');
            end
            fprintf(fid,myjson);
            fclose(fid);
            %%%
            %
            myjson = micrographIOT_autoIndentJson(fullfile(obj.viewer.moviePath,'MAKECELL_DATA',sprintf('makeCellPosition_%d.txt',obj.positionIndex)));
            fid = fopen(fullfile(obj.viewer.moviePath,'MAKECELL_DATA',sprintf('makeCellPosition_%d.txt',obj.positionIndex)),'w');
            if fid == -1
                error('smdaITF:badfile','Cannot open the file, preventing the export of the smdaITF.');
            end
            fprintf(fid,myjson);
            fclose(fid);
        end
    end
end