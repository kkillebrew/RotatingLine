% Rotating line experiment 3/15/17

%% Initialization variables
clear all;
close all;

labComp = 1;
testComp =0;

if testComp == 1
    Screen('Preference', 'SkipSyncTests', 1);
end

rng('shuffle')

c = clock;
time_stamp = sprintf('%02d/%02d/%04d %02d:%02d:%02.0f',c(2),c(3),c(1),c(4),c(5),c(6)); % month/day/year hour:min:sec
datecode = datestr(now,'mmddyy');
experiment = 'RotatingLine_2AFC_ACC_180_rot';

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

% Block type 1 (speed judgement)
sizeList = [1 2];   % 1=long 2=short
numSize = length(sizeList);
speedList = [1 2 3 4 5 6 7];   % 1=slowest 7=fastest
numSpeed = length(speedList);
repetitions1 = 20;

% Block type 2 (modulated speed judgement)
accList = [1 2 3 4 5 6 7 8 9];    % 1=no modulation 5=double modulation 9 = triple modulation
numAcc = length(accList);
repetitions2 = 20;

varList1 = repmat(fullfact([numSize numSpeed]),[repetitions1,1]);
trialOrder1 = randperm(length(varList1));
varList2 = repmat(fullfact([numAcc]),[repetitions2,1]);
trialOrder2 = randperm(length(varList2));

% Preallocate rawdata files
rawdata1 = zeros(length(trialOrder1),10);
rawdata2 = zeros(length(trialOrder2),7);  

% Block variables
blockList = [1 2];   % Total number of blocks for each type
numBlock = length(blockList);
blockTypeList = [1 2];   % Block type 1 or 2
numBlockType = length(blockTypeList);

numTrials = length(varList1)+length(varList2); % Total number of trials

% Determine the order of block presentation and create trialOrder
count1 = 1;
count2 = 1;
counter = 1;
for i=1:2:numBlock*numBlockType
    blockOrder(i:i+1) = randperm(numBlockType);
    
    if blockOrder(i:i+1)==1:2
        for j=1:length(trialOrder1)/numBlock
            trialOrder(counter,1) = trialOrder1(count1);
            trialOrder(counter,2) = 1;
            count1=count1+1;
            counter=counter+1;
        end
        for j=1:length(trialOrder2)/numBlock
            trialOrder(counter,1) = trialOrder2(count2);
            trialOrder(counter,2) = 2;
            count2=count2+1;
            counter=counter+1;
        end
    elseif blockOrder(i:i+1)==2:-1:1
        for j=1:length(trialOrder2)/numBlock
            trialOrder(counter,1) = trialOrder2(count2);
            trialOrder(counter,2) = 2;
            count2=count2+1;
            counter=counter+1;
        end
        for j=1:length(trialOrder1)/numBlock
            trialOrder(counter,1) = trialOrder1(count1);
            trialOrder(counter,2) = 1;
            count1=count1+1;
            counter=counter+1;
        end
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

% Large aperture
apLength = apSize;
apHeight = apSize;
n = rect(4); % size of matrix, odd
n2 = floor(n/2) ;
[x,y] = meshgrid(-n2:n2);

Rl = apLength/2; % width
Rh = apHeight/2; % length
M = ((x - 0) / Rh) .^2    +   ((y - 0) / Rl) .^2     <= 1;
M = double(M) ; % convert from logical to double
alphaLayer = ~double(M)*255;
circleApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,4) = alphaLayer;
apTexture(1) = Screen('MakeTexture',w,circleApertureArray);

clear Rl Rh M alphLayer circleApertureArray

% Small aperture
apLength = round(apSize/2);
apHeight = round(apSize/2);
n = rect(4); % size of matrix, odd
n2 = floor(n/2) ;
[x,y] = meshgrid(-n2:n2);

Rl = apLength/2; % width
Rh = apHeight/2; % length
M = ((x - 0) / Rh) .^2    +   ((y - 0) / Rl) .^2     <= 1;
M = double(M) ; % convert from logical to double
alphaLayer = ~double(M)*255;
circleApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,4) = alphaLayer;
apTexture(2) = Screen('MakeTexture',w,circleApertureArray);

