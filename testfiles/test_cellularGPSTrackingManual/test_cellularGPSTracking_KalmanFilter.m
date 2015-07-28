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
myCentroid.speed = zeros(height(myCentroid),1);
centroidCell{1} = myCentroid;
%%
% kalman filter variables
kf.A = [1,1,0,0;0,1,0,0;0,0,1,1;0,0,0,1];
kf.R = diag([4,9,4,9]); % estimated from tracking data without Kalman filter
kf.U = 0; % there is no input
kf.B = 0; % there is no input
kf.Q = eye(4); % assume measurement error of centroid is 1 pixel
kf.H = eye(4); % measurement is the same a process
kf.I = eye(4);
kf.Ppri = [2,1,0,0;1,2,0,0;0,0,2,1;0,0,1,2]; % estimated from applying Kalman filter to a test track
kfcellM = repmat({kf},height(myCentroid),1);
 for i = 1:size(myCentroid,1)
     mykf = kfcellM{i};
     mykf.Xpri = [myCentroid.centroid_col(i);0;myCentroid.centroid_row(i);0];
     kfcellM{i} = mykf;
 end
%% cost matrix
% the cost matrix for the first timepoint cannot take into account any
% prior tracking or position information
for i = 2:length(mytime) %loop 1
    centroidM = centroidCell{i-1};
    Mlp1 = centroidM{:,{'centroid_col','centroid_row'}};
    centroidN = centroidCell{i};
    Nlp1 = centroidN{:,{'centroid_col','centroid_row'}};
    masterCentroidlp1 = vertcat(centroidCell{1:i-1});
    %%% Kalman filter: linear motion
    % time update, predict
    predictlp1 = zeros(size(Mlp1));
    for j = 1:size(Mlp1,1)
        mykf = kfcellM{j};
        mykf = cellularGPSTracking_Kalman_Predict(mykf);
        predictlp1(j,1) = mykf.Xpredict(1);
        predictlp1(j,2) = mykf.Xpredict(3);
        kfcellM{j} = mykf;
    end
    %distM = cellularGPSTracking_distanceMatrix(Mlp1,Nlp1);
    distM = cellularGPSTracking_distanceMatrix(predictlp1,Nlp1);
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
    trackSpeed = zeros(size(Nlp1,1),1);
    kfcellN = cell(size(Nlp1,1),1);
    distM3 = cellularGPSTracking_distanceMatrix(Mlp1,Nlp1);
    for j = 1:size(Mlp1,1)
        if ROWSOL(j) <= size(Nlp1,1)
            trackID(ROWSOL(j)) = centroidM.trackID(j);
            trackCost(ROWSOL(j)) = costM11(j,ROWSOL(j));
            trackDisplacement(ROWSOL(j)) = distM3(j,ROWSOL(j));
            %%% kalman filter
            % measurement update, correct
            mykf = kfcellM{j};
            mykf.Z = [Nlp1(ROWSOL(j),1);Nlp1(ROWSOL(j),1)-Mlp1(j,1);Nlp1(ROWSOL(j),2);Nlp1(ROWSOL(j),2)-Mlp1(j,2)];
            mykf = cellularGPSTracking_Kalman_Correct(mykf);
            mykf = cellularGPSTracking_Kalman_Predict_update(mykf);
            %mykf.Xpri(1) = Nlp1(ROWSOL(j),1);
            %mykf.Xpri(3) = Nlp1(ROWSOL(j),2);
            kfcellN{ROWSOL(j)} = mykf;
            trackSpeed(ROWSOL(j)) = norm([mykf.Xpost(2),mykf.Xpost(4)]);
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
        %%% kalman filter
        % measurement update, correct
        kf.Xpri = [Nlp1(j,1);0;Nlp1(j,2);0];
        kfcellN{j} = kf;
    end
    centroidN.trackID = trackID;
    centroidN.trackCost = trackCost;
    centroidN.displacement = trackDisplacement;
    centroidN.speed = trackSpeed;
    centroidCell{i} = centroidN;
    kfcellM = kfcellN;
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
xlp2 = {};
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
        %%% persistence length
        % what is the length/time scale that cells travel in the same
        % direction? cos = exp(-t/P). P is the persistence length. The
        % persistence length is important when estimating the velocity, for
        % choosing the start point and end point might not be accurate if
        % the time between is > persistence length.
        %%% estimate the process noise
        % the process noise is the fluctuation of accelerations, because a
        % change in velocity is acceleration and a change in position is a
        % fluctuation in velocity.
        i = i+1;
        trackID(j)
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

%%%
% looking at the mean and standard deviation of alp2 and xlp2
% reveals zero mean, but the distributions from this test case are not
% gaussian, as the noise does not have as much spread. The x noise is also
% dependent on the cells not changing directions throughout the trace. By
% eyeballing the data it looks like cells might change direction, although
% not randomly, 2 to 3 times, so the noise in x is likely an overestimate.
a = vertcat(alp2{:});
x = vertcat(xlp2{:});
x = x(:);
a = a(:);
[ha,pa] = kstest(a/std(a))
[hx,px] = kstest(x/std(x))
