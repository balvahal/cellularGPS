%% parameters
%
movementThreshold = 50;
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
trackCounter = height(centroidCell{1})+1;
trackID = transpose(1:height(centroidCell{1}));
trackCostMax = ones(height(myCentroid),1)*movementThreshold^2;
myCentroid = centroidCell{1};
myCentroid.trackID = trackID;
myCentroid.trackCost = trackCostMax;
centroidCell{1} = myCentroid;
%%%
% the cost matrix for the first timepoint cannot take into account any
% prior tracking or position information
for i = 2:length(mytime) %loop 1
    centroid1lp1 = centroidCell{i-1};
    Mlp1 = centroid1lp1{:,{'centroid_col','centroid_row'}};
    centroid2lp1 = centroidCell{i};
    Nlp1 = centroid2lp1{:,{'centroid_col','centroid_row'}};
    distM = cellularGPSTracking_distanceMatrix(Mlp1,Nlp1);
    distM(distM>movementThreshold) = -1;
    costM11 = distM;
    costM12 = ones(size(Mlp1,1),size(Mlp1,1))*-1;
    for j = 1:size(Mlp1,1) %loop 1 in loop 1
            costM12(j,j) = trackCostMax(j);
    end
    costM21 = ones(size(Nlp1,1),size(Nlp1,1))*-1;
    costNoLink = max(costM12(:));
    for j = 1:size(Nlp1,1)
        costM21(j,j) = costNoLink;
    end
    costM = [costM11,costM12;costM21,ones(size(Nlp1,1),size(Mlp1,1))*costNoLink];
    costM(costM == -1) = Inf;
    [ROWSOL,COST,v,u,rMat] = lapjv(costM);
    %%
    %
    trackID = zeros(size(Nlp1,1),1);
    trackCostOld = trackCostMax;
    trackCostMax  = zeros(size(Nlp1,1),1);
    trackCost = zeros(size(Nlp1,1),1);
for j = 1:size(Mlp1,1)
    if ROWSOL(j) <= size(Nlp1,1)
        trackID(ROWSOL(j)) = centroid1lp1.trackID(j);
        trackCost(ROWSOL(j)) = costM(j,ROWSOL(j));
            if costM(j,ROWSOL(j)) > trackCostOld(j)/1.05 || i == 1
                trackCostMax(ROWSOL(j)) = 1.05*costM(j,ROWSOL(j)); 
            else
                trackCostMax(ROWSOL(j)) = trackCostOld(j);
            end
    end
end
trackCostMax(trackCostMax == 0) = median(trackCostMax(trackCostMax ~= 0));
for j = find(trackID == 0)
        trackID(j) = trackCounter;
        trackCounter = trackCounter + 1;
        trackCost(j) = trackCostMax(j);
end
centroid2lp1.trackID = trackID;
centroid2lp1.trackCost = trackCost;
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
i = 0;
for j = 1:length(trackID)
    mylogical = masterCentroid.trackID == trackID(j);
    tracklength(j) = sum(mylogical);
%     if tracklength(j) < 50
%         continue
%     else
%         i = i+1
%     end
    myrow = masterCentroid.centroid_row(mylogical);
    mycol = masterCentroid.centroid_col(mylogical);
    mytime = masterCentroid.timepoint(mylogical);
    output = sortrows([mytime,mycol,myrow]);
    plot(output(:,2),output(:,3),'Color',[rand rand rand],'LineWidth',1.5);
end
hold off
myax = gca;
set(myax,'ydir','reverse')