% Will go through an (limited) interactive demo of the rotating line.

function [whichPart,autoRunToggle] = autorunDemo(whichPart,autoRunToggle,apTexture,gratingTexture,radialLength,orientation,actualSpeed,baseSpeed,...
    dirVal,apHeight,apLength,maxLength,texArray,texLocationArray,texRotationArray,whichCompare,...
    autoRotate,apNumber,combinedTexArray,combinedTexLocationArray,combinedTexRotationArray,toggleCompare,...
    translateDEI,phaseValue,phaseCount,phaseHolder,drawDotsNLine,drawDotsToggle,gratingNumber,drawOutsideToggle,...
    dev_ID,button1,button2,button3,buttonSpace,buttonEscape,buttonS,apSize,imSize,texX1,texY1,texX2,texY2,gray,inc,rect,x0,w,hz)


if whichPart == 1
    %% Compare modulated vs not modulated
    
    toggleCompare = 1;
    constant = 1;
    orientation = randi(359);
    orientation2 =  randi(359);
    
    combinedTexArray = [gratingTexture(1), apTexture(3),gratingTexture(1), apTexture(3)];
 
    while 1
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
                
        % Calculate the orientation for the right display (not modulating).
        radialLength2 = sqrt( 1 / ( ( sind(orientation2)/apHeight )^2 + ( cosd(orientation2)/apLength )^2 ) );
        actualSpeed2 = ((((maxLength(3)/radialLength2) - 1) * 0) + baseSpeed) * dirVal;
        orientationLast2 = orientation2;
        orientation2 = orientationLast2 + actualSpeed2;
  
        combinedTexRotationArray = [orientation, 0, orientation2, 0];
        
        % Draw
        [orientation,actualSpeed,radialLength,texRotationArray,texArray] = ...
            drawDemo(w,radialLength,orientation,actualSpeed,constant,baseSpeed,dirVal,apHeight,apLength,apSize,maxLength,texArray,texLocationArray,texRotationArray,...
            autoRotate,apNumber,combinedTexArray,combinedTexLocationArray,combinedTexRotationArray,toggleCompare,drawDotsToggle,gratingNumber,drawOutsideToggle,...
            x0,rect,whichCompare,whichPart,autoRunToggle);
        
        
        if keycode(buttonSpace)
            whichPart = 2;
            KbReleaseWait;
            break
        elseif keycode(buttonEscape)
            break
        elseif keycode(button1)
            whichPart = 1;
            KbReleaseWait;
            break
        elseif keycode(button2)
            autoRunToggle = 2;
            KbReleaseWait;
            break
        elseif keycode(button3)
            whichPart = 11;
            KbReleaseWait;
            break
        end
    end
    
end

constant = 0;

