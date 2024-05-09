% Draw the given textures in array [t1 t1...tn] using
% coordinate array [t1x1 t1y1 t1x2 t1y2;...tnx1 tny1 tnx2 tny2]

function [orientation,actualSpeed,radialLength,texRotationArray,texArray] = ...
    drawDemo(w,radialLength,orientation,actualSpeed,constant,baseSpeed,dirVal,apHeight,apLength,apSize,maxLength,texArray,texLocationArray,texRotationArray,...
    autoRotate,apNumber,combinedTexArray,combinedTexLocationArray,combinedTexRotationArray,toggleCompare,drawDotsToggle,gratingNumber,drawOutsideToggle,...
    x0,rect,whichCompare,whichPart,autoRunToggle)

if toggleCompare == 0
    Screen('DrawTextures',w,texArray,[],texLocationArray,texRotationArray);
elseif toggleCompare == 1
    Screen('DrawTextures',w,combinedTexArray,[],combinedTexLocationArray,combinedTexRotationArray);
end

if apNumber == 3   % Elipse
    if gratingNumber == 1 || gratingNumber == 3   % Line
        
        % Change the center points for drawing dots depending on what is
        % occluded.
        if drawDotsToggle ~= 0
            if toggleCompare == 0
                dotLocArray = [x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)];
            elseif toggleCompare == 1
                if whichCompare == 1
                    dotLocArray = [(x0-rect(4)/2)-(rect(3)/4), 0, (x0+rect(4)/2)-(rect(3)/4),rect(4)];
                elseif whichCompare ==2
                    dotLocArray = [(x0-rect(4)/2)+(rect(3)/4), 0, (x0+rect(4)/2)+(rect(3)/4),rect(4)];
                end
            end
        end
        
        if drawDotsToggle == 1   % Draw the dots on the inside aperture
            radialLengthDot = sqrt( 1 / ( ( sind(orientation)/apHeight )^2 + ( cosd(orientation)/apLength )^2 ) );
            colorArray = [0 255 0];
        elseif drawDotsToggle == 2 && drawOutsideToggle == 1   % Draw along the outside aperture
            radialLengthDot = round(apSize*(3/2));
            colorArray = [255 0 0];
        elseif drawDotsToggle == 3 && drawOutsideToggle == 1
            radialLengthDot = sqrt( 1 / ( ( sind(orientation)/apHeight )^2 + ( cosd(orientation)/apLength )^2 ) );
            colorArray = [0 255 0];
            radialLengthDot2 = round(apSize*(3/2));
            colorArray2 = [255 0 0];
        end
        
        if drawDotsToggle ~= 0
            dotX1 = (dotLocArray(3)-(dotLocArray(3)-dotLocArray(1))/2) + radialLengthDot/2 * cosd(orientation+90);
            dotY1 = (dotLocArray(4)-(dotLocArray(4)-dotLocArray(2))/2) + radialLengthDot/2 * sind(orientation+90);
            dotX2 = (dotLocArray(3)-(dotLocArray(3)-dotLocArray(1))/2) + radialLengthDot/2 * cosd(orientation-90);
            dotY2 = (dotLocArray(4)-(dotLocArray(4)-dotLocArray(2))/2) + radialLengthDot/2 * sind(orientation-90);
            
            Screen('FillOval',w,colorArray,[dotX1-3,dotY1-3,dotX1+3,dotY1+3]);
            Screen('FillOval',w,colorArray,[dotX2-3,dotY2-3,dotX2+3,dotY2+3]);
            if drawDotsToggle == 3
                dotX1 = (dotLocArray(3)-(dotLocArray(3)-dotLocArray(1))/2) + radialLengthDot2/2 * cosd(orientation+90);
                dotY1 = (dotLocArray(4)-(dotLocArray(4)-dotLocArray(2))/2) + radialLengthDot2/2 * sind(orientation+90);
                dotX2 = (dotLocArray(3)-(dotLocArray(3)-dotLocArray(1))/2) + radialLengthDot2/2 * cosd(orientation-90);
                dotY2 = (dotLocArray(4)-(dotLocArray(4)-dotLocArray(2))/2) + radialLengthDot2/2 * sind(orientation-90);
                
                Screen('FillOval',w,colorArray2,[dotX1-3,dotY1-3,dotX1+3,dotY1+3]);
                Screen('FillOval',w,colorArray2,[dotX2-3,dotY2-3,dotX2+3,dotY2+3]);
            end
        end
        
    end
end

% If autorundemo, draw text at the bottom of screen.
if autoRunToggle == 1
    if whichPart == 1
        demoText = 'Which line appears to rotate at a constant speed?';
        height =RectHeight(Screen('TextBounds',w,demoText));
        width = RectWidth(Screen('TextBounds',w,demoText));
    elseif whichPart == 2
        demoText = 'The Drifting Edge Illusion. Caplovitz, Paymer, & Tse, 2008';
        height =RectHeight(Screen('TextBounds',w,demoText));
        width = RectWidth(Screen('TextBounds',w,demoText));
    elseif whichPart == 3
        demoText = 'What if we rotate the grating?';
        height =RectHeight(Screen('TextBounds',w,demoText));
        width = RectWidth(Screen('TextBounds',w,demoText));
    elseif whichPart == 4
        demoText = 'It works with a rectangular aperture.';
        height =RectHeight(Screen('TextBounds',w,demoText));
        width = RectWidth(Screen('TextBounds',w,demoText));
    elseif whichPart == 5
        demoText = '...and an eliptical aperture.';
        height =RectHeight(Screen('TextBounds',w,demoText));
        width = RectWidth(Screen('TextBounds',w,demoText));
    elseif whichPart == 6
        demoText = '...and a line instead of a grating.';
        height =RectHeight(Screen('TextBounds',w,demoText));
        width = RectWidth(Screen('TextBounds',w,demoText));
    elseif whichPart == 7
        demoText = 'Can this be explained by a difference in line size?';
        height =RectHeight(Screen('TextBounds',w,demoText));
        width = RectWidth(Screen('TextBounds',w,demoText));
    elseif whichPart == 8
        demoText = 'What if we modulate the speed as a function of the line length?';
        height =RectHeight(Screen('TextBounds',w,demoText));
        width = RectWidth(Screen('TextBounds',w,demoText));
    elseif whichPart == 9
        demoText = 'Back to the unmodulated line.';
        height =RectHeight(Screen('TextBounds',w,demoText));
        width = RectWidth(Screen('TextBounds',w,demoText));
    elseif whichPart == 10
        demoText = 'What if we occlude the center of the line?';
        height =RectHeight(Screen('TextBounds',w,demoText));
        width = RectWidth(Screen('TextBounds',w,demoText));
    elseif whichPart == 11
        demoText = 'Pay attention to the dots. Is the line moving at a constant speed?';
        height =RectHeight(Screen('TextBounds',w,demoText));
        width = RectWidth(Screen('TextBounds',w,demoText));
    end
    Screen('TextSize',w,25);
    Screen('DrawText',w,demoText,x0-width/2, (rect(4)-200)-height/2,[0 0 0]);
end

Screen('Flip',w);

if autoRotate == 1
    % Keep track of the radius length to calculate current speed
    radialLength = sqrt( 1 / ( ( sind(orientation)/apHeight )^2 + ( cosd(orientation)/apLength )^2 ) );
    
    % Change the speed as a function of the length of the radius
    actualSpeed = ((((maxLength(apNumber)/radialLength) - 1) * constant) + baseSpeed) * dirVal;
    
    orientationLast = orientation;
    orientation = orientationLast + actualSpeed;

end

% Update Arrays
texRotationArray(1) = orientation;

end