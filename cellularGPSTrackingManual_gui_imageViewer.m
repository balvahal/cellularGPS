%% p53CinemaManual_gui_imageViewer
% a simple gui to pause, stop, and resume a running MDA
function [f] = cellularGPSTrackingManual_gui_imageViewer(trackman)
%% Create the figure
% % The size of the figure will fill 90% of the primary screen and respect
% the aspect ratio of the input image.
%%
% get pixels to character info
handles.image = imread(fullfile(trackman.moviePath,'PROCESSED_DATA',trackman.smda_databaseSubset.filename{trackman.indImage}));
handles.image_width = size(handles.image,2);
handles.image_height = size(handles.image,1);
myunits = get(0,'units');
set(0,'units','pixels');
Pix_SS = get(0,'screensize');
set(0,'units','characters');
Char_SS = get(0,'screensize');
ppChar = Pix_SS./Char_SS;
ppChar = ppChar([3,4]);
set(0,'units',myunits);

if handles.image_width > handles.image_height
    if handles.image_width/handles.image_height >= Pix_SS(3)/Pix_SS(4)
        fwidth = 0.9*Pix_SS(3);
        fheight = fwidth*handles.image_height/handles.image_width;
    else
        fheight = 0.9*Pix_SS(4);
        fwidth = fheight*handles.image_width/handles.image_height;
    end
else
    if handles.image_height/handles.image_width >= Pix_SS(4)/Pix_SS(3)
        fheight = 0.9*Pix_SS(4);
        fwidth = fheight*handles.image_width/handles.image_height;
    else
        fwidth = 0.9*Pix_SS(3);
        fheight = fwidth*handles.image_height/handles.image_width;
        
    end
end

fwidth = fwidth/ppChar(1);
fheight = fheight/ppChar(2);

f = figure('Visible','off','Units','characters','MenuBar','none',...
    'Resize','off','Name','Image Viewer',...
    'Renderer','OpenGL','Position',[(Char_SS(3)-fwidth)/2 (Char_SS(4)-fheight)/2 fwidth fheight],...
    'CloseRequestFcn',{@fDeleteFcn},...
    'KeyPressFcn',{@fKeyPressFcn},...
    'WindowButtonDownFcn',{@fWindowButtonDownFcn},...
    'WindowButtonMotionFcn',{@fHover},...
    'WindowScrollWheelFcn',{@fWindowScrollWheelFcn});

%hwidth = master.obj_imageViewer.image_width/master.ppChar(1);
%hheight = master.obj_imageViewer.image_height/master.ppChar(2);
%hx = (fwidth-hwidth)/2;
%hy = (fheight-hheight-100/master.ppChar(2))/2+100/master.ppChar(2);
handles.haxesImageViewer = axes('Parent',f,...
    'Units','characters',...
    'Position',[0 0 fwidth  fheight],...
    'YDir','reverse',...
    'Visible','on',...
    'XLim',[0.5,handles.image_width+0.5],...
    'YLim',[0.5,handles.image_height+0.5]); %when displaying images the center of the pixels are located at the position on the axis. Therefore, the limits must account for the half pixel border.
%% Create an axes
% highlighted cell with hover haxesHighlight =
% axes('Units','characters','DrawMode','fast','color','none',...
%     'Position',[hx hy hwidth hheight],...
%     'XLim',[1,master.image_width],'YLim',[1,master.image_height]);
% cmapHighlight = colormap(haxesImageViewer,jet(16)); %63 matches the number of elements in ang
%% object order
% # image
% # annotation layer
% # highlight
% # selected cell
% colormap(haxesImageViewer,gray(255));
handles.displayedImage = image('Parent',handles.haxesImageViewer,...
    'CData',handles.image);
