%%
% increase step group
function [sv] = cellularGPSSimpleViewer_kybrd_w(sv)
sv.indG = sv.indG + 1;
sv.refresh;
%%
% user update
str = sprintf('Keyboard ''w''. GROUP %d',sv.P);
disp(str);
end