clear Rl Rh M alphLayer circleApertureArray

% Eliptical aperture
apLength = round(apSize/2);
apHeight = round(apSize);
n = rect(4); % size of matrix, odd
n2 = floor(n/2) ;
[x,y] = meshgrid(-n2:n2);

Rl = apLength/2; % width
Rh = apHeight/2; % length
M = ((x - 0) / Rh) .^2    +   ((y - 0) / Rl) .^2     <= 1;
M = double(M) ; % convert from logical to double
alphaLayer = ~double(M)*255;
elipseApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,4) = alphaLayer;
apTexture(3) = Screen('MakeTexture',w,elipseApertureArray);

% Max length of the radius
maxLength = apHeight;

% Line texture
gratingArray = zeros(imSize)+gray;
gratingArray(:,round(imSize/2)) = 0;
gratingTexture=Screen('MakeTexture', w, gratingArray);

% Rotation variables
rotSpeed = [30 45 55 60 65 75 90];   % number of degrees / second

% Acceleration variables (as a function of rotational speed)
accRate = [0 .25 .5 .75 1 2 3 4 5];   % Constant value

%% Instructions
Screen('TextSize',w,25);
text='There will be two types of trials organized into two blocks each.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
text='At the start of each block you will be notified of the change in trial types,';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
text='and instructions will appear to let you know what type of block it will be.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-100,tColor);
text='Would you like to do some practice trials? (Press ''Y'')';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0,tColor);
text='Press ''N'' to begin the experiment.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+100,tColor);

Screen('Flip',w);

[keyIsDown, secs, keycode] = KbCheck(dev_ID);
while 1
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    if keycode(buttonY)
        rotLinePractice_2AFC_Acc_180_rot(w,rect,dev_ID,x0,y0,tColor,buttonF,buttonJ,rotSpeed,hz,apLength,apHeight,apTexture,gratingTexture,accRate,texX1,texY1,texX2,texY2,numPracTrials);
        break
    elseif keycode(buttonN)
        break
    end
end

trialNumCounter=0;
trialNumCounter1=1;
trialNumCounter2=1;

[keyIsDown, secs, keycode] = KbCheck(dev_ID);

