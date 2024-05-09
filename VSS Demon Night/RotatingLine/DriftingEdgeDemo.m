clear all
close all

ListenChar(2);

KbName('UnifyKeyNames');
Screen('Preference', 'SkipSyncTests', 1);
buttonEscape = KbName('Escape');
buttonRight = KbName('RightArrow');
buttonLeft = KbName('LeftArrow');
buttonUp = KbName('UpArrow');
buttonDown = KbName('DownArrow');
buttonM = KbName('M');
buttonP = KbName('P');
buttonF = KbName('F');
buttonR = KbName('R');
buttonI = KbName('I');
buttonG = KbName('G');
buttonO = KbName('O');
buttonK = KbName('K');
buttonL = KbName('L');
buttonQ = KbName('Q');
buttonGreaterThan = KbName('.>');
buttonLessThan = KbName(',<');

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

% Sin wave grating variables
imSize = 500;
orientation = 0;
wavelength = .03;

% Aperture variables
apLength = 300;
apHeight = 100;
apSize = 300;

% Texture variables
texX1 = x0-imSize/2;
texY1 = y0-imSize/2;
texX2 = x0+imSize/2;
texY2 = y0+imSize/2;

% Toggle variable
speed=1;
rotSpeed = 2;
motionToggle = 3;
toggleAp = 1;
toggleApChange = 1;
circleApp = 0;
fixationToggle = 0;
rotateToggle = 1;
instToggle = 1;
gratingToggle = 1;
outlineToggle = 0;
radiusTracker = 0; 

