clear all 
close all

Screen('Preference', 'SkipSyncTests', 1);

buttonEscape = KbName('escape');

ListenChar(2);
HideCursor;

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

[nums, names] = GetKeyboardIndices;
dev_ID=nums(1);

%% Stimulus variables
stimTime(1) = 1;   % Block 1
stimTime(2) = .500;   % Block 2

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

% Line texture
gratingArray = zeros(imSize)+gray;
gratingArray(:,round(imSize/2)) = 0;
gratingTexture=Screen('MakeTexture', w, gratingArray);

% Rotation variables
rotSpeed = [30 45 55 60 65 75 90];   % number of degrees / second

% Acceleration variables (as a function of rotational speed)
accRate = [-50 -30 -15 -5 0 5 15 30 50];
% accRate = [-30 -15 0 15 30];

%% Exp Start
[keyIsDown, secs, keycode] = KbCheck(dev_ID);
% while ~keycode(buttonEscape)
for i=1:length(accRate)
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    
    % Present Stimuli
    
    % IF BLOCK 2....
    orientation(i,1) = 0;
    orientationStart = orientation(i,1);
    
    accIdx = i;
    
    % Determine the speed
    startSpeed = rotSpeed(4);
    finalSpeed = startSpeed + accRate(accIdx);
    % Find the acceleration 
    % Acc = ( (original vel)^2 - (final vel)^2 ) / (distance*2);
    acceleration = ((finalSpeed/hz)^2 - (startSpeed/hz)^2) / (90*2);       
    
    % Velocity using acceleration
    actualSpeed(i,1) = startSpeed/hz;
    
    startTime = GetSecs;
    counter = 1;
    %     while (GetSecs-startTime) < stimTime(2)
    while floor(orientation(i,counter)) <  90
        
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        if keycode(buttonEscape)
            break
        end
        
        
        Screen('DrawTextures',w,[gratingTexture, apTexture(3)],[],...
            [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation(i,counter), 0]);
        
        text = num2str(actualSpeed(i,counter)*hz);
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
        Screen('Flip',w);
        
        Screen('Flip',w);
        
        counter = counter + 1;
        orientation(i,counter) = orientation(i,counter-1) + actualSpeed(i,counter-1);
        actualSpeed(i,counter) = actualSpeed(i,counter-1)+acceleration;
        
    end
    
    %     KbWait(dev_ID);
    %     KbReleaseWait(dev_ID);
    
end

for i=1:length(accRate)
    accRateTitle{i} = num2str(accRate(i));
end

Screen('CloseAll');

ListenChar(0);
ShowCursor;


figure(1)
subplot(1,2,1);
line(1:size(actualSpeed,2),actualSpeed(:,:));
%     plot(actualSpeed(i,:));
hold on
legend(accRateTitle)

subplot(1,2,2)
line(1:size(orientation,2),orientation(:,:));
%     plot(orientation(i,:));
hold on



