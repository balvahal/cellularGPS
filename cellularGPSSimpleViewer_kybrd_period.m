function [sv] = cellularGPSSimpleViewer_kybrd_period(sv)
sv.indT = sv.indT + 1;
sv.refresh;
%%
% user update
str = sprintf('Keyboard ''comma''. TIME %d',sv.T);
disp(str);
end