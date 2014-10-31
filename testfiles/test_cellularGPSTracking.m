%% LAPJV
%
%% generate random data for tracking
%
nx = [10,20,40,80,160,320,640];
t = zeros(size(nx));
for j = 1:length(nx)
    n = nx(j);
    points1 = rand(n,2)*10;
    mybiasx = ones(n,1);
    mybiasy = ones(n,1);
    mybiasx(randsample(n,round(n/2))) = -1;
    mybiasy(randsample(n,round(n/2))) = -1;
    points2 = points1 + rand(n,2).*[mybiasx,mybiasy];
    %%%
    % delete some data from points2 to simulate disappearing centroids
    points2(randsample(n,round(0.1*n)),:) = [];
    %% find distance matrix
    %
    dm = cellularGPSTracking_distanceMatrix(points1,points2);
    %%% threshold the distances
    %
    dm(dm > quantile(dm(:),0.25)) = Inf;
    %% create cost matrix
    % The cost function in this example will be distance squared.
    dm11 = dm.*dm;
    dm12 = ones(size(points1,1),size(points1,1))*Inf;
    for i = 1:size(points1,1)
        dm12(i,i) = 1.05*max(dm11(i,:));
    end
    dm21 = ones(size(points2,1),size(points2,1))*Inf;
    for i = 1:size(points2,1)
        dm21(i,i) = 1.05*max(dm11(:,i));
    end
    cm = [dm11,dm12;dm21,ones(size(points2,1),size(points1,1))*Inf];
    %%
    %
    tic
    [ROWSOL,COST,v,u,rMat] = lapjv(cm);
    t(j) = toc;
    %% plot solution
    %
    mycolors = colormap(parula(n));
    myfig = figure;
    plot(points1(:,1),points1(:,2),'k.','MarkerSize',14);
    myax = gca;
    hold on
    plot(myax,points2(:,1),points2(:,2),'r.','MarkerSize',14);
    for i = 1:size(points1,1)
        if ROWSOL(i) <= size(points2,1)
            line([points1(i,1),points2(ROWSOL(i),1)],[points1(i,2),points2(ROWSOL(i),2)],'Parent',myax,'Color',mycolors(i,:),'LineWidth',1.5);
        else
            plot(myax,points1(i,1),points1(i,2),'o','MarkerSize',16,'Color',mycolors(i,:),'LineWidth',1.5);
        end
    end
    hold off
end
tLAPjv = t;
%% MUNKRES
%
%% generate random data for tracking
%
t = zeros(size(nx));
for j = 1:length(nx)
    n = nx(j);
    points1 = rand(n,2)*10;
    mybiasx = ones(n,1);
    mybiasy = ones(n,1);
    mybiasx(randsample(n,round(n/2))) = -1;
    mybiasy(randsample(n,round(n/2))) = -1;
    points2 = points1 + rand(n,2).*[mybiasx,mybiasy];
    %%%
    % delete some data from points2 to simulate disappearing centroids
    points2(randsample(n,round(0.1*n)),:) = [];
    %% find distance matrix
    %
    dm = cellularGPSTracking_distanceMatrix(points1,points2);
    %%% threshold the distances
    %
    dm(dm > quantile(dm(:),0.25)) = Inf;
    %% create cost matrix
    % The cost function in this example will be distance squared.
    dm11 = dm.*dm;
    dm12 = ones(size(points1,1),size(points1,1))*Inf;
    for i = 1:size(points1,1)
        dm12(i,i) = 1.05*max(dm11(i,:));
    end
    dm21 = ones(size(points2,1),size(points2,1))*Inf;
    for i = 1:size(points2,1)
        dm21(i,i) = 1.05*max(dm11(:,i));
    end
    cm = [dm11,dm12;dm21,ones(size(points2,1),size(points1,1))*Inf];
    %%
    %
    tic
    [ROWSOL,COST] = munkres(dm11);
    t(j) = toc;
    %% plot solution
    %
    mycolors = colormap(parula(n));
    myfig = figure;
    plot(points1(:,1),points1(:,2),'k.','MarkerSize',14);
    myax = gca;
    hold on
    plot(myax,points2(:,1),points2(:,2),'r.','MarkerSize',14);
    for i = 1:size(points1,1)
        if ROWSOL(i) ~= 0 && ROWSOL(i) <= size(points2,1) 
            line([points1(i,1),points2(ROWSOL(i),1)],[points1(i,2),points2(ROWSOL(i),2)],'Parent',myax,'Color',mycolors(i,:),'LineWidth',1.5);
        else
            plot(myax,points1(i,1),points1(i,2),'o','MarkerSize',16,'Color',mycolors(i,:),'LineWidth',1.5);
        end
    end
    hold off
end
tMunk = t;
%% MUNKRES without Inf
%
%% generate random data for tracking
%
t = zeros(size(nx));
for j = 1:length(nx)
    n = nx(j);
    points1 = rand(n,2)*10;
    mybiasx = ones(n,1);
    mybiasy = ones(n,1);
    mybiasx(randsample(n,round(n/2))) = -1;
    mybiasy(randsample(n,round(n/2))) = -1;
    points2 = points1 + rand(n,2).*[mybiasx,mybiasy];
    %%%
    % delete some data from points2 to simulate disappearing centroids
    points2(randsample(n,round(0.1*n)),:) = [];
    %% find distance matrix
    %
    dm = cellularGPSTracking_distanceMatrix(points1,points2);
    dm_max = max(dm(:));
    %% create cost matrix
    % The cost function in this example will be distance squared.
    dm11 = dm.*dm;
    dm12 = ones(size(points1,1),size(points1,1))*dm_max;
    for i = 1:size(points1,1)
        dm12(i,i) = 1.05*max(dm11(i,:));
    end
    dm21 = ones(size(points2,1),size(points2,1))*dm_max;
    for i = 1:size(points2,1)
        dm21(i,i) = 1.05*max(dm11(:,i));
    end
    cm = [dm11,dm12;dm21,ones(size(points2,1),size(points1,1))*dm_max];
    %%
    %
    tic
    [ROWSOL,COST] = munkres(cm);
    t(j) = toc;
    %% plot solution
    %
    mycolors = colormap(parula(n));
    myfig = figure;
    plot(points1(:,1),points1(:,2),'k.','MarkerSize',14);
    myax = gca;
    hold on
    plot(myax,points2(:,1),points2(:,2),'r.','MarkerSize',14);
    for i = 1:size(points1,1)
        if ROWSOL(i) <= size(points2,1)
            line([points1(i,1),points2(ROWSOL(i),1)],[points1(i,2),points2(ROWSOL(i),2)],'Parent',myax,'Color',mycolors(i,:),'LineWidth',1.5);
        else
            plot(myax,points1(i,1),points1(i,2),'o','MarkerSize',16,'Color',mycolors(i,:),'LineWidth',1.5);
        end
    end
    hold off
end
tMunk2 = t;
figure
plot(nx,tLAPjv,'g');
hold on
plot(nx,tMunk,'r');
plot(nx,tMunk2,'k');
legend({'LAPjv','Munk','Munk with no Inf'});