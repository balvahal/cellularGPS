%% SuperMDATravelAgent_gui_main
% a simple gui to pause, stop, and resume a running MDA
function [f] = cellularGPSTrackingManual_gui_smda(trackman)
%% Create the figure
%
myunits = get(0,'units');
set(0,'units','pixels');
Pix_SS = get(0,'screensize');
set(0,'units','characters');
Char_SS = get(0,'screensize');
ppChar = Pix_SS./Char_SS;
set(0,'units',myunits);
fwidth = 136.6; %683/ppChar(3);
fheight = 70; %910/ppChar(4);
fx = Char_SS(3) - (Char_SS(3)*.1 + fwidth);
fy = Char_SS(4) - (Char_SS(4)*.1 + fheight);
f = figure('Visible','off','Units','characters','MenuBar','none','Position',[fx fy fwidth fheight],...
    'CloseRequestFcn',{@fDeleteFcn},'Name','Travel Agent Main');

textBackgroundColorRegion1 = [37 124 224]/255; %tendoBlueLight
buttonBackgroundColorRegion1 = [29 97 175]/255; %tendoBlueDark
textBackgroundColorRegion2 = [56 165 95]/255; %tendoGreenLight
buttonBackgroundColorRegion2 = [44 129 74]/255; %tendoGreenDark
textBackgroundColorRegion3 = [255 214 95]/255; %tendoYellowLight
buttonBackgroundColorRegion3 = [199 164 74]/255; %tendoYellowDark
textBackgroundColorRegion4 = [255 103 97]/255; %tendoRedLight
buttonBackgroundColorRegion4 = [199 80 76]/255; %tendoRedDark
buttonSize = [20 3.0769]; %[100/ppChar(3) 40/ppChar(4)];
region1 = [0 56.1538]; %[0 730/ppChar(4)]; %180 pixels
region2 = [0 42.3077]; %[0 550/ppChar(4)]; %180 pixels
region3 = [0 13.8462]; %[0 180/ppChar(4)]; %370 pixels
region4 = [0 0]; %180 pixels

%% Assemble Region 1
%
%% Time Info
%
% hpopupmenuUnitsOfTime = uicontrol('Style','popupmenu','Units','characters',...
%     'FontSize',14,'FontName','Verdana',...
%     'String',{'seconds','minutes','hours','days'},...
%     'Position',[region1(1)+2, region1(2)+0.7692, buttonSize(1),buttonSize(2)],...
%     'Callback',{@popupmenuUnitsOfTime_Callback});
% 
% uicontrol('Style','text','Units','characters','String','Units of Time',...
%     'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion1,...
%     'Position',[region1(1)+2, region1(2)+4.2308, buttonSize(1),1.5385]);
% 
% heditFundamentalPeriod = uicontrol('Style','edit','Units','characters',...
%     'FontSize',14,'FontName','Verdana',...
%     'String',num2str(trackman.itinerary.fundamental_period),...
%     'Position',[region1(1)+2, region1(2)+6.5385, buttonSize(1),buttonSize(2)],...
%     'Callback',{@editFundamentalPeriod_Callback});
% 
% uicontrol('Style','text','Units','characters','String','Fundamental Period',...
%     'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion1,...
%     'Position',[region1(1)+2, region1(2)+10, buttonSize(1),2.6923]);
% 
% heditDuration = uicontrol('Style','edit','Units','characters',...
%     'FontSize',14,'FontName','Verdana',...
%     'String',num2str(trackman.itinerary.duration),...
%     'Position',[region1(1)+24, region1(2)+0.7692, buttonSize(1),buttonSize(2)],...
%     'Callback',{@editDuration_Callback});
% 
% uicontrol('Style','text','Units','characters','String','Duration',...
%     'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion1,...
%     'Position',[region1(1)+24, region1(2)+4.2308, buttonSize(1),1.5385]);
% 
% heditNumberOfTimepoints = uicontrol('Style','edit','Units','characters',...
%     'FontSize',14,'FontName','Verdana',...
%     'String',num2str(trackman.itinerary.number_of_timepoints),...
%     'Position',[region1(1)+24, region1(2)+6.5385, buttonSize(1),buttonSize(2)],...
%     'Callback',{@editNumberOfTimepoints_Callback});
% 
% uicontrol('Style','text','Units','characters','String','Number of Timepoints',...
%     'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion1,...
%     'Position',[region1(1)+24, region1(2)+10, buttonSize(1),2.6923]);
%% Output directory
%
heditOutputDirectory = uicontrol('Style','edit','Units','characters',...
    'FontSize',12,'FontName','Verdana','HorizontalAlignment','left',...
    'String',num2str(trackman.moviePath),...
    'Position',[region1(1)+46, region1(2)+0.7692, buttonSize(1)*3.5,buttonSize(2)],...
    'Callback',{@editOutputDirectory_Callback});

uicontrol('Style','text','Units','characters','String','Output Directory',...
    'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion1,...
    'Position',[region1(1)+46, region1(2)+4.2308, buttonSize(1)*3.5,1.5385]);

hpushbuttonOutputDirectory = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',20,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion1,...
    'String','...',...
    'Position',[region1(1)+48+buttonSize(1)*3.5, region1(2)+0.7692, buttonSize(1)*.5,buttonSize(2)],...
    'Callback',{@pushbuttonOutputDirectory_Callback});
%% Save or load current SuperMDAItinerary
%
hpushbuttonSave = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion1,...
    'String','Save',...
    'Position',[region1(1)+46, region1(2)+6.5385, buttonSize(1),buttonSize(2)],...
    'Callback',{@pushbuttonSave_Callback});

uicontrol('Style','text','Units','characters','String','Save an Itinerary',...
    'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion1,...
    'Position',[region1(1)+46, region1(2)+10, buttonSize(1),2.6923]);

hpushbuttonLoad = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion1,...
    'String','Load',...
    'Position',[region1(1)+68, region1(2)+6.5385, buttonSize(1),buttonSize(2)],...
    'Callback',{@pushbuttonLoad_Callback});

uicontrol('Style','text','Units','characters','String','Load an Itinerary',...
    'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion1,...
    'Position',[region1(1)+68, region1(2)+10, buttonSize(1),2.6923]);
%% Assemble Region 2
%
%% The group table
%
htableGroup = uitable('Units','characters',...
    'BackgroundColor',[textBackgroundColorRegion2;buttonBackgroundColorRegion2],...
    'ColumnName',{'label','group #','# of positions','function before','function after'},...
    'ColumnEditable',logical([0,0,0]),...
    'ColumnFormat',{'char','numeric','numeric'},...
    'ColumnWidth',{'auto' 'auto' 'auto'},...
    'FontSize',8,'FontName','Verdana',...
    'CellEditCallback',@tableGroup_CellEditCallback,...
    'CellSelectionCallback',@tableGroup_CellSelectionCallback,...
    'Position',[region2(1)+2, region2(2)+0.7692, 91.6, 13.0769]);
%% add or drop a group
%
hpushbuttonGroupAdd = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion2,...
    'String','Add',...
    'Position',[fwidth - 4 - buttonSize(1)*1.25, region2(2)+7.6923, buttonSize(1)*.75,buttonSize(2)],...
    'Callback',{@pushbuttonGroupAdd_Callback});

uicontrol('Style','text','Units','characters','String','Add a group',...
    'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion2,...
    'Position',[fwidth - 4 - buttonSize(1)*1.25, region2(2)+11.1538, buttonSize(1)*.75,2.6923]);

