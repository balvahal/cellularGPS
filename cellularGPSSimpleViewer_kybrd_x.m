%%
% increase step settings
function [sv] = cellularGPSSimpleViewer_kybrd_x(sv)
sv.indS = sv.indS + 1;
sv.refresh;
%%
% user update
str = sprintf('Keyboard ''x''. SETTINGS %d',sv.S);
disp(str);
end