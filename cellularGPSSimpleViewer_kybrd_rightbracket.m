function [sv] = cellularGPSSimpleViewer_kybrd_rightbracket(sv)
sv.indT = sv.smda_itinerary.number_of_timepoints;
sv.refresh;
%%
% user update
str = sprintf('Keyboard ''rightbracket''. TIME %d',sv.T);
disp(str);
end