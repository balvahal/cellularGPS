%%
% increase step position
function [sv] = cellularGPSSimpleViewer_kybrd_s(sv)
sv.indP = sv.indP + 1;
sv.refresh;
%%
% user update
str = sprintf('Keyboard ''s''. POSITION %d',sv.P);
disp(str);
end