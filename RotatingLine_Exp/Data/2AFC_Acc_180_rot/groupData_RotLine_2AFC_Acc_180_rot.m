% Takes group averages for both parts of the exp. Part 1 takes average of
% all participant data points then fits a sig curve and takes the PSE. 
% Part 2 takes average of all participant data points and fits a parabola
% and finds the largest point (PSE).

clear all
close all

% Experiment variables
sizeList = [1 2];   % 1=long 2=short
numSize = length(sizeList);
speedList = [1 2 3 4 5 6 7];   % 1=slowest 7=fastest
numSpeed = length(speedList);
rotSpeed = [30 45 55 60 65 75 90];

accList = [1 2 3 4 5 6 7 8 9];    % 1=no modulation 5=double modulation 9 = triple modulation
numAcc = length(accList);
accRate = [0 .25 .5 .75 1 2 3 4 5];   % Constant value

% Participant lists
partID = {'MT','SG','AK','SG2','EK'};
% partID = {'MT','SG'};

rawdataID = {'MT_RotatingLine_2AFC_ACC_180_rot_040317_001','SG_RotatingLine_2AFC_ACC_180_rot_040317_001',...
    'AK_RotatingLine_2AFC_ACC_180_rot_040317_001','SG2_RotatingLine_2AFC_ACC_180_rot_040317_001','EK_RotatingLine_2AFC_ACC_180_rot_040517_001'};
% rawdataID = {'MT_RotatingLine_2AFC_ACC_180_rot_040317_001','SG_RotatingLine_2AFC_ACC_180_rot_040317_001'};

fileID = '/Users/C-Lab/Google Drive/Lab Projects/RotatingLine/RotatingLine_Exp/Data/2AFC_Acc_180_rot/';

%% Part 1

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

