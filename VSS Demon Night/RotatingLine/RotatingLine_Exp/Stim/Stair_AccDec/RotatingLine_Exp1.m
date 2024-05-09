% Rotating line experiment 1/10/17

%% Initialization variables
clear all;
close all;

Screen('Preference', 'SkipSyncTests', 1);

rng('shuffle')

c = clock;
time_stamp = sprintf('%02d/%02d/%04d %02d:%02d:%02.0f',c(2),c(3),c(1),c(4),c(5),c(6)); % month/day/year hour:min:sec
datecode = datestr(now,'mmddyy');
experiment = 'RotatingLine_Exp1';

% get input
subjid = input('Enter Subject Code:','s');
runid  = input('Enter Run:');
datadir = '/Users/C-Lab/Google Drive/Lab Projects/RotatingLine/Data/';
% datadir = '/Volumes/C-Lab/Google Drive/Lab Projects/Data/';

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

[w,rect] = Screen('OpenWindow',1,backColor);

% oldScreen=Screen('Resolution',0);
screenWide=1024;
screenHigh=768;
hz=60;
% Screen('Resolution',0,screenWide,screenHigh,hz);

% PPD stuff
mon_width_cm = 40;
mon_dist_cm = 73;
mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
PPD = (screenWide/mon_width_deg);

x0 = rect(3)/2;
y0 = rect(4)/2;

break_trials = .1:.3:.9;

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

%% Trial Variables
sizeList = [1];   % 1=short
numSize = length(sizeList);
speedList = [1 2 3 4 5 6 7];
numSpeed = length(speedList);

repetitions = 5;

varList = repmat(fullfact([numSize numSpeed]),[repetitions,1]);
numTrials = length(varList);
trialOrder = randperm(numTrials);

% Define the keypresses
buttonJ = KbName('j');
buttonF = KbName('f');

[nums, names] = GetKeyboardIndices;
dev_ID=nums(1);

totalTime=GetSecs;

%% Stimulus variables
stimTime = 1;

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

% Line texture
gratingArray = zeros(imSize)+gray;
gratingArray(:,round(imSize/2)) = 0;
gratingTexture=Screen('MakeTexture', w, gratingArray);

% Rotation variables
rotSpeed = linspace(40,80,numSpeed);   % number of degrees / second]

%% Instructions
Screen('TextSize',w,35);
text='You will see two rotating lines presented consecutively.';
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

KbWait(dev_ID);
KbReleaseWait(dev_ID);

trialNumCounter=1;

[keyIsDown, secs, keycode] = KbCheck(dev_ID);

%% Experiment start
for n=trialOrder
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    
    rawdata(n,1) = n;   % Actual trial number
    
    rawdata(n,2)=trialNumCounter;   % Order of presentation
    trialNumCounter=trialNumCounter+1;
    
    rawdata(n,3) = varList(n,1);   % 1=long 2=short
    shapeIdx = rawdata(n,3);
    
    rawdata(n,4) = varList(n,2);   % 1=slowest speed   7=fastest speed
    speedIdx = rawdata(n,4);
    
    rawdata(n,5:6) = randperm(2); % Which stim will be presented first 1=large 2=small
    
    rawdata(n,7:8) = [randi(360) randi(360)]; % what is the starting orientation of each line
    
    this_b = 0;
    for b = break_trials
        if trialNumCounter==round(b*length(trialOrder))
            this_b = b;
            break
        end
    end
    
    if this_b
        % display break message
        text=sprintf('You have completed %d%% of the trials.',round(b*100));
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
    
    % Present Stimuli
    for i=rawdata(n,5:6)   % present the test or control
        startTime = GetSecs;
        orientation = rawdata(n,6+i);
        
        % Determine the speed
        if i == 1
            actualSpeed = rotSpeed(speedIdx)/hz;
        elseif i == 2
            actualSpeed = rotSpeed(4)/hz;
        end
        
        while (GetSecs-startTime) < stimTime
            
            % Determine the fixed speed (how much you want to rotate per screen
            % flip or actualspeed = rotspeed/hz
            orientation = orientation + actualSpeed;
            
            Screen('DrawTextures',w,[gratingTexture, apTexture(i)],[],...
                [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation, 0]);
            
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
        if keycode(buttonJ)   % they chose the first line as going faster
            rawdata(n,9) = 1;
            break
        elseif keycode(buttonF)   % they chose the second line a going faster
            rawdata(n,9) = 2;
            break
        end
    end
    
    % Did they say the test was faster than the compare?
    if (rawdata(n,9) == 1 && rawdata(n,5) == 1) || (rawdata(n,9) == 2 && rawdata(n,6) == 1)  % They chose long (test) as going faster
        rawdata(n,10) = 1;   % reported test as going faster
    elseif (rawdata(n,9) == 1 && rawdata(n,5) == 2) || (rawdata(n,9) == 2 && rawdata(n,6) == 2)   % They chose short (compare) as going faster
        rawdata(n,10) = 0;   % reported compare as going faster
    end
    
    
    
    % if they said test was faster = 1
    % if they said compare was faster = 1
    %     if shapeIdx==1   % long was test
    %         if (rawdata(n,9) == 1 && rawdata(n,5) == 1) || (rawdata(n,9) == 2 && rawdata(n,6) == 1)  % They chose long (test) as going faster
    %             rawdata(n,10) = 1;   % reported test as going faster
    %         elseif (rawdata(n,9) == 1 && rawdata(n,5) == 2) || (rawdata(n,9) == 2 && rawdata(n,6) == 2)   % They chose short (compare) as going faster
    %             rawdata(n,10) = 0;   % reported compare as going faster
    %         end
    %     elseif shapeIdx==2   % short was test
    %         if (rawdata(n,9) == 1 && rawdata(n,5) == 2) || (rawdata(n,9) == 2 && rawdata(n,6) == 2)  % They chose short (test) as going faster
    %             rawdata(n,10) = 1;   % reported test as going faster
    %         elseif (rawdata(n,9) == 1 && rawdata(n,5) == 1) || (rawdata(n,9) == 2 && rawdata(n,6) == 1)   % They chose long (compare) as going faster
    %             rawdata(n,10) = 0;   % reported compare as going faster
    %         end
    %     end
    
    %     if rawdata(n,10) == 1
    %         text='Test';
    %     elseif rawdata(n,10) == 0
    %         text='Compare';
    %     end
    %     width=RectWidth(Screen('TextBounds',w,text));
    %     Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
    %     Screen('Flip',w);
    %     KbWait(dev_ID);
    %     KbReleaseWait(dev_ID);
    
    %save trial information on each trial
    save(sprintf('%s%s',datadir,datafile),'rawdata');
    
end

% Number of trials in which they said test was faster than compare for each
% speed and for both sizes
for i=1:numSize
    for j=1:numSpeed
        propFaster(i,j) = sum(rawdata(and(rawdata(:,3)==i,rawdata(:,4)==j),10));
    end
end

% save two files: 1 for rawdata and 2 that holds all the variables you
% created
save(sprintf('%s%s',datadir,datafile),'rawdata');
save(datafile_full);

Screen('CloseAll')
ListenChar(0);
ShowCursor;




