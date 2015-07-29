function [sv] = cellularGPSSimpleViewer_kybrd_o(sv)
sv.indT = sv.indT + 1;
sv.refresh;
%%
% user update
str = sprintf('Keyboard ''o''. TIME %d',sv.T);
disp(str);
end