if whichPart == 2  
    %% Draw the two DEI
    
    % Set the values you want here
    translateDEI = 1;
    toggleCompare = 1;
    autoRotate = 0;
    orientation = 25;
    
    % Make the texture for the second DEI display
    n = floor(rect(4));
    alphaLayer = ones(n,n).*255;
    
    xAp(1) = length(alphaLayer)/2 - round(apSize)/2;
    yAp(1) = length(alphaLayer)/2;
    xAp(2) = length(alphaLayer)/2 + round(apSize)/2;
    yAp(2) = length(alphaLayer)/2 - round(apSize/3);
    xAp(3) = length(alphaLayer)/2 - round(apSize)/2;
    yAp(3) = length(alphaLayer)/2 + round(apSize/3);
    xAp(4) = length(alphaLayer)/2 + round(apSize)/2;
    yAp(4) = length(alphaLayer)/2;
    
    % Found solution at: https://www.mathworks.com/matlabcentral/answers/67664-how-to-make-triangle-for-a-synthetic-image-in-gray-scale
    xCoords = [xAp(1) xAp(2) xAp(4) xAp(3)];
    yCoords = [yAp(1) yAp(2) yAp(4) yAp(3)];
    mask = poly2mask(xCoords, yCoords, length(alphaLayer), length(alphaLayer));
    alphaLayer(mask) = 0; % or whatever value you want.
    
    apertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
    apertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
    apertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
    apertureArray(rect(4)/4:rect(4)-rect(4)/4,round((size(apertureArray,1)/2)-apSize/2)+1:round((size(apertureArray,1)/2)+apSize/2),1:3) = 0;   % Add in a black strip the length of the aperture
    apertureArray(:,:,4) = alphaLayer;
    newApTexture = Screen('MakeTexture',w,apertureArray);
    
    clear apertureArray n alphaLayer
    
    combinedTexArray = [gratingTexture(2), apTexture(6),gratingTexture(2), newApTexture];
    combinedTexLocationArray = [texX1-(rect(3)/4) texY1 texX2-(rect(3)/4) texY2; (x0-rect(4)/2)-(rect(3)/4), 0, (x0+rect(4)/2)-(rect(3)/4),rect(4);...
        texX1+(rect(3)/4) texY1 texX2+(rect(3)/4) texY2; (x0-rect(4)/2)+(rect(3)/4), 0, (x0+rect(4)/2)+(rect(3)/4),rect(4)]';
    combinedTexRotationArray = [orientation, 0, orientation, 0];
    
    while 1
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        
        [gratingTexture,phaseValue,phaseCount,phaseHolder] = translateGrating(translateDEI,phaseValue,phaseCount,phaseHolder,gratingTexture,imSize,inc,gray,w);
        
        combinedTexArray(1) = gratingTexture(2);
        combinedTexArray(3) = gratingTexture(2);
        
        % Draw
        [orientation,actualSpeed,radialLength,texRotationArray,texArray] = ...
            drawDemo(w,radialLength,orientation,actualSpeed,constant,baseSpeed,dirVal,apHeight,apLength,apSize,maxLength,texArray,texLocationArray,texRotationArray,...
            autoRotate,apNumber,combinedTexArray,combinedTexLocationArray,combinedTexRotationArray,toggleCompare,drawDotsToggle,gratingNumber,drawOutsideToggle,...
            x0,rect,whichCompare,whichPart,autoRunToggle);
        
        
        if keycode(buttonSpace)
            whichPart = 3;
            KbReleaseWait;
            break
        elseif keycode(buttonEscape)
            break
        elseif keycode(button1)
            whichPart = 1;
            KbReleaseWait;
            break
        elseif keycode(button2)
            autoRunToggle = 2;
            KbReleaseWait;
            break
        elseif keycode(button3)
            whichPart = 1;
            KbReleaseWait;
            break
        end
    end
end

if whichPart == 3   
    %% Draw the DEI in the center rotating
    
    % Set the values you want here
    translateDEI = 0;
    toggleCompare = 0;
    autoRotate = 1;
    
    texArray = [gratingTexture(2), apTexture(6)];
    texLocationArray = [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]';
    texRotationArray = [orientation, 0];
    
    while 1
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        
        % Draw
        [orientation,actualSpeed,radialLength,texRotationArray,texArray] = ...
            drawDemo(w,radialLength,orientation,actualSpeed,constant,baseSpeed,dirVal,apHeight,apLength,apSize,maxLength,texArray,texLocationArray,texRotationArray,...
            autoRotate,apNumber,combinedTexArray,combinedTexLocationArray,combinedTexRotationArray,toggleCompare,drawDotsToggle,gratingNumber,drawOutsideToggle,...
            x0,rect,whichCompare,whichPart,autoRunToggle);
        
        if keycode(buttonSpace)
            whichPart = 4;
            KbReleaseWait;
            break
        elseif keycode(buttonEscape)
            break
        elseif keycode(button1)
            KbReleaseWait;
            whichPart = 1;
            break
        elseif keycode(button2)
            autoRunToggle = 2;
            KbReleaseWait;
            break
        elseif keycode(button3)
            whichPart = 2;
            KbReleaseWait;
            break
        end
    end