% hold(haxesImageViewer, 'on');
% cellFateEventPatch = patch('XData',[],'YData',[],...
%     'EdgeColor','none','FaceColor','none','MarkerSize',20,...
%     'Marker','o','MarkerEdgeColor',[0.7,0.6,0],'MarkerFaceColor',[1,0.9,0],...
%     'Parent',haxesImageViewer,'LineSmoothing', 'off');
% 
% trackedCellsPatch = patch('XData',[],'YData',[],...
%     'EdgeColor','none','FaceColor','none','MarkerSize',10,...
%     'Marker','o','MarkerEdgeColor',[0,0.75,1],'MarkerFaceColor',[0,0.25,1],...
%     'Parent',haxesImageViewer,'LineSmoothing', 'off');
% 
% selectedCellPatch = patch('XData',[],'YData',[],...
%     'EdgeColor','none','FaceColor','none','MarkerSize',10,...
%     'Marker','o','MarkerEdgeColor',[1,0.75,0],'MarkerFaceColor',[1,0,0],...
%     'Parent',haxesImageViewer,'LineSmoothing', 'off');
% 
% cellsInRangePatch = patch('XData',[],'YData',[],...
%     'EdgeColor','none','FaceColor','none','MarkerSize',1,...
%     'Marker','o','MarkerEdgeColor',[1,0.75,0],'MarkerFaceColor',[1,0,0],...
%     'Parent',haxesImageViewer,'LineSmoothing', 'off');
% 
% closestCellPatch = patch('XData',[],'YData',[],...
%     'EdgeColor','none','FaceColor','none','MarkerSize',5,...
%     'Marker','o','MarkerEdgeColor',[0,0.75,0.24],'MarkerFaceColor',[0,1,0],...
%     'Parent',haxesImageViewer,'LineSmoothing', 'off');
% hold(haxesImageViewer, 'off');

%% Create controls
% % Slider bar and two buttons
% hwidth = hwidthaxes;
% hheight = 20/master.ppChar(2);
% hx = 0;
% hy = 0;
% 
% sliderStep = 1/(master.obj_fileManager.numImages - 1);
% hsliderExploreStack = uicontrol('Style','slider','Units','characters',...
%     'Min',0,'Max',1,'BackgroundColor',[255 215 0]/255,...
%     'Value',0,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
%     'Callback',{@sliderExploreStack_Callback});
% hListener = handle.listener(hsliderExploreStack,'ActionEvent',@sliderExploreStack_Callback);
% setappdata(hsliderExploreStack,'sliderListener',hListener);
% 
% hx = 0;
% hy = hy + hheight + 1;
% hwidth = 60/master.ppChar(1);
% hheight = 30/master.ppChar(2);
% 
% hpushbuttonFirstImage = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',10,'FontName','Arial','BackgroundColor',[255 215 0]/255,...
%     'String','First Image','Position',[hx hy hwidth hheight],...
%     'Callback',{@pushbuttonFirstImage_Callback});
% 
% hx = fwidth - hwidth;
% hpushbuttonLastImage = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',10,'FontName','Arial','BackgroundColor',[60 179 113]/255,...
%     'String','Last Image','Position',[hx hy hwidth hheight],...
%     'Callback',{@pushbuttonLastImage_Callback});
%%
% store the uicontrol handles in the figure handles via guidata()
% handles.cmapHighlight = cmapHighlight;
% handles.cellFateEventPatch = cellFateEventPatch;
% handles.trackedCellsPatch = trackedCellsPatch;
% handles.selectedCellPatch = selectedCellPatch;
% handles.cellsInRangePatch = cellsInRangePatch;
% handles.closestCellPatch = closestCellPatch;
guidata(f,handles);
%%
% make the gui visible
set(f,'Visible','on');

%% Callbacks
%
%%
%
%     function fCloseRequestFcn(~,~)
%         %do nothing. This means only the master object can close this
%         %window.
%     end
%%
%
%%
%
    function fDeleteFcn(~,~)
        %do nothing. This means only the master object can close this
        %window.
        delete(f);
    end
