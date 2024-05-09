clear all
close all

ListenChar(2);
HideCursor;

KbName('UnifyKeyNames');
Screen('Preference', 'SkipSyncTests', 1);
buttonEscape = KbName('Escape');
buttonR = KbName('R');

% rect=[0 100 1024 868];     % test comps
screens=Screen('Screens');
screenNumber=max(screens);

% Find the color values which correspond to white and black: Usually
% black is always 0 and white 255, but this rule is not true if one of
% the high precision framebuffer modes is enabled via the
% PsychImaging() commmand, so we query the true values via the
% functions WhiteIndex and BlackIndex:
white=WhiteIndex(screenNumber);BlackIndex(screenNumber);
black=BlackIndex(screenNumber);

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

% Screen params
[w,rect]=Screen('OpenWindow', screenNumber,[128 128 128]);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;
backColor = [gray gray gray];

% Enable alpha blending for anti-aliasing
% For help see: Screen BlendFunction?
% Also see: Chapter 6 of the OpenGL programming guide
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

buttonUp = KbName('UpArrow');
buttonDown = KbName('DownArrow');
buttonLeft = KbName('LeftArrow');
buttonRight = KbName('RightArrow');

%% Illusion Variables
counter = 1;

% Sin wave grating variables
imSize = 500;

% Texture variables
texX1 = x0-imSize/2;
texY1 = y0-imSize/2;
texX2 = x0+imSize/2;
texY2 = y0+imSize/2;

% Aperture variables
apSize = 300;
apLength = round(apSize/2);
apHeight = apSize;
n = rect(4); % size of matrix, odd
n2 = floor(n/2) ;
[x,y] = meshgrid(-n2:n2);

% Create the elliptical aperture and texture inside it
Rl = apLength/2; % width
Rh = apHeight/2; % length
M = ((x - 0) / Rh) .^2    +   ((y - 0) / Rl) .^2     <= 1;
M = double(M) ; % convert from logical to double
alphaLayer = ~double(M)*255; 
circleApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,4) = alphaLayer;
apTexture = Screen('MakeTexture',w,circleApertureArray);

gratingArray = zeros(imSize)+gray;
gratingArray(:,round(imSize/2)) = 0;

gratingTexture=Screen('MakeTexture', w, gratingArray);

% Rotation variables
rotSpeed = 60;   % number of degrees / second

% Max length of the radius
maxLength = apHeight;

% Refresh rate
monRez = Screen('Resolution',w);
hz = monRez.hz;

% Determine the fixed speed (how much you want to rotate per screen
% flip or actualspeed = rotspeed/hz
baseSpeed = rotSpeed/hz;

% Initialize variables
orientation(counter) = 0;
radialLength(counter) = sqrt( 1 / ( ( sind(orientation(counter))/apHeight )^2 + ( cosd(orientation(counter))/apLength )^2 ) );
% Change the speed as a function of the length of the radius
constant = 1;
dirVal = 1;
actualSpeed(counter) = ((((maxLength/radialLength(counter)) - 1) * constant) + baseSpeed) * dirVal;

%% Draw the stimulus
[keyIsDown, secs, keycode] = KbCheck;
tic
% while orientation <= 360
while ~keycode(buttonEscape)
    [keyIsDown, secs, keycode] = KbCheck; 
    
%     % Reset orientation so it doesn't get HUGE
%     if orientation(counter) >= 359
%         orientation(counter) = 0;
%     end

    %% Draw
    Screen('DrawTextures',w,[gratingTexture, apTexture],[],...
        [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation(counter), 0])
    
    Screen('Flip',w);
    
    % Keep track of the radius length to calculate current speed
    radialLength(counter) = sqrt( 1 / ( ( sind(orientation(counter))/apHeight )^2 + ( cosd(orientation(counter))/apLength )^2 ) );
    
    if keycode(buttonLeft)
        dirVal = 1;
    elseif keycode(buttonRight)
        dirVal = -1;
    end
    
    % Change the speed as a function of the length of the radius
    actualSpeed(counter) = ((((maxLength/radialLength(counter)) - 1) * constant) + baseSpeed) * dirVal;
    
    orientation(counter + 1) = orientation(counter) + actualSpeed(counter);
    
    counter = counter + 1;
    
    if keycode(buttonUp)
%         if constant <= 10
%             constant = constant+.01;
%         end
constant = 1;
    elseif keycode(buttonDown)
%         if constant > 0
%             constant = constant-.01;
%         end
constant = 0;
    end
    
%     KbWait;
%     KbReleaseWait;
    
end
toc

figure()
plot(actualSpeed.*hz);
% figure()
% plot(orientation);

Screen('CloseAll')
ListenChar(0)
ShowCursor;