end
    
if whichPart == 4   
    %% Draw it in a rectangle
    
    texArray = [gratingTexture(2), apTexture(5)];
    
    while 1
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        
        % Draw
        [orientation,actualSpeed,radialLength,texRotationArray,texArray] = ...
            drawDemo(w,radialLength,orientation,actualSpeed,constant,baseSpeed,dirVal,apHeight,apLength,apSize,maxLength,texArray,texLocationArray,texRotationArray,...
            autoRotate,apNumber,combinedTexArray,combinedTexLocationArray,combinedTexRotationArray,toggleCompare,drawDotsToggle,gratingNumber,drawOutsideToggle,...
            x0,rect,whichCompare,whichPart,autoRunToggle);
        
        if keycode(buttonSpace)
            whichPart = 5;
            KbReleaseWait;
            break
        elseif keycode(buttonEscape)
            break
        elseif keycode(button1)
            whichPart = 1;
            KbReleaseWait;
            break
        elseif keycode(button2)
            autoRunToggle = 2;
            KbReleaseWait;
            break
        elseif keycode(button3)
            whichPart = 3;
            KbReleaseWait;
            break
        end
    end
end

if whichPart == 5   
    %% Draw it in an ellipse
    
    texArray = [gratingTexture(2), apTexture(3)];
    
    while 1
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        
        % Draw
        [orientation,actualSpeed,radialLength,texRotationArray,texArray] = ...
            drawDemo(w,radialLength,orientation,actualSpeed,constant,baseSpeed,dirVal,apHeight,apLength,apSize,maxLength,texArray,texLocationArray,texRotationArray,...
            autoRotate,apNumber,combinedTexArray,combinedTexLocationArray,combinedTexRotationArray,toggleCompare,drawDotsToggle,gratingNumber,drawOutsideToggle,...
            x0,rect,whichCompare,whichPart,autoRunToggle);
        
        if keycode(buttonSpace)
            whichPart = 6;
            KbReleaseWait;
            break
        elseif keycode(buttonEscape)
            break
        elseif keycode(button1)
            whichPart = 1;
            KbReleaseWait;
            break
        elseif keycode(button2)
            autoRunToggle = 2;
            KbReleaseWait;
            break
        elseif keycode(button3)
            whichPart = 4;
            KbReleaseWait;
            break
        end
    end
end

if whichPart == 6
    %% Draw it with a line
    
    texArray = [gratingTexture(1), apTexture(3)];
    
    while 1
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        
        % Draw
        [orientation,actualSpeed,radialLength,texRotationArray,texArray] = ...
            drawDemo(w,radialLength,orientation,actualSpeed,constant,baseSpeed,dirVal,apHeight,apLength,apSize,maxLength,texArray,texLocationArray,texRotationArray,...
            autoRotate,apNumber,combinedTexArray,combinedTexLocationArray,combinedTexRotationArray,toggleCompare,drawDotsToggle,gratingNumber,drawOutsideToggle,...
            x0,rect,whichCompare,whichPart,autoRunToggle);
        
        
        if keycode(buttonSpace)
            whichPart = 7;
            KbReleaseWait;
            break
        elseif keycode(buttonEscape)
            break
        elseif keycode(button1)
            whichPart = 1;
            KbReleaseWait;
            break
        elseif keycode(button2)
            autoRunToggle = 2;
            KbReleaseWait;
            break
        elseif keycode(button3)
            whichPart = 5;
            KbReleaseWait;
            break
        end
    end
    
end

