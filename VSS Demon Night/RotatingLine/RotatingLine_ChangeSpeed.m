clear all
% close all

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

%% Illusion Variables
% Sin wave grating variables
imSize = 500;
orientation = 0;
circOrientation = 90;
wavelength = .03;

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
orientationCounter = 0;
% speedCounter = 0;
% Max length of the radius
maxLength = apHeight;
modSpeed = 1;

% Refresh rate
monRez = Screen('Resolution',w);
hz = monRez.hz;

counter = 0;

%% Draw the stimulus
[keyIsDown, secs, keycode] = KbCheck;
tic
% while orientation <= 360
while ~keycode(buttonEscape)
    [keyIsDown, secs, keycode] = KbCheck; 
    % Reset orientation so it doesn't get HUGE
    if orientation >= 361
        orientation = 1;
    end
%     if circOrientation >=361
%         circOrientation = 1;
%     end

    orientationCounter = orientationCounter+1;
    radialLength(orientationCounter) = sqrt( 1 / ( ( sind(orientation)/apHeight )^2 + ( cosd(orientation)/apLength )^2 ) );
    orientationArray(orientationCounter) = orientation;
    
    % Determine the fixed speed (how much you want to rotate per screen
    % flip or actualspeed = rotspeed/hz
    actualSpeed = rotSpeed/hz;
    
    if keycode(buttonR)
        if modSpeed == 0
            modSpeed = 1;
        elseif modSpeed == 1
            modSpeed = 0;
        end
        KbReleaseWait;
    end
    
    counter = counter + 1;
    if modSpeed == 0
        % Keep the speed constant
        orientation = orientation + actualSpeed;
%         circOrientation = circOrientation + actualSpeed;
        speed(counter) = actualSpeed;
    elseif modSpeed == 1
        % Change the speed as a function of the length of the radius
        orientation = orientation + (1/(radialLength(orientationCounter)/maxLength))*actualSpeed;
%         circOrientation = circOrientation + (1/(radialLength(orientationCounter)/maxLength))*actualSpeed;
        speed(counter) = (1/(radialLength(orientationCounter)/maxLength))*actualSpeed;
    end
    
    orien(orientationCounter) = orientation;
    orienCirc(orientationCounter) = circOrientation;
    
%     % Find coordinates for single point rotating around the line
%     if circOrientation < 90 && circOrientation >= 0 || circOrientation >= 270 && circOrientation <= 360
%         xCoord = (Rl*Rh) / sqrt( (Rl^2) + ((Rh^2) * ((tand(circOrientation))^2)) ) ;
%         yCoord = (Rl*Rh*tand(circOrientation)) / sqrt( (Rl^2) + ((Rh^2) * ((tand(circOrientation))^2)) ) ;
%     elseif circOrientation >= 90 || circOrientation < 270
%         xCoord = -((Rl*Rh) / sqrt( (Rl^2) + ((Rh^2) * ((tand(circOrientation))^2)) )) ;
%         yCoord = -((Rl*Rh*tand(circOrientation)) / sqrt( (Rl^2) + ((Rh^2) * ((tand(circOrientation))^2)) )) ;
%     end
    
    %% Draw
    
    Screen('DrawTextures',w,[gratingTexture, apTexture],[],...
        [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation, 0])
    
    %     Screen('DrawTextures',w,[gratingTexture],[],...
    %         [texX1 texY1 texX2 texY2]', [orientation])
        
%     Screen('FillOval',w,[0 255 0],[x0+(xCoord-3),y0+(yCoord-3),x0+(xCoord+3),y0+(yCoord+3)]);
    
    Screen('Flip',w);
    
end
toc

Screen('CloseAll')
close all
ListenChar(0)
ShowCursor;