hpushbuttonGroupDrop = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion2,...
    'String','Drop',...
    'Position',[fwidth - 4 - buttonSize(1)*1.25, region2(2)+0.7692, buttonSize(1)*.75,buttonSize(2)],...
    'Callback',{@pushbuttonGroupDrop_Callback});

uicontrol('Style','text','Units','characters','String','Drop a group',...
    'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion2,...
    'Position',[fwidth - 4 - buttonSize(1)*1.25, region2(2)+4.2308, buttonSize(1)*.75,2.6923]);
%% change group functions
%
% uicontrol('Style','text','Units','characters','String',sprintf('Group\nFunction\nBefore'),...
%     'FontSize',7,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion2,...
%     'Position',[fwidth - 2 - buttonSize(1)*0.5, region2(2)+4.2308, buttonSize(1)*0.5,2.6923]);
% 
% hpushbuttonGroupFunctionBefore = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',20,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion2,...
%     'String','...',...
%     'Position',[fwidth - 2 - buttonSize(1)*0.5, region2(2)+0.7692, buttonSize(1)*.5,buttonSize(2)],...
%     'Callback',{@pushbuttonGroupFunctionBefore_Callback});
% 
% uicontrol('Style','text','Units','characters','String',sprintf('Group\nFunction\nAfter'),...
%     'FontSize',7,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion2,...
%     'Position',[fwidth - 2 - buttonSize(1)*0.5, region2(2)+11.1538, buttonSize(1)*0.5,2.6923]);
% 
% hpushbuttonGroupFunctionAfter = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',20,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion2,...
%     'String','...',...
%     'Position',[fwidth - 2 - buttonSize(1)*0.5, region2(2)+7.6923, buttonSize(1)*.5,buttonSize(2)],...
%     'Callback',{@pushbuttonGroupFunctionAfter_Callback});
%% Change group order
%
% uicontrol('Style','text','Units','characters','String',sprintf('Move\nGroup\nDown'),...
%     'FontSize',7,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion2,...
%     'Position',[fwidth - 6 - buttonSize(1)*1.75, region2(2)+4.2308, buttonSize(1)*0.5,2.6923]);
% 
% hpushbuttonGroupDown = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion2,...
%     'String','Dn',...
%     'Position',[fwidth - 6 - buttonSize(1)*1.75, region2(2)+0.7692, buttonSize(1)*.5,buttonSize(2)],...
%     'Callback',{@pushbuttonGroupDown_Callback});
% 
% uicontrol('Style','text','Units','characters','String',sprintf('Move\nGroup\nUp'),...
%     'FontSize',7,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion2,...
%     'Position',[fwidth - 6 - buttonSize(1)*1.75, region2(2)+11.1538, buttonSize(1)*0.5,2.6923]);
% 
% hpushbuttonGroupUp = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion2,...
%     'String','Up',...
%     'Position',[fwidth - 6 - buttonSize(1)*1.75, region2(2)+7.6923, buttonSize(1)*.5,buttonSize(2)],...
%     'Callback',{@pushbuttonGroupUp_Callback});
%% Assemble Region 3
%
%% The position table
%
htablePosition = uitable('Units','characters',...
    'BackgroundColor',[textBackgroundColorRegion3;buttonBackgroundColorRegion3],...
    'ColumnName',{'label','position #','X','Y','Z','# of settings'},...
    'ColumnEditable',logical([0,0,0,0,0,0]),...
    'ColumnFormat',{'char','numeric','numeric','numeric','numeric','numeric'},...
    'ColumnWidth',{'auto' 'auto' 'auto' 'auto' 'auto' 'auto'},...
    'FontSize',8,'FontName','Verdana',...
    'CellEditCallback',@tablePosition_CellEditCallback,...
    'CellSelectionCallback',@tablePosition_CellSelectionCallback,...
    'Position',[region3(1)+2, region3(2)+0.7692, 91.6, 28.1538]);
%% add or drop positions
%
hpushbuttonPositionAdd = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion3,...
    'String','Add',...
    'Position',[fwidth - 4 - buttonSize(1)*1.25, region3(2)+14.0769+7.6923, buttonSize(1)*.75,buttonSize(2)],...
    'Callback',{@pushbuttonPositionAdd_Callback});

uicontrol('Style','text','Units','characters','String','Add a position',...
    'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion3,...
    'Position',[fwidth - 4 - buttonSize(1)*1.25, region3(2)+14.0769+11.1538, buttonSize(1)*.75,2.6923]);

hpushbuttonPositionDrop = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion3,...
    'String','Drop',...
    'Position',[fwidth - 4 - buttonSize(1)*1.25, region3(2)+14.0769+0.7692, buttonSize(1)*.75,buttonSize(2)],...
    'Callback',{@pushbuttonPositionDrop_Callback});

uicontrol('Style','text','Units','characters','String','Drop a position',...
    'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion3,...
    'Position',[fwidth - 4 - buttonSize(1)*1.25, region3(2)+14.0769+4.2308, buttonSize(1)*.75,2.6923]);
%% change position order
%
% uicontrol('Style','text','Units','characters','String',sprintf('Move\nPosition\nDown'),...
%     'FontSize',7,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion3,...
%     'Position',[fwidth - 6 - buttonSize(1)*1.75, region3(2)+14.0769+4.2308, buttonSize(1)*0.5,2.6923]);
% 
% hpushbuttonPositionDown = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion3,...
%     'String','Dn',...
%     'Position',[fwidth - 6 - buttonSize(1)*1.75, region3(2)+14.0769+0.7692, buttonSize(1)*.5,buttonSize(2)],...
%     'Callback',{@pushbuttonPositionDown_Callback});
% 
% uicontrol('Style','text','Units','characters','String',sprintf('Move\nPosition\nUp'),...
%     'FontSize',7,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion3,...
%     'Position',[fwidth - 6 - buttonSize(1)*1.75, region3(2)+14.0769+11.1538, buttonSize(1)*0.5,2.6923]);
% 
% hpushbuttonPositionUp = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion3,...
%     'String','Up',...
%     'Position',[fwidth - 6 - buttonSize(1)*1.75, region3(2)+14.0769+7.6923, buttonSize(1)*.5,buttonSize(2)],...
%     'Callback',{@pushbuttonPositionUp_Callback});
%% move to a position
%
% hpushbuttonPositionMove = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion3,...
%     'String','Move',...
%     'Position',[fwidth - 6 - buttonSize(1)*1.75, region3(2)+7.6923, buttonSize(1),buttonSize(2)],...
%     'Callback',{@pushbuttonPositionMove_Callback});
% 
% uicontrol('Style','text','Units','characters','String',sprintf('Move the stage\nto the\nselected position'),...
%     'FontSize',7,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion3,...
%     'Position',[fwidth - 6 - buttonSize(1)*1.75, region3(2)+11.1538, buttonSize(1),2.6923]);
%% change a position value to the current position
%
% hpushbuttonPositionSet = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion3,...
%     'String','Set',...
%     'Position',[fwidth - 6 - buttonSize(1)*1.75, region3(2)+0.7692, buttonSize(1),buttonSize(2)],...
%     'Callback',{@pushbuttonPositionSet_Callback});
% 
% uicontrol('Style','text','Units','characters','String',sprintf('Set the position\nto the current\nstage position'),...
%     'FontSize',7,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion3,...
%     'Position',[fwidth - 6 - buttonSize(1)*1.75, region3(2)+4.2308, buttonSize(1),2.6923]);
%% add a grid
%
% hpushbuttonSetAllZ = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',10,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion3,...
%     'String',sprintf('Set All Z'),...
%     'Position',[fwidth - 2 - buttonSize(1)*.75, region3(2)+7.6923, buttonSize(1)*.75,buttonSize(2)],...
%     'Callback',{@pushbuttonSetAllZ_Callback});
% 
% uicontrol('Style','text','Units','characters','String',sprintf('Add a grid\nof positions'),...
%     'FontSize',7,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion3,...
%     'Position',[fwidth - 2 - buttonSize(1)*.75, region3(2)+11.1538, buttonSize(1)*.75,2.6923]);
%% change position functions
%
% uicontrol('Style','text','Units','characters','String',sprintf('Position\nFunction\nBefore'),...
%     'FontSize',7,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion3,...
%     'Position',[fwidth - 2 - buttonSize(1)*0.5, region3(2)+14.0769+4.2308, buttonSize(1)*0.5,2.6923]);
% 
% hpushbuttonPositionFunctionBefore = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',20,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion3,...
%     'String','...',...
%     'Position',[fwidth - 2 - buttonSize(1)*0.5, region3(2)+14.0769+0.7692, buttonSize(1)*.5,buttonSize(2)],...
%     'Callback',{@pushbuttonPositionFunctionBefore_Callback});
% 
% uicontrol('Style','text','Units','characters','String',sprintf('Position\nFunction\nAfter'),...
%     'FontSize',7,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion3,...
%     'Position',[fwidth - 2 - buttonSize(1)*0.5, region3(2)+14.0769+11.1538, buttonSize(1)*0.5,2.6923]);
% 
% hpushbuttonPositionFunctionAfter = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',20,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion3,...
%     'String','...',...
%     'Position',[fwidth - 2 - buttonSize(1)*0.5, region3(2)+14.0769+7.6923, buttonSize(1)*.5,buttonSize(2)],...
%     'Callback',{@pushbuttonPositionFunctionAfter_Callback});
%% Assemble Region 4
%
%% The settings table
%

