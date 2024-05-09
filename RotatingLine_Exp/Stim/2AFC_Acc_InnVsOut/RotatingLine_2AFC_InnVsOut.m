% Rotating line experiment modulating the focus of attention on either the
% inner or outer terminators of a line rotating behind an elliptical
% occluder.

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

% Condition Lists
focusList = [1 2];   % 1=inner terminators 2=outer terminators
numFocus = length(focusList);
% accList = [1 2 3 4 5 6 7 8 9];
accList = [1];
numAcc = length(accList);
repetitions = 20;

varList = repmat(fullfact([numFocus numAcc]),[repetitions,1]);
trialOrder = randperm(length(varList));

% Preallocate rawdata files
rawdata = zeros(length(trialOrder),7);

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

clear Rl Rh M alphLayer circleApertureArray elipseApertureArray

% ~Eliptical aperture
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
elipseApertureArray(:,:,4) = double(M)*255;
apTexture(2) = Screen('MakeTexture',w,elipseApertureArray);

clear Rl Rh M alphLayer circleApertureArray elipseApertureArray

% Large circular aperture (Outer aperture)
apLength = round(apSize*(3/2));
apHeight = round(apSize*(3/2));
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

clear Rl Rh M alphLayer circleApertureArray elipseApertureArray

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
        rotLinePractice_2AFC_Acc_180_rot(w,rect,dev_ID,x0,y0,tColor,buttonF,buttonJ,rotSpeed,hz,apLengthEl,apHeightEl,apTexture,gratingTexture,accRate,texX1,texY1,texX2,texY2,numPracTrials);
        break
    elseif keycode(buttonN)
        break
    end
end

