%%
% decrease step group
function [sv] = cellularGPSSimpleViewer_kybrd_q(sv)
sv.indG = sv.indG - 1;
sv.refresh;
%%
% user update
str = sprintf('Keyboard ''q''. GROUP %d',sv.G);
disp(str);
end