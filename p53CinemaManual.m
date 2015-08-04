classdef p53CinemaManual < cellularGPSSimpleViewer_object
    properties
        listenImag3RowCol;
        scrollTimerArray = [Inf 1 0.5 0.25 0.125 0.06 0.03];
        scrollTimerIndex = 1;
        scrollTimer;
        
        makecell;
        makecell_viewer;
    end
    properties (SetAccess = private)
        
    end
    events
        
    end
    methods
        function obj = p53CinemaManual()
            obj@cellularGPSSimpleViewer_object;
            
            obj.listenImag3RowCol = addlistener(obj,'imag3RowCol','PostSet',@obj.listenerImag3RowCol);
        
            obj.kybrd_cmd.o = @p53CinemaManual_kybrd_o;
            obj.kybrd_cmd.p = @p53CinemaManual_kybrd_p;
            obj.kybrd_cmd.e = @p53CinemaManual_kybrd_e;
            obj.kybrd_cmd.q = @p53CinemaManual_kybrd_q;
            obj.kybrd_cmd.w = @p53CinemaManual_kybrd_w;
            obj.kybrd_cmd.a = @p53CinemaManual_kybrd_a;
            obj.kybrd_cmd.s = @p53CinemaManual_kybrd_s;
            obj.kybrd_cmd.zero = @p53CinemaManual_kybrd_zero;
      
            obj.scrollTimer = timer;
            obj.scrollTimer.ExecutionMode = 'fixedRate';
            obj.scrollTimer.BusyMode = 'drop';
            obj.scrollTimer.TimerFcn = @(~,~) obj.timer_scrollTimerFcn;
            obj.scrollTimer.Period = 1;
            
            obj.makecell = p53CinemaManual_makecell;
            obj.makecell.viewer = obj;
            obj.makecell.initialize;
            
            obj.makecell_viewer = p53CinemaManual_makecell_viewer;
            obj.makecell_viewer.makecell = obj.makecell;
            obj.makecell_viewer.initialize;
        end
        
        function obj = timer_scrollTimerFcn(obj,~,~)
            %% identify location of the mouse and save to cell
            %
            obj.getImag3RowCol;
            obj.makecell.makecell_ind{obj.makecell.pointer_makecell}(obj.indT) = sub2ind([obj.smda_itinerary.imageHeightNoBin/obj.smda_itinerary.settings_binning(obj.S),obj.smda_itinerary.imageWidthNoBin/obj.smda_itinerary.settings_binning(obj.S)],obj.imag3RowCol(1),obj.imag3RowCol(2));
            %% update the image and move it forward
            %
            obj.indT = obj.indT + 1;
            if obj.indT == obj.smda_itinerary.number_of_timepoints+1
                obj.kybrd_cmd.zero(obj);
            end
            obj.refresh;
        end
        
        %% delete
        % for a clean delete make sure the objects that are stored as
        % properties are also deleted.
        function delete(obj,~,~)
            stop(obj.scrollTimer);
            delete(obj.scrollTimer);
            delete(obj.gui_main);
            delete(obj.gps.gui_main);
            delete(obj.zoom.gui_main);
            delete(obj.contrast.gui_main);
            delete(obj.makecell_viewer.gui_main);
        end
    end
    methods (Static)
        function listenerImag3RowCol(~,evt)
            str = sprintf('row = %d, col = %d, intensity = %d',evt.AffectedObject.imag3RowCol,evt.AffectedObject.imag3RowColIntensity);
            disp(str);
        end
    end
end