% Instructions
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
    
    % Determine which acc to use
    accIdx = varList(n,2);
    rawdata(n,3) = accIdx;
    
    % Determine where focus will be
    focusIdx = varList(n,1);
    rawdata(n,4) = focusIdx;
    
    % Which stim will be presented first 1=test 2=compare
    rawdata(n,5) = randi(2);
    if rawdata(n,5) == 1
        stimOrder = [1 2];
    elseif rawdata(n,5) == 2
        stimOrder = [2 1];
    end
    
    for i=stimOrder
        
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
        
        if i==1   % Compare
            
            constant = accRate(5);
            
        elseif i==2   % Test
            
            constant = accRate(accIdx);
            
        end
        
        % Set the texture list (lineTex, largeTex, ~elipTex)
        texList = [gratingTexture, apTexture(3), apTexture(2)];
        texLocList = [texX1 texY1 texX2 texY2; x0-rect(4)/2,0,x0+rect(4)/2,rect(4); x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]';
        texRotList = [orientation, 0, 0];
        
        % Determine the fixed speed (how much you want to rotate per screen
        % flip or actualspeed = rotspeed/hz
        baseSpeed = rotSpeed(4)/hz;
        
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
            
            % Draw the dots
            if i == 1   % If drawing compare
                radialLengthDot = radialLength;
            elseif i == 2   % Test
                if focusIdx == 1   % Inner focus
                    % Keep radialLength the same (same as the ellipse
                    % radialLength)
                    radialLengthDot = radialLength;
                elseif focusIdx == 2   % Outer focus
                    % Make radialLength same as the size of the large
                    % circular outer aperture. 
                    radialLengthDot = round(apSize*(3/2));
                end                
            end
            
            % Use the known radial length and orientation to find the
            % center point of the dots
            dotX1 = (texLocList(3,2)-(texLocList(3,2)-texLocList(1,2))/2) + radialLengthDot/2 * cosd(orientation-90);
            dotY1 = (texLocList(4,2)-(texLocList(4,2)-texLocList(2,2))/2) + radialLengthDot/2 * sind(orientation-90);
            
            dotX2 = (texLocList(3,2)-(texLocList(3,2)-texLocList(1,2))/2) + radialLengthDot/2 * cosd(orientation+90);
            dotY2 = (texLocList(4,2)-(texLocList(4,2)-texLocList(2,2))/2) + radialLengthDot/2 * sind(orientation+90);
            
            Screen('FillOval',w,[255 0 0],[dotX1-3,dotY1-3,dotX1+3,dotY1+3]);
            Screen('FillOval',w,[255 0 0],[dotX2-3,dotY2-3,dotX2+3,dotY2+3]);
            
            % Fixation spot
            Screen('FillOval',w,[0 255 0],[x0-3,y0-3,x0+3,y0+3]);
            Screen('FillOval',w,[0 0 0],[x0-1.5,y0-1.5,x0+1.5,y0+1.5]);
            
            Screen('Flip',w);
            
%             KbWait;
%             KbReleaseWait;
%             
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
            rawdata(n,6) = 1;
            break
        elseif keycode(buttonJ)   % they choose the second
            rawdata(n,6) = 2;
            break
        end
    end
    
    % Did they say the test or compare was changing more?
    if (rawdata(n,6) == 1 && rawdata(n,4) == 1) || (rawdata(n,6) == 2 && rawdata(n,5) == 1)  % They chose test
        rawdata(n,7) = 1;   % reported test as changing more
    elseif (rawdata(n,6) == 1 && rawdata(n,4) == 2) || (rawdata(n,6) == 2 && rawdata(n,5) == 2)   % They chose compare
        rawdata(n,7) = 0;   % reported compare as changing more
    end
    
    
    %save trial information on each trial
%     save(sprintf('%s%s',datadir,datafile),'rawdata');
    
end

%% End the experiment
% save two files: 1 for rawdata and 2 that holds all the variables you
% created
% save(sprintf('%s%s',datadir,datafile),'rawdata1','rawdata2');
% save(sprintf('%s%s',datadir,datafile_full));

Screen('CloseAll')
ListenChar(0);
ShowCursor;

% rawdata(1) = actual trial number
% rawdata(2) = order of presentation
% rawdata(3) = acc idx 1=no mod 9=5x
% rawdata(4) = focus idx 1-inner 2-outer
% rawdata(5) = what was presented first 1-test 2-compare
% rawdata(6) = participant response 1-first 2-second
% rawdata(7) = which was modulating more 1-test 0-compare

 
% Reverese the responses
% rawdata(:,7) = ~rawdata(:,7);

% Number of trials in which they said test was modulating more than compare for each
% speed for each focus
for i=1:numFocus
    for j=1:numAcc
        numChanged(i,j) = sum(rawdata(rawdata(rawdata(:,4)==i,3)==j,7));
        numTotal(i,j) = sum(rawdata(rawdata(:,4)==i,3)==j);
        percentFaster(i,j) = numChanged(i,j)/numTotal(i,j);
    end
end


% clear x_axis xx_axis speedTitle
% % Calculate curve fit and PSE values
% x_axis = accRate;
% xx_axis = 30:.001:90;
% 
% for i=1:numAcc
%     speedTitle{i}  = num2str(accRate(i));
% end
% 
% % datafit2(:,:) = [numChanged2(:),numTotal2(:)];
% % b2(:,:) = glmfit(x_axis',datafit2(:,:),'binomial','logit');
% % fitdata2(:,:) = 100 * exp(b2(1) + b2(2) * xx_axis') ./ (1 + exp(b2(1) + b2(2) * xx_axis'));
% 
% figure()
% plot(x_axis,100*percentFaster2(:)','LineWidth',2);   % Plot the rawdata
% % hold on
% % plot(xx_axis,fitdata2(:,1),'LineWidth',2);    % Plot the curve fit
% set(gca,'ylim',[0,100],'xlim',[0,accRate(9)]);
% set(gca,'xtick',accRate,'xTickLabels',speedTitle);
% 
% save(sprintf('%s%s',datadir,datafile_full));






