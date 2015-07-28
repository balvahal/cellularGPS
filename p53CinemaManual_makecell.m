classdef p53CinemaManual_makecell < handle
    properties
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
    end
    properties (SetAccess = private)
        
    end
    events
        
    end
    methods
        function obj = p53CinemaManual_makecell()
            
        end
    end
end