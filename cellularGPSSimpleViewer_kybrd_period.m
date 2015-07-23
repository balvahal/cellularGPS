function [sv] = cellularGPSSimpleViewer_kybrd_period(sv)
sv.indT = sv.indT + 1;
if sv.indT > height(sv.tblRegister)
    sv.indT = height(sv.tblRegister);
    return
end
T = sv.tblRegister.timepoint(sv.indT);
sv.update_mainImage;
%%
% user update
str = sprintf('Keyboard ''comma''. TIME %d',T);
disp(str);
end