htableSettings = uitable('Units','characters',...
    'BackgroundColor',[textBackgroundColorRegion4;buttonBackgroundColorRegion4],...
    'ColumnName',{'channel','exposure','settings #'},...
    'ColumnEditable',logical([0,0,0]),...
    'ColumnFormat',{trackman.smda_database.channel_name(1),'numeric','numeric'},...
    'ColumnWidth',{'auto' 'auto' 'auto'},...
    'FontSize',8,'FontName','Verdana',...
    'CellEditCallback',@tableSettings_CellEditCallback,...
    'CellSelectionCallback',@tableSettings_CellSelectionCallback,...
    'Position',[region4(1)+2, region4(2)+0.7692, 79.6, 13.0769]);
%% add or drop a group
%
hpushbuttonSettingsAdd = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion4,...
    'String','Add',...
    'Position',[fwidth - 6 - buttonSize(1)*1.75, region4(2)+7.6923, buttonSize(1)*.75,buttonSize(2)],...
    'Callback',{@pushbuttonSettingsAdd_Callback});

uicontrol('Style','text','Units','characters','String','Add a settings',...
    'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion4,...
    'Position',[fwidth - 6 - buttonSize(1)*1.75, region4(2)+11.1538, buttonSize(1)*.75,2.6923]);

hpushbuttonSettingsDrop = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion4,...
    'String','Drop',...
    'Position',[fwidth - 6 - buttonSize(1)*1.75, region4(2)+0.7692, buttonSize(1)*.75,buttonSize(2)],...
    'Callback',{@pushbuttonSettingsDrop_Callback});

uicontrol('Style','text','Units','characters','String','Drop a settings',...
    'FontSize',10,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion4,...
    'Position',[fwidth - 6 - buttonSize(1)*1.75, region4(2)+4.2308, buttonSize(1)*.75,2.6923]);
%% change Settings functions
%
% uicontrol('Style','text','Units','characters','String',sprintf('Settings\nFunction'),...
%     'FontSize',7,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion4,...
%     'Position',[fwidth - 2 - buttonSize(1)*0.5, region4(2)+11.1538, buttonSize(1)*0.5,2.6923]);
% 
% hpushbuttonSettingsFunction = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',20,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion4,...
%     'String','...',...
%     'Position',[fwidth - 2 - buttonSize(1)*0.5, region4(2)+7.6923, buttonSize(1)*.5,buttonSize(2)],...
%     'Callback',{@pushbuttonSettingsFunction_Callback});
%% Change Settings order
%
% uicontrol('Style','text','Units','characters','String',sprintf('Move\nSettings\nDown'),...
%     'FontSize',7,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion4,...
%     'Position',[fwidth - 8 - buttonSize(1)*2.25, region4(2)+4.2308, buttonSize(1)*0.5,2.6923]);
% 
% hpushbuttonSettingsDown = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion4,...
%     'String','Dn',...
%     'Position',[fwidth - 8 - buttonSize(1)*2.25, region4(2)+0.7692, buttonSize(1)*.5,buttonSize(2)],...
%     'Callback',{@pushbuttonSettingsDown_Callback});
% 
% uicontrol('Style','text','Units','characters','String',sprintf('Move\nSettings\nUp'),...
%     'FontSize',7,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion4,...
%     'Position',[fwidth - 8 - buttonSize(1)*2.25, region4(2)+11.1538, buttonSize(1)*0.5,2.6923]);
% 
% hpushbuttonSettingsUp = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion4,...
%     'String','Up',...
%     'Position',[fwidth - 8 - buttonSize(1)*2.25, region4(2)+7.6923, buttonSize(1)*.5,buttonSize(2)],...
%     'Callback',{@pushbuttonSettingsUp_Callback});
%% Set Z upper or Z lower boundaries
%
% uicontrol('Style','text','Units','characters','String',sprintf('Set Z\nLower'),...
%     'FontSize',7,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion4,...
%     'Position',[fwidth - 4 - buttonSize(1), region4(2)+4.2308, buttonSize(1)*0.5,2.6923]);
% 
% hpushbuttonSettingsZLower = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion4,...
%     'String','Z-',...
%     'Position',[fwidth - 4 - buttonSize(1), region4(2)+0.7692, buttonSize(1)*.5,buttonSize(2)],...
%     'Callback',{@pushbuttonSettingsZLower_Callback});
% 
% uicontrol('Style','text','Units','characters','String',sprintf('Set Z\nUpper'),...
%     'FontSize',7,'FontName','Verdana','BackgroundColor',textBackgroundColorRegion4,...
%     'Position',[fwidth - 4 - buttonSize(1), region4(2)+11.1538, buttonSize(1)*0.5,2.6923]);
% 
% hpushbuttonSettingsZUpper = uicontrol('Style','pushbutton','Units','characters',...
%     'FontSize',14,'FontName','Verdana','BackgroundColor',buttonBackgroundColorRegion4,...
%     'String','Z+',...
%     'Position',[fwidth - 4 - buttonSize(1), region4(2)+7.6923, buttonSize(1)*.5,buttonSize(2)],...
%     'Callback',{@pushbuttonSettingsZUpper_Callback});
%%
% store the uicontrol handles in the figure handles via guidata()
% handles.popupmenuUnitsOfTime = hpopupmenuUnitsOfTime;
% handles.editFundamentalPeriod = heditFundamentalPeriod;
% handles.editDuration = heditDuration;
% handles.editNumberOfTimepoints = heditNumberOfTimepoints;
 handles.editOutputDirectory = heditOutputDirectory;
