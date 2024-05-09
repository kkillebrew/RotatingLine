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
    datadir = '/Users/C-Lab/Google Drive/Lab Projects/RotatingLine/RotatingLine_Exp/Data/2AFC_Acc_180_rot/';
elseif testComp == 1
    datadir = '/Users/gideon/Documents/Kyle/Rotating Line/Data/2AFC_Acc_180_rot/';
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
stairList = [1];  % number of staircases
numStair = length(stairList);
startList = [1 2];   % Starting from the 1=bottom or 2=top of staircase
numStart = length(startList);
accList = [1 2 3 4 5 6 7 8 9];
numAcc = length(accList);
repetitions = 20;

varList = repmat(fullfact([numStair numStart]),[repetitions,1]);
trialOrder = randperm(length(varList));

% Preallocate rawdata files
rawdata = zeros(length(trialOrder),7);

numTrials = length(varList); % Total number of trials

% Set up the staircase
% Need 3 arrays: 1 that determines the step you are on in the staircase (stepCount), 1
% that tells you what the participant answered previously (prevAns), and 1 that keeps
% track of reversals (placeList).
for j=1:numStair    % Number of staircases
    for k=1:numStart    % Starting from the 1=bottom or 2=top of staircase
        if k==1   % Starting at the bottom of staircase
            stepCount(j,k)=1;   % Sets the value of stepCount at the greatest acceleration until they choose another val
            prevAns(j,k)=2;     % Line was judged as accelerating
        elseif k==2       % Starting at the top of staircase
            stepCount(j,k)=numAcc;     % Sets the value of stepCount at the greatest decceleration until they choose another val
            prevAns(j,k)=1;     % Line was judged as deccelerating
        end
        placeList(j,k)=1;             % If you had a reversal add one to place list
    end
end

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

% Eliptical aperture
apLengthEl = round(apSize/2);
apHeightEl = round(apSize);
n = rect(4); % size of matrix, odd
n2 = floor(n/2) ;
[x,y] = meshgrid(-n2:n2);

Rl = apLengthEl/2; % width
Rh = apHeightEl/2; % length
M = ((x - 0) / Rh) .^2    +   ((y - 0) / Rl) .^2     <= 1;
M = double(M) ; % convert from logical to double
alphaLayer = ~double(M)*255;
elipseApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,4) = alphaLayer;
apTexture(1) = Screen('MakeTexture',w,elipseApertureArray);

% Max length of the radius
maxLength = apHeightEl;

% Line texture
gratingArray = zeros(imSize)+gray;
gratingArray(:,round(imSize/2)) = 0;
gratingTexture=Screen('MakeTexture', w, gratingArray);

% Rotation variables
rotSpeed = 60;   % number of degrees / second

% Acceleration variables (as a function of rotational speed)
accRate = [0 .25 .5 .75 1 2 3 4 5];   % Constant value

%% Instructions
Screen('TextSize',w,25);
text='For each trial you will see a line rotating 180 degrees.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
text='Determine whether or not the speed of the line is changing or constant.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
text='If you thought it''s speed was changing speed press ''F''.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-100,tColor);
text='If you thought it was rotating at a constant speed press ''J''.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0,tColor);
text='Press any key to begin.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+100,tColor);
text='Would you like to do some practice trials? (Press ''Y'')';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+200,tColor);
text='Press ''N'' to begin the experiment.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+300,tColor);

Screen('Flip',w);

[keyIsDown, secs, keycode] = KbCheck(dev_ID);
while 1
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    if keycode(buttonY)
        rotLinePractice_2AFC_Acc_180_rot(w,rect,dev_ID,x0,y0,tColor,buttonF,buttonJ,rotSpeed,hz,apLengthEl,apHeightEl,apTexture,gratingTexture,accRate,texX1,texY1,texX2,texY2,numPracTrials);
        break
    elseif keycode(buttonN)
        break
    end
end

