% Rotating line demo that switches what part of the line is shown (in front
% of or behind the elliptical aperture) 4/12/2017

%% Initialization variables
clear all
close all

Screen('Preference', 'SkipSyncTests', 1);

ListenChar(2);
HideCursor;

%% Monitor Variables
backColor = [128 128 128];
tColor = [0 0 0];

[w,rect] = Screen('OpenWindow',1,backColor);
screenWide=1024;
screenHigh=768;
hz=60;

% PPD stuff
mon_width_cm = 40;
mon_dist_cm = 73;
mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
PPD = (screenWide/mon_width_deg);

x0 = rect(3)/2;
y0 = rect(4)/2;

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

% Define the key presses
buttonA = KbName('a');
buttonRight = KbName('RightArrow');
buttonLeft = KbName('LeftArrow');
buttonEscape = KbName('escape');

[nums, names] = GetKeyboardIndices;
dev_ID=nums(1);

%% Stimulus variables

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
apTexture(4) = Screen('MakeTexture',w,elipseApertureArray);

clear Rl Rh M alphLayer circleApertureArray elipseApertureArray

% Large circular aperture
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
apTexture(5) = Screen('MakeTexture',w,elipseApertureArray);

% Size variables
imSize = round(apSize*(3/2));

% Texture variables
texX1 = x0-imSize/2;
texY1 = y0-imSize/2;
texX2 = x0+imSize/2;
texY2 = y0+imSize/2;

% Line texture
gratingArray = zeros(imSize)+gray;
gratingArray(:,round(imSize/2)) = 0;
% gratingArray(1,:) = 255;
% gratingArray(end,:) = 255;
% gratingArray(:,end) = 255;
% gratingArray(:,1) = 255;
gratingTexture=Screen('MakeTexture', w, gratingArray);

% Reassign apLength and Height
apLength = round(apSize/2);
apHeight = round(apSize);

% Rotation variables
rotSpeed = [30 45 55 60 65 75 90];   % number of degrees / second

% Acceleration variables (as a function of rotational speed)
accRate = [0 .25 .5 .75 1 2 3 4 5];   % Constant value

counter = 1;
% Reset the orientation
orientation2(counter) = -90;
dirVal = 1;

% Determine the fixed speed (how much you want to rotate per screen
% flip or actualspeed = rotspeed/hz
baseSpeed = rotSpeed(4)/hz;

% Initialize variables
radialLength(counter) = sqrt( 1 / ( ( sind(orientation2(counter))/apHeight )^2 + ( cosd(orientation2(counter))/apLength )^2 ) );

constant = accRate(5);

% Change the speed as a function of the length of the radius
actualSpeed2(counter) = ((((maxLength/radialLength(counter)) - 1) * constant) + baseSpeed) * dirVal;

drawOutside = 1;

% Present Stimuli
startTimer = GetSecs;
[keyIsDown, secs, keycode] = KbCheck(dev_ID);
while 1
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    
    % Toggle apertures
    if keycode(buttonA)
       if drawOutside == 0
           drawOutside = 1;
       elseif drawOutside == 1
           drawOutside = 0;
       end
       KbReleaseWait;
    end
    
    % Inc/dec constant value
    if keycode(buttonRight)
        if constant < 5
            constant = constant+.05;
        end
    elseif keycode(buttonLeft)
        if constant > 0
            constant = constant-.05;
        end
    end
    
    % Draw
    if drawOutside == 0
        Screen('DrawTextures',w,[gratingTexture, apTexture(3)],[],...
            [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation2(counter), 0])
    elseif drawOutside == 1
        Screen('DrawTextures',w,[gratingTexture, apTexture(5),apTexture(4)],[],...
            [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4);x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation2(counter), 0, 0]) 
    end
    
    % Fixation spot
    Screen('FillOval',w,[0 255 0],[x0-3,y0-3,x0+3,y0+3]);
    Screen('FillOval',w,[0 0 0],[x0-1.5,y0-1.5,x0+1.5,y0+1.5]);
    
    Screen('Flip',w);
    
    % Keep track of the radius length to calculate current speed
    radialLength(counter) = sqrt( 1 / ( ( sind(orientation2(counter))/apHeight )^2 + ( cosd(orientation2(counter))/apLength )^2 ) );
    
    % Change the speed as a function of the length of the radius
    actualSpeed2(counter) = ((((maxLength/radialLength(counter)) - 1) * constant) + baseSpeed) * dirVal;
    
    orientation2(counter+1) = orientation2(counter) + actualSpeed2(counter);
    
    counter = counter + 1;
    
    if keycode(buttonEscape)
        break
    end
    
end


Screen('CloseAll')

ListenChar(0);
ShowCursor;








