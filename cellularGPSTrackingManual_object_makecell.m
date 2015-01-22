classdef cellularGPSTrackingManual_object_makecell < handle
    properties
        moviePath
        positionIndex %the position number
        %%% DATA
        %
        makecell_logical = false;
        makecell_order = cell(1,1);
        makecell_ind = cell(1,1);
        makecell_mother = 0;
        makecell_divisionStart = 0;
        makecell_divisionEnd = 0;
        makecell_apoptosisStart = 0;
        makecell_apoptosisEnd = 0;
        
        track_database
        track_logical
        track_makecell
        
        pointer_track = 1;
        pointer_track2 = 1;
        pointer_next_track = 1;
        pointer_makecell = 1;
        pointer_makecell2 = 1;
        pointer_makecell3 = 1;
        pointer_next_makecell = 1;
        pointer_timepoint = 1;
    end
    %     properties (SetAccess = private)
    %     end
    %     events
    %     end
    methods
        %%
        %
        function obj = cellularGPSTrackingManual_object_makecell(moviePath,varargin)
            %%%
            % parse the input
            q = inputParser;
            addRequired(q, 'moviePath', @(x) isdir(x));
            addOptional(q, 'pInd',0, @(x)isnumeric(x));
            parse(q,moviePath,varargin{:});
            obj.positionIndex = q.Results.pInd;
            obj.moviePath = q.Results.moviePath;
            if ~isdir(fullfile(obj.moviePath,'MAKECELL_DATA'))
                mkdir(fullfile(obj.moviePath,'MAKECELL_DATA'));
            end
            if obj.positionIndex == 0
                % no positionIndex was given
                return
            end
            obj.import;
        end
        %%
        %
        function obj = loadTrackData(obj,varargin)
            %%%
            % parse the input
            q = inputParser;
            addRequired(q, 'obj', @(x) isa(x,'cellularGPSTrackingManual_object_makecell'));
            addOptional(q, 'trackfilename','nofile', @(x)exist(fullfile(obj.moviePath,'TRACKING_DATA',x),'file'));
            parse(q,obj,varargin{:});
            
            if ~strcmp(q.Results.myfilename,'nofile')
                obj.track_database = readtable(fullfile(obj.moviePath,'TRACKING_DATA',q.Reults.trackfilename),'Delimiter','\t');
            elseif ~istable(obj.track_database)
                error('mkcell:notrack','The track_database is not a table');
            end
            %%%
            % identify tracks
            trackID = unique(obj.track_database.trackID);
            obj.track_logical = false(max(trackID),1);
            obj.track_logical(trackID) = true;
            obj.track_makecell = zeros(max(trackID),1);
            obj.find_pointer_next_track;
        end
        %% find_pointer_next_group
        %
        function obj = find_pointer_next_track(obj)
            if any(~obj.track_logical)
                obj.pointer_next_track = find(~obj.track_logical,1,'first');
            else
                obj.pointer_next_track = numel(obj.track_logical) + 1;
            end
        end
        %% find_pointer_next_group
        %
        function obj = find_pointer_next_makecell(obj)
            if any(~obj.makecell_logical)
                obj.pointer_next_makecell = find(~obj.makecell_logical,1,'first');
            else
                obj.pointer_next_makecell = numel(obj.makecell_logical) + 1;
            end
        end
        %% addTrack
        %
        function obj = addTrack2Cell(obj,varargin)
            %%%
            % parse the input
            q = inputParser;
            addRequired(q, 'obj', @(x) isa(x,'cellularGPSTrackingManual_object_makecell'));
            addOptional(q, 'trackID',obj.pointer_track, @(x)isnumeric(x));
            addOptional(q, 'makecellID',obj.pointer_makecell, @(x)isnumeric(x));
            parse(q,obj,varargin{:});
            
            obj.pointer_track = q.Results.trackID;
            obj.pointer_makecell = q.Results.makecellID;
            
            if isempty(obj.makecell_ind{obj.pointer_makecell}) || ~ismember(obj.pointer_track,obj.makecell_ind{obj.pointer_makecell})
                obj.makecell_ind{obj.pointer_makecell}(end+1) = obj.pointer_track;
                obj.track_makecell(obj.pointer_track) = obj.pointer_makecell;
            end
        end
        %% newCell
        %
        function obj = newCell(obj)
            obj.find_pointer_next_makecell;
            obj.pointer_makecell = obj.pointer_next_makecell;
            obj.makecell_logical(obj.pointer_makecell) = true;
            obj.makecell_ind{obj.pointer_makecell} = [];
            obj.makecell_mother(obj.pointer_makecell) = 0;
            obj.makecell_divisionStart(obj.pointer_makecell) = 0;
            obj.makecell_divisionEnd(obj.pointer_makecell) = 0;
            obj.makecell_apoptosisStart(obj.pointer_makecell) = 0;
            obj.makecell_apoptosisEnd(obj.pointer_makecell) = 0;
        end
        %% breakTrack
        %
        function obj = breakTrack(obj,varargin)
            %%%
            % the columns of the track table are
            % * trackID
            % * timepoint
            % * centroid_row
            % * centroid_col
            %%%
            % parse the input
            q = inputParser;
            addRequired(q, 'obj', @(x) isa(x,'cellularGPSTrackingManual_object_makecell'));
            addOptional(q, 'trackID', obj.pointer_track, @(x)isnumeric(x));
            addOptional(q, 'timepoint', obj.pointer_timepoint, @(x)isnumeric(x));
            parse(q,obj,varargin{:});
            
            obj.pointer_track = q.Results.trackID;
            obj.pointer_timepoint = q.Results.timepoint;
            
            myLogicalDatabase = obj.track_database.trackID == obj.pointer_track;
            mySubDatabase = obj.track_database(myLogicalDatabase,:);
            myLogicalBefore = mySubDatabase.timepoint < obj.pointer_timepoint;
            if ~any(myLogicalBefore)
                error('makecell:nobreak','Could not break track, because none of the track exists before timepoint %d',q.Results.timepoint);
            end
            tableBefore = mySubDatabase(myLogicalBefore,:);
            tableAfter = mySubDatabase(~myLogicalBefore,:);
            obj.find_pointer_next_track;
            tableAfter.trackID(:) = obj.pointer_next_track;
            obj.pointer_track = obj.pointer_next_track; %the pointer now identifies the new track number
            obj.track_makecell(obj.pointer_track) = 0;
            obj.track_logical(obj.pointer_next_track) = true;
            obj.find_pointer_next_track;
            tableOld = obj.track_database(~myLogicalDatabase,:);
            obj.track_database = vertcat(tableOld,tableBefore,tableAfter);
        end
        %% joinTrack
        %
        function obj = joinTrack(obj,varargin)
            %%%
            % parse the input
            q = inputParser;
            addRequired(q, 'obj', @(x) isa(x,'cellularGPSTrackingManual_object_makecell'));
            addOptional(q, 'trackID1',obj.pointer_track, @(x)isnumeric(x));
            addOptional(q, 'trackID2',obj.pointer_track2, @(x)isnumeric(x));
            parse(q,obj,varargin{:});
            
            obj.pointer_track = q.Results.trackID1;
            obj.pointer_track2 = q.Results.trackID2;
            
            if obj.pointer_track == obj.pointer_track2
                warning('makecell:sametrack','Could not join tracks, because the inputs %d and %d represent only a single track.',q.Results.trackID1,q.Results.trackID2);
                return
            end
            
            existingTracks = 1:numel(obj.track_logical);
            existingTracks = existingTracks(obj.track_logical);
            
            if ~ismember(obj.pointer_track,existingTracks) || ~ismember(obj.pointer_track2,existingTracks)
                error('makecell:badtrack','Could not join tracks, because the inputs %d and %d represent only a single track.',q.Results.trackID1,q.Results.trackID2);
            end
            
            obj.track_database.trackID(obj.track_database.trackID == obj.pointer_track2) = obj.pointer_track;
            obj.track_logical(obj.pointer_track2) = false;
            obj.pointer_track2 = obj.pointer_track;
            obj.find_pointer_next_track;
        end
        %% deleteTrack
        %
        function obj = deleteTrack(obj,varargin)
            %%%
            % parse the input
            q = inputParser;
            addRequired(q, 'obj', @(x) isa(x,'cellularGPSTrackingManual_object_makecell'));
            addOptional(q, 'trackID',obj.pointer_track, @(x)isnumeric(x));
            parse(q,obj,varargin{:});
            
            obj.pointer_track = q.Results.trackID;
            existingTracks = 1:numel(obj.track_logical);
            existingTracks = existingTracks(obj.track_logical);
            
            if ~ismember(obj.pointer_track,existingTracks)
                error('makecell:badtrack','Could not delete track, because the input %d is not a track.',obj.pointer_track);
            end
            
            obj.track_logical(obj.pointer_track) = false;
            obj.track_database = obj.track_database(obj.track_database.trackID(:) ~= obj.pointer_track,:);
            obj.find_pointer_next_track;
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
                if iscell(data.moviePath)
                    obj.moviePath = fullfile(data.moviePath{:});
                else
                    obj.moviePath = data.moviePath;
                end
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
            %%%
            % parse the input
            q = inputParser;
            addRequired(q, 'obj', @(x) isa(x,'cellularGPSTrackingManual_object_makecell'));
            parse(q,obj);
            [obj.track_database,~] = sortrows(obj.track_database,{'trackID','timepoint'},{'ascend','ascend'});
            writetable(obj.track_database,fullfile(obj.moviePath,'MAKECELL_DATA',sprintf('trackingPosition_%d.txt',obj.positionIndex)),'Delimiter','\t');
            
            %% convert data into JSON
            %
            jsonStrings = {};
            n = 1;
            %%%
            %
            jsonStrings{n} = micrographIOT_cellStringArray2json('moviePath',strsplit(obj.moviePath,filesep)); n = n + 1;
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
            %%%
            %
            jsonStrings{n} = micrographIOT_array2json('track_logical',obj.track_logical); n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('track_makecell',obj.track_makecell); n = n + 1;
            %%%
            %
            jsonStrings{n} = micrographIOT_array2json('pointer_track',obj.pointer_track); n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('pointer_track2',obj.pointer_track2); n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('pointer_next_track',obj.pointer_next_track); n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('pointer_makecell',obj.pointer_makecell); n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('pointer_makecell2',obj.pointer_makecell2); n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('pointer_makecell3',obj.pointer_makecell3); n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('pointer_next_makecell',obj.pointer_next_makecell); n = n + 1;
            jsonStrings{n} = micrographIOT_array2json('pointer_timepoint',obj.pointer_timepoint);
            %% export the JSON data to a text file
            %
            myjson = micrographIOT_jsonStrings2Object(jsonStrings);
            fid = fopen(fullfile(obj.moviePath,'MAKECELL_DATA',sprintf('makeCellPosition_%d.txt',obj.positionIndex)),'w');
            if fid == -1
                error('smdaITF:badfile','Cannot open the file, preventing the export of the smdaITF.');
            end
            fprintf(fid,myjson);
            fclose(fid);
            %%%
            %
            myjson = micrographIOT_autoIndentJson(fullfile(obj.moviePath,'MAKECELL_DATA',sprintf('makeCellPosition_%d.txt',obj.positionIndex)));
            fid = fopen(fullfile(obj.moviePath,'MAKECELL_DATA',sprintf('makeCellPosition_%d.txt',obj.positionIndex)),'w');
            if fid == -1
                error('smdaITF:badfile','Cannot open the file, preventing the export of the smdaITF.');
            end
            fprintf(fid,myjson);
            fclose(fid);
        end
        %%
        %
        function [mom,dau] = identifyMother(obj,varargin)
            %%%
            % parse the input
            q = inputParser;
            addRequired(q, 'obj', @(x) isa(x,'cellularGPSTrackingManual_object_makecell'));
            addOptional(q, 'mom', obj.pointer_makecell, @(x)isnumeric(x));
            addOptional(q, 'dau', obj.pointer_makecell2, @(x)isnumeric(x));
            parse(q,obj,varargin{:});
            obj.pointer_makecell = q.Results.mom;
            obj.pointer_makecell2 = q.Results.dau;
            
            existingMakecell = 1:numel(obj.makecell_logical);
            existingMakecell = existingMakecell(obj.makecell_logical);
            
            if ~ismember(obj.pointer_makecell,existingMakecell) || ~ismember(obj.pointer_makecell2,existingMakecell)
                error('makecell:badmkcl','Could not assign mother cell, because of invalid cell number.');
            elseif obj.pointer_makecell == obj.pointer_makecell2
                error('makecell:samemkcl','Could not assign mother cell, because the two cell numbers are the same.');
            end
            mom = obj.pointer_makecell;
            dau = obj.pointer_makecell2;
            obj.makecell_mother(obj.pointer_makecell2) = obj.pointer_makecell;
        end
        %% exportTracesMatrix
        % Several matrices will be created with time represented by
        % columns:
        %
        % * a matrix where each row represents a cell
        % * a matrix where traces are connected along rows according to
        % their mother
        % * a subset of the previous matrix where only unique traces exist
        % along all rows
        function obj = exportTracesMatrix(obj)
            
        end
    end
end