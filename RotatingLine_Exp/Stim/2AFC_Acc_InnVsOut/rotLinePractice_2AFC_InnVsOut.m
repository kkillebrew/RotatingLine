function [] = rotLinePractice_2AFC_Acc_180_rot(w,rect,dev_ID,x0,y0,tColor,buttonF,buttonJ,rotSpeed,hz,apLength,apHeight,apTexture,gratingTexture,accRate,texX1,texY1,texX2,texY2,numPracTrials)

% % Instructions
% Screen('TextSize',w,25);
% text='For this block of practice trials,';
% width=RectWidth(Screen('TextBounds',w,text));
% Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
% text='you will see two rotating lines presented one after another.';
% width=RectWidth(Screen('TextBounds',w,text));
% Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
% text='Determine which line was rotating faster.';
% width=RectWidth(Screen('TextBounds',w,text));
% Screen('DrawText',w,text,x0-width/2,y0-100,tColor);
% text='If the first line was rotating faster press ''F''.';
% width=RectWidth(Screen('TextBounds',w,text));
% Screen('DrawText',w,text,x0-width/2,y0,tColor);
% text='If the second line was rotating faster press ''J''.';
% width=RectWidth(Screen('TextBounds',w,text));
% Screen('DrawText',w,text,x0-width/2,y0+100,tColor);
% text='Press any key to begin.';
% width=RectWidth(Screen('TextBounds',w,text));
% Screen('DrawText',w,text,x0-width/2,y0+200,tColor);
% 
% Screen('Flip',w);
% 
% WaitSecs(1);
% KbWait(dev_ID);
% KbReleaseWait(dev_ID);
% 
% for n=1:numPracTrials
%     % Present Stimuli
%     for i=randperm(2)   % present the test or control
%         startTime = GetSecs;
%         orientation1 = randi(360);
%         
%         % Jitter the stim time to prevent subjects from guessing based
%         % on distance rotated
%         stimTime = .8 + (1.2-.8) .* rand(1);
%         
%         % Determine the speed
%         tempSpeed = randi(7);
%         if i == 1
%             actualSpeed1 = rotSpeed(tempSpeed)/hz;
%             repSpeedIdx = tempSpeed;
%         elseif i == 2
%             actualSpeed1 = rotSpeed(4)/hz;
%             repSpeedIdx = 4;
%         end
%         
%         % Randomly determine the direction of rotation
%         rotDir = randi(2);
%         
%         shapeIdx = randi(2);
%         
%         while (GetSecs-startTime) < stimTime
%             
%             % Determine the fixed speed (how much you want to rotate per screen
%             % flip or actualspeed = rotspeed/hz
%             if rotDir == 1
%                 orientation1 = orientation1 + actualSpeed1;
%             else
%                 orientation1 = orientation1 - actualSpeed1;
%             end
%             
%             if i==1   % if test (always short)
%                 Screen('DrawTextures',w,[gratingTexture, apTexture(2)],[],...
%                     [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation1, 0]);
%             elseif i==2   % if compare
%                 if shapeIdx == 1   % if long compare
%                     Screen('DrawTextures',w,[gratingTexture, apTexture(1)],[],...
%                         [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation1, 0]);
%                 elseif shapeIdx ==  2    % if short compare
%                     Screen('DrawTextures',w,[gratingTexture, apTexture(2)],[],...
%                         [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation1, 0]);
%                 end
%             end
%             
%             Screen('Flip',w);
%             
%         end
%         Screen('Flip',w);
%         WaitSecs(.5);
%     end
%     
%     % Response
%     text='Which line was rotating faster?';
%     width=RectWidth(Screen('TextBounds',w,text));
%     Screen('DrawText',w,text,x0-width/2,y0-300,tColor);
%     text='Press ''F'' for first or ''J'' for second.';
%     width=RectWidth(Screen('TextBounds',w,text));
%     Screen('DrawText',w,text,x0-width/2,y0-200,tColor);
%     Screen('Flip',w);
%     [keyIsDown, secs, keycode] = KbCheck(dev_ID);
%     while 1
%         [keyIsDown, secs, keycode] = KbCheck(dev_ID);
%         if keycode(buttonF)   % they chose the first line as going faster
%             break
%         elseif keycode(buttonJ)   % they chose the second line a going faster
%             break
%         end
%     end
% end

% Instructions
Screen('TextSize',w,25);
text='For this block of practice trials,';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-350,tColor);
text='you will again see two rotating lines presented consecutively.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-250,tColor);
text='Each line will rotate 180 degrees.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-150,tColor);
text='Determine which line appeared to change speed more.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-50,tColor);
text='If you thought it was the first line press ''F''.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+50,tColor);
text='If you thought it was the second line press ''J''.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+150,tColor);
text='Press any key to begin.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+250,tColor);

Screen('Flip',w);

WaitSecs(1);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

% Max length of the radius
maxLength = apHeight;

trialCountHolder = 0;
for i=1:numPracTrials
    % Present Stimuli
    accIdx = randi(9);
    trialCountHolder = trialCountHolder + 1;
    
    for j=randperm(2)   % present the test or control
        
        % Determine the direction of rotation
        rotDir = randi(2);
        
        counter = 1;
        % Reset the orientation
        if rotDir == 1   % rotate clockwise
            orientation2(trialCountHolder,counter) = -90;
            dirVal = 1;
        elseif rotDir == 2   % rotate counter-clockwise
            orientation2(trialCountHolder,counter) = 90;
            dirVal = -1;
        end
        
        % Determine the fixed speed (how much you want to rotate per screen
        % flip or actualspeed = rotspeed/hz
        baseSpeed = rotSpeed(4)/hz;
        
        % Initialize variables
        radialLength(counter) = sqrt( 1 / ( ( sind(orientation2(trialCountHolder,counter))/apHeight )^2 + ( cosd(orientation2(trialCountHolder,counter))/apLength )^2 ) );
        
        if j==1   % Test
            constant = accRate(4);
        elseif j==2   % Compare
            constant = accRate(accIdx);
        end
        
        % Change the speed as a function of the length of the radius
        actualSpeed2(counter) = ((((maxLength/radialLength(counter)) - 1) * constant) + baseSpeed) * dirVal;
        
        % Present Stimuli
        startTimer = GetSecs;
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        while 1
            
            % Draw
            Screen('DrawTextures',w,[gratingTexture, apTexture(3)],[],...
                [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]', [orientation2(trialCountHolder,counter), 0])
            
            % Fixation spot
            Screen('FillOval',w,[0 255 0],[x0-3,y0-3,x0+3,y0+3]);
            Screen('FillOval',w,[0 0 0],[x0-1.5,y0-1.5,x0+1.5,y0+1.5]);
            
            Screen('Flip',w);
            
            % Keep track of the radius length to calculate current speed
            radialLength(counter) = sqrt( 1 / ( ( sind(orientation2(trialCountHolder,counter))/apHeight )^2 + ( cosd(orientation2(trialCountHolder,counter))/apLength )^2 ) );
            
            % Change the speed as a function of the length of the radius
            actualSpeed2(counter) = ((((maxLength/radialLength(counter)) - 1) * constant) + baseSpeed) * dirVal;
            
            orientation2(trialCountHolder,counter+1) = orientation2(trialCountHolder,counter) + actualSpeed2(counter);
            
            counter = counter + 1;
            
            if orientation2(trialCountHolder,counter) >= 90 && rotDir == 1   % start at -90 and rotate clockwise to 90
                break
            elseif orientation2(trialCountHolder,counter) <= -90 && rotDir == 2   % start at 90 and rotate counter-clockwise to -90
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

