%%
% increase step group
function [sv] = cellularGPSSimpleViewer_kybrd_e(sv)
sv.indG = sv.indG + 1;
sv.refresh;
%%
% user update
str = sprintf('Keyboard ''e''. GROUP %d',sv.P);
disp(str);
end