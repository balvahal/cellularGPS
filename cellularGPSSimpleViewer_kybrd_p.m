function [sv] = cellularGPSSimpleViewer_kybrd_p(sv)
sv.indT = sv.indT - 1;
sv.refresh;
%%
% user update
str = sprintf('Keyboard ''p''. TIME %d',sv.T);
disp(str);
end