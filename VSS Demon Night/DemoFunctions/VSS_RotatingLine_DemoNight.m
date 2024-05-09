% Rotating line demo for demo night at VSS

%% Initializing variables
clear all; close all;

% Screen('Preference', 'SkipSyncTests', 1);

KbName('UnifyKeyNames');

ListenChar(2);
HideCursor;

%% Monitor variables
backColor = [128 128 128];

[w,rect] = Screen('OpenWindow',0,backColor);
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
buttonR = KbName('r');
buttonO = KbName('o');
buttonM = KbName('m');
buttonC = KbName('c');
buttonG = KbName('g');
buttonD = KbName('d');
buttonL = KbName('l');
buttonS = KbName('s');
button1 = KbName('1!');
button2 = KbName('2@');
button3 = KbName('3#');
buttonSpace = KbName('space');
buttonRight = KbName('RightArrow');
buttonLeft = KbName('LeftArrow');
buttonPlus = KbName('=+');
buttonEscape = KbName('escape');

[nums, names] = GetKeyboardIndices;
dev_ID=nums(1);


%% Texture variables
[apTotal,apNumber,apTexture,apSize,gratingTexture,imSize,texX1,texY1,texX2,texY2,maxLength,gratingNumber,phaseValue,phaseHolder] =...
    texVars(w,PPD,rect,x0,y0,gray,white,black,inc);

%% Initialize variables

% Reassign apLength and Height
apLength = round(apSize/2);
apHeight = round(apSize);

% Rotation variables
rotSpeed = 60;   % number of degrees / second

% Reset the orientation
orientation = -90;

