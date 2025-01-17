% 080817 - Rotating line experiment to determine the modulation rate that nulls the rotating line illusion.

%% Initialization variables
clear all;
close all;

labComp = 1;
testComp =0;

Screen('Preference', 'SkipSyncTests', 1);

rng('shuffle')

c = clock;
time_stamp = sprintf('%02d/%02d/%04d %02d:%02d:%02.0f',c(2),c(3),c(1),c(4),c(5),c(6)); % month/day/year hour:min:sec
datecode = datestr(now,'mmddyy');
experiment = 'RotatingLine_Stair_Acc_180';

% get input
subjid = input('Enter Subject Code:','s');
runid  = input('Enter Run:');
if labComp == 1
    datadir = '/Users/C-Lab/Google Drive/Lab Projects/RotatingLine/RotatingLine_Exp/Data/2AFC_Acc_NullPoint/';
elseif testComp == 1
    datadir = '/Users/gideon/Documents/Kyle/Rotating Line/Data/2AFC_Acc_NullPoint/';
end

datafile=sprintf('%s_%s_%s_%03d',subjid,experiment,datecode,runid);
datafile_full=sprintf('%s_full',datafile);

% check to see if this file exists
if exist(fullfile(datadir,[datafile '.mat']),'file')
    tmpfile = input('File exists.  Overwrite? y/n:','s');
    while ~ismember(tmpfile,{'n' 'y'})
        tmpfile = input('Invalid choice. File exists.  Overwrite? y/n:','s');
    end
    if strcmp(tmpfile,'n')
        display('Bye-bye...');
        return; % will need to start over for new input
    end
end

ListenChar(2);
HideCursor;

%% Monitor Variables
backColor = [128 128 128];
tColor = [0 0 0];

if labComp == 1
    [w,rect] = Screen('OpenWindow',1,backColor);
    screenWide=1024;
    screenHigh=768;
    hz=60;
elseif testComp == 1
    oldScreen=Screen('Resolution',1);
    screenWide=1024;
    screenHigh=768;
    hz=120;
    Screen('Resolution',1,screenWide,screenHigh,hz);
    [w,rect] = Screen('OpenWindow',1,backColor);
end

% PPD stuff
mon_width_cm = 40;
mon_dist_cm = 73;
mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
PPD = (screenWide/mon_width_deg);

x0 = rect(3)/2;
y0 = rect(4)/2;

break_trials = 0:.33:.66;

Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Find the color values which correspond to white and black: Usually
% black is always 0 and white 255, but this rule is not true if one of
% the high precision framebuffer modes is enabled via the
% PsychImaging() commmand, so we query the true values via the
% functions WhiteIndex and BlackIndex:
white=WhiteIndex(w);BlackIndex(w);
black=BlackIndex(w);

% Round gray to integral number, to avoid roundoff artifacts with some
% graphics cards:
gray=round((white+black)/2);

% This makes sure that on floating point framebuffers we still get a
% well defined gray. It isn't strictly neccessary in this demo:
if gray == white
    gray=white / 2;
end

% Contrast 'inc'rement range for given white and gray values:
inc=white-gray;

% Define the keypresses
buttonJ = KbName('j');
buttonF = KbName('f');
buttonY = KbName('y');
buttonN = KbName('n');

if labComp == 1
    [nums, names] = GetKeyboardIndices;
    dev_ID=nums(1);
elseif testComp == 1
    [nums, names] = GetKeyboardIndices;
    dev_ID=nums(2);
end

%% Trial Variables
% Number of practice trials
numPracTrials = 10;

% Condition Lists
speedList = [1 2];
numSpeed = length(speedList);
apOriList = [1 2];
numApOri = length(apOriList);
accList = [1 2 3 4 5 6 7 8 9];
numAcc = length(accList);
repetitions = 20;

varList = repmat(fullfact([numSpeed numApOri numAcc]),[repetitions,1]);
trialOrder = randperm(length(varList));

% Preallocate rawdata files
rawdata = zeros(length(trialOrder),6);

numTrials = length(varList); % Total number of trials

totalTime=GetSecs;

%% Stimulus variables

% Size variables
imSize = 500;

% Texture variables
texX1 = x0-imSize/2;
texY1 = y0-imSize/2;
texX2 = x0+imSize/2;
texY2 = y0+imSize/2;

% Aperture variables
apSize = 10*PPD;

clear Rl Rh M alphLayer circleApertureArray

% Horizontal elliptical aperture
apLengthEl(1) = round(apSize/2);
apHeightEl(1) = round(apSize);
n = rect(4); % size of matrix, odd
n2 = floor(n/2) ;
[x,y] = meshgrid(-n2:n2);

Rl = apLengthEl(1)/2; % width
Rh = apHeightEl(1)/2; % length
M = ((x - 0) / Rh) .^2    +   ((y - 0) / Rl) .^2     <= 1;
M = double(M) ; % convert from logical to double
alphaLayer = ~double(M)*255;
elipseApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,4) = alphaLayer;
apTexture(1) = Screen('MakeTexture',w,elipseApertureArray);

% Max length of the radius
maxLength = apHeightEl(1);

