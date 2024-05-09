% 080817 - Rotating line experiment to determine the modulation rate that nulls the rotating line illusion.

%% Initialization variables
clear all;
close all;

Screen('Preference', 'SkipSyncTests', 1);

rng('shuffle')

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

% Define the keypresses
buttonJ = KbName('j');
buttonF = KbName('f');
buttonY = KbName('y');
buttonN = KbName('n');

[nums, names] = GetKeyboardIndices;
dev_ID=nums(1);

%% Trial Variables
% Condition Lists
speedList = [1];
numSpeed = length(speedList);
apOriList = [1 2];
numApOri = length(apOriList);
accList = [1 2 3 4 5 6 7 8 9 10 11];
numAcc = length(accList);

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
accRate = [.5 1 1.5 1.75 1.9 2.0 2.1 2.25 2.5 3.0 3.5];
% accRate = [-.75];

%% Experiment start
[keyIsDown, secs, keycode] = KbCheck(dev_ID);
for n=1:numSpeed
    for m=1:numApOri
        for o=1:numAcc
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            
            % Determine which speed to use
            speedIdx = n;
            
            % Determine which aperture orientation to use
            apOriIdx = m;
            
            % Determine which acc to use
            accIdx = o;
            
            % Determine the direction of rotation
            rotDir = 1;
            orientation = -90;
            dirVal = 1;
            
            
            % Determine what constant value to use based on the position in the
            % staircase
            constant = accRate(o);
            
            % Set the texture list (lineTex, largeTex, ~elipTex)
            texList = [gratingTexture, apTexture(apOriIdx)];
            texLocList = [texX1 texY1 texX2 texY2; x0-rect(4)/2,0,x0+rect(4)/2,rect(4)]';
            texRotList = [orientation, 0];
            
            % Determine the fixed speed (how much you want to rotate per screen
            % flip or actualspeed = rotspeed/hz
            baseSpeed = 30/hz;
            
            % Initialize variables
            radialLength = sqrt( 1 / ( ( sind(orientation)/apHeightEl(apOriIdx) )^2 + ( cosd(orientation)/apLengthEl(apOriIdx) )^2 ) );
            
            % Change the speed as a function of the length of the radius
            actualSpeed = baseSpeed + ((maxLength./radialLength)-1)*(constant-1)*baseSpeed;
%             actualSpeed = (1 * constant + baseSpeed) * dirVal;
            
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
%                 actualSpeed = ((((maxLength/radialLength) - 1) * constant) + baseSpeed) * dirVal;
                actualSpeed = baseSpeed + ((maxLength/radialLength)-1)*(constant-1)*baseSpeed*dirVal;
 
                orientation = orientation + actualSpeed;
                texRotList(1)=orientation;
                
                if orientation >= 90 && rotDir == 1   % start at -90 and rotate clockwise to 90
                    break
                end
                
            end
            
            KbWait;
            KbReleaseWait;
            
        end
    end
end

%% End the experiment
Screen('CloseAll')
ListenChar(0);
ShowCursor;