% Determine the fixed speed (how much you want to rotate per screen
% flip or actualspeed = rotspeed/hz
baseSpeed = rotSpeed/hz;

radialLength = sqrt( 1 / ( ( sind(orientation)/apHeight )^2 + ( cosd(orientation)/apLength )^2 ) );

% Acceleration variables (as a function of rotational speed)
constant = 0;
constantHolder = constant;

% Change the speed as a function of the length of the radius
actualSpeed = ((((maxLength(apNumber)/radialLength) - 1) * constant) + baseSpeed);

% Initial arrays for drawing textures
texArray = [gratingTexture(1), apTexture(3)];
texLocationArray = [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]';
texRotationArray = [orientation, 0];
combinedTexArray = [gratingTexture(1), apTexture(3),gratingTexture(1), apTexture(3)];
combinedTexLocationArray = [texX1-(rect(3)/4) texY1 texX2-(rect(3)/4) texY2; (x0-rect(4)/2)-(rect(3)/4), 0, (x0+rect(4)/2)-(rect(3)/4),rect(4);...
    texX1+(rect(3)/4) texY1 texX2+(rect(3)/4) texY2; (x0-rect(4)/2)+(rect(3)/4), 0, (x0+rect(4)/2)+(rect(3)/4),rect(4)]';
combinedTexRotationArray = [orientation, 0, orientation, 0];

%% Toggle values
drawOutsideToggle = 0;   % Draw the line outside the aperture
dirVal = 1;        % Which direction is the line rotating
autoRotate = 1;         % Automatically or manually rotate the line
toggleModulation = 0;
toggleCompare = 0;
whichCompare = 1;
translateDEI = 0;
phaseCount = 1;
autoRunToggle = 1;
whichPart = 1;
drawDotsNLine = 1;
drawDotsToggle = 0;

% Variables for comparing the two displays
% Keep track of the variables for the two displays
texArray1 = texArray;
texArray2 = texArray;
texLocationArray1 = texLocationArray;
texLocationArray2 = texLocationArray;
orientation1 = orientation;
orientation2 = orientation;
constant1 = constant;
constant2 = constant;
radialLength1 = radialLength;
radialLength2 = radialLength;
actualSpeed1 = actualSpeed;
actualSpeed2 = actualSpeed;
apNumber1 = apNumber;
apNumber2 = apNumber;
apHeight1 = apHeight;
apHeight2 = apHeight;
apLength1 = apLength;
apLength2 = apLength;
occluded1 = drawOutsideToggle;
occluded2 = drawOutsideToggle;
baseSpeed1 = baseSpeed;
baseSpeed2 = baseSpeed;
dirVal1 = dirVal;
dirVal2 = dirVal;
autoRotate1 = autoRotate;
autoRotate2 = autoRotate;
drawDotsToggle1 = drawDotsToggle;
drawDotsToggle2 = drawDotsToggle;
drawDotsNLine1 = drawDotsNLine;
drawDotsNLine2 = drawDotsNLine;

%% Demo
[keyIsDown, secs, keycode] = KbCheck(dev_ID);
while ~keycode(buttonEscape)
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    if keycode(button1)
        autoRunToggle = 1;
        KbReleaseWait;
    elseif keycode(button2)
        autoRunToggle = 2;
        KbReleaseWait;
    end
    
    if keycode(buttonEscape)
        break
    end
    
    if autoRunToggle == 1
        %% Autorun demo
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        
        [whichPart,autoRunToggle] = autorunDemo(whichPart,autoRunToggle,apTexture,gratingTexture,radialLength,orientation,actualSpeed,baseSpeed,...
            dirVal,apHeight,apLength,maxLength,texArray,texLocationArray,texRotationArray,whichCompare,...
            autoRotate,apNumber,combinedTexArray,combinedTexLocationArray,combinedTexRotationArray,toggleCompare,...
            translateDEI,phaseValue,phaseCount,phaseHolder,drawDotsNLine,drawDotsToggle,gratingNumber,drawOutsideToggle,...
            dev_ID,button1,button2,button3,buttonSpace,buttonEscape,buttonS,apSize,imSize,texX1,texY1,texX2,texY2,gray,inc,rect,x0,w,hz);
        
    elseif autoRunToggle == 2
        %% Specific functions
        
        % Draw demo
        [orientation,actualSpeed,radialLength,texRotationArray,texArray] = ...
            drawDemo(w,radialLength,orientation,actualSpeed,constant,baseSpeed,dirVal,apHeight,apLength,apSize,maxLength,texArray,texLocationArray,texRotationArray,...
            autoRotate,apNumber,combinedTexArray,combinedTexLocationArray,combinedTexRotationArray,toggleCompare,drawDotsToggle,gratingNumber,drawOutsideToggle,...
            x0,rect,whichCompare,whichPart,autoRunToggle);
        
        % Rotate - toggle auto rotation using 'r'; if toggled off can use left
        % right arrows to rotate
        [autoRotate,orientation] =...
            rotateTex(autoRotate,orientation,keycode,buttonR,buttonLeft,buttonRight);
        
        % Draw outside - toggle which parts of the line are occluded (within or
        % without the aperture)
        [drawOutsideToggle,texArray,texLocationArray,texRotationArray] =...
            drawOutside(drawOutsideToggle,texArray,texLocationArray,texRotationArray,...
            buttonO,keycode,apTexture,rect,x0,apNumber,apTotal);
        
        % Change aperture - toggle between aperture types (parallelogram,square,elipse,circle)
        [apNumber,apLength,apHeight] = changeAperture(apNumber,keycode,buttonA,apLength,apHeight,apSize);
        
        % Change texture (line/grating) - Change the texture between the grating and the line.
        [gratingNumber,texArray] = changeTexture(gratingNumber,keycode,buttonG,texArray,gratingTexture,drawDotsNLine,drawDotsToggle);
        
        % Turn on outlines of apertures.
        %     [] = drawOutline();
        
        % Toggle modulation - toggle on/off modulation of speed to cancel
        % effect
        [constant,constantHolder,toggleModulation] = modulateSpeed(constant,constantHolder,toggleModulation,buttonM,keycode,buttonLeft,buttonRight);
        
        % Draws dots on the edges of the occluder. Only usable if the occluder is
        % an ellipse and while using the line. If drawing on outside can switch between drawing along the
        % edge of the inner occluder or outer occluder.
        [drawDotsNLine,drawDotsToggle,gratingNumber] = drawDots(drawDotsNLine,drawDotsToggle,gratingNumber,drawOutsideToggle,buttonL,buttonD,keycode);
        
        % Compare speed - Brings up two of the rotating lines (pressing c) that
        % are side by side. Can adjust the speed/aperture/rotation/etc. of each
        % one seperately by hitting '+', which will toggle back and forth
        % between them (indicated by arrow). MUST CALL LAST!
        [combinedTexArray,combinedTexLocationArray,combinedTexRotationArray,toggleCompare,whichCompare,...
            texArray,texArray1,texArray2,texLocationArray,texLocationArray1,texLocationArray2,orientation,orientation1,orientation2,constant,constant1,constant2,radialLength,radialLength1,radialLength2,...
            actualSpeed,actualSpeed1,actualSpeed2,apNumber,apNumber1,apNumber2,drawOutsideToggle,occluded1,occluded2,baseSpeed,baseSpeed1,baseSpeed2,...
            dirVal,dirVal1,dirVal2,apHeight,apHeight1,apHeight2,apLength,apLength1,apLength2,autoRotate,autoRotate1,autoRotate2,...
            drawDotsToggle,drawDotsToggle1,drawDotsToggle2,drawDotsNLine,drawDotsNLine1,drawDotsNLine2] =...
            compareSpeed(combinedTexArray,combinedTexRotationArray,toggleCompare,whichCompare,keycode,buttonC,buttonPlus,...
            texArray,texArray1,texArray2,texLocationArray,texLocationArray1,texLocationArray2,orientation,orientation1,orientation2,constant,constant1,constant2,radialLength,radialLength1,radialLength2,...
            actualSpeed,actualSpeed1,actualSpeed2,apNumber,apNumber1,apNumber2,drawOutsideToggle,occluded1,occluded2,baseSpeed,baseSpeed1,baseSpeed2,...
            dirVal,dirVal1,dirVal2,apHeight,apHeight1,apHeight2,apLength,apLength1,apLength2,autoRotate,autoRotate1,autoRotate2,...
            maxLength,texX1,texY1,texX2,texY2,rect,x0,drawDotsToggle,drawDotsToggle1,drawDotsToggle2,drawDotsNLine,drawDotsNLine1,drawDotsNLine2);
        
    end
end

Screen('CloseAll');
ListenChar(0);
ShowCursor;


% Specific functions

% Tanslate
% Translate the inner texture for [t1 t1...tn] using
% coordinate array [t1x1 t1y1 t1x2 t1y2;...tnx1 tny1 tnx2 tny2] (only when
% using the grating). Add in functionality that imitates the translation of
% the DEI when the demo is playing.

% Increase the base rotation speed

% Turn on outlines of apertures.

% Turn on dots at ends of lines.

% Fixation
% Draw a fixation spot in the center of the screen

% Draw instructions
% Displays instructions, but stops the program from running.