%%
%
    function fKeyPressFcn(~,keyInfo)
        switch keyInfo.Key
            case 'period'
                trackman.gui_imageViewer_nextImage;
            case 'comma'
                trackman.gui_imageViewer_previousImage;
            case 'rightarrow'
                breakpoints = getTrackBreakpoints(master.obj_imageViewer.obj_cellTracker.centroidsTracks);
                if(~isempty(breakpoints))
                    jumpFrame = find(breakpoints > master.obj_imageViewer.currentFrame,1,'first');
                    if(~isempty(jumpFrame))
                        master.obj_imageViewer.setFrame(breakpoints(jumpFrame));
                    end
                end
            case 'leftarrow'
                breakpoints = getTrackBreakpoints(master.obj_imageViewer.obj_cellTracker.centroidsTracks);
                if(~isempty(breakpoints))
                    jumpFrame = find(breakpoints < master.obj_imageViewer.currentFrame,1,'last');
                    if(~isempty(jumpFrame))
                        master.obj_imageViewer.setFrame(breakpoints(jumpFrame));
                    end
                end
            case 'downarrow'
                breakpoints = getTrackBreakpoints(master.obj_imageViewer.obj_cellTracker.centroidsDivisions);
                if(~isempty(breakpoints))
                    jumpFrame = find(breakpoints > master.obj_imageViewer.currentFrame,1,'first');
                    if(~isempty(jumpFrame))
                        master.obj_imageViewer.setFrame(breakpoints(jumpFrame));
                    end
                end
            case 'uparrow'
                breakpoints = getTrackBreakpoints(master.obj_imageViewer.obj_cellTracker.centroidsDivisions);
                if(~isempty(breakpoints))
                    jumpFrame = find(breakpoints < master.obj_imageViewer.currentFrame,1,'last');
                    if(~isempty(jumpFrame))
                        master.obj_imageViewer.setFrame(breakpoints(jumpFrame));
                    end
                end
            case 'backspace'
                currentCentroid = master.obj_imageViewer.obj_cellTracker.centroidsTracks.getCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell);
                if(currentCentroid(1) > 0)
                    master.obj_imageViewer.obj_cellTracker.centroidsTracks.setCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell, [0,0], 0);
                    master.obj_imageViewer.obj_cellTracker.centroidsDivisions.setCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell, [0,0], 0);
                    master.obj_imageViewer.obj_cellTracker.centroidsDeath.setCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell, [0,0], 0);
                    master.obj_imageViewer.setImage;
                else
                    master.obj_imageViewer.deleteSelectedCellTrack();
                end
        end
    end

    function breakpoints = getTrackBreakpoints(centroidsObject)
        selectedCell = master.obj_imageViewer.selectedCell;
        if(master.obj_imageViewer.selectedCell > 0)
            currentTrack = centroidsObject.getCellTrack(selectedCell);
            currentTrack = currentTrack(master.obj_fileManager.currentImageTimepoints,:);
            activeTimepoints = find(currentTrack(:,1) > 0);
            if(~isempty(activeTimepoints))
                breakpoints = unique([1, find(diff(activeTimepoints) > 1)'+1, length(activeTimepoints)]);
                breakpoints = activeTimepoints(breakpoints);
            else
                breakpoints = [];
            end
        else
            breakpoints = [];
        end
    end

%%
%
    function fWindowButtonDownFcn(~,~)
        master.obj_imageViewer.obj_cellTracker.triggerTracking(get(master.obj_imageViewer.gui_imageViewer,'SelectionType'));
        %         %%
        %         % This if statement prevents multiple button firings from a single
        %         % click event
        %         %         if master.obj_imageViewer.isMyButtonDown
        %         %             return
        %         %         end
        %         if master.debugmode
        %             currentPoint = master.obj_imageViewer.getPixelxy;
        %             if ~isempty(currentPoint)
        %                 mystr = sprintf('x = %d\ty = %d',currentPoint(1),currentPoint(2));
        %                 disp(mystr);
        %             else
        %                 mystr = sprintf('OUTSIDE AXES!!!');
        %                 disp(mystr);
        %             end
        %         end
        %         currentPoint = master.obj_imageViewer.getPixelxy;
        %         if(~master.obj_imageViewer.obj_cellTracker.isTracking)
        %             return;
        %         end
        %
        %         %         master.obj_imageViewer.isMyButtonDown = true;
        %
        %         currentPoint = master.obj_imageViewer.getPixelxy;
        %         if(isempty(currentPoint))
        %             return;
        %         end
        %         % If the dataset has been preprocessed, perform tracking under
        %         % "magnet mode"
        %         if(master.obj_fileManager.preprocessMode)
        %             lookupRadius = master.obj_imageViewer.obj_cellTracker.getDistanceRadius;
        %             queryCentroid = master.obj_imageViewer.obj_cellTracker.centroidsLocalMaxima.getClosestCentroid(master.obj_imageViewer.currentTimepoint, fliplr(currentPoint), lookupRadius);
        %         else
        %             queryCentroid = fliplr(currentPoint);
        %         end
        %         % If this is the first time the user clicks after starting a new
        %         % track, define the selected cell
        %         if(master.obj_imageViewer.obj_cellTracker.firstClick)
        %             lookupRadius = master.obj_imageViewer.obj_cellTracker.getDistanceRadius / 6;
        %             [cellCentroid1, cell_id1] = master.obj_imageViewer.obj_cellTracker.centroidsTracks.getClosestCentroid(master.obj_imageViewer.currentTimepoint, queryCentroid, lookupRadius);
        %             [cellCentroid2, cell_id2] = master.obj_imageViewer.obj_cellTracker.centroidsTracks.getClosestCentroid(master.obj_imageViewer.currentTimepoint, fliplr(currentPoint), lookupRadius);
        %             if(~isempty(cell_id2))
        %                 master.obj_imageViewer.setSelectedCell(cell_id2);
        %                 queryCentroid = cellCentroid2;
        %             elseif(~isempty(cell_id1))
        %                 master.obj_imageViewer.setSelectedCell(cell_id1);
        %                 queryCentroid = cellCentroid1;
        %             else
        %                 master.obj_imageViewer.setSelectedCell(master.obj_imageViewer.obj_cellTracker.centroidsTracks.getAvailableCellId);
        %             end
        %             master.obj_imageViewer.obj_cellTracker.firstClick = 0;
        %         end
        %
        %         %% Set the centroids in selected cell and time
        %         master.obj_imageViewer.obj_cellTracker.centroidsTracks.setCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell, queryCentroid, 1);
        %         % Move centroid if there was one in division or death events
        %         if(master.obj_imageViewer.obj_cellTracker.centroidsDivisions.getValue(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell))
        %                 master.obj_imageViewer.obj_cellTracker.centroidsDivisions.setCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell, queryCentroid, 1);
        %         end
        %         if(master.obj_imageViewer.obj_cellTracker.centroidsDeath.getValue(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell))
        %                 master.obj_imageViewer.obj_cellTracker.centroidsDeath.setCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell, queryCentroid, 1);
        %         end
        %
        %         master.obj_imageViewer.obj_cellTracker.setAvailableCells;
        %
        %         selectionType = get(master.obj_imageViewer.gui_imageViewer,'SelectionType');
        %         if(strcmp(selectionType, 'alt'))
        %             annotationType = master.obj_imageViewer.obj_cellTracker.cellFateEvent;
        %             if(strcmp(annotationType, 'Division'))
        %                 master.obj_imageViewer.obj_cellTracker.centroidsDivisions.setCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell, queryCentroid, 1);
        %             end
        %             if(strcmp(annotationType, 'Death'))
        %                 master.obj_imageViewer.obj_cellTracker.centroidsDeath.setCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell, queryCentroid, 1);
        %             end
        %         end
        %
        %         master.obj_imageViewer.setImage;
        %         drawnow;
        %         frameSkip = master.obj_imageViewer.obj_cellTracker.getFrameSkip;
        %         master.obj_imageViewer.nextFrame;
        %
        %         %         master.obj_imageViewer.isMyButtonDown = false;
    end

    function fWindowScrollWheelFcn(~,event)
        newFrame = master.obj_imageViewer.currentFrame + event.VerticalScrollCount;
        master.obj_imageViewer.setFrame(newFrame);
    end
%%
% Translate the mouse position into the pixel location in the source image
    function fHover(~,~)
        %         set(f, 'HandleVisibility', 'on');
        %         set(0, 'currentfigure', f);
        %         % This function is redundant with the setImage function
        %         currentPoint = master.obj_imageViewer.getPixelxy;
        %         if(isempty(currentPoint))
        %             return;
        %         end
        %
        %         if(~master.obj_fileManager.preprocessMode)
        %             return;
        %         end
        %         master.obj_imageViewer.setImage;
    end
%%
%
    function sliderExploreStack_Callback(~,~)
        frame = get(hsliderExploreStack,'Value');
        sliderStep = get(hsliderExploreStack,'SliderStep');
        targetFrame = round((frame / sliderStep(1)) + 1);
        master.obj_imageViewer.setFrame(targetFrame);
    end
%%
%
    function pushbuttonFirstImage_Callback(~,~)
        master.obj_imageViewer.setFrame(1);
    end
%%
%
    function pushbuttonLastImage_Callback(~,~)
        master.obj_imageViewer.setFrame(length(master.obj_fileManager.currentImageFilenames));
    end
end