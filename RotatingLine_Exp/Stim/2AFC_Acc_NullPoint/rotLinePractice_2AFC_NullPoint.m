function [] = rotLinePractice_2AFC_NullPoint(w,rect,dev_ID,x0,y0,tColor,buttonF,buttonJ,rotSpeed,hz,apLengthEl,apHeightEl,maxLength,apTexture,gratingTexture,accRate,texX1,texY1,texX2,texY2,numPracTrials)

% Insructions
Screen('TextSize',w,15);
text='For each trial you will see a line rotating 180 degrees.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-400,tColor);
text='Determine whether or not the speed of the line is changing or constant.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
text='If you thought it was changing speed press ''F''.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
text='If you thought it was rotating at a constant speed press ''J''.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-100,tColor);
text='Remember to only judge changes in speed and not overall speed.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0,tColor);
text='For example, some lines may appear slow or fast but may not change their speed during rotation.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+100,tColor);
text='Press any key to begin.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+200,tColor);
Screen('Flip',w);

WaitSecs(1);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

% Give them examples of max change, no change, and middle
this = randi(3,numPracTrials,1);
accList = [1 5 9];
that = randi(2,numPracTrials,1);
speedList = [1 2];
these = randi(2,numPracTrials,1);
apOriList = [1 2];

% Rotation variables
rotSpeed = [30 60];   % number of degrees / second

% Acceleration variables (as a function of rotational speed)
accRate = [.75 1.5 1.75 1.9 2.0 2.1 2.25 2.5 3.25];

trialCountHolder = 0;
for i=1:numPracTrials
    
    % Present Stimuli
    accIdx = accList(this(i));
    
    trialCountHolder = trialCountHolder + 1;
    
    speedIdx = speedList(that(i));
    
    apOriIdx = apOriList(these(i));
        
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
    
    % Determine what constant value to use based on the position in the
    % staircase
    constant = accRate(accIdx);
    
    % Set the texture list (lineTex, largeTex, ~elipTex)
    texList = [gratingTexture, apTexture(apOriIdx)];
    texLocList = [texX1 texY1 texX2 texY2; x0-rect(4)/2,0,x0+rect(4)/2,rect(4)]';
    texRotList = [orientation, 0];
    
    % Determine the fixed speed (how much you want to rotate per screen
    % flip or actualspeed = rotspeed/hz
    baseSpeed = rotSpeed(speedIdx)/hz;
    
    % Initialize variables
    radialLength = sqrt( 1 / ( ( sind(orientation)/apHeightEl(apOriIdx) )^2 + ( cosd(orientation)/apLengthEl(apOriIdx) )^2 ) );
    
    % Change the speed as a function of the length of the radius
    actualSpeed = (baseSpeed + ((maxLength./radialLength)-1)*(constant-1)*baseSpeed)*dirVal;
    
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
        actualSpeed = (baseSpeed + ((maxLength./radialLength)-1)*(constant-1)*baseSpeed)*dirVal;
        
        orientationLast = orientation;
        orientation = orientationLast + actualSpeed;
        texRotList(1)=orientation;
                
        if orientation >= 90 && rotDir == 1   % start at -90 and rotate clockwise to 90
            break
        elseif orientation <= -90 && rotDir == 2   % start at 90 and rotate counter-clockwise to -90
            break
        end
        
    end

    % Response
    text='Was the line changing speed?';
    width=RectWidth(Screen('TextBounds',w,text));
    Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
    text='Press ''F'' for changing speed or ''J'' for constant speed.';
    width=RectWidth(Screen('TextBounds',w,text));
    Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
    Screen('Flip',w);
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    while 1
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        if keycode(buttonF)   % they choose changing speed
            break
        elseif keycode(buttonJ)   % they choose constant speed
            break
        end
    end
    
    Screen('Flip',w);
    WaitSecs(.5);
    
end

% Insructions
Screen('TextSize',w,25);
text='Now that practice is over, the experiment will begin.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-400,tColor);
text='If you are confused, please feel free to ask any questions to the experimenter.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
text='Press any key to begin.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
Screen('Flip',w);

WaitSecs(1);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

end


