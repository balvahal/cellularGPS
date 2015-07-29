function [sv] = cellularGPSSimpleViewer_kybrd_backslash(sv)
sv.indT = 1;
sv.refresh;
%%
% user update
str = sprintf('Keyboard ''backslash''. TIME %d',sv.T);
disp(str);
end