% Instructions
Screen('TextSize',w,25);
text='For each trial you will see a line rotating 180 degrees.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
text='Determine whether or not the speed of the line is changing or constant.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
text='If you thought it''s speed was changing speed press ''F''.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-100,tColor);
text='If you thought it was rotating at a constant speed press ''J''.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0,tColor);
text='Press any key to begin.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+100,tColor);
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
    this_b = 0;
    for b1 = break_trials
        if trialNumCounter==round(b1*length(trialOrder))
            this_b = b1;
            break
        end
    end
    trialNumCounter = trialNumCounter+1;
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
    
    % Which staircase am I on?
    stairIdx = varList(n,1);
    rawdata(n,3) = stairIdx;
    
    % Where is the staircase starting? (max modulation or min modulation)
    startIdx = varList(n,2);
    rawdata(n,4) = startIdx;
    
    % Determine which acc to use based on staircase
    accIdx = stepCount(stairIdx,startIdx);
    rawdata(n,5) = accIdx;
    
    % Determine the direction of rotation
    rotDir = randi(2);
    
    % Reset the orientation
    if rotDir == 1   % rotate clockwise
        orientation = -90;
        dirVal = 1;
    elseif rotDir == 2   % rotate counter-clockwise
        orientation = 90;
        dirVal = -1;
    end
    
    % Determine what constant value to use based on the position in the
    % staircase
    constant = accRate(accIdx);
    
    disp(sprintf('%s%d','Constant value of: ',constant));
    disp(sprintf('%s%d','Staircase #: ',stairIdx));
    disp(sprintf('%s%d','Start position: ',startIdx));
    
    % Set the texture list (lineTex, largeTex, ~elipTex)
    texList = [gratingTexture, apTexture(1)];
    texLocList = [texX1 texY1 texX2 texY2; x0-rect(4)/2,0,x0+rect(4)/2,rect(4)]';
    texRotList = [orientation, 0];
    
    % Determine the fixed speed (how much you want to rotate per screen
    % flip or actualspeed = rotspeed/hz
    baseSpeed = rotSpeed/hz;
    
    % Initialize variables
    radialLength = sqrt( 1 / ( ( sind(orientation)/apHeightEl )^2 + ( cosd(orientation)/apLengthEl )^2 ) );
    
    % Change the speed as a function of the length of the radius
    actualSpeed = ((((maxLength/radialLength) - 1) * constant) + baseSpeed) * dirVal;
    
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
        radialLength = sqrt( 1 / ( ( sind(orientation)/apHeightEl )^2 + ( cosd(orientation)/apLengthEl )^2 ) );
        
        % Change the speed as a function of the length of the radius
        actualSpeed = ((((maxLength/radialLength) - 1) * constant) + baseSpeed) * dirVal;
        
        orientationLast = orientation;
        orientation = orientationLast + actualSpeed;
        texRotList(1)=orientation;
        
        orientationDiff = orientationLast - orientation;
        
        if orientation >= 90 && rotDir == 1   % start at -90 and rotate clockwise to 90
            break
        elseif orientation <= -90 && rotDir == 2   % start at 90 and rotate counter-clockwise to -90
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
            rawdata(n,6) = 2;
            break
        end
    end
    
    % Update staircase lists to determine which stimui to present next
    % for that staircase depending on participants response.
    if rawdata(n,6)==1    % choose changing
        if prevAns(stairIdx,startIdx)==2   % States that on the last trial, choose constant
            reversalList(stairIdx,startIdx,placeList(stairIdx,startIdx))=1;   % Keep track of the reversals
            placeList(stairIdx,startIdx)=placeList(stairIdx,startIdx)+1;
            rawdata(n,7)=1;   % reversal
        else
            rawdata(n,7)=0;   % reversal?
        end
        prevAns(stairIdx,startIdx)=1;
        % They choose changing so make stim speed more constant
        stepCount(stairIdx,startIdx)=min(stepCount(stairIdx,startIdx)-1,numAcc);
        
    elseif rawdata(n,6)==2   %  choose constant
        if prevAns(stairIdx,startIdx)==2
            rawdata(n,7)=0;
        else
            reversalList(stairIdx,startIdx,placeList(stairIdx,startIdx))=1;
            placeList(stairIdx,startIdx)=placeList(stairIdx,startIdx)+1;
            rawdata(n,7)=1;
        end
        
        prevAns(stairIdx,startIdx)=2;
        % They choose constant so make stim speed change more
        stepCount(stairIdx,startIdx)=max(stepCount(stairIdx,startIdx)-1,1);
        
    end
    
    
    %save trial information on each trial
%     save(sprintf('%s%s',datadir,datafile),'rawdata1','rawdata2');
    
end

%% End the experiment
% save two files: 1 for rawdata and 2 that holds all the variables you
% created
% save(sprintf('%s%s',datadir,datafile),'rawdata1','rawdata2');
% save(sprintf('%s%s',datadir,datafile_full));

Screen('CloseAll')
ListenChar(0);
ShowCursor;

% Plot the staircases
for i=1:length(accRate)
    accTitle{i}  = num2str(accRate(i));
end

lineColor{1} = [1 0 0];
lineColor{2} = [0 0 1];
lineColor{3} = [0 1 0];
lineColor{4} = [1 0 1];

% Create 4 lists for each staircase
holderRawdata = sortrows(rawdata,2);   % Sort rawdata based on order of presentation
counter = 0;
figure()
for  i=1:numStair
    for j=1:numStart
        counter = counter+1;
        holderData = holderRawdata((holderRawdata(:,3)==i & holderRawdata(:,4)==j),:);
        stairData(:,i,j) = holderData(:,5);
        plot(1:repetitions,accRate(stairData(:,i,j)),'Color',lineColor{counter},'LineWidth',2);
        hold on
        set(gca,'ytick',accRate);
        set(gca,'xtick',1:repetitions);
    end
end

% save(sprintf('%s%s',datadir,datafile_full));