% handles.pushbuttonOutputDirectory = hpushbuttonOutputDirectory;
% handles.pushbuttonSave = hpushbuttonSave;
% handles.pushbuttonLoad = hpushbuttonLoad;
% handles.pushbuttonGroupAdd = hpushbuttonGroupAdd;
% handles.pushbuttonGroupDrop = hpushbuttonGroupDrop;
% handles.pushbuttonGroupFunctionBefore = hpushbuttonGroupFunctionBefore;
% handles.pushbuttonGroupFunctionAfter = hpushbuttonGroupFunctionAfter;
% handles.pushbuttonGroupDown = hpushbuttonGroupDown;
% handles.pushbuttonGroupUp = hpushbuttonGroupUp;
% handles.pushbuttonPositionAdd = hpushbuttonPositionAdd;
% handles.pushbuttonPositionDown = hpushbuttonPositionDown;
% handles.pushbuttonPositionDrop = hpushbuttonPositionDrop;
% handles.pushbuttonPositionFunctionAfter = hpushbuttonPositionFunctionAfter;
% handles.pushbuttonPositionFunctionBefore = hpushbuttonPositionFunctionBefore;
% handles.pushbuttonPositionMove = hpushbuttonPositionMove;
% handles.pushbuttonPositionSet = hpushbuttonPositionSet;
% handles.pushbuttonPositionUp = hpushbuttonPositionUp;
% handles.pushbuttonSettingsAdd = hpushbuttonSettingsAdd;
% handles.pushbuttonSettingsDown = hpushbuttonSettingsDown;
% handles.pushbuttonSettingsDrop = hpushbuttonSettingsDrop;
% handles.pushbuttonSettingsFunction = hpushbuttonSettingsFunction;
% handles.pushbuttonSettingsUp = hpushbuttonSettingsUp;
% handles.pushbuttonSettingsZUpper = hpushbuttonSettingsZUpper;
% handles.pushbuttonSettingsZLower = hpushbuttonSettingsZLower;
 handles.tableGroup = htableGroup;
 handles.tablePosition = htablePosition;
 handles.tableSettings = htableSettings;
 guidata(f,handles);
%%
% make the gui visible
set(f,'Visible','on');

%% Callbacks
%
%%
% 
%     function fDeleteFcn(~,~)
%         %do nothing. This means only the master object can close this
%         %window.
%     end

%%
%
    function editFundamentalPeriod_Callback(~,~)
        myValue = str2double(get(heditFundamentalPeriod,'String'))*trackman.uot_conversion;
        trackman.itinerary.newFundamentalPeriod(myValue);
        trackman.refresh_gui_main;
    end
%%
%
    function editDuration_Callback(~,~)
        myValue = str2double(get(heditDuration,'String'))*trackman.uot_conversion;
        trackman.itinerary.newDuration(myValue);
        trackman.refresh_gui_main;
    end
%%
%
    function editNumberOfTimepoints_Callback(~,~)
        myValue = str2double(get(heditNumberOfTimepoints,'String'));
        trackman.itinerary.newNumberOfTimepoints(myValue);
        trackman.refresh_gui_main;
    end

