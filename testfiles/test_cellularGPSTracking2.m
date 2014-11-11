%% parameters
%
movementThresholdMax = 30;
movementThresholdMaxMin = 10;
%% Load centroids
%
[mfilepath,~,~] = fileparts(mfilename('fullpath')); %finds the path to this script
cenTable = readtable(fullfile(mfilepath,'centroid_measurements.txt'),'Delimiter','\t');
%% parse apart the centroid table
% currently this is not necessaryNum = unique(cenTable.position_number);
%%
% go backwards in time, because merging events are more obvious then
% divisions.
mytime = sort(unique(cenTable.timepoint),'descend');
centroidCell = cell(size(mytime));
for i = 1:length(mytime)
    centroidCell{i} = sortrows(cenTable(cenTable.timepoint == mytime(i),:),{'centroid_col','centroid_row'},{'ascend','ascend'});
end
myCentroid = centroidCell{1};
trackCounter = height(myCentroid)+1;
trackID = transpose(1:height(myCentroid));
trackCostMax = 0;
myCentroid.trackID = trackID;
myCentroid.trackCost = zeros(height(myCentroid),1);
myCentroid.displacement = zeros(height(myCentroid),1);
centroidCell{1} = myCentroid;
%%
% kalman filter variables
    s.A = [1,1,0,0;0,1,0,0;0,0,1,1;0,0,0,1];
    s.R = eye(4);
    s.P = eye(4);
    s.u = 0;
    s.B = 0;
    s.Q = zeros(4);
    s.H = eye(4);
%% cost matrix
% the cost matrix for the first timepoint cannot take into account any
% prior tracking or position information
for i = 2:length(mytime) %loop 1
    centroid1lp1 = centroidCell{i-1};
    Mlp1 = centroid1lp1{:,{'centroid_col','centroid_row'}};
    centroid2lp1 = centroidCell{i};
    Nlp1 = centroid2lp1{:,{'centroid_col','centroid_row'}};
    masterCentroidlp1 = vertcat(centroidCell{1:i-1});
    %%% Kalman filter: linear motion
    %
    
    
    distM = cellularGPSTracking_distanceMatrix(Mlp1,Nlp1);
    %%% particle specific distance thresholds
    % * track specific movement threshold is 3x the standard deviation of
    % previous links
    % * local density threshold is half the distance to its nearest
    % neighbor
    distM2 = cellularGPSTracking_distanceMatrix(Mlp1,Mlp1);
    for j = 1:size(Mlp1,1)
        displacementlp1 = masterCentroidlp1.displacement(masterCentroidlp1.trackID == trackID(j));
        if length(displacementlp1) > 5
            tsmthresh = mean(displacementlp1) + 2*std(displacementlp1);
        else
            displacementlp1 = masterCentroidlp1.displacement;
            tsmthresh = mean(displacementlp1) + 2*std(displacementlp1);
        end
        distM2row = sort(distM2(j,:));
        ldthresh = 0.5*distM2row(2);
        finalthresh = max([ldthresh,tsmthresh,movementThresholdMaxMin]);
        distMrow = distM(j,:);
        distMrow(distMrow>finalthresh) = Inf;
        distM(j,:) = distMrow;
    end
    %%% costM11
    %
    costM11 = distM.^2;
    costM11(costM11>movementThresholdMax^2) = -1;
    %%%
    % this is to initialize the trackCostMax
    if i==2 && any(costM11(:)~=-1)
        trackCostMax = prctile(costM11(costM11~=-1),80);
    end
    %%% costM12
    %
    costM12 = ones(size(Mlp1,1),size(Mlp1,1))*-1;
    for j = 1:size(Mlp1,1) %loop 1 in loop 1
        costM12(j,j) = trackCostMax;
    end
    %%% costM21
    %
    costM21 = ones(size(Nlp1,1),size(Nlp1,1))*-1;
    for j = 1:size(Nlp1,1)
        costM21(j,j) = trackCostMax;
    end
    %%% costM22
    % The minimum value of the costM11 at the values of the transpose of
    % costM11.
    costM22 = transpose(costM11);
    costM22(costM22 ~= -1) = min([min(costM11(costM11 ~= -1)),min(diag(costM12)),min(diag(costM21))]);
    %%% assemble the cost matrix
    %
    costM = [costM11,costM12;costM21,costM22];
    costM(costM == -1) = Inf;
    [ROWSOL,COST,v,u,rMat] = lapjv(costM);
    %%
    %
    trackID = zeros(size(Nlp1,1),1);
    trackCost = zeros(size(Nlp1,1),1);
    trackDisplacement = zeros(size(Nlp1,1),1);
    for j = 1:size(Mlp1,1)
        if ROWSOL(j) <= size(Nlp1,1)
            trackID(ROWSOL(j)) = centroid1lp1.trackID(j);
            trackCost(ROWSOL(j)) = costM11(j,ROWSOL(j));
            trackDisplacement(ROWSOL(j)) = distM(j,ROWSOL(j));
        end
    end
    if max(trackCost) > trackCostMax
        trackCostMax = max(trackCost);
    end
    for j = transpose(find(trackID == 0))
        trackID(j) = trackCounter;
        trackCounter = trackCounter + 1;
        trackCost(j) = costM21(j,j);
        trackDisplacement(j) = 0;
    end
    centroid2lp1.trackID = trackID;
    centroid2lp1.trackCost = trackCost;
    centroid2lp1.displacement = trackDisplacement;
    centroidCell{i} = centroid2lp1;
end
%% plot solution
%
myfig = figure;
hold on
masterCentroid = vertcat(centroidCell{:});
trackID = unique(masterCentroid.trackID);
mycolors = colormap(parula(length(trackID)));
tracklength = zeros(size(trackID));
vlp2 = {};
xlp2 = {}
i = 0;
for j = 1:length(trackID) % loop2
    mylogical = masterCentroid.trackID == trackID(j);
    tracklength(j) = sum(mylogical);
    if tracklength(j) == 1
        myrow = masterCentroid.centroid_row(mylogical);
        mycol = masterCentroid.centroid_col(mylogical);
        mytime = masterCentroid.timepoint(mylogical);
        output = sortrows([mytime,mycol,myrow]);
        plot(output(:,2),output(:,3),'o','Color',[rand rand rand],'LineWidth',1.5);
        continue
    end
    myrow = masterCentroid.centroid_row(mylogical);
    mycol = masterCentroid.centroid_col(mylogical);
    mytime = masterCentroid.timepoint(mylogical);
    output = sortrows([mytime,mycol,myrow]);
    if tracklength(j) > 50
        %%% estimate the process noise
        % the process noise is the fluctuation of accelerations, because a
        % change in velocity is acceleration and a change in position is a
        % fluctuation in velocity.
        i = i+1
        alp2{i} = output(3:end,2:3)-2*output(2:end-1,2:3)+output(1:end-2,2:3);
        vlp2 = mean(diff(output(:,2:3)));
        xlp2{i} = output(2:end,2:3) - (output(1:end-1,2:3)+repmat(vlp2,size(output,1)-1,1));
    end
    plot(output(:,2),output(:,3),'Color',[rand rand rand],'LineWidth',1.5);
end
hold off
myax = gca;
set(myax,'ydir','reverse')
sum(tracklength > 50)