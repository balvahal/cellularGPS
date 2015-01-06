classdef cellularGPSTrackingManual_object_makecell < handle
    properties
        moviePath
        %%% DATA
        %
        makecell_logical = false;
        makecell_order = {};
        makecell_ind = {};
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
        function obj = cellularGPSTrackingManual_object_makecell()

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
        function obj = addTrack(obj,varargin)
            %%%
            % parse the input
            q = inputParser;
            addRequired(q, 'obj', @(x) isa(x,'cellularGPSTrackingManual_object_makecell'));
            addOptional(q, 'trackID',obj.pointer_track, @(x)isnumeric(x));
            addOptional(q, 'makecellID',obj.pointer_makecell, @(x)isnumeric(x));
            parse(q,obj,varargin{:});
            
            obj.pointer_track = q.Results.trackID;
            obj.pointer_makecell = q.Results.makecellID;
            
            if ~ismember(obj.pointer_track,obj.makecell_ind{obj.pointer_makecell})
                obj.makecell_ind{obj.pointer_makecell}(end+1) = obj.pointer_track;
            end
        end
        %% newCell
        %
        function obj = newCell(obj)
            obj.pointer_makecell = obj.pointer_next_makecell;
            obj.find_pointer_next_makecell;
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
                warning('makecell:nobreak','Could not break track, because none of the track exists before timepoint %d',q.Results.timepoint);
                return
            end
            tableBefore = mySubDatabase(myLogicalBefore,:);
            tableAfter = mySubDatabase(~myLogicalBefore,:);
            obj.find_pointer_next_track;
            tableAfter.trackID(:) = obj.pointer_next_track;
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
                warning('makecell:sametrack','Could not join tracks, because the inputs %d and %d represent only a single track.',trackID1,trackID2);
                return
            end
            
            existingTracks = 1:numel(obj.track_logical);
            existingTracks = existingTracks(obj.track_logical);
            
            if ~ismember(obj.pointer_track,existingTracks) || ~ismember(obj.pointer_track2,existingTracks)
                error('makecell:badtrack','Could not join tracks, because the inputs %d and %d represent only a single track.',trackID1,trackID2);
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
            addRequired(q, 'trackID',obj.pointer_track, @(x)isnumeric(x));
            parse(q,obj,varargin{:});
            
            obj.pointer_track = q.Results.trackID1;         
            existingTracks = 1:numel(obj.track_logical);
            existingTracks = existingTracks(obj.track_logical);
            
            if ~ismember(obj.pointer_track,existingTracks)
                error('makecell:badtrack','Could not delete track, because the input %d is not a track.',obj.pointer_track);
            end
            
            obj.track_logical(obj.pointer_track) = false;
            obj.track_database = obj.track_database(obj.track_database.trackID(:) ~= obj.pointer_track,:);
            obj.find_pointer_next_track;
        end
    end
end