%%
% decrease step position
function [sv] = cellularGPSSimpleViewer_kybrd_a(sv)
sv.indP = sv.indP - 1;
sv.refresh;
%%
% user update
str = sprintf('Keyboard ''a''. POSITION %d',sv.P);
disp(str);
end