% Average together the data from part 1
for n=1:length(partID)
    
    load(sprintf('%s',fileID,rawdataID{n},'/'));
    
    % Number of trials in which they said test was faster than compare for each
    % speed
    for i=1:numSize   % 1=long test 2=short test
        for j=1:numSpeed
            numFaster(n,i,j) = sum(rawdata1(and(rawdata1(:,3)==i,rawdata1(:,4)==j),10));
            numTotal(n,i,j) = sum(rawdata1(:,3)==i & rawdata1(:,4)==j);
            percentFaster(n,i,j) = numFaster(n,i,j)/numTotal(n,i,j);
        end
    end
    
    figure()
    subplot(1,2,1)
    for i=1:2
        datafitTemp(:,:,i) = [squeeze(numFaster(n,i,:)),squeeze(numTotal(n,i,:))];
        bTemp(:,i) = glmfit(x_axis',datafitTemp(:,:,i),'binomial','logit');
        fitdata(:,i) = 100 * exp(bTemp(1,i) + bTemp(2,i) * xx_axis') ./ (1 + exp(bTemp(1,i) + bTemp(2,i) * xx_axis'));
        PSETemp(n,i) = -bTemp(1,i)/bTemp(2,i);
        
        
        % Plot participant data
        h(n,i) = plot(x_axis,100*squeeze(percentFaster(n,i,:))','Color',lineColor{i},'LineWidth',2);   % Plot the rawdata
        hold on
        set(gca,'ylim',[0,100]);
        set(gca,'xtick',rotSpeed,'xTickLabels',speedTitle);
        plot(x_axis,50*ones(length(x_axis),1),'k--','LineWidth',2);   % Plot the 50% line
        plot(xx_axis,fitdata(:,i)','Color',lineColor{i},'LineWidth',2);    % Plot the curve fit
        plot(PSETemp(n,i)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the PSE
        
    end
    legend(h(n,[1 2]),'Long','Short');
    
    % Plot the PSEs
    subplot(1,2,2)   
    p = bar(PSETemp(n,:));
    hold on
    set(gca,'xticklabel',{'Long' 'Short'});
    set(gca,'ylim',[0,100]);
    bChild = get(p,'Children');
    set(bChild,'FaceVertexCData',[1 0 0; 0 0 1]);
end

aveNumFaster = squeeze(mean(numFaster,1));
steNumFaster = squeeze(ste(numFaster,1));
aveNumTotal = squeeze(mean(numTotal,1));
steNumTotal = squeeze(ste(numTotal,1));
avePercentFaster = squeeze(mean(percentFaster,1));
stePercentFaster = squeeze(ste(percentFaster,1));

avePSE = squeeze(mean(PSETemp,1));
stePSE = squeeze(ste(PSETemp,1));

% Calculate the curve fit and extract PSE
figure()
subplot(1,2,1)   % Plot the curves
for i=1:2
    datafit(:,:,i) = [aveNumFaster(i,:)',aveNumTotal(i,:)'];
    b(:,i) = glmfit(x_axis',datafit(:,:,i),'binomial','logit');
    fitdata(:,i) = 100 * exp(b(1,i) + b(2,i) * xx_axis') ./ (1 + exp(b(1,i) + b(2,i) * xx_axis'));
    PSE(i) = -b(1,i)/b(2,i);
    
    % Plot
    h(i) = plot(x_axis,100*avePercentFaster(i,:)','Color',lineColor{i},'LineWidth',2);   % Plot the rawdata
    set(gca,'ylim',[0,100]);
    set(gca,'xtick',rotSpeed,'xTickLabels',speedTitle);
    hold on;
    errorbar(x_axis,100*avePercentFaster(i,:)',100*stePercentFaster(i,:)','.k')
    plot(x_axis,50*ones(length(x_axis),1),'k--','LineWidth',2);   % Plot the 50% line
    plot(xx_axis,fitdata(:,i)','Color',lineColor{i},'LineWidth',2);    % Plot the curve fit
    plot(PSE(i)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the PSE
end

% Plot the PSEs
legend(h([1 2]),'Long','Short');

subplot(1,2,2)   % Plot the PSEs
p = bar(PSE(:));
hold on
errorbar(PSE(:),stePSE(:),'.k');
set(gca,'xticklabel',{'Long' 'Short'});
set(gca,'ylim',[0,100]);
bChild = get(p,'Children');
set(bChild,'FaceVertexCData',[1 0 0; 0 0 1]);


%% Part 2

clearvars -except sizeList numSize speedList numSpeed rotSpeed accList numAcc accRate partID rawdataID fileID

% Calculate curve fit and PSE values
x_axis = accRate;
xx_axis = 30:.001:90;

% for i=1:numAcc
%     speedTitle{i}  = num2str(accRate(i));
% end
speedTitle = {'60-60','60-75','60-90','60-105','60-120','60-180','60-240','60-300','60-360'};

% Average together the data from part 2
for n=1:length(partID)
    
    load(sprintf('%s',fileID,rawdataID{n},'/'));
    
    rawdata2(:,7) = ~rawdata2(:,7);
    
    % Number of trials in which they said test was faster than compare for each
    % speed
    for j=1:numAcc
        numChanged(n,j) = sum(rawdata2(rawdata2(:,3)==j,7));
        numTotal(n,j) = sum(rawdata2(:,3)==j);
        percentFaster(n,j) = numChanged(n,j)/numTotal(n,j);
    end
    
    figure()
    plot(x_axis,100*percentFaster(n,:),'LineWidth',2);
    xlabel('Number of times test reported as modulating more.');
    ylabel('Amount of modulation (degrees/second).');
    set(gca,'ylim',[0,100],'xlim',[-1,accRate(9)+1]);
    set(gca,'xtick',accRate,'xTickLabels',speedTitle);   
end

avePercentFaster = squeeze(mean(percentFaster,1));
stePercentFaster = squeeze(ste(percentFaster,1));

% Plot the average data

figure()
plot(x_axis,100*avePercentFaster(:),'LineWidth',2);   
hold on
errorbar(x_axis,100*avePercentFaster(:),100*stePercentFaster,'.k')
% plot(xx_axis,fitdata2(:,1),'LineWidth',2);    % Plot the curve fit
xlabel('Number of times test reported as modulating more.');
ylabel('Amount of modulation (degrees/second).');
set(gca,'ylim',[0,100],'xlim',[-1,accRate(9)+1]);
set(gca,'xtick',accRate,'xTickLabels',speedTitle);








