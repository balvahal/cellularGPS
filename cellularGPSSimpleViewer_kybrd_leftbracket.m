function [sv] = cellularGPSSimpleViewer_kybrd_leftbracket(sv)
sv.indT = 1;
sv.refresh;
%%
% user update
str = sprintf('Keyboard ''leftbracket''. TIME %d',sv.T);
disp(str);
end