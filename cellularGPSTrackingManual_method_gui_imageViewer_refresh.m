%%
% Update the gui_imageViewer to reflect the current state.
function trackman = cellularGPSTrackingManual_method_gui_imageViewer_refresh(trackman)
handles = guidata(trackman.gui_imageViewer);
handles.displayedImage.CData = imread(fullfile(trackman.moviePath,'PROCESSED_DATA',trackman.smda_databaseSubset.filename{trackman.indImage}));
guidata(trackman.gui_imageViewer,handles);
end