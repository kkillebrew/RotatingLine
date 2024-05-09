%% Analysis of 2AFC rotating line

clear all
close all

datadir = '/Users/C-Lab/Google Drive/Lab Projects/RotatingLine/RotatingLine_Exp/Data/2AFC_Acc/';

partID = {'EK','JS','RT'};

fileID = {'EK_RotatingLine_2AFC_ACC_031517_001','JS_RotatingLine_2AFC_ACC_031517_001','RT_RotatingLine_2AFC_ACC_031517_001'};

% Experiment variables
rotSpeed = [30 45 55 60 65 75 90];   
accRate = [0 15 30 45 60 75 90 105 120];
sizeList = [1 2];   % 1=long 2=short
numSize = length(sizeList);
speedList = [1 2 3 4 5 6 7];   % 1=slowest 7=fastest
numSpeed = length(speedList);
accList = [1 2 3 4 5 6 7 8 9];    % 1=no acceleration 5=double acc 9 = triple acc
numAcc = length(accList);

for n=1:length(partID)
    
    %% Load in participants
    load(sprintf('%s%s',datadir,fileID{n}));
    
    %% BLOCK 1    
    % Number of trials in which they said test was faster than compare for each
    % speed
    for i=1:numSize   % 1=long test 2=short test
        for j=1:numSpeed
            numFaster1(i,j) = sum(rawdata1(and(rawdata1(:,3)==i,rawdata1(:,4)==j),10));
            numTotal1(i,j) = sum(rawdata1(:,3)==i & rawdata1(:,4)==j);
            percentFaster1(i,j) = numFaster1(i,j)/numTotal1(i,j);
        end
    end
    
    % Calculate curve fit and PSE values
    x_axis = rotSpeed;
    xx_axis = 30:.001:90;
    
    lineColor{1} = [1 0 0];
    lineColor{2} = [0 0 1];
    lineColor{3} = [0 1 0];
    lineColor{4} = [1 0 1];
    
    for i=1:length(rotSpeed)
        speedTitle{i}  = num2str(rotSpeed(i));
    end
    
    figure()
    subplot(1,2,1)   % Plot the curves
    for i=1:2
        datafit(:,:,i) = [numFaster1(i,:)',numTotal1(i,:)'];
        b(:,i) = glmfit(x_axis',datafit(:,:,i),'binomial','logit');
        fitdata(:,i) = 100 * exp(b(1,i) + b(2,i) * xx_axis') ./ (1 + exp(b(1,i) + b(2,i) * xx_axis'));
        PSE(n,i) = -b(1,i)/b(2,i);
        
        % Plot
        h(i) = plot(x_axis,100*percentFaster1(i,:)','Color',lineColor{i},'LineWidth',2);   % Plot the rawdata
        set(gca,'ylim',[0,100]);
        set(gca,'xtick',rotSpeed,'xTickLabels',speedTitle);
        hold on;
        plot(x_axis,50*ones(length(x_axis),1),'k--','LineWidth',2);   % Plot the 50% line
        plot(xx_axis,fitdata(:,i)','Color',lineColor{i},'LineWidth',2);    % Plot the curve fit
        plot(PSE(n,i)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the PSE
    end
    
    legend(h([1 2]),'Long','Short');
    
    subplot(1,2,2)   % Plot the PSEs
    b = bar(PSE(n,:));
    set(gca,'xticklabel',{'Long' 'Short'});
    set(gca,'ylim',[0,100]);
    bChild = get(b,'Children');
    set(bChild,'FaceVertexCData',[1 0 0; 0 0 1]);

    % Create variable to store arrays for group lvl analysis
    groupPercentFaster(n,:,:) = percentFaster1(:,:);
    groupNumFaster(n,:,:) = numFaster1(:,:);
    groupNumTotal1(n,:,:) = numTotal1(:,:);
        
    %% BLOCK 2
    
    % Number of trials in which they said test was faster than compare for each
    % speed
    for j=1:numAcc
        numChanged2(j) = sum(rawdata2(rawdata2(:,3)==j,7));
        numTotal2(j) = sum(rawdata2(:,3)==j);
        percentChanged2(j) = numChanged2(j)/numTotal2(j);
    end
    
    clear x_axis xx_axis speedTitle
    % Calculate curve fit and PSE values
    x_axis = accRate;
    xx_axis = 30:.001:90;
    
    for i=1:numAcc
        speedTitle{i}  = num2str(accRate(i));
    end
    
    figure()
    plot(x_axis,100*percentChanged2(:)','LineWidth',2);   % Plot the rawdata
    set(gca,'ylim',[0,100]);
    set(gca,'xtick',accRate,'xTickLabels',speedTitle);
    
    % Create variable to store arrays for group lvl analysis
    groupPercentChanged(n,:) = percentChanged2(:);
    groupNumChanged(n,:) = numChanged2(:);
    groupNumTotal2(n,:) = numTotal2(:);
    
    % Clear variables
    clear rawdata1 rawdata2 numFaster1 percentFaster1 x_axis xx_axis numChanged2 numTotal2 percentChanged2 datafit b fitdata 
    
end

%% Group Lvl

% BLOCK 1
meanPercentFaster = squeeze(mean(groupPercentFaster,1));
stePercentFaster = squeeze(ste(groupPercentFaster,1));
meanNumFaster = squeeze(mean(groupNumFaster,1));
steNumFaster = squeeze(ste(groupNumFaster,1));
meanNumTotal1 = squeeze(mean(groupNumTotal1,1));
steNumTotal1 = squeeze(ste(groupNumTotal1,1));

x_axis = rotSpeed;
xx_axis = 30:.001:90;

% Find PSE using the group averaged data
figure()
for i=1:2
    datafitMean(:,:,i) = [meanNumFaster(i,:)',meanNumTotal1(i,:)'];
    bMean(:,i) = glmfit(x_axis',datafitMean(:,:,i),'binomial','logit');
    fitdataMean(:,i) = 100 * exp(bMean(1,i) + bMean(2,i) * xx_axis') ./ (1 + exp(bMean(1,i) + bMean(2,i) * xx_axis'));
    PSEMean(i) = -bMean(1,i)/bMean(2,i);
    
    % Plot
    subplot(1,2,1)   % Plot the curves
    h(i) = plot(x_axis,100*meanPercentFaster(i,:)','Color',lineColor{i},'LineWidth',2);   % Plot the rawdata
    set(gca,'ylim',[0,100]);
    set(gca,'xtick',rotSpeed,'xTickLabels',speedTitle);
    hold on;
    plot(x_axis,50*ones(length(x_axis),1),'k--','LineWidth',2);   % Plot the 50% line
    plot(xx_axis,fitdataMean(:,i)','Color',lineColor{i},'LineWidth',2);    % Plot the curve fit
    plot(PSEMean(i)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the PSE
end

legend(h([1 2]),'Long','Short');

subplot(1,2,2)   % Plot the PSEs
b = bar(PSEMean);
hold on
errorbar(PSEMean,ste(PSE,1),'.k');
set(gca,'xticklabel',{'Long' 'Short'});
set(gca,'ylim',[0,100]);
bChild = get(b,'Children');
set(bChild,'FaceVertexCData',[1 0 0; 0 0 1]);


% BLOCK 2
meanPercentChanged = mean(groupPercentChanged,1);
stePercentChanged = ste(groupPercentChanged,1);
meanNumChanged = mean(groupNumChanged,1);
meanNumTotal2 = mean(groupNumTotal2,1);

clear x_axis xx_axis speedTitle
% Calculate curve fit and PSE values
x_axis = accRate;
xx_axis = 30:.001:90;
for i=1:numAcc
    speedTitle{i}  = num2str(accRate(i));
end

figure()
plot(x_axis,100*meanPercentChanged(:)','LineWidth',2);   % Plot the rawdata
hold on
errorbar(x_axis,100*meanPercentChanged(:)',100*stePercentChanged(:)','.k')
set(gca,'ylim',[0,100]);
set(gca,'xtick',accRate,'xTickLabels',speedTitle);





