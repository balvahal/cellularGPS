%%
% Update the gui_imageViewer to reflect the current state.
function trackman = cellularGPSTrackingManual_method_gui_imageViewer_refresh(trackman)
handles = guidata(trackman.gui_imageViewer);
handles.image = imread(fullfile(trackman.moviePath,'.thumb',trackman.smda_databaseSubset.filename{trackman.indImage}));
handles.displayedImage.CData = handles.image;
drawnow;
guidata(trackman.gui_imageViewer,handles);
end