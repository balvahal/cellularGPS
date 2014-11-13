%% LAPJV
%
%% generate random data for tracking
%
nx = [80,120,160,200,240,280,320];
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
%% fit curves
% and predict how long it would take to compute LAP for 200 positions with
% 200 timepoints and a 1000 x 1000 cost matrix.
mymodel = @(b,x) b(1)*x.^(b(2));
beta0 = [.00001,3];
dataLAPjv = table(nx',tLAPjv','VariableNames',{'dim','time'});
dataMunk = table(nx',tMunk','VariableNames',{'dim','time'});
dataMunk2 = table(nx',tMunk2','VariableNames',{'dim','time'});
mdlLAPjv = fitnlm(dataLAPjv,mymodel,beta0);
mdlMunk = fitnlm(dataMunk,mymodel,beta0);
mdlMunk2 = fitnlm(dataMunk2,mymodel,beta0);
%% plot results
figure
plot(nx,log(tLAPjv)/log(10),'go');
hold on
plot(nx,log(tMunk)/log(10),'ro');
plot(nx,log(tMunk2)/log(10),'ko');
legend({sprintf('LAPjv %1.2f',mdlLAPjv.Coefficients.Estimate(2)),...
    sprintf('Munk %1.2f',mdlMunk.Coefficients.Estimate(2)),...
    sprintf('Munk no Inf %1.2f',mdlMunk2.Coefficients.Estimate(2))});
plot(nx,log10(mymodel(mdlLAPjv.Coefficients.Estimate,nx)),'g');
plot(nx,log10(mymodel(mdlMunk.Coefficients.Estimate,nx)),'r');
plot(nx,log10(mymodel(mdlMunk2.Coefficients.Estimate,nx)),'k');