[keyIsDown, secs, keycode] = KbCheck;
counter = 1;
while ~keycode(buttonEscape)
    [keyIsDown, secs, keycode] = KbCheck;
    
    %% toggle start/stop motion and direction of motion
    % Increase speed of drift
    if keycode(buttonGreaterThan)
        if speed < 4
            speed = speed + .1;
        end
    elseif keycode(buttonLessThan)
        if speed >= .1
            speed = speed - .1;
        end
    end
    
    if keycode(buttonM)
        if motionToggle == 1
            motionToggle = 2;
        elseif motionToggle == 2
            motionToggle = 3;
        elseif motionToggle == 3
            motionToggle = 1;
        end
        KbReleaseWait;
    end
    
    if motionToggle == 1
        counter = counter + speed;
    elseif motionToggle == 2
        counter = counter - speed;
    elseif motionToggle == 3
        counter = counter;
    end
    
    phase=(counter/30)*2*pi;
    
    %% Turn on a fixation point
    if keycode(buttonF)
        if fixationToggle == 1
            fixationToggle = 0;
        elseif fixationToggle == 0
            fixationToggle = 1;
        end
        KbReleaseWait;
    end
    
    %% Manually rotate using left and right arrows
    if keycode(buttonR)
        if rotateToggle == 0
            rotateToggle = 1;
        elseif rotateToggle == 1
            rotateToggle = 2;
        elseif rotateToggle == 2
            rotateToggle = 0;
        end
        KbReleaseWait;
    end
    
    if rotateToggle == 0
        if keycode(buttonLeft)
            orientation = orientation-rotSpeed;
        elseif keycode(buttonRight)
            orientation = orientation+rotSpeed;
        end
        
        % Auto rotate
    elseif rotateToggle == 1
        % Speed up/slow down rotation
        if keycode(buttonLeft)
            if rotSpeed >= .1
                rotSpeed = rotSpeed-.1;
            end
        elseif keycode(buttonRight)
            if rotSpeed <= 5
                rotSpeed = rotSpeed+.1;
            end
        end
        orientation = orientation-rotSpeed;
    elseif rotateToggle == 2
        % Speed up/slow down rotation
        if keycode(buttonLeft)
            if rotSpeed >= .1
                rotSpeed = rotSpeed-.1;
            end
        elseif keycode(buttonRight)
            if rotSpeed <= 8
                rotSpeed = rotSpeed+.1;
            end
        end
        orientation = orientation+rotSpeed;
    end
    
    % Reset orientation so it doesn't get HUGE
    if orientation >= 360
        orientation = 0;
    elseif orientation <= -360
        orientation = 0;
    end
    
    %% Toggle on the aperture outline
    if keycode(buttonO)
       if outlineToggle == 1
           outlineToggle = 0;
       elseif outlineToggle == 0
           outlineToggle = 1;
       end
       toggleApChange = 1;
       KbReleaseWait;
    end
    
    %% Increase/decrease the size of the aperture up to the size of the size of the grating-1 and down to 10
    if keycode(buttonK)
        if round(apSize/3) >= 10
            apSize = apSize - 5;
        end
        toggleApChange = 1;
    elseif keycode(buttonL)
        if apSize < 300
            apSize = apSize + 5;
        end
        toggleApChange = 1;
    end
    
    %% Change the type of aperture (rectangle vs parallelagram?)
    if keycode(buttonP)
        if toggleAp == 1
            toggleAp = 2;
        elseif toggleAp == 2
            toggleAp = 3;
        elseif toggleAp == 3
            toggleAp = 4;
        elseif toggleAp == 4
            toggleAp = 5;
        elseif toggleAp == 5
            toggleAp = 1;
        end
        toggleApChange = 1;
        KbReleaseWait;
    end
    % Create the aperture (destination rect of texture)
    % Determine the four corners of the aperture
    if toggleAp == 1        % Make it a parallelogram (?).
        if toggleApChange == 1
            toggleApChange = 0;
            
            apLength = apSize;
            apHeight = round(apSize/3);
            xAp(1) = x0-apLength/2;
            yAp(1) = y0;
            xAp(2) = x0+apLength/2;
            yAp(2) = y0-apHeight;
            xAp(3) = x0-apLength/2;
            yAp(3) = y0+apHeight;
            xAp(4) = x0+apLength/2;
            yAp(4) = y0;
            
            circleApp = 0;
        end
    elseif toggleAp == 2    % Make it a rectangle
        if toggleApChange == 1
            toggleApChange = 0;
            
            apLength = apSize;
            apHeight = round(apSize/3);
            xAp(1) = x0-apLength/2;
            yAp(1) = y0-apHeight/2;
            xAp(2) = x0+apLength/2;
            yAp(2) = y0-apHeight/2;
            xAp(3) = x0-apLength/2;
            yAp(3) = y0+apHeight/2;
            xAp(4) = x0+apLength/2;
            yAp(4) = y0+apHeight/2;
            
            circleApp = 0;
        end
    elseif toggleAp == 3
        if toggleApChange == 1
            toggleApChange = 0;
            
            apLength = apSize;
            apHeight = apSize;
            xAp(1) = x0-apLength/2;
            yAp(1) = y0-apHeight/2;
            xAp(2) = x0+apLength/2;
            yAp(2) = y0-apHeight/2;
            xAp(3) = x0-apLength/2;
            yAp(3) = y0+apHeight/2;
            xAp(4) = x0+apLength/2;
            yAp(4) = y0+apHeight/2;
            
            circleApp = 0;
        end
    elseif toggleAp == 4
        if toggleApChange == 1
            toggleApChange = 0;
            
            apLength = apSize;
            apHeight = apSize;
            n = rect(4); % size of matrix, odd
            R = apLength/2; % radius
            n2 = floor(n/2);
            [x,y] = meshgrid(-n2:n2);
            M = sqrt(x.^2 + y.^2) < R;
            M = double(M) ; % convert from logical to double
            
            alphaLayer = ~double(M)*255; % convert from logical to double
            
            circleApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
            circleApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
            circleApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
            circleApertureArray(:,:,4) = alphaLayer;
            
            % Add an outline to the circle 1 px wide
            if outlineToggle == 1
                for k=1:size(circleApertureArray,1)-1
                    for l=1:size(circleApertureArray,2)-1
                        if circleApertureArray(k+1,l,4) == 0 && circleApertureArray(k,l,4) == 255
                            circleApertureArray(k,l,1:3) = 0;
                            circleApertureArray(k,l,4) = 255;
                            circleApertureArray(size(circleApertureArray,1)-k,l,1:3) = 0;
                            circleApertureArray(size(circleApertureArray,1)-k,l,4) = 255;
                        end
                        if circleApertureArray(k,l+1,4) == 0 && circleApertureArray(k,l,4) == 255
                            circleApertureArray(k,l,1:3) = 0;
                            circleApertureArray(k,l,4) = 255;
                            circleApertureArray(k,size(circleApertureArray,2)-l,1:3) = 0;
                            circleApertureArray(k,size(circleApertureArray,2)-l,4) = 255;
                        end
                    end
                end
            end
            
            circleApp = 1;
        end
    elseif toggleAp == 5
        if toggleApChange == 1
            toggleApChange = 0;
            apLength = round(apSize/2);
            apHeight = apSize;
            n = rect(4); % size of matrix, odd
            Rh = apHeight/2; % length
            Rl = apLength/2; % width
            n2 = floor(n/2) ;
            [x,y] = meshgrid(-n2:n2);
            M = ((x - 0) / Rh) .^2    +   ((y - 0) / Rl) .^2     <= 1;
            M = double(M) ; % convert from logical to double
            
            alphaLayer = ~double(M)*255; % convert from logical to double
            
            circleApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
            circleApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
            circleApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
            circleApertureArray(:,:,4) = alphaLayer;
            
            % Add an outline to the circle 1 px wide
            if outlineToggle == 1
                for k=1:size(circleApertureArray,1)-1
                    for l=1:size(circleApertureArray,2)-1
                        if circleApertureArray(k+1,l,4) == 0 && circleApertureArray(k,l,4) == 255
                            circleApertureArray(k,l,1:3) = 0;
                            circleApertureArray(k,l,4) = 255;
                            circleApertureArray(size(circleApertureArray,1)-k,l,1:3) = 0;
                            circleApertureArray(size(circleApertureArray,1)-k,l,4) = 255;
                        end
                        if circleApertureArray(k,l+1,4) == 0 && circleApertureArray(k,l,4) == 255
                            circleApertureArray(k,l,1:3) = 0;
                            circleApertureArray(k,l,4) = 255;
                            circleApertureArray(k,size(circleApertureArray,2)-l,1:3) = 0;
                            circleApertureArray(k,size(circleApertureArray,2)-l,4) = 255;
                        end
                    end
                end
            end
            
            circleApp = 1;
        end
    end
    
    
    %% Record the radius of the line/grating to the edge of the aperture as it changes orientation from 0 to 360.
    if keycode(buttonQ)
        if toggleAp == 2 || toggleAp == 3   % Rectangle or square
            radiusTracker = 2;
        elseif toggleAp == 5   % Ellipse
            radiusTracker = 5;
        end
        orientationCounter = 1;
        KbReleaseWait;
    end
    
    if radiusTracker == 2   % rectangle/square
        
        orientation = orientationCounter-1;
        
        % http://stackoverflow.com/questions/4061576/finding-points-on-a-rectangle-at-a-given-angle
        % First determine where in the rectangle you are depending on the
        % orientation of the line
        if (orientation >= 45 && orientation < 135)    % Regions 1
            % Find the coordinate of the intersection point using the
            % orientation, length, and width
            xInt = x0 + apLength/2;
            
            if orientation >= 45 && orientation < 90
                yInt = y0 - apLength/2 * cotd(orientation);
            elseif orientation >= 90 && orientation < 135
                yInt = y0 + apLength/2 * cotd(orientation);
            end
        elseif ((orientation >= 315 && orientation <= 360) || (orientation >= 0 && orientation < 45)) % Regions 2
            if (orientation >= 315 && orientation < 360)
                xInt = x0 - apHeight/2 * tand(orientation);
            elseif orientation >= 0 && orientation < 45
                xInt = x0 + apHeight/2 * tand(orientation);
            end
            yInt = y0 - apHeight/2;
        elseif (orientation >= 225 && orientation < 315)   % Regions3
            xInt = x0 - apLength/2;
            if orientation >= 225 && orientation < 270
                yInt = y0 + apLength/2 * cotd(orientation);
            elseif orientation >= 270 && orientation < 315
                yInt = y0 - apLength/2 * cotd(orientation);
            end
        elseif (orientation >= 135 && orientation < 225)   % Regions 4
            if (orientation >= 135 && orientation < 180)
                xInt = x0 + apHeight/2 * tand(orientation);
            elseif orientation >= 180 && orientation < 225
                xInt = x0 - apHeight/2 * tand(orientation);
            end
            yInt = y0 + apHeight/2;
        end
        
        % Find the distance using center points and intersection point
        radialLength(orientationCounter) = sqrt((xInt - x0)^2 + (yInt - y0)^2);
        orientationArray(orientationCounter) = orientation;
        
        % Reset the orientation. Will slow it down for one full
        % rotation while it is recording the radius and moving
        % through 1-360 deg.
        orientationCounter = orientationCounter + 1;
        
        if orientationCounter == 361
            radiusTracker = 0;
        end
    elseif radiusTracker == 5   % elipse
        
        orientation = orientationCounter-1;
        
        % https://warpycode.wordpress.com/2011/01/21/calculating-the-distance-to-the-edge-of-an-ellipse/
        % Formula for length of radius in an elipse:
        % length/radius = sqrt( 1 / ( ( sin(orientation)/rHoriz )^2 + ( cos(orientation)/rVert )^2 )
        radialLength(orientationCounter) = sqrt( 1 / ( ( sind(orientation)/apLength )^2 + ( cosd(orientation)/apHeight )^2 ) );
        orientationArray(orientationCounter) = orientation;
        
        % Reset the orientation. Will slow it down for one full
        % rotation while it is recording the radius and moving
        % through 1-360 deg.
        orientationCounter = orientationCounter + 1;
        
        if orientationCounter == 361
            radiusTracker = 0;
        end
    end
     
    %% Change spatial frequency
    if keycode(buttonUp)
        wavelength = wavelength+.001;
    elseif keycode(buttonDown)
        wavelength = wavelength-.001;
    end
    
    %% Reset to original drifting edge illusion (same angle used in paper)
    
    %% Draw
    % Create the grating
    [x,y]=meshgrid(-imSize/2:imSize/2,-imSize/2:imSize/2);
    angle=pi/180; % 30 deg orientation.
    f=wavelength*2*pi; % cycles/pixel
    a=cos(angle)*f;
    b=sin(angle)*f;
    m=sin(a*x+b*y+phase);
    
    % Toggle between grating and single line
    if keycode(buttonG)
        if gratingToggle == 1
            gratingToggle = 2;
        elseif gratingToggle == 2
            gratingToggle = 1;
        end
        KbReleaseWait;
    end
    
    if gratingToggle == 1    % Draw the grating
        gratingArray = gray+inc*m;
    elseif gratingToggle == 2    % Draw a single black line
        gratingArray = zeros(length(m))+gray;
        gratingArray(:,round(length(m)/2)) = 0;
    end
    
    if circleApp == 0
        gratingTexture=Screen('MakeTexture', w, gratingArray); 
        
        Screen('DrawTexture',w,gratingTexture,[],[texX1 texY1 texX2 texY2],orientation,[],1);
        
        % Draw 4 'occluders' that will create the aperature on the texture
        Screen('FillRect',w,backColor,[0 0 xAp(1) yAp(1)]);
        Screen('FillRect',w,backColor,[xAp(2) 0 rect(3) yAp(2)]);
        Screen('FillRect',w,backColor,[0 yAp(3) xAp(3) rect(4)]);
        Screen('FillRect',w,backColor,[xAp(4) yAp(4) rect(3) rect(4)]);
        
        % Draw 4 fill poly to cover the other open spaces of the tex
        Screen('FillPoly',w,backColor,[xAp(1),0;xAp(2),0;xAp(2),yAp(2);xAp(1),yAp(1)]);
        Screen('FillPoly',w,backColor,[0,yAp(1);xAp(1),yAp(1);xAp(3),yAp(3);0,yAp(3)]);
        Screen('FillPoly',w,backColor,[xAp(3),yAp(3);xAp(4),yAp(4);xAp(4),rect(4);xAp(3),rect(4)]);
        Screen('FillPoly',w,backColor,[xAp(2),yAp(2);rect(3),yAp(2);rect(3),yAp(4);xAp(4),yAp(4)]);
        
        % Add in an outline around the aperture
        if outlineToggle == 1
            Screen('FramePoly',w,[0 0 0],[xAp(1),yAp(1);xAp(2),yAp(2);xAp(4),yAp(4);xAp(3),yAp(3)]);
        end
        
    elseif circleApp == 1
        apTexture = Screen('MakeTexture',w,circleApertureArray);
        
        gratingTexture=Screen('MakeTexture', w, gratingArray);
        
        %         Screen('DrawTexture',w,gratingTexture,[],[texX1 texY1 texX2 texY2],orientation,[],1);
        Screen('DrawTextures',w,[gratingTexture, apTexture],[],...
            [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2, rect(4)]', [orientation, 0])
    end
    
    % Draw a fixation to the texture
    if fixationToggle == 1
        Screen('FillOval',w,[0 255 0],[x0-5,y0-5,x0+5,y0+5]);
        Screen('FillOval',w,[0 0 0],[x0-2,y0-2,x0+2,y0+2]);
    end
    
    
    %% Toggle on/off instructions
    if keycode(buttonI)
        if instToggle == 1
            instToggle = 0;
        elseif instToggle == 0
            instToggle = 1;
        end
        KbReleaseWait;
    end
    
    if instToggle == 1
        Screen('TextSize',w,17);
        text='P toggles between apertures (parallelogram, rectangle, square, circle, ellipse)';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,(rect(3))-(width),(10),[0 0 0]);
        
        text='M toggles between motion left, motion right, and no motion';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,(rect(3))-(width),(30),[0 0 0]);
        
        text='< / > increase speed of motion';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,(rect(3))-(width),(50),[0 0 0]);
        
        text='R toggles between rotate left, rotate right, and no rotation';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,(rect(3))-(width),(70),[0 0 0]);
        
        text='While no rotation left/right buttons manually rotate';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,(rect(3))-(width),(90),[0 0 0]);
        
        text='While grating is rotating left/right buttons increase rotation speed';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,(rect(3))-(width),(110),[0 0 0]);
        
        text='Up/Down buttons increase/decrease spatial frequency';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,(rect(3))-(width),(130),[0 0 0]);
        
        text='G toggles between gradient and single line';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,(rect(3))-(width),(150),[0 0 0]);
        
        text='O toggles on/off an outline around the aperture';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,(rect(3))-(width),(170),[0 0 0]);
        
        text='K / L decrease / increase the size of the aperture';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,(rect(3))-(width),(190),[0 0 0]);
        
        text='F toggles on central fixation point';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,(rect(3))-(width),(210),[0 0 0]);
        
        text='I toggles on/off insturctions';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,(rect(3))-(width),(230),[0 0 0]);
    end
    
    Screen('Flip',w);
    
end

ListenChar(0);
Screen('Close',w);
