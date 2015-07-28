classdef p53CinemaManual < cellularGPSSimpleViewer_object
    properties
listenImag3RowCol;

    end
    properties (SetAccess = private)
        
    end
    events
        
    end
    methods
        function obj = p53CinemaManual()
            obj.listenImag3RowCol = addlistener(obj,'imag3RowCol','PostSet',@obj.dosomething);
        end
        
    end
    methods (Static)
        function dosomething(src,evt)
            str = sprintf('row = %d, col = %d',evt.AffectedObject.imag3RowCol);
            disp(str);
        end
    end
end