if whichPart == 7
    %% Compare big vs small
    
    toggleCompare = 1;
    orientation2 =  randi(359);
    
    combinedTexArray = [gratingTexture(1), apTexture(1),gratingTexture(1), apTexture(2)];
    
    while 1
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        
        % Calculate the orientation for the right display (not modulating).
        radialLength2 = sqrt( 1 / ( ( sind(orientation2)/apHeight )^2 + ( cosd(orientation2)/apLength )^2 ) );
        actualSpeed2 = ((((maxLength(3)/radialLength2) - 1) * 0) + baseSpeed) * dirVal;
        orientationLast2 = orientation2;
        orientation2 = orientationLast2 + actualSpeed2;
        
        combinedTexRotationArray = [orientation, 0, orientation2, 0];
        
        % Draw
        [orientation,actualSpeed,radialLength,texRotationArray,texArray] = ...
            drawDemo(w,radialLength,orientation,actualSpeed,constant,baseSpeed,dirVal,apHeight,apLength,apSize,maxLength,texArray,texLocationArray,texRotationArray,...
            autoRotate,apNumber,combinedTexArray,combinedTexLocationArray,combinedTexRotationArray,toggleCompare,drawDotsToggle,gratingNumber,drawOutsideToggle,...
            x0,rect,whichCompare,whichPart,autoRunToggle);
        
        
        if keycode(buttonSpace)
            whichPart = 8;
            KbReleaseWait;
            break
        elseif keycode(buttonEscape)
            break
        elseif keycode(button1)
            whichPart = 1;
            KbReleaseWait;
            break
        elseif keycode(button2)
            autoRunToggle = 2;
            KbReleaseWait;
            break
        elseif keycode(button3)
            whichPart = 6;
            KbReleaseWait;
            break
        end
    end
    
end

if whichPart == 8
    %% Compare modulated vs not modulated
    
    toggleCompare = 1;
    constant = 1;
    orientation2 =  randi(359);
    
    combinedTexArray = [gratingTexture(1), apTexture(3),gratingTexture(1), apTexture(3)];
 
    while 1
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
                
        % Calculate the orientation for the right display (not modulating).
        radialLength2 = sqrt( 1 / ( ( sind(orientation2)/apHeight )^2 + ( cosd(orientation2)/apLength )^2 ) );
        actualSpeed2 = ((((maxLength(3)/radialLength2) - 1) * 0) + baseSpeed) * dirVal;
        orientationLast2 = orientation2;
        orientation2 = orientationLast2 + actualSpeed2;
  
        combinedTexRotationArray = [orientation, 0, orientation2, 0];
        
        % Draw
        [orientation,actualSpeed,radialLength,texRotationArray,texArray] = ...
            drawDemo(w,radialLength,orientation,actualSpeed,constant,baseSpeed,dirVal,apHeight,apLength,apSize,maxLength,texArray,texLocationArray,texRotationArray,...
            autoRotate,apNumber,combinedTexArray,combinedTexLocationArray,combinedTexRotationArray,toggleCompare,drawDotsToggle,gratingNumber,drawOutsideToggle,...
            x0,rect,whichCompare,whichPart,autoRunToggle);
        
        
        if keycode(buttonSpace)
            whichPart = 9;
            KbReleaseWait;
            break
        elseif keycode(buttonEscape)
            break
        elseif keycode(button1)
            whichPart = 1;
            KbReleaseWait;
            break
        elseif keycode(button2)
            autoRunToggle = 2;
            KbReleaseWait;
            break
        elseif keycode(button3)
            whichPart = 7;
            KbReleaseWait;
            break
        end
    end
    
end