clear Rl Rh M alphLayer circleApertureArray

% Vertical elliptical aperture
apLengthEl(2) = round(apSize);
apHeightEl(2) = round(apSize/2);
n = rect(4); % size of matrix, odd
n2 = floor(n/2) ;
[x,y] = meshgrid(-n2:n2);

Rl = apLengthEl(2)/2; % width
Rh = apHeightEl(2)/2; % length
M = ((x - 0) / Rh) .^2    +   ((y - 0) / Rl) .^2     <= 1;
M = double(M) ; % convert from logical to double
alphaLayer = ~double(M)*255;
elipseApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,4) = alphaLayer;
apTexture(2) = Screen('MakeTexture',w,elipseApertureArray);

% Line texture
gratingArray = zeros(imSize)+gray;
gratingArray(:,round(imSize/2)) = 0;
gratingTexture=Screen('MakeTexture', w, gratingArray);

% Rotation variables
rotSpeed = [30 60];   % number of degrees / second

% Acceleration variables (as a function of rotational speed)
% accRate = [-.75 0 .5 .7 .85 1 1.15 1.3 1.5 2 2.75];   % Constant value
accRate = [.75 1.5 1.75 1.9 2.0 2.1 2.25 2.5 3.25];

%% Instructions
Screen('TextSize',w,15);
text='For each trial you will see a line rotating 180 degrees.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-400,tColor);
text='Determine whether or not the speed of the line is changing or constant.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
text='If you thought it was changing speed press ''F''.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
text='If you thought it was rotating at a constant speed press ''J''.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-100,tColor);
text='Press any key to begin.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0,tColor);
text='Would you like to do some practice trials? (Press ''Y'')';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+100,tColor);
text='Press ''N'' to begin the experiment.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+200,tColor);

Screen('Flip',w);

[keyIsDown, secs, keycode] = KbCheck(dev_ID);
while 1
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    if keycode(buttonY)
        rotLinePractice_2AFC_NullPoint(w,rect,dev_ID,x0,y0,tColor,buttonF,buttonJ,rotSpeed,hz,apLengthEl,apHeightEl,maxLength,apTexture,gratingTexture,accRate,texX1,texY1,texX2,texY2,numPracTrials);
        break
    elseif keycode(buttonN)
        break
    end
end

% Instructions
Screen('TextSize',w,15);
text='For each trial you will see a line rotating 180 degrees.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-400,tColor);
text='Determine whether or not the speed of the line is changing or constant.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
text='If you thought it was changing speed press ''F''.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
text='If you thought it was rotating at a constant speed press ''J''.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-100,tColor);
text='Press any key to begin.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0,tColor);
Screen('Flip',w);

WaitSecs(.5);
while 1
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    if keyIsDown
        break
    end
end

trialNumCounter=0;

[keyIsDown, secs, keycode] = KbCheck(dev_ID);

