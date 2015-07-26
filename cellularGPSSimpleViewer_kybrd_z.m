%%
% decrease step settings
function [sv] = cellularGPSSimpleViewer_kybrd_z(sv)
sv.indS = sv.indS - 1;
sv.refresh;
%%
% user update
str = sprintf('Keyboard ''z''. SETTINGS %d',sv.S);
disp(str);
end