function [sv] = cellularGPSSimpleViewer_kybrd_comma(sv)
sv.indT = sv.indT - 1;
if sv.indT < 1
    sv.indT = 1;
    return
end
T = sv.tblRegister.timepoint(sv.indT);
sv.update_mainImage;
%%
% user update
str = sprintf('Keyboard ''comma''. TIME %d',T);
disp(str);
end