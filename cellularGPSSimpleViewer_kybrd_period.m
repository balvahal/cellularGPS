function [sv] = cellularGPSSimpleViewer_kybrd_period(sv)
if sv.makecellBool
    sv.getImag3RowCol;
    sv.makecell.makecell_ind{sv.makecell.pointer_makecell}(sv.indT) = sub2ind([sv.smda_itinerary.imageHeightNoBin/sv.smda_itinerary.settings_binning(sv.S),sv.smda_itinerary.imageWidthNoBin/sv.smda_itinerary.settings_binning(sv.S)],sv.imag3RowCol(1),sv.imag3RowCol(2));
end
sv.indT = sv.indT + 1;
sv.refresh;
%%
% user update
str = sprintf('Keyboard ''comma''. TIME %d',sv.T);
disp(str);
end