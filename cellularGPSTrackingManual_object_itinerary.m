%% The SuperMDAItinerary
% The SuperMDA allows multiple multi-dimensional-acquisitions to be run
% simulataneously. Each group consists of 1 or more positions. Each
% position consists of 1 or more settings.
classdef cellularGPSTrackingManual_object_itinerary < SuperMDAItineraryTimeFixed_object
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

    end
    %%
    %
    methods
        %% The constructor method
        % The first argument is always mm
        function obj = cellularGPSTrackingManual_object_itinerary()
            
        end
        
    end
    %%
    %
    methods (Static)
        
    end
end