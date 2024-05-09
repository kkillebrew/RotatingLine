function [] = rotLinePractice_Stair_AccDec(w,rect,dev_ID,x0,y0,tColor,buttonF,buttonJ,rotSpeed,hz,apTexture,gratingTexture,accRate,texX1,texY1,texX2,texY2,numPracTrials)

% Instructions
Screen('TextSize',w,25);
text='For this block of practice trials,';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
text='you will see two rotating lines presented one after another.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
text='Determine which line was rotating faster.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-100,tColor);
text='If the first line was rotating faster press ''F''.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0,tColor);
text='If the second line was rotating faster press ''J''.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+100,tColor);
text='Press any key to begin';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+200,tColor);

Screen('Flip',w);

WaitSecs(1);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

for n=1:numPracTrials
    % Present Stimuli
    for i=randperm(2)   % present the test or control
        startTime = GetSecs;
        orientation1 = randi(360);
        
        % Jitter the stim time to prevent subjects from guessing based
        % on distance rotated
        stimTime = .8 + (1.2-.8) .* rand(1);
        
        % Determine the speed
        tempSpeed = randi(7);
        if i == 1
            actualSpeed1 = rotSpeed(tempSpeed)/hz;
            repSpeedIdx = tempSpeed;
        elseif i == 2
            actualSpeed1 = rotSpeed(4)/hz;
            repSpeedIdx = 4;
        end
        
        % Randomly determine the direction of rotation
        rotDir = randi(2);
        
        shapeIdx = randi(2);
        
        while (GetSecs-startTime) < stimTime
            
            % Determine the fixed speed (how much you want to rotate per screen
            % flip or actualspeed = rotspeed/hz
            if rotDir == 1
                orientation1 = orientation1 + actualSpeed1;
            else
                orientation1 = orientation1 - actualSpeed1;
            end
            
            if i==1   % if test (always short)
                Screen('DrawTextures',w,[gratingTexture, apTexture(2)],[],...
                    [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation1, 0]);
            elseif i==2   % if compare
                if shapeIdx == 1   % if long compare
                    Screen('DrawTextures',w,[gratingTexture, apTexture(1)],[],...
                        [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation1, 0]);
                elseif shapeIdx ==  2    % if short compare
                    Screen('DrawTextures',w,[gratingTexture, apTexture(2)],[],...
                        [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation1, 0]);
                end
            end
            
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
        if keycode(buttonF)   % they chose the first line as going faster
            break
        elseif keycode(buttonJ)   % they chose the second line a going faster
            break
        end
    end
end

% Instructions
Screen('TextSize',w,25);
text='For this block of practice trials,';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
text='you will see one line rotating from vertical to horizontal.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
text='Determine whether it was accelerating or deccelerating.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-100,tColor);
text='If it was deccelerating press ''F''.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0,tColor);
text='If it was accelerating press ''J''.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+100,tColor);
text='Press any key to begin';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+200,tColor);

Screen('Flip',w);

WaitSecs(1);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

trialCountHolder = 0;
for i=1:numPracTrials
    % Present Stimuli
    counter = 1;
    accIdx = randi(9);
    trialCountHolder = trialCountHolder + 1; 
    orientation2(trialCountHolder,counter) = 0;
    
    % Determine the direction of rotation
    rotDir = randi(2);
    
    % Determine the start/end speed
    startSpeed = rotSpeed(4);
    finalSpeed = startSpeed + accRate(accIdx);   % Determined by the staircase
    % Determine the aceleration
    acceleration = ((finalSpeed/hz)^2 - (startSpeed/hz)^2) / (90*2);
    % Determine velocity using acceleration
    actualSpeed2(trialCountHolder,1) = startSpeed/hz;
    
    startTimer = GetSecs;
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    while 1
        if floor(orientation2(trialCountHolder,counter)) < 90 && floor(orientation2(trialCountHolder,counter)) > -90
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            
            Screen('DrawTextures',w,[gratingTexture, apTexture(3)],[],...
                [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation2(trialCountHolder,counter), 0]);
            
            Screen('Flip',w);
            
            counter = counter + 1;
            if rotDir == 1
                orientation2(trialCountHolder,counter) = orientation2(trialCountHolder,counter-1) + actualSpeed2(trialCountHolder,counter-1);
                actualSpeed2(trialCountHolder,counter) = actualSpeed2(trialCountHolder,counter-1) + acceleration;
            elseif rotDir == 2
                orientation2(trialCountHolder,counter) = orientation2(trialCountHolder,counter-1) - actualSpeed2(trialCountHolder,counter-1);
                actualSpeed2(trialCountHolder,counter) = actualSpeed2(trialCountHolder,counter-1) + acceleration;
            end
        else
            break
        end
    end
    
    
    % Response
    text='Was the line accelerating or deccelerating?';
    width=RectWidth(Screen('TextBounds',w,text));
    Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
    text='Press ''F'' for deccelerating or ''J'' for accelerating.';
    width=RectWidth(Screen('TextBounds',w,text));
    Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
    Screen('Flip',w);
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    while 1
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        if keycode(buttonF)   % they choose deccelerating
            break
        elseif keycode(buttonJ)   % they choose accelerating
            break
        end
    end
end


% Final instructions
Screen('TextSize',w,25);
text='Now that you''ve finished the practice trials,';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
text='we will start the experiment.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
text='You will be told which type of trials each block contains';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-100,tColor);
text='before the start of that block.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0,tColor);
text='Press any key to begin';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+100,tColor);

Screen('Flip',w);

WaitSecs(1);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

end