if whichPart == 9
    %% Show one that is not modulating
    
    toggleCompare = 0;
    constant = 0;
    
    texArray = [gratingTexture(1), apTexture(3)];
    texLocationArray = [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]';
    texRotationArray = [orientation, 0];
    
    while 1
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        
        % Draw
        [orientation,actualSpeed,radialLength,texRotationArray,texArray] = ...
            drawDemo(w,radialLength,orientation,actualSpeed,constant,baseSpeed,dirVal,apHeight,apLength,apSize,maxLength,texArray,texLocationArray,texRotationArray,...
            autoRotate,apNumber,combinedTexArray,combinedTexLocationArray,combinedTexRotationArray,toggleCompare,drawDotsToggle,gratingNumber,drawOutsideToggle,...
            x0,rect,whichCompare,whichPart,autoRunToggle);
        
        
        if keycode(buttonSpace)
            whichPart = 10;
            KbReleaseWait;
            break
        elseif keycode(buttonEscape)
            break
        elseif keycode(button1)
            whichPart = 1;
            KbReleaseWait;
            break
        elseif keycode(button2)
            autoRunToggle = 2;
            KbReleaseWait;
            break
        elseif keycode(button3)
            whichPart = 8;
            KbReleaseWait;
            break
        end
    end
    
end

if whichPart == 10
    %% Inside occluded
    
    toggleCompare = 0;
    constant = 0;
    
    texArray = [gratingTexture(1), apTexture(13),apTexture(9)];
    texLocationArray = [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4); x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]';
    texRotationArray = [orientation, 0, 0];
    
    while 1
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        
        % Draw
        [orientation,actualSpeed,radialLength,texRotationArray,texArray] = ...
            drawDemo(w,radialLength,orientation,actualSpeed,constant,baseSpeed,dirVal,apHeight,apLength,apSize,maxLength,texArray,texLocationArray,texRotationArray,...
            autoRotate,apNumber,combinedTexArray,combinedTexLocationArray,combinedTexRotationArray,toggleCompare,drawDotsToggle,gratingNumber,drawOutsideToggle,...
            x0,rect,whichCompare,whichPart,autoRunToggle);
        
        
        if keycode(buttonSpace)
            whichPart = 11;
            KbReleaseWait;
            break
        elseif keycode(buttonEscape)
            break
        elseif keycode(button1)
            whichPart = 1;
            KbReleaseWait;
            break
        elseif keycode(button2)
            autoRunToggle = 2;
            KbReleaseWait;
            break
        elseif keycode(button3)
            whichPart = 9;
            KbReleaseWait;
            break
        end
    end
    
end

if whichPart == 11
    %% Inside occluded w/ dots on inside
    
    drawDotsToggle = 1;
    drawOutsideToggle = 1;
    toggleCompare = 0;
    
    texArray = [gratingTexture(1), apTexture(13),apTexture(9)];
    texLocationArray = [texX1 texY1 texX2 texY2; x0-rect(4)/2, 0, x0+rect(4)/2,rect(4); x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]';
    texRotationArray = [orientation, 0, 0];
    
    while 1
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        
        % Draw
        [orientation,actualSpeed,radialLength,texRotationArray,texArray] = ...
            drawDemo(w,radialLength,orientation,actualSpeed,constant,baseSpeed,dirVal,apHeight,apLength,apSize,maxLength,texArray,texLocationArray,texRotationArray,...
            autoRotate,apNumber,combinedTexArray,combinedTexLocationArray,combinedTexRotationArray,toggleCompare,drawDotsToggle,gratingNumber,drawOutsideToggle,...
            x0,rect,whichCompare,whichPart,autoRunToggle);
        
        
        if keycode(buttonSpace)
            whichPart = 1;
            KbReleaseWait;
            break
        elseif keycode(buttonEscape)
            break
        elseif keycode(buttonS)
            if drawDotsToggle == 1 
                drawDotsToggle = 2;
            elseif drawDotsToggle == 2
                drawDotsToggle = 1;
            end
            KbReleaseWait;
        elseif keycode(button1)
            whichPart = 1;
            KbReleaseWait;
            break
        elseif keycode(button2)
            autoRunToggle = 2;
            KbReleaseWait;
            break
        elseif keycode(button3)
            whichPart = 10;
            KbReleaseWait;
            break
        end
    end
    
end

end