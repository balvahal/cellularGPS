%%
%
function trackman = cellularGPSTrackingManual_method_gui_smda_refresh(trackman)
handles = guidata(trackman.gui_smda);
%% Region 1
%
%% Output Directory
%
set(handles.editOutputDirectory,'String',trackman.moviePath);
%% Region 2
%
%% Group Table
% Show the data in the itinerary |group_order| property
tableGroupData = cell(trackman.itinerary.number_group,...
    length(get(handles.tableGroup,'ColumnName')));
n=0;
for i = trackman.itinerary.order_group
    n = n + 1;
    tableGroupData{n,1} = trackman.itinerary.group_label{i};
    tableGroupData{n,2} = i;
    tableGroupData{n,3} = trackman.itinerary.number_position(i);
end
set(handles.tableGroup,'Data',tableGroupData);
%% Region 3
%
%% Position Table
% Show the data in the itinerary |position_order| property for a given
% group
myGroupOrder = trackman.itinerary.order_group;
gInd = myGroupOrder(trackman.pointerGroup(1));
myPositionOrder = trackman.itinerary.order_position{gInd};
tablePositionData = cell(length(myPositionOrder),...
    length(get(handles.tablePosition,'ColumnName')));
n=0;
for i = myPositionOrder
    n = n + 1;
    tablePositionData{n,1} = trackman.itinerary.position_label{i};
    tablePositionData{n,2} = i;
    tablePositionData{n,3} = trackman.itinerary.position_xyz(i,1);
    tablePositionData{n,4} = trackman.itinerary.position_xyz(i,2);
    tablePositionData{n,5} = trackman.itinerary.position_xyz(i,3);
    tablePositionData{n,6} = trackman.itinerary.number_settings(i);
end
set(handles.tablePosition,'Data',tablePositionData);
%% Region 4
%
%% Settings Table
% Show the prototype_settings
pInd = trackman.itinerary.ind_position{gInd};
pInd = pInd(1);
mySettingsOrder = trackman.itinerary.order_settings{pInd};
tableSettingsData = cell(length(mySettingsOrder),...
    length(get(handles.tableSettings,'ColumnName')));
n=1;
for i = mySettingsOrder
    tableSettingsData{n,1} = trackman.itinerary.channel_names{trackman.itinerary.settings_channel(i)};
    tableSettingsData{n,2} = trackman.itinerary.settings_exposure(i);
    tableSettingsData{n,3} = i;
    n = n + 1;
end
set(handles.tableSettings,'Data',tableSettingsData);
%% Trackman indices
myGroupOrder = trackman.itinerary.order_group;
trackman.indG = myGroupOrder(trackman.pointerGroup(1));
myPositionOrder = trackman.itinerary.ind_position{gInd};
trackman.indP = myPositionOrder(trackman.pointerPosition(1));
mySettingsOrder = trackman.itinerary.ind_settings{pInd};
trackman.indS = mySettingsOrder(trackman.pointerSettings(1));
trackman.updateFilenameListImage;
end