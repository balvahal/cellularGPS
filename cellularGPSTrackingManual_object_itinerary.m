%% The SuperMDAItinerary
% The SuperMDA allows multiple multi-dimensional-acquisitions to be run
% simulataneously. Each group consists of 1 or more positions. Each
% position consists of 1 or more settings.
classdef cellularGPSTrackingManual_object_itinerary < handle
    %%
    % * channel_names: the names of the channels group in the current
    % session of uManager.
    % * gps: a matrix that contains the groups, positions, and settings
    % information. As the SuperMDA processes through orderVector it will
    % keep track of which index is changing and execute a function based on
    % this change.
    % * orderVector: a vector with the number of rows of the GPS matrix. It
    % contains the sequence of natural numbers from 1 to the number of
    % rows. The SuperMDA will follow the numbers in the orderVector as they
    % increase and the row that contains the current number corresponds to
    % the next row in the GPS to be executed.
    % * filename_prefix: the string that is placed at the front of the
    % image filename.
    % * fundamental_period: the shortest period that images are taken in
    % seconds.
    % * output_directory: The directory where the output images are stored.
    % * group_order: The group_order exists to deal with the issue of
    % pre-allocation. Performance suffers without pre-allocation. Groups
    % are only active if their index exists in the group_order. The
    % |TravelAgent| enforces the numbers within the group_order vector to
    % be sequential (though not necessarily in order).
    properties
        channel_names;
        database_filenamePNG;
        gps;
        gps_logical;
        mm;
        orderVector;
        output_directory
        png_path;
        
        group_function_after;
        group_function_before;
        group_label;
        group_logical;
        group_scratchpad;
        
        ind_first_group;
        ind_last_group;
        ind_next_gps;
        ind_next_group;
        ind_next_position;
        ind_next_settings;
        
        position_continuous_focus_offset;
        position_continuous_focus_bool;
        position_function_after;
        position_function_before;
        position_label;
        position_logical;
        position_scratchpad;
        position_xyz;
        
        settings_binning;
        settings_channel;
        settings_exposure;
        settings_function;
        settings_gain;
        settings_logical;
        settings_period_multiplier;
        settings_scratchpad;
        settings_timepoints;
        settings_z_origin_offset;
        settings_z_stack_lower_offset;
        settings_z_stack_upper_offset;
        settings_z_step_size;
    end
    properties (SetAccess = private)
        duration = 0;
        fundamental_period = 600; %The units are seconds. 600 is 10 minutes.
        clock_relative = 0;
        number_of_timepoints = 1;
    end
    %%
    %
    methods
        %% The constructor method
        % The first argument is always mm
        function obj = cellularGPSTrackingManual_object_itinerary()
            
        end
        %%
        %
        function obj = import(obj,filename)
            data = loadjson(filename);
            %%
            %
            if iscell(data.channel_names)
                obj.channel_names = data.channel_names;
            else
                obj.channel_names = {data.channel_names};
            end
            obj.gps = data.gps;
            obj.gps_logical = logical(data.gps_logical);
            obj.orderVector = data.orderVector;
            if iscell(data.output_directory)
                obj.output_directory = fullfile(data.output_directory{:});
            else
                obj.output_directory = data.output_directory;
            end
            %%
            % group
            if iscell(data.group_function_after)
                obj.group_function_after = data.group_function_after;
            else
                obj.group_function_after = {data.group_function_after};
            end
            if iscell(data.group_function_before)
                obj.group_function_before = data.group_function_before;
            else
                obj.group_function_before = {data.group_function_before};
            end
            if iscell(data.group_label)
                obj.group_label = data.group_label;
            else
                obj.group_label = {data.group_label};
            end
            obj.group_logical = logical(data.group_logical);
            %%
            % navigation indices
            obj.ind_first_group = data.ind_first_group;
            obj.ind_last_group = data.ind_last_group;
            obj.ind_next_gps = data.ind_next_gps;
            obj.ind_next_group = data.ind_next_group;
            obj.ind_next_position = data.ind_next_position;
            obj.ind_next_settings = data.ind_next_settings;
            %%
            % position
            obj.position_continuous_focus_offset = data.position_continuous_focus_offset;
            obj.position_continuous_focus_bool = logical(data.position_continuous_focus_bool);
            if iscell(data.position_function_after)
                obj.position_function_after = data.position_function_after;
            else
                obj.position_function_after = {data.position_function_after};
            end
            if iscell(data.position_function_before)
                obj.position_function_before = data.position_function_before;
            else
                obj.position_function_before = {data.position_function_before};
            end
            if iscell(data.position_label)
                obj.position_label = data.position_label;
            else
                obj.position_label = {data.position_label};
            end
            obj.position_logical = logical(data.position_logical);
            obj.position_xyz = data.position_xyz;
            %%
            % settings
            obj.settings_binning = data.settings_binning;
            obj.settings_channel = data.settings_channel;
            obj.settings_exposure = data.settings_exposure;
            if iscell(data.settings_function)
                obj.settings_function = data.settings_function;
            else
                obj.settings_function = {data.settings_function};
            end
            obj.settings_logical = logical(data.settings_logical);
            obj.settings_period_multiplier = data.settings_period_multiplier;
            obj.settings_timepoints = data.settings_timepoints;
            obj.settings_z_origin_offset = data.settings_z_origin_offset;
            obj.settings_z_stack_lower_offset = data.settings_z_stack_lower_offset;
            obj.settings_z_stack_upper_offset = data.settings_z_stack_upper_offset;
            obj.settings_z_step_size = data.settings_z_step_size;
        end
        %%
        % returns the inds of "active" groups
        function n = indOfGroup(obj)
            n = transpose(1:length(obj.group_logical)); %outputs a column
            n = n(obj.group_logical);
        end
        %%
        % returns the positions found in a group
        function n = indOfPosition(obj,gNum)
            myGpsPosition = obj.gps(:,2);
            myPositionsInGNum = myGpsPosition((obj.gps(:,1) == gNum) & transpose(obj.gps_logical));
            n = unique(myPositionsInGNum); %outputs a column
        end
        %%
        % returns all the settings found in a group if the group number is
        % input. returns all the settings for a position if the group and
        % position number are input
        function n = indOfSettings(obj,varargin)
            if numel(varargin) == 2
                gNum = varargin{1};
                pNum = varargin{2};
                myGpsSettings = obj.gps(:,3);
                n = myGpsSettings((obj.gps(:,1) == gNum) & (obj.gps(:,2) == pNum) & transpose(obj.gps_logical)); %outputs a column
            else
                gNum = varargin{1};
                myGpsSettings = obj.gps(:,3);
                mySettingsInGNum = myGpsSettings((obj.gps(:,1) == gNum) & transpose(obj.gps_logical));
                n = unique(mySettingsInGNum); %outputs a column
            end
        end
        %%
        % computes the number of groups in the itinerary
        function n = numberOfGroup(obj)
            n = sum(obj.group_logical);
        end
        %%
        % computes the number of positions in a give group
        function n = numberOfPosition(obj,gNum)
            myGpsPosition = obj.gps(:,2);
            myPositionsInGNum = myGpsPosition(obj.gps(:,1) == gNum);
            n = sum(obj.position_logical((unique(myPositionsInGNum))));
        end
        %%
        % computes the number of settings in a given position and group
        function n = numberOfSettings(obj,gNum,pNum)
            myGpsSettings = obj.gps(:,3);
            mySettingsInGNumPNum = myGpsSettings((obj.gps(:,1) == gNum) & (obj.gps(:,2) == pNum));
            n = sum(obj.settings_logical((mySettingsInGNumPNum)));
        end
        %%
        %
        function n = orderOfGroup(obj)
            myGpsGroup = obj.gps(:,1);
            myGpsGroupOrder = myGpsGroup(obj.orderVector);
            groupInds = obj.indOfGroup;
            indicesOfFirstAppearance = zeros(size(groupInds));
            for i = 1:length(indicesOfFirstAppearance)
                indicesOfFirstAppearance(i) = find(myGpsGroupOrder == groupInds(i),1,'first');
            end
            n = sortrows(horzcat(groupInds,indicesOfFirstAppearance),2);
            n = transpose(n(:,1)); %outputs a row
        end
        %%
        %
        function n = orderOfPosition(obj,gNum)
            myGpsPosition = obj.gps(:,2);
            myGpsPositionOrder = myGpsPosition(obj.orderVector);
            positionInds = obj.indOfPosition(gNum);
            indicesOfFirstAppearance = zeros(size(positionInds));
            for i = 1:length(indicesOfFirstAppearance)
                indicesOfFirstAppearance(i) = find(myGpsPositionOrder == positionInds(i),1,'first');
            end
            n = sortrows(horzcat(positionInds,indicesOfFirstAppearance),2);
            n = transpose(n(:,1)); %outputs a row
        end
        %%
        %
        function n = orderOfSettings(obj,gNum,pNum)
            myGpsSettings = obj.gps(:,3);
            myGpsSettingsOrder = myGpsSettings(obj.orderVector);
            settingsInds = obj.indOfSettings(gNum,pNum);
            indicesOfFirstAppearance = zeros(size(settingsInds));
            for i = 1:length(indicesOfFirstAppearance)
                indicesOfFirstAppearance(i) = find(myGpsSettingsOrder == settingsInds(i),1,'first');
            end
            n = sortrows(horzcat(settingsInds,indicesOfFirstAppearance),2);
            n = transpose(n(:,1)); %outputs a row
        end
    end
    %%
    %
    methods (Static)
        
    end
end