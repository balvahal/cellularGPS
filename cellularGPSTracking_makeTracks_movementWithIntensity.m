function [] = cellularGPSTracking_makeTracks_movementWithIntensity(moviePath)
trackingProfile = loadjson(fullfile(moviePath,'cGPS_trackingProfile.txt'));
cenTable = readtable(fullfile(moviePath,'centroid_measurements.txt'),'Delimiter','\t');
positionNumber = transpose(unique(cenTable.position_number));
tablePathOut = fullfile(moviePath,'TRACKING_DATA');
if ~isdir(tablePathOut)
    mkdir(tablePathOut);
end
%% find tracks for centroids in each position
%
for i = positionNumber
    %% sort out centroids for each timepoint
    % sorting timepoints in descending order means the tracking will be
    % performed in reverse time.
    cenTablePosition = cenTable(cenTable.position_number == i,:);
    mytime = sort(unique(cenTablePosition.timepoint),'descend');
    centroidCell = cell(size(mytime));
    for j = 1:length(mytime)
        centroidCell{j} = sortrows(cenTablePosition(cenTablePosition.timepoint == mytime(j),:),{'centroid_col','centroid_row'},{'ascend','ascend'});
    end
    %% initialize the tracking variables with the first set of centroids
    %
    centroidPrime = centroidCell{1};
    trackCounter = height(centroidPrime)+1;
    trackID = transpose(1:height(centroidPrime));
    trackCostMax = 0;
    centroidPrime.trackID = trackID;
    centroidPrime.trackCost = zeros(height(centroidPrime),1);
    centroidPrime.displacement = zeros(height(centroidPrime),1);
    centroidPrime.speed = zeros(height(centroidPrime),1);
    centroidCell{1} = centroidPrime;
    %%% setup the starting conditions for the kalman filter
    % The starting conditions are stored within a JSON file. These
    % conditions include the model and covariance matrices for process and
    % measurement noise, which have been estimated from previous tracking
    % data.
    kf = trackingProfile.kalmanFilter;
    %%% replicate a Kalman filter for every track.
    % the variable suffix *M* denotes the data is sourced from the _t-1_
    % timepoint. *N* denotes the data is sourced from the _t_ timepoint.
    % After a round of tracking the *N* data will become the *M* data.
    kfcellM = repmat({kf},height(centroidPrime),1);
    for j = 1:size(centroidPrime,1)
        mykf = kfcellM{j};
        mykf.Xpri = [centroidPrime.centroid_col(j);0;centroidPrime.centroid_row(j);0];
        kfcellM{j} = mykf;
    end
    %% link tracks using the global solution to a cost matrix
    % based upon the Jaqaman-Danuser 2008 Nat. Methods paper
    for j = 2:length(mytime) %loop 1
        %%% find centroids
        % find the centroids for the _t-1_ and _t_ timepoints
        centroidM = centroidCell{j-1};
        centroidN = centroidCell{j};
        posM = centroidM{:,{'centroid_col','centroid_row'}};
        posN = centroidN{:,{'centroid_col','centroid_row'}};
        masterCentroid = vertcat(centroidCell{1:j-1});
        %%% Kalman filter: linear motion
        % time update, predict
        predictlp1 = zeros(size(posM));
        for k = 1:size(posM,1)
            mykf = kfcellM{k};
            mykf = cellularGPSTracking_Kalman_Predict(mykf);
            predictlp1(k,1) = mykf.Xpredict(1);
            predictlp1(k,2) = mykf.Xpredict(3);
            kfcellM{k} = mykf;
        end
        %distM = cellularGPSTracking_distanceMatrix(posM,posN);
        distM = cellularGPSTracking_distanceMatrix(predictlp1,posN);
        %%% particle specific distance thresholds
        % * track specific movement threshold is 3x the standard deviation of
        % previous links
        % * local density threshold is half the distance to its nearest
        % neighbor
        distM2 = cellularGPSTracking_distanceMatrix(posM,posM);
        for k = 1:size(posM,1)
            displacementlp1 = masterCentroid.displacement(masterCentroid.trackID == trackID(k));
            if length(displacementlp1) > 5
                tsmthresh = mean(displacementlp1) + 2*std(displacementlp1);
            else
                displacementlp1 = masterCentroid.displacement;
                tsmthresh = mean(displacementlp1) + 2*std(displacementlp1);
            end
            distM2row = sort(distM2(k,:));
            ldthresh = 0.5*distM2row(2);
            finalthresh = max([ldthresh,tsmthresh,trackingProfile.distance.movementThresholdMaxMin]);
            distMrow = distM(k,:);
            distMrow(distMrow>finalthresh) = Inf;
            distM(k,:) = distMrow;
        end
        %%% costM11
        %
        costM11 = distM.^2;
        costM11(costM11>trackingProfile.distance.movementThresholdMax^2) = -1;
        %%%
        % this is to initialize the trackCostMax
        if j==2 && any(costM11(:)~=-1)
            trackCostMax = prctile(costM11(costM11~=-1),80);
        end
        %%% costM12
        %
        costM12 = ones(size(posM,1),size(posM,1))*-1;
        for k = 1:size(posM,1) %loop 1 in loop 1
            costM12(k,k) = trackCostMax;
        end
        %%% costM21
        %
        costM21 = ones(size(posN,1),size(posN,1))*-1;
        for k = 1:size(posN,1)
            costM21(k,k) = trackCostMax;
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
        [ROWSOL,~,~,~,~] = lapjv(costM);
        %%
        %
        trackID = zeros(size(posN,1),1);
        trackCost = zeros(size(posN,1),1);
        trackDisplacement = zeros(size(posN,1),1);
        trackSpeed = zeros(size(posN,1),1);
        kfcellN = cell(size(posN,1),1);
        distM3 = cellularGPSTracking_distanceMatrix(posM,posN);
        for k = 1:size(posM,1)
            if ROWSOL(k) <= size(posN,1)
                trackID(ROWSOL(k)) = centroidM.trackID(k);
                trackCost(ROWSOL(k)) = costM11(k,ROWSOL(k));
                trackDisplacement(ROWSOL(k)) = distM3(k,ROWSOL(k));
                %%% kalman filter
                % measurement update, correct
                mykf = kfcellM{k};
                mykf.Z = [posN(ROWSOL(k),1);posN(ROWSOL(k),1)-posM(k,1);posN(ROWSOL(k),2);posN(ROWSOL(k),2)-posM(k,2)];
                mykf = cellularGPSTracking_Kalman_Correct(mykf);
                mykf = cellularGPSTracking_Kalman_Predict_update(mykf);
                %mykf.Xpri(1) = posN(ROWSOL(k),1);
                %mykf.Xpri(3) = posN(ROWSOL(k),2);
                kfcellN{ROWSOL(k)} = mykf;
                trackSpeed(ROWSOL(k)) = norm([mykf.Xpost(2),mykf.Xpost(4)]);
            end
        end
        if max(trackCost) > trackCostMax
            trackCostMax = max(trackCost);
        end
        for k = transpose(find(trackID == 0))
            trackID(k) = trackCounter;
            trackCounter = trackCounter + 1;
            trackCost(k) = costM21(k,k);
            trackDisplacement(k) = 0;
            %%% kalman filter
            % measurement update, correct
            kf.Xpri = [posN(k,1);0;posN(k,2);0];
            kfcellN{k} = kf;
        end
        centroidN.trackID = trackID;
        centroidN.trackCost = trackCost;
        centroidN.displacement = trackDisplacement;
        centroidN.speed = trackSpeed;
        centroidCell{j} = centroidN;
        kfcellM = kfcellN;
    end
    positionCentroid = vertcat(centroidCell{:});
    positionCentroid2 = positionCentroid(:,{'trackID','timepoint','centroid_row','centroid_col'});
    positionCentroid2 = horzcat(positionCentroid2,table(zeros(height(positionCentroid2),1),zeros(height(positionCentroid2),1),zeros(height(positionCentroid2),1),zeros(height(positionCentroid2),1),'VariableNames',{'value','parent','division_start','division_end'})); %#ok<AGROW>
    tablename = sprintf('trackingPosition_%d.txt',i);
    writetable(positionCentroid2,fullfile(tablePathOut,tablename),'Delimiter','\t');
    %% plot data for feedback purposes
    %
    figure;
    hold on
    masterCentroid = vertcat(centroidCell{:});
    trackID = unique(masterCentroid.trackID);
    tracklength = zeros(size(trackID));
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
        plot(output(:,2),output(:,3),'Color',[rand rand rand],'LineWidth',1.5);
    end
    hold off
    myax = gca;
    set(myax,'ydir','reverse')
    sum(tracklength > 50)
end

end