%%
%
    function editOutputDirectory_Callback(~,~)
        folder_name = get(heditOutputDirectory,'String');
        if exist(folder_name,'dir')
            trackman.itinerary.output_directory = folder_name;
        else
            str = sprintf('''%s'' is not a directory',folder_name);
            disp(str);
        end
        trackman.refresh_gui_main;
    end
%%
%
    function popupmenuUnitsOfTime_Callback(~,~)
        seconds2array = [1,60,3600,86400];
        trackman.uot_conversion = seconds2array(get(hpopupmenuUnitsOfTime,'Value'));
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonGroupAdd_Callback(~,~)
        trackman.addGroup;
        trackman.pointerGroup = trackman.itinerary.numberOfGroup;
        trackman.refresh_gui_main;
    end

%%
%
    function pushbuttonGroupDown_Callback(~,~)
        %%
        % What follows below might have a more elegant solution.
        % essentially all selected rows are moved down 1.
        if max(trackman.pointerGroup) == trackman.itinerary.numberOfGroup
            return
        end
        currentOrder = 1:trackman.itinerary.numberOfGroup; % what the table looks like now
        movingGroup = trackman.pointerGroup+1; % where the selected rows want to go
        reactingGroup = setdiff(currentOrder,trackman.pointerGroup); % the rows that are not moving
        fillmeinArray = zeros(1,length(currentOrder)); % a vector to store the new order
        fillmeinArray(movingGroup) = trackman.pointerGroup; % the selected rows are moved
        fillmeinArray(fillmeinArray==0) = reactingGroup; % the remaining rows are moved
        % use the fillmeinArray to rearrange the groups
        myGroupOrder = trackman.itinerary.orderOfGroup;
        myGroupOrder = myGroupOrder(fillmeinArray);
        % use the new group order to rearrange the orderVector
        groupGPS = trackman.itinerary.gps(:,1);
        groupGPS = groupGPS(trackman.itinerary.gps_logical);
        newInds = zeros(2,trackman.itinerary.numberOfGroup);
        newInds(1,1) = 1;
        newInds(2,1) = sum(groupGPS == myGroupOrder(1));
        for i = 2:length(newInds)
            newInds(1,i) = newInds(1,i-1)+sum(groupGPS == myGroupOrder(i-1));
            newInds(2,i) = newInds(2,i-1)+sum(groupGPS == myGroupOrder(i));
        end
        newOrderVector = zeros(size(trackman.itinerary.orderVector));
        for i = 1:trackman.itinerary.numberOfGroup
            newOrderLogical = (trackman.itinerary.gps(:,1) == myGroupOrder(i)) & transpose(trackman.itinerary.gps_logical);
            newOrderLogical = newOrderLogical(trackman.itinerary.orderVector);
            newOrderSegment = trackman.itinerary.orderVector(newOrderLogical);
            newOrderVector(newInds(1,i):newInds(2,i)) = newOrderSegment;
        end
        trackman.itinerary.orderVector = newOrderVector;
        %
        trackman.pointerGroup = movingGroup;
        trackman.itinerary.find_ind_last_group;
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonGroupDrop_Callback(~,~)
        if trackman.itinerary.numberOfGroup==1
            return
        elseif length(trackman.pointerGroup) == trackman.itinerary.numberOfGroup
            trackman.pointerGroup(1) = [];
        end
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInds = myGroupOrder(trackman.pointerGroup);
        for i = 1:length(gInds)
            trackman.dropGroup(gInds(i));
        end
        trackman.pointerGroup = trackman.itinerary.numberOfGroup;
        trackman.itinerary.find_ind_last_group;
        trackman.refresh_gui_main;
    end

%%
%
    function pushbuttonGroupFunctionAfter_Callback(~,~)
        myGroupInd = trackman.itinerary.indOfGroup;
        mypwd = pwd;
        cd(trackman.itinerary.output_directory);
        [filename,pathname] = uigetfile({'*.m'},'Choose the group-function-after');
        if exist(fullfile(pathname,filename),'file')
            [trackman.itinerary.group_function_after{myGroupInd}] = deal(char(regexp(filename,'.*(?=\.m)','match')));
        else
            disp('The group-function-after selection was invalid.');
        end
        cd(mypwd);
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonGroupFunctionBefore_Callback(~,~)
        myGroupInd = trackman.itinerary.indOfGroup;
        mypwd = pwd;
        cd(trackman.itinerary.output_directory);
        [filename,pathname] = uigetfile({'*.m'},'Choose the group-function-before');
        if exist(fullfile(pathname,filename),'file')
            [trackman.itinerary.group_function_before{myGroupInd}] = deal(char(regexp(filename,'.*(?=\.m)','match')));
        else
            disp('The group-function-before selection was invalid.');
        end
        cd(mypwd);
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonGroupUp_Callback(~,~)
        %%
        % What follows below might have a more elegant solution.
        % essentially all selected rows are moved up 1.
        if min(trackman.pointerGroup) == 1
            return
        end
        currentOrder = 1:trackman.itinerary.numberOfGroup; % what the table looks like now
        movingGroup = trackman.pointerGroup-1; % where the selected rows want to go
        reactingGroup = setdiff(currentOrder,trackman.pointerGroup); % the rows that are not moving
        fillmeinArray = zeros(1,length(currentOrder)); % a vector to store the new order
        fillmeinArray(movingGroup) = trackman.pointerGroup; % the selected rows are moved
        fillmeinArray(fillmeinArray==0) = reactingGroup; % the remaining rows are moved
        % use the fillmeinArray to rearrange the groups
        myGroupOrder = trackman.itinerary.orderOfGroup;
        myGroupOrder = myGroupOrder(fillmeinArray);
        % use the new group order to rearrange the orderVector
        groupGPS = trackman.itinerary.gps(:,1);
        groupGPS = groupGPS(trackman.itinerary.gps_logical);
        newInds = zeros(2,trackman.itinerary.numberOfGroup);
        newInds(1,1) = 1;
        newInds(2,1) = sum(groupGPS == myGroupOrder(1));
        for i = 2:length(newInds)
            newInds(1,i) = newInds(1,i-1)+sum(groupGPS == myGroupOrder(i-1));
            newInds(2,i) = newInds(2,i-1)+sum(groupGPS == myGroupOrder(i));
        end
        newOrderVector = zeros(size(trackman.itinerary.orderVector));
        for i = 1:trackman.itinerary.numberOfGroup
            newOrderLogical = (trackman.itinerary.gps(:,1) == myGroupOrder(i)) & transpose(trackman.itinerary.gps_logical);
            newOrderLogical = newOrderLogical(trackman.itinerary.orderVector);
            newOrderSegment = trackman.itinerary.orderVector(newOrderLogical);
            newOrderVector(newInds(1,i):newInds(2,i)) = newOrderSegment;
        end
        trackman.itinerary.orderVector = newOrderVector;
        %
        trackman.pointerGroup = movingGroup;
        trackman.itinerary.find_ind_last_group;
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonPositionAdd_Callback(~,~)
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        trackman.addPosition(gInd);
        trackman.pointerPosition = trackman.itinerary.numberOfPosition(gInd);
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonPositionDown_Callback(~,~)
        %%
        % What follows below might have a more elegant solution.
        % essentially all selected rows are moved down 1.
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        if max(trackman.pointerPosition) == trackman.itinerary.numberOfPosition(gInd)
            return
        end
        currentOrder = 1:trackman.itinerary.numberOfPosition(gInd); % what the table looks like now
        movingPosition = trackman.pointerPosition+1; % where the selected rows want to go
        reactingPosition = setdiff(currentOrder,trackman.pointerPosition); % the rows that are not moving
        fillmeinArray = zeros(1,length(currentOrder)); % a vector to store the new order
        fillmeinArray(movingPosition) = trackman.pointerPosition; % the selected rows are moved
        fillmeinArray(fillmeinArray==0) = reactingPosition; % the remaining rows are moved
        % use the fillmeinArray to rearrange the positions
        myPositionOrder = trackman.itinerary.orderOfPosition(gInd);
        myPositionOrder = myPositionOrder(fillmeinArray);
        % find the location of the group within the orderVector
        newOrderLogical2 = (trackman.itinerary.gps(:,1) == gInd) & transpose(trackman.itinerary.gps_logical);
        newOrderLogical2 = newOrderLogical2(trackman.itinerary.orderVector);
        myGInd(1) = find(newOrderLogical2,1,'first');
        myGInd(2) = find(newOrderLogical2,1,'last');
        if (myGInd(2) - myGInd(1) + 1) ~= sum(newOrderLogical2)
            error('trackman:orderVpMove','The orderVector is corrupt. Please start over.');
        end
        % use the new position order to rearrange the orderVector
        positionGPS = trackman.itinerary.gps(:,2);
        positionGPS = positionGPS(trackman.itinerary.gps_logical);
        newInds = zeros(2,trackman.itinerary.numberOfPosition(gInd));
        newInds(1,1) = 1;
        newInds(2,1) = sum(positionGPS == myPositionOrder(1));
        for i = 2:length(newInds)
            newInds(1,i) = newInds(1,i-1)+sum(positionGPS == myPositionOrder(i-1));
            newInds(2,i) = newInds(2,i-1)+sum(positionGPS == myPositionOrder(i));
        end
        newOrderVector = zeros(1,(myGInd(2) - myGInd(1) + 1));
        for i = 1:trackman.itinerary.numberOfPosition(gInd)
            newOrderLogical = (trackman.itinerary.gps(:,2) == myPositionOrder(i)) & transpose(trackman.itinerary.gps_logical);
            newOrderLogical = newOrderLogical(trackman.itinerary.orderVector);
            newOrderSegment = trackman.itinerary.orderVector(newOrderLogical);
            newOrderVector(newInds(1,i):newInds(2,i)) = newOrderSegment;
        end
        trackman.itinerary.orderVector(myGInd(1):myGInd(2)) = newOrderVector;
        %
        trackman.pointerPosition = movingPosition;
        trackman.itinerary.find_ind_last_group(gInd);
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonPositionDrop_Callback(~,~)
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        if trackman.itinerary.numberOfPosition(gInd)==1
            return
        elseif length(trackman.pointerPosition) == trackman.itinerary.numberOfPosition(gInd)
            trackman.pointerPosition(1) = [];
        end
        myPositionInd = trackman.itinerary.orderOfPosition(gInd);
        for i = 1:length(trackman.pointerPosition)
            trackman.itinerary.dropPosition(myPositionInd(trackman.pointerPosition(i)));
        end
        trackman.pointerPosition = trackman.itinerary.numberOfPosition(gInd);
        trackman.itinerary.find_ind_last_group(gInd);
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonSetAllZ_Callback(~,~)
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        myPInd = trackman.itinerary.indOfPosition(gInd);
        trackman.itinerary.position_continuous_focus_offset(myPInd) = str2double(trackman.mm.core.getProperty(trackman.mm.AutoFocusDevice,'Position'));
        xyz = trackman.mm.getXYZ;
        trackman.itinerary.position_xyz(myPInd,3) = xyz(3);
        fprintf('positions in group %d have Z postions updated!\n',gInd);
    end
%%
%
    function pushbuttonPositionFunctionAfter_Callback(~,~)
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        mypwd = pwd;
        myPositionInd = trackman.itinerary.indOfPosition(gInd);
        cd(trackman.itinerary.output_directory);
        [filename,pathname] = uigetfile({'*.m'},'Choose the position-function-after');
        if exist(fullfile(pathname,filename),'file')
            [trackman.itinerary.position_function_after{myPositionInd}] = deal(char(regexp(filename,'.*(?=\.m)','match')));
        else
            disp('The position-function-before selection was invalid.');
        end
        cd(mypwd);
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonPositionFunctionBefore_Callback(~,~)
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        mypwd = pwd;
        myPositionInd = trackman.itinerary.indOfPosition(gInd);
        cd(trackman.itinerary.output_directory);
        [filename,pathname] = uigetfile({'*.m'},'Choose the position-function-before');
        if exist(fullfile(pathname,filename),'file')
            [trackman.itinerary.position_function_before{myPositionInd}] = deal(char(regexp(filename,'.*(?=\.m)','match')));
        else
            disp('The position-function-before selection was invalid.');
        end
        cd(mypwd);
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonPositionMove_Callback(~,~)
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        pInd = trackman.itinerary.orderOfPosition(gInd);
        pInd = pInd(trackman.pointerPosition(1));
        xyz = trackman.itinerary.position_xyz(pInd,:);
        if trackman.itinerary.position_continuous_focus_bool(pInd)
            %% PFS lock-on will be attempted
            %
            trackman.mm.setXYZ(xyz(1:2)); % setting the z through the focus device will disable the PFS. Therefore, the stage is moved in the XY direction before assessing the status of the PFS system.
            trackman.mm.core.waitForDevice(trackman.mm.xyStageDevice);
            if strcmp(trackman.mm.core.getProperty(trackman.mm.AutoFocusStatusDevice,'State'),'Off')
                %%
                % If the PFS is |OFF|, then the scope is moved to an
                % absolute z that will give the system the best chance of
                % locking onto the correct z.
                trackman.mm.setXYZ(xyz(3),'direction','z');
                trackman.mm.core.waitForDevice(trackman.mm.FocusDevice);
                trackman.mm.core.setProperty(trackman.mm.AutoFocusDevice,'Position',trackman.itinerary.position_continuous_focus_offset(pInd));
                trackman.mm.core.fullFocus(); % PFS will return to |OFF|
            else
                %%
                % If the PFS system is already on, then changing the offset
                % will adjust the z-position. fullFocus() will have the
                % system wait until the new z-position has been reached.
                trackman.mm.core.setProperty(trackman.mm.AutoFocusDevice,'Position',trackman.itinerary.position_continuous_focus_offset(pInd));
                trackman.mm.core.fullFocus(); % PFS will remain |ON|
            end
        else
            %% PFS will not be utilized
            %
            trackman.mm.setXYZ(xyz);
            trackman.mm.core.waitForDevice(trackman.mm.FocusDevice);
            trackman.mm.core.waitForDevice(trackman.mm.xyStageDevice);
        end
    end
%%
%
    function pushbuttonPositionSet_Callback(~,~)
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        pInd = trackman.itinerary.orderOfPosition(gInd);
        pInd = pInd(trackman.pointerPosition(1));
        trackman.mm.getXYZ;
        trackman.itinerary.position_xyz(pInd,:) = trackman.mm.pos;
        trackman.itinerary.position_continuous_focus_offset(pInd) = str2double(trackman.mm.core.getProperty(trackman.mm.AutoFocusDevice,'Position'));
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonPositionUp_Callback(~,~)
        %%
        % What follows below might have a more elegant solution.
        % essentially all selected rows are moved up 1.
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        if min(trackman.pointerPosition) == 1
            return
        end
        currentOrder = 1:trackman.itinerary.numberOfPosition(gInd); % what the table looks like now
        movingPosition = trackman.pointerPosition-1; % where the selected rows want to go
        reactingPosition = setdiff(currentOrder,trackman.pointerPosition); % the rows that are not moving
        fillmeinArray = zeros(1,length(currentOrder)); % a vector to store the new order
        fillmeinArray(movingPosition) = trackman.pointerPosition; % the selected rows are moved
        fillmeinArray(fillmeinArray==0) = reactingPosition; % the remaining rows are moved
        % use the fillmeinArray to rearrange the positions
        myPositionOrder = trackman.itinerary.orderOfPosition(gInd);
        myPositionOrder = myPositionOrder(fillmeinArray);
        % find the location of the group within the orderVector
        newOrderLogical2 = (trackman.itinerary.gps(:,1) == gInd) & transpose(trackman.itinerary.gps_logical);
        newOrderLogical2 = newOrderLogical2(trackman.itinerary.orderVector);
        myGInd(1) = find(newOrderLogical2,1,'first');
        myGInd(2) = find(newOrderLogical2,1,'last');
        if (myGInd(2) - myGInd(1) + 1) ~= sum(newOrderLogical2)
            error('trackman:orderVpMove','The orderVector is corrupt. Please start over.');
        end
        % use the new position order to rearrange the orderVector
        positionGPS = trackman.itinerary.gps(:,2);
        positionGPS = positionGPS(trackman.itinerary.gps_logical);
        newInds = zeros(2,trackman.itinerary.numberOfPosition(gInd));
        newInds(1,1) = 1;
        newInds(2,1) = sum(positionGPS == myPositionOrder(1));
        for i = 2:length(newInds)
            newInds(1,i) = newInds(1,i-1)+sum(positionGPS == myPositionOrder(i-1));
            newInds(2,i) = newInds(2,i-1)+sum(positionGPS == myPositionOrder(i));
        end
        newOrderVector = zeros(1,(myGInd(2) - myGInd(1) + 1));
        for i = 1:trackman.itinerary.numberOfPosition(gInd)
            newOrderLogical = (trackman.itinerary.gps(:,2) == myPositionOrder(i)) & transpose(trackman.itinerary.gps_logical);
            newOrderLogical = newOrderLogical(trackman.itinerary.orderVector);
            newOrderSegment = trackman.itinerary.orderVector(newOrderLogical);
            newOrderVector(newInds(1,i):newInds(2,i)) = newOrderSegment;
        end
        trackman.itinerary.orderVector(myGInd(1):myGInd(2)) = newOrderVector;
        %
        trackman.pointerPosition = movingPosition;
        trackman.itinerary.find_ind_last_group(gInd);
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonLoad_Callback(~,~)
        uiwait(warndlg('The current SuperMDA will be erased!','Load a SuperMDA','modal'));
        mypwd = pwd;
        cd(trackman.itinerary.output_directory);
        [filename,pathname] = uigetfile({'*.mat'},'Load a SuperMDAItinerary');
        cd(mypwd);
        if exist(fullfile(pathname,filename),'file')
            trackman.itinerary.import(fullfile(pathname,filename));
        else
            disp('The SuperMDAItinerary file selected was invalid.');
        end
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonOutputDirectory_Callback(~,~)
        folder_name = uigetdir;
        if folder_name==0
            return
        elseif exist(folder_name,'dir')
            trackman.itinerary.output_directory = folder_name;
        else
            str = sprintf('''%s'' is not a directory',folder_name);
            disp(str);
        end
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonSave_Callback(~,~)
        trackman.itinerary.export;
    end
%%
%
    function pushbuttonSettingsAdd_Callback(~,~)
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        pInd = trackman.itinerary.indOfPosition(gInd);
        pInd = pInd(1);
        trackman.addSettings(gInd);
        trackman.pointerSettings = trackman.itinerary.numberOfSettings(gInd,pInd);
        trackman.itinerary.find_ind_last_group(gInd);
        trackman.refresh_gui_main;
        %        trackman.pushSettings(gInd);
    end
%%
%
    function pushbuttonSettingsDown_Callback(~,~)
        %%
        % What follows below might have a more elegant solution.
        % essentially all selected rows are moved down 1.
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        pInd = trackman.itinerary.indOfPosition(gInd);
        pInd = pInd(1);
        if max(trackman.pointerSettings) == trackman.itinerary.numberOfSettings(gInd,pInd);
            return
        end
        currentOrder = 1:trackman.itinerary.numberOfSettings(gInd,pInd); % what the table looks like now
        movingSettings = trackman.pointerSettings+1; % where the selected rows want to go
        reactingSettings = setdiff(currentOrder,trackman.pointerSettings); % the rows that are not moving
        fillmeinArray = zeros(1,length(currentOrder)); % a vector to store the new order
        fillmeinArray(movingSettings) = trackman.pointerSettings; % the selected rows are moved
        fillmeinArray(fillmeinArray==0) = reactingSettings; % the remaining rows are moved
        % use the fillmeinArray to rearrange the settings
        mySettingsOrderPrior = trackman.itinerary.orderOfSettings(gInd,pInd);
        mySettingsOrder = mySettingsOrderPrior(fillmeinArray);
        % change the order of the settings to rearrange the order of the
        trackman.itinerary.settings_binning(mySettingsOrderPrior) = trackman.itinerary.settings_binning(mySettingsOrder);
        trackman.itinerary.settings_channel(mySettingsOrderPrior) = trackman.itinerary.settings_channel(mySettingsOrder);
        trackman.itinerary.settings_exposure(mySettingsOrderPrior) = trackman.itinerary.settings_exposure(mySettingsOrder);
        trackman.itinerary.settings_function(mySettingsOrderPrior) = trackman.itinerary.settings_function(mySettingsOrder);
        trackman.itinerary.settings_gain(mySettingsOrderPrior) = trackman.itinerary.settings_gain(mySettingsOrder);
        trackman.itinerary.settings_period_multiplier(mySettingsOrderPrior) = trackman.itinerary.settings_period_multiplier(mySettingsOrder);
        trackman.itinerary.settings_timepoints(mySettingsOrderPrior) = trackman.itinerary.settings_timepoints(mySettingsOrder);
        trackman.itinerary.settings_z_origin_offset(mySettingsOrderPrior) = trackman.itinerary.settings_z_origin_offset(mySettingsOrder);
        trackman.itinerary.settings_z_stack_lower_offset(mySettingsOrderPrior) = trackman.itinerary.settings_z_stack_lower_offset(mySettingsOrder);
        trackman.itinerary.settings_z_stack_upper_offset(mySettingsOrderPrior) = trackman.itinerary.settings_z_stack_upper_offset(mySettingsOrder);
        trackman.itinerary.settings_z_step_size(mySettingsOrderPrior) = trackman.itinerary.settings_z_step_size(mySettingsOrder);
        %
        trackman.pointerSettings = movingSettings;
        trackman.itinerary.find_ind_last_group(gInd);
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonSettingsDrop_Callback(~,~)
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        pInd = trackman.itinerary.indOfPosition(gInd);
        pInd = pInd(1);
        if trackman.itinerary.numberOfSettings(gInd,pInd) == 1
            return
        elseif length(trackman.pointerSettings) == trackman.itinerary.numberOfSettings(gInd,pInd)
            trackman.pointerSettings(1) = [];
        end
        mySettingsInd = trackman.itinerary.orderOfSettings(gInd,pInd);
        for i = 1:length(trackman.pointerSettings)
            trackman.itinerary.dropSettings(mySettingsInd(trackman.pointerSettings(i)));
        end
        trackman.pointerSettings = trackman.itinerary.numberOfSettings(gInd,pInd);
        trackman.itinerary.find_ind_last_group(gInd);
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonSettingsFunction_Callback(~,~)
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        pInd = trackman.itinerary.indOfPosition(gInd);
        pInd = pInd(1);
        sInds = trackman.itinerary.indOfSettings(gInd,pInd);
        mypwd = pwd;
        cd(trackman.itinerary.output_directory);
        [filename,pathname] = uigetfile({'*.m'},'Choose the settings-function');
        if exist(fullfile(pathname,filename),'file')
            [trackman.itinerary.settings_function{sInds}] = deal(char(regexp(filename,'.*(?=\.m)','match')));
        else
            disp('The settings-function selection was invalid.');
        end
        cd(mypwd);
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonSettingsUp_Callback(~,~)
        %%
        % What follows below might have a more elegant solution.
        % essentially all selected rows are moved up 1. This will only work
        % if all positions have the same settings
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        pInd = trackman.itinerary.indOfPosition(gInd);
        pInd = pInd(trackman.pointerPosition(1));
        if min(trackman.pointerSettings) == 1
            return
        end
        currentOrder = 1:trackman.itinerary.numberOfSettings(gInd,pInd); % what the table looks like now
        movingSettings = trackman.pointerSettings-1; % where the selected rows want to go
        reactingSettings = setdiff(currentOrder,trackman.pointerSettings); % the rows that are not moving
        fillmeinArray = zeros(1,length(currentOrder)); % a vector to store the new order
        fillmeinArray(movingSettings) = trackman.pointerSettings; % the selected rows are moved
        fillmeinArray(fillmeinArray==0) = reactingSettings; % the remaining rows are moved
        % use the fillmeinArray to rearrange the settings
        mySettingsOrderPrior = trackman.itinerary.orderOfSettings(gInd,pInd);
        mySettingsOrder = mySettingsOrderPrior(fillmeinArray);
        % change the order of the settings to rearrange the order of the
        trackman.itinerary.settings_binning(mySettingsOrderPrior) = trackman.itinerary.settings_binning(mySettingsOrder);
        trackman.itinerary.settings_channel(mySettingsOrderPrior) = trackman.itinerary.settings_channel(mySettingsOrder);
        trackman.itinerary.settings_exposure(mySettingsOrderPrior) = trackman.itinerary.settings_exposure(mySettingsOrder);
        trackman.itinerary.settings_function(mySettingsOrderPrior) = trackman.itinerary.settings_function(mySettingsOrder);
        trackman.itinerary.settings_gain(mySettingsOrderPrior) = trackman.itinerary.settings_gain(mySettingsOrder);
        trackman.itinerary.settings_period_multiplier(mySettingsOrderPrior) = trackman.itinerary.settings_period_multiplier(mySettingsOrder);
        trackman.itinerary.settings_timepoints(mySettingsOrderPrior) = trackman.itinerary.settings_timepoints(mySettingsOrder);
        trackman.itinerary.settings_z_origin_offset(mySettingsOrderPrior) = trackman.itinerary.settings_z_origin_offset(mySettingsOrder);
        trackman.itinerary.settings_z_stack_lower_offset(mySettingsOrderPrior) = trackman.itinerary.settings_z_stack_lower_offset(mySettingsOrder);
        trackman.itinerary.settings_z_stack_upper_offset(mySettingsOrderPrior) = trackman.itinerary.settings_z_stack_upper_offset(mySettingsOrder);
        trackman.itinerary.settings_z_step_size(mySettingsOrderPrior) = trackman.itinerary.settings_z_step_size(mySettingsOrder);
        %
        trackman.pointerSettings = movingSettings;
        trackman.itinerary.find_ind_last_group(gInd);
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonSettingsZLower_Callback(~,~)
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        pInd = trackman.itinerary.indOfPosition(gInd);
        pInd = pInd(trackman.pointerPosition(1));
        mySettingsOrder = trackman.itinerary.indOfSettings(gInd,pInd);
        sInd = mySettingsOrder(trackman.pointerSettings);
        trackman.mm.getXYZ;
        xyz = trackman.mm.pos;
        offset = trackman.itinerary.position_xyz(pInd,3)-xyz(3);
        if offset <0
            trackman.itinerary.settings_z_stack_lower_offset(sInd) = 0;
        else
            trackman.itinerary.settings_z_stack_lower_offset(sInd) = -offset;
        end
        trackman.refresh_gui_main;
    end
%%
%
    function pushbuttonSettingsZUpper_Callback(~,~)
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        pInd = trackman.itinerary.indOfPosition(gInd);
        pInd = pInd(trackman.pointerPosition(1));
        mySettingsOrder = trackman.itinerary.indOfSettings(gInd,pInd);
        sInd = mySettingsOrder(trackman.pointerSettings);
        trackman.mm.getXYZ;
        xyz = trackman.mm.pos;
        offset = xyz(3)-trackman.itinerary.position_xyz(pInd,3);
        if offset <0
            trackman.itinerary.settings_z_stack_upper_offset(sInd) = 0;
        else
            trackman.itinerary.settings_z_stack_upper_offset(sInd) = offset;
        end
        trackman.refresh_gui_main;
    end
%%
%
    function tableGroup_CellEditCallback(~, eventdata)
        %%
        % |trackman.pointerGroup| should always be a singleton in this case
        myCol = eventdata.Indices(2);
        myGroupOrder = trackman.itinerary.orderOfGroup;
        myRow = myGroupOrder(eventdata.Indices(1));
        switch myCol
            case 1 %label change
                if isempty(eventdata.NewData) || any(regexp(eventdata.NewData,'\W'))
                    return
                else
                    trackman.itinerary.group_label{myRow} = eventdata.NewData;
                end
        end
        trackman.refresh_gui_main;
    end
%%
%
    function tableGroup_CellSelectionCallback(~, eventdata)
        %%
        % The main purpose of this function is to keep the information
        % displayed in the table consistent with the Itinerary object.
        % Changes to the object either through the command line or the gui
        % can affect the information that is displayed in the gui and this
        % function will keep the gui information consistent with the
        % Itinerary information.
        %
        % The pointer of the TravelAgent should always point to a valid
        % group from the the group_order.
        if isempty(eventdata.Indices)
            % if nothing is selected, which triggers after deleting data,
            % make sure the pointer is still valid
            if any(trackman.pointerGroup > trackman.itinerary.numberOfGroup)
                % move pointer to last entry
                trackman.pointerGroup = trackman.itinerary.numberOfGroup;
            end
            return
        else
            trackman.pointerGroup = sort(unique(eventdata.Indices(:,1)));
        end
        trackman.refresh_gui_main;
    end
%%
%
    function tablePosition_CellEditCallback(~, eventdata)
        %%
        % |trackman.pointerPosition| should always be a singleton in this
        % case
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        myCol = eventdata.Indices(2);
        myPositionOrder = trackman.itinerary.orderOfPosition(gInd);
        myRow = myPositionOrder(eventdata.Indices(1));
        switch myCol
            case 1 %label change
                if isempty(eventdata.NewData) || any(regexp(eventdata.NewData,'\W'))
                    return
                else
                    trackman.itinerary.position_label{myRow} = eventdata.NewData;
                end
            case 3 %X
                trackman.itinerary.position_xyz(myRow,1) = eventdata.NewData;
            case 4 %Y
                trackman.itinerary.position_xyz(myRow,2) = eventdata.NewData;
            case 5 %Z
                trackman.itinerary.position_xyz(myRow,3) = eventdata.NewData;
            case 6 %PFS
                if strcmp(eventdata.NewData,'yes')
                    trackman.itinerary.position_continuous_focus_bool(myRow) = true;
                else
                    trackman.itinerary.position_continuous_focus_bool(myRow) = false;
                end
                trackman.itinerary.position_continuous_focus_bool(myPositionOrder) = trackman.itinerary.position_continuous_focus_bool(myRow);
            case 7 %PFS offset
                trackman.itinerary.position_continuous_focus_offset(myRow) = eventdata.NewData;
        end
        trackman.refresh_gui_main;
    end
%%
%
    function tablePosition_CellSelectionCallback(~, eventdata)
        %%
        % The main purpose of this function is to keep the information
        % displayed in the table consistent with the Itinerary object.
        % Changes to the object either through the command line or the gui
        % can affect the information that is displayed in the gui and this
        % function will keep the gui information consistent with the
        % Itinerary information.
        %
        % The pointer of the TravelAgent should always point to a valid
        % position from the the position_order in a given group.
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        if isempty(eventdata.Indices)
            % if nothing is selected, which triggers after deleting data,
            % make sure the pointer is still valid
            if any(trackman.pointerPosition > trackman.itinerary.numberOfPosition(gInd))
                % move pointer to last entry
                trackman.pointerPosition = trackman.itinerary.numberOfPosition(gInd);
            end
            return
        else
            trackman.pointerPosition = sort(unique(eventdata.Indices(:,1)));
        end
        %trackman.refresh_gui_main;
    end
%%
%
    function tableSettings_CellEditCallback(~, eventdata)
        %%
        % |trackman.pointerSettings| should always be a singleton in this
        % case
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        pInd = trackman.itinerary.indOfPosition(gInd);
        pInd = pInd(1);
        myCol = eventdata.Indices(2);
        mySettingsOrder = trackman.itinerary.orderOfSettings(gInd,pInd);
        myRow = mySettingsOrder(eventdata.Indices(1));
        switch myCol
            case 1 %channel
                trackman.itinerary.settings_channel(myRow) = find(strcmp(eventdata.NewData,trackman.mm.Channel));
            case 2 %exposure
                trackman.itinerary.settings_exposure(myRow) = eventdata.NewData;
            case 3 %binning
                trackman.itinerary.settings_binning(myRow) = eventdata.NewData;
            case 4 %gain
                trackman.itinerary.settings_gain(myRow) = eventdata.NewData;
            case 5 %Z step size
                trackman.itinerary.settings_z_step_size(myRow) = eventdata.NewData;
            case 6 %Z upper
                trackman.itinerary.settings_z_stack_upper_offset(myRow) = eventdata.NewData;
            case 7 %Z lower
                trackman.itinerary.settings_z_stack_lower_offset(myRow) = eventdata.NewData;
            case 9 %Z offset
                trackman.itinerary.settings_z_origin_offset(myRow) = eventdata.NewData;
            case 10 %period multiplier
                trackman.itinerary.settings_period_multiplier(myRow) = eventdata.NewData;
        end
        trackman.refresh_gui_main;
    end
%%
%
    function tableSettings_CellSelectionCallback(~, eventdata)
        %%
        % The |Travel Agent| aims to recreate the experience that
        % microscope users expect from a multi-dimensional acquistion tool.
        % Therefore, most of the customizability is masked by the
        % |TravelAgent| to provide a streamlined presentation and simple
        % manipulation of the |Itinerary|. Unlike the group and position
        % tables, which edit the itinerary directly, the settings table
        % will modify the the prototype, which will then be pushed to all
        % positions in a group.
        myGroupOrder = trackman.itinerary.orderOfGroup;
        gInd = myGroupOrder(trackman.pointerGroup(1));
        pInd = trackman.itinerary.indOfPosition(gInd);
        pInd = pInd(1);
        if isempty(eventdata.Indices)
            % if nothing is selected, which triggers after deleting data,
            % make sure the pointer is still valid
            if any(trackman.pointerSettings > trackman.itinerary.numberOfSettings(gInd,pInd))
                % move pointer to last entry
                trackman.pointerSettings = trackman.itinerary.numberOfSettings(gInd,pInd);
            end
            return
        else
            trackman.pointerSettings = sort(unique(eventdata.Indices(:,1)));
        end
        trackman.refresh_gui_main;
    end
end