%% Experiment start
for n=trialOrder
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    
    % Give participants breaks
    trialNumCounter = trialNumCounter+1;
    this_b = 0;
    for b1 = break_trials
        if trialNumCounter==round(b1*numTrials)
            this_b = 1;
            break
        end
    end
    if this_b
        % display break message
        text=sprintf('You have completed %d%% of the trials.',round(b1*100));
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
        text='Press any key when you are ready to continue.';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-100,tColor);
        Screen('Flip',w);
        disp(this_b);
        disp((GetSecs-totalTime)/60);
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        KbReleaseWait(dev_ID);
        while 1
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            if keyIsDown
                break
            end
        end
    end
    
    rawdata(n,1) = n;   % Actual trial number
    
    rawdata(n,2)=trialNumCounter;   % Order of presentation
    trialNumCounter=trialNumCounter+1;
    
    % Determine which speed to use
    speedIdx = varList(n,1);
    rawdata(n,3) = speedIdx;
    
    % Determine which aperture orientation to use
    apOriIdx = varList(n,2);
    rawdata(n,4) = apOriIdx;
    
    % Determine which acc to use
    accIdx = varList(n,3);
    rawdata(n,5) = accIdx;
        
    % Determine the direction of rotation
    rotDir(n) = randi(2);
    
    % Reset the orientation
    if rotDir(n) == 1   % rotate clockwise
        orientation = -90;
        dirVal = 1;
    elseif rotDir(n) == 2   % rotate counter-clockwise
        orientation = 90;
        dirVal = -1;
    end
    
    % Determine what constant value to use based on the position in the
    % staircase
    constant = accRate(accIdx);
    
    % Set the texture list (lineTex, largeTex, ~elipTex)
    texList = [gratingTexture, apTexture(apOriIdx)];
    texLocList = [texX1 texY1 texX2 texY2; x0-rect(4)/2,0,x0+rect(4)/2,rect(4)]';
    texRotList = [orientation, 0];
    
    % Determine the fixed speed (how much you want to rotate per screen
    % flip or actualspeed = rotspeed/hz
    baseSpeed = rotSpeed(speedIdx)/hz;
    
    % Initialize variables
    radialLength = sqrt( 1 / ( ( sind(orientation)/apHeightEl(apOriIdx) )^2 + ( cosd(orientation)/apLengthEl(apOriIdx) )^2 ) );
    
    % Change the speed as a function of the length of the radius
    actualSpeed = (baseSpeed + ((maxLength./radialLength)-1)*(constant-1)*baseSpeed)*dirVal;
    
    % Present Stimuli
    startTimer = GetSecs;
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    while 1
        
        % Draw
        Screen('DrawTextures', w, texList, [], texLocList, texRotList)
        
        % Fixation spot
        Screen('FillOval',w,[0 255 0],[x0-3,y0-3,x0+3,y0+3]);
        Screen('FillOval',w,[0 0 0],[x0-1.5,y0-1.5,x0+1.5,y0+1.5]);
        
        Screen('Flip',w);
        
        % Keep track of the radius length to calculate current speed
        radialLength = sqrt( 1 / ( ( sind(orientation)/apHeightEl(apOriIdx) )^2 + ( cosd(orientation)/apLengthEl(apOriIdx) )^2 ) );
        
        % Change the speed as a function of the length of the radius
        actualSpeed = (baseSpeed + ((maxLength./radialLength)-1)*(constant-1)*baseSpeed)*dirVal;
        
        orientation = orientation + actualSpeed;
        texRotList(1)=orientation;
                
        if orientation >= 90 && rotDir(n) == 1   % start at -90 and rotate clockwise to 90
            break
        elseif orientation <= -90 && rotDir(n) == 2   % start at 90 and rotate counter-clockwise to -90
            break
        end
        
    end

    % Response
    text='Was the line changing speed?';
    width=RectWidth(Screen('TextBounds',w,text));
    Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
    text='Press ''F'' for changing speed or ''J'' for constant speed.';
    width=RectWidth(Screen('TextBounds',w,text));
    Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
    Screen('Flip',w);
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    while 1
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        if keycode(buttonF)   % they choose changing speed
            rawdata(n,6) = 1;
            break
        elseif keycode(buttonJ)   % they choose constant speed
            rawdata(n,6) = 0;
            break
        end
    end
    
    Screen('Flip',w);
    WaitSecs(.5);
    
    %save trial information on each trial
    save(sprintf('%s%s',datadir,datafile),'rawdata');
    
end

%% End the experiment
% save two files: 1 for rawdata and 2 that holds all the variables you
% created
save(sprintf('%s%s',datadir,datafile),'rawdata');
save(sprintf('%s%s',datadir,datafile_full));

Screen('CloseAll')
ListenChar(0);
ShowCursor;

%% Analysis

% rawdata(1) = actual trial number
% rawdata(2) = order of presentation
% rawdata(3) = speed index
% rawdata(4) = aperture index
% rawdata(5) = accelration index
% rawdata(6) = response 1=chose changing 2=chose constant

% Determine how many times they reported each speed as 'changing'
for i=1:numAcc
    for j=1:numSpeed
        for k=1:numApOri
            numChanging(i,j,k) = sum(rawdata(rawdata(:,3)==j & rawdata(:,4)==k & rawdata(:,5)==i,6));
        end
    end
end

% Change to proportion
propChanging = (numChanging./repetitions).*100;

figure()
subplot(1,2,1)
plot(propChanging(:,1,1),'Color','r')
hold on
plot(propChanging(:,2,1),'Color','g')
set(gca,'fontsize',15);
ylim([0 100])
title('Horizontal Aperture');
xlabel('Acceleration Ratios');
ylabel('Proportion of Times Reported As Modulating');
subplot(1,2,2)
plot(propChanging(:,1,2),'Color','r')
hold on
plot(propChanging(:,2,2),'Color','g')
set(gca,'fontsize',15);
ylim([0 100])
title('Vertical Aperture');
xlabel('Acceleration Ratios');
ylabel('Proportion of Times Reported As Modulating');
legend('30�/s','60�/s');

figure()
avePropChanging = mean(mean(propChanging,3),2);
plot(avePropChanging);
% set(gca,'YLim',0:100);
ylim([0 100])
title('Average Across Speed and Aperture');
xlabel('Acceleration Ratios');
ylabel('Proportion of Times Reported As Modulating');

% 
% % Plot the staircases
% for i=1:length(accRate)
%     accTitle{i}  = num2str(accRate(i));
% end
% 
% lineColor{1} = [1 0 0];
% lineColor{2} = [0 0 1];
% lineColor{3} = [0 1 0];
% lineColor{4} = [1 0 1];
% 
% % Create 4 lists for each staircase
% holderRawdata = sortrows(rawdata,2);   % Sort rawdata based on order of presentation
% counter = 0;
% figure()
% for  i=1:numStair
%     for j=1:numStart
%         counter = counter+1;
%         holderData = holderRawdata((holderRawdata(:,3)==i & holderRawdata(:,4)==j),:);
%         stairData(:,i,j) = holderData(:,5);
%         plot(1:repetitions,accRate(stairData(:,i,j)),'Color',lineColor{counter},'LineWidth',2);
%         hold on
%         set(gca,'ytick',accRate);
%         set(gca,'xtick',1:repetitions);
%     end
% end

% save(sprintf('%s%s',datadir,datafile_full));