%% Experiment start
for n=trialOrder(:,1)'
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
    
    % Instructions
    if trialNumCounter == 1
        if trialOrder(trialNumCounter,2) == 1
            Screen('TextSize',w,25);
            text='For this block of trials, you will see two rotating lines presented consecutively.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
            text='Determine which line was rotating faster.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
            text='If the first line was rotating faster press ''F''.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-100,tColor);
            text='If the second line was rotating faster press ''J''.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0,tColor);
            text='Press any key to begin.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0+100,tColor);
        elseif trialOrder(trialNumCounter,2) == 2
            Screen('TextSize',w,25);
            text='For this block of trials, you will again see two rotating lines presented consecutively.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
            text='Each line will rotate 180 degrees.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
            text='Determine which line appeared to change speed more.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-100,tColor);
            text='If you thought it was the first line press ''F''.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0,tColor);
            text='If you thought it was the second line press ''J''.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0+100,tColor);
            text='Press any key to begin.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0+200,tColor);
        end
        Screen('Flip',w);
        
        WaitSecs(1);
        while 1
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            if keyIsDown
                break
            end
        end
    elseif trialNumCounter > 1
        if trialOrder(trialNumCounter-1,2) == 2 && trialOrder(trialNumCounter,2) == 1
            Screen('TextSize',w,25);
            text='For this block of trials, you will see two rotating lines presented consecutively.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
            text='Determine which line was rotating faster.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
            text='If the first line was rotating faster press ''F''.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-100,tColor);
            text='If the second line was rotating faster press ''J''.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0,tColor);
            text='Press any key to begin.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0+100,tColor);
            
            Screen('Flip',w);
            
            WaitSecs(1);
            while 1
                [keyIsDown, secs, keycode] = KbCheck(dev_ID);
                if keyIsDown
                    break
                end
            end
        elseif trialOrder(trialNumCounter-1,2) == 1 && trialOrder(trialNumCounter,2) == 2
            Screen('TextSize',w,25);
            text='For this block of trials, you will again see two rotating lines presented consecutively.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
            text='Each line will rotate 180 degrees.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
            text='Determine which line appeared to change speed more.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-100,tColor);
            text='If you thought it was the first line press ''F''.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0,tColor);
            text='If you thought it was the second line press ''J''.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0+100,tColor);
            text='Press any key to begin.';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0+200,tColor);
            
            Screen('Flip',w);
            
            WaitSecs(1);
            while 1
                [keyIsDown, secs, keycode] = KbCheck(dev_ID);
                if keyIsDown
                    break
                end
            end
        end
    end
    
    if trialOrder(trialNumCounter,2) == 1
        %% Block type 1 - rotational speed discrimination
        rawdata1(n,1) = n;   % Actual trial number
        
        rawdata1(n,2)=trialNumCounter1;   % Order of presentation
        trialNumCounter1=trialNumCounter1+1;
        
        rawdata1(n,3) = varList1(n,1);   % 1=long compare 2=short compare
        shapeIdx = rawdata1(n,3);
        
        rawdata1(n,4) = varList1(n,2);   % 1=slowest speed   7=fastest speed
        speedIdx = rawdata1(n,4);
        
        rawdata1(n,5:6) = randperm(2); % Which stim will be presented first 1=test 2=compare
        
        rawdata1(n,7:8) = [randi(360) randi(360)]; % what is the starting orientation of each line
        
        % Present Stimuli
        for i=rawdata1(n,5:6)   % present the test or control
            
            % Jitter the stim time to prevent subjects from guessing based
            % on distance rotated
            stimTime = .8 + (1.2-.8) .* rand(1);
            
            startTime = GetSecs;
            orientation1 = rawdata1(n,6+i);
            
            % Determine the speed
            if i == 1
                actualSpeed1 = rotSpeed(speedIdx)/hz;
                repSpeedIdx = speedIdx;
            elseif i == 2
                actualSpeed1 = rotSpeed(4)/hz;
                repSpeedIdx = 4;
            end
            
            % Randomly determine the direction of rotation
            rotDir = randi(2);
            
            while (GetSecs-startTime) < stimTime
                
                % Determine the fixed speed (how much you want to rotate per screen
                % flip or actualspeed = rotspeed/hz
                if rotDir == 1
                    orientation1 = orientation1 + actualSpeed1;
                else
                    orientation1 = orientation1 - actualSpeed1;
                end
                
                if i==1   % if test (always short)
                    Screen('DrawTextures',w,[gratingTexture, apTexture(2)],[],...
                        [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation1, 0]);
                elseif i==2   % if compare
                    if shapeIdx == 1   % if long compare
                        Screen('DrawTextures',w,[gratingTexture, apTexture(1)],[],...
                            [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation1, 0]);
                    elseif shapeIdx ==  2    % if short compare
                        Screen('DrawTextures',w,[gratingTexture, apTexture(2)],[],...
                            [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation1, 0]);
                    end
                end
                
                % Fixation spot
                Screen('FillOval',w,[0 255 0],[x0-3,y0-3,x0+3,y0+3]);
                Screen('FillOval',w,[0 0 0],[x0-1.5,y0-1.5,x0+1.5,y0+1.5]);
                
                Screen('Flip',w);
                
            end
            Screen('Flip',w);
            WaitSecs(.5);
        end

        % Response
        text='Which line was rotating faster?';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
        text='Press ''F'' for first or ''J'' for second.';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
        Screen('Flip',w);
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        while 1
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            if keycode(buttonF)   % they chose the first line as going faster
                rawdata1(n,9) = 1;
                break
            elseif keycode(buttonJ)   % they chose the second line a going faster
                rawdata1(n,9) = 2;
                break
            end
        end
        
        % Did they say the test was faster than the compare?
        if (rawdata1(n,9) == 1 && rawdata1(n,5) == 1) || (rawdata1(n,9) == 2 && rawdata1(n,6) == 1)  % They chose test as going faster
            rawdata1(n,10) = 1;   % reported test as going faster
        elseif (rawdata1(n,9) == 1 && rawdata1(n,5) == 2) || (rawdata1(n,9) == 2 && rawdata1(n,6) == 2)   % They chose short (compare) as going faster
            rawdata1(n,10) = 0;   % reported compare as going faster
        end
        
    elseif trialOrder(trialNumCounter,2) == 2
        %% Block type 2
        rawdata2(n,1) = n;   % Actual trial number
        
        rawdata2(n,2)=trialNumCounter2;   % Order of presentation
        trialNumCounter2=trialNumCounter2+1;
        
        % Determine which acc to use
        accIdx = varList2(n);
        rawdata2(n,3) = accIdx;
        
        rawdata2(n,4:5) = randperm(2); % Which stim will be presented first 1=test 2=compare
        
        for i=rawdata2(n,4:5)   % present the test or control
            
            % Determine the direction of rotation
            rotDir = randi(2);
            
            counter = 1;
            % Reset the orientation
            if rotDir == 1   % rotate clockwise
                orientation2(trialNumCounter2,counter) = -90;
                dirVal = 1;
            elseif rotDir == 2   % rotate counter-clockwise
                orientation2(trialNumCounter2,counter) = 90;
                dirVal = -1;
            end
            
            % Determine the fixed speed (how much you want to rotate per screen
            % flip or actualspeed = rotspeed/hz
            baseSpeed = rotSpeed(4)/hz;
            
            % Initialize variables
            radialLength(counter) = sqrt( 1 / ( ( sind(orientation2(trialNumCounter2,counter))/apHeight )^2 + ( cosd(orientation2(trialNumCounter2,counter))/apLength )^2 ) );
            
            if i==1   % Compare
                constant = accRate(5);
            elseif i==2   % Test
                constant = accRate(accIdx);
            end
            
            % Change the speed as a function of the length of the radius
            actualSpeed2(counter) = ((((maxLength/radialLength(counter)) - 1) * constant) + baseSpeed) * dirVal;
            
            % Present Stimuli
            startTimer = GetSecs;
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            while 1
                
                % Draw
                Screen('DrawTextures',w,[gratingTexture, apTexture(3)],[],...
                    [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation2(trialNumCounter2,counter), 0])
                
                % Fixation spot
                Screen('FillOval',w,[0 255 0],[x0-3,y0-3,x0+3,y0+3]);
                Screen('FillOval',w,[0 0 0],[x0-1.5,y0-1.5,x0+1.5,y0+1.5]);
                
                Screen('Flip',w);
                
                % Keep track of the radius length to calculate current speed
                radialLength(counter) = sqrt( 1 / ( ( sind(orientation2(trialNumCounter2,counter))/apHeight )^2 + ( cosd(orientation2(trialNumCounter2,counter))/apLength )^2 ) );
                
                % Change the speed as a function of the length of the radius
                actualSpeed2(counter) = ((((maxLength/radialLength(counter)) - 1) * constant) + baseSpeed) * dirVal;
                
                orientation2(trialNumCounter2,counter+1) = orientation2(trialNumCounter2,counter) + actualSpeed2(counter);
                
                counter = counter + 1;
                
                if orientation2(trialNumCounter2,counter) >= 90 && rotDir == 1   % start at -90 and rotate clockwise to 90
                    break
                elseif orientation2(trialNumCounter2,counter) <= -90 && rotDir == 2   % start at 90 and rotate counter-clockwise to -90
                    break
                end
                
            end
            
            Screen('Flip',w);
            WaitSecs(.5);
        end
        
        % Response
        text='Which line appeared to change speed the most?';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
        text='Press ''F'' for the first line or ''J'' for the second line.';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
        Screen('Flip',w);
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        while 1
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            if keycode(buttonF)   % they choose the first
                rawdata2(n,6) = 1;
                break
            elseif keycode(buttonJ)   % they choose the second
                rawdata2(n,6) = 2;
                break
            end
        end
        
        % Did they say the test or compare was changing more?
        if (rawdata2(n,6) == 1 && rawdata2(n,4) == 1) || (rawdata2(n,6) == 2 && rawdata2(n,5) == 1)  % They chose test
            rawdata2(n,7) = 1;   % reported test as changing more
        elseif (rawdata2(n,6) == 1 && rawdata2(n,4) == 2) || (rawdata2(n,6) == 2 && rawdata2(n,5) == 2)   % They chose compare
            rawdata2(n,7) = 0;   % reported compare as changing more
        end
        
        
    end
    
    %save trial information on each trial
    save(sprintf('%s%s',datadir,datafile),'rawdata1','rawdata2');
    
end

%% End the experiment
% save two files: 1 for rawdata and 2 that holds all the variables you
% created
save(sprintf('%s%s',datadir,datafile),'rawdata1','rawdata2');
save(sprintf('%s%s',datadir,datafile_full));

Screen('CloseAll')
ListenChar(0);
ShowCursor;


%% Analysis
% BLOCK 1
clear datafit1 b1

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
    datafit1(:,:,i) = [numFaster1(i,:)',numTotal1(i,:)'];
    b1(:,i) = glmfit(x_axis',datafit1(:,:,i),'binomial','logit');
    fitdata1(:,i) = 100 * exp(b1(1,i) + b1(2,i) * xx_axis') ./ (1 + exp(b1(1,i) + b1(2,i) * xx_axis'));
    PSE1(i) = -b1(1,i)/b1(2,i);
    
    % Plot
    h(i) = plot(x_axis,100*percentFaster1(i,:)','Color',lineColor{i},'LineWidth',2);   % Plot the rawdata
    set(gca,'ylim',[0,100]);
    set(gca,'xtick',rotSpeed,'xTickLabels',speedTitle);
    hold on;
    plot(x_axis,50*ones(length(x_axis),1),'k--','LineWidth',2);   % Plot the 50% line
    plot(xx_axis,fitdata1(:,i)','Color',lineColor{i},'LineWidth',2);    % Plot the curve fit
    plot(PSE1(i)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the PSE
end

legend(h([1 2]),'Long','Short');

subplot(1,2,2)   % Plot the PSEs
b = bar(PSE1(:));
set(gca,'xticklabel',{'Long' 'Short'});
set(gca,'ylim',[0,100]);
bChild = get(b,'Children');
set(bChild,'FaceVertexCData',[1 0 0; 0 0 1]);


% BLOCK 2

% Reverese the responses
rawdata2(:,7) = ~rawdata2(:,7);

% Number of trials in which they said test was faster than compare for each
% speed
for j=1:numAcc
    numChanged2(j) = sum(rawdata2(rawdata2(:,3)==j,7));
    numTotal2(j) = sum(rawdata2(:,3)==j);
    percentFaster2(j) = numChanged2(j)/numTotal2(j);
end

clear x_axis xx_axis speedTitle
% Calculate curve fit and PSE values
x_axis = accRate;
xx_axis = 30:.001:90;

for i=1:numAcc
    speedTitle{i}  = num2str(accRate(i));
end

% datafit2(:,:) = [numChanged2(:),numTotal2(:)];
% b2(:,:) = glmfit(x_axis',datafit2(:,:),'binomial','logit');
% fitdata2(:,:) = 100 * exp(b2(1) + b2(2) * xx_axis') ./ (1 + exp(b2(1) + b2(2) * xx_axis'));

figure()
plot(x_axis,100*percentFaster2(:)','LineWidth',2);   % Plot the rawdata
% hold on
% plot(xx_axis,fitdata2(:,1),'LineWidth',2);    % Plot the curve fit
set(gca,'ylim',[0,100],'xlim',[0,accRate(9)]);
set(gca,'xtick',accRate,'xTickLabels',speedTitle);

save(sprintf('%s%s',datadir,datafile_full));




