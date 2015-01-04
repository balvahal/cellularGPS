classdef cellularGPSTrackingManual_object_makecell < handle
    properties
        moviePath
        %%% DATA
        %
        makecell_logical
        makecell_order
        makecell_ind
        
        track_database
        track_logical
        track_makecell
        
        pointer_track
        pointer_next_track
        pointer_makecell = 1;
        pointer_next_makecell = 2;

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
            addOptional(q, 'trackID',obj.pointer_track, @(x)exist(fullfile(obj.moviePath,'TRACKING_DATA',x),'file'));
            addOptional(q, 'makecellID',obj.pointer_makecell, @(x)exist(fullfile(obj.moviePath,'TRACKING_DATA',x),'file'));
            parse(q,obj,varargin{:});
            
            obj.pointer_track = q.Results.trackID;
            obj.pointer_makecell = q.Results.makecellID;
            
            obj.makecell_ind{obj.pointer_makecell}(end+1) = obj.pointer_track;
        end
    end
end