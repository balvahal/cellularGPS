function [sv] = cellularGPSSimpleViewer_kybrd_comma(sv)
            sv.indImag3 = sv.indImag3 + sv.stepSize;
            if sv.indImage > height(obj.smda_databaseSubsetA)
                sv.indImage = height(obj.smda_databaseSubsetA);
            end
            %handlesControl = guidata(obj.gui_control.gui_main);
            %handlesControl.infoBk_editTimepoint.String = num2str(obj.indImage);
            %guidata(obj.gui_control.gui_main,handlesControl);
            obj.loop_stepX;
            if exist(fullfile(obj.moviePathA,sprintf('data%d.mat',obj.indImage)),'file')
                obj.importTable;
            else
                obj.connect_database_template_struct = [];
            end
            obj.refreshSpots;
end