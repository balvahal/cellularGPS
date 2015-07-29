function [sv] = cellularGPSSimpleViewer_kybrd_zero(sv)
sv.indT = sv.indT - 1;
sv.refresh;
%%
% user update
str = sprintf('Keyboard ''zero''. TIME %d',sv.T);
disp(str);
end