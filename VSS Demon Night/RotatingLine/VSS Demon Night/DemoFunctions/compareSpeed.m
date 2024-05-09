% Compare speed - Brings up two of the rotating lines (pressing c) that
% are side by side. Can adjust the speed/aperture/rotation/etc. of each
% one seperately by hitting '+', which will toggle back and forth
% between them (indicated by arrow). MUST CALL LAST!

function [combinedTexArray,combinedTexLocationArray,combinedTexRotationArray,toggleCompare,whichCompare,...
    texArray,texArray1,texArray2,texLocationArray,texLocationArray1,texLocationArray2,orientation,orientation1,orientation2,constant,constant1,constant2,radialLength,radialLength1,radialLength2,...
    actualSpeed,actualSpeed1,actualSpeed2,apNumber,apNumber1,apNumber2,drawOutsideToggle,occluded1,occluded2,baseSpeed,baseSpeed1,baseSpeed2,...
    dirVal,dirVal1,dirVal2,apHeight,apHeight1,apHeight2,apLength,apLength1,apLength2,autoRotate,autoRotate1,autoRotate2,...
    drawDotsToggle,drawDotsToggle1,drawDotsToggle2,drawDotsNLine,drawDotsNLine1,drawDotsNLine2] =...
    compareSpeed(combinedTexArray,combinedTexRotationArray,toggleCompare,whichCompare,keycode,buttonC,buttonPlus,...
    texArray,texArray1,texArray2,texLocationArray,texLocationArray1,texLocationArray2,orientation,orientation1,orientation2,constant,constant1,constant2,radialLength,radialLength1,radialLength2,...
    actualSpeed,actualSpeed1,actualSpeed2,apNumber,apNumber1,apNumber2,drawOutsideToggle,occluded1,occluded2,baseSpeed,baseSpeed1,baseSpeed2,...
    dirVal,dirVal1,dirVal2,apHeight,apHeight1,apHeight2,apLength,apLength1,apLength2,autoRotate,autoRotate1,autoRotate2,...
    maxLength,texX1,texY1,texX2,texY2,rect,x0,drawDotsToggle,drawDotsToggle1,drawDotsToggle2,drawDotsNLine,drawDotsNLine1,drawDotsNLine2)

% Toggle on/off
if keycode(buttonC)
    if toggleCompare == 0
        toggleCompare = 1;
        
        % Set all the values of both displays to the value of the previous
        % single display.
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
    elseif toggleCompare == 1
        toggleCompare = 0;
    end
    KbReleaseWait;
end

if toggleCompare == 1

    if keycode(buttonPlus)
        if whichCompare == 1
            whichCompare = 2;
            
            % Reset the original values when changing which display you are
            % working on.
            texArray = texArray2;
            texLocationArray = texLocationArray2;
            radialLength = radialLength2;
            actualSpeed = actualSpeed2;
            orientation = orientation2;
            constant = constant2;
            apNumber = apNumber2;
            drawOutsideToggle = occluded2;
            baseSpeed = baseSpeed2;
            dirVal = dirVal2; 
            autoRotate = autoRotate2;
            drawDotsToggle = drawDotsToggle2;
            drawDotsNLine = drawDotsNLine2;
            
        elseif whichCompare == 2
            whichCompare = 1;
            
            % Reset the original values when changing which display you are
            % working on.
            texArray = texArray1;
            texLocationArray = texLocationArray1;
            radialLength = radialLength1;
            actualSpeed = actualSpeed1;
            orientation = orientation1;
            constant = constant1;
            apNumber = apNumber1;
            drawOutsideToggle = occluded1;
            baseSpeed = baseSpeed1;
            dirVal = dirVal1; 
            autoRotate = autoRotate1;
            drawDotsToggle = drawDotsToggle1;
            drawDotsNLine = drawDotsNLine1;
            
        end
        KbReleaseWait;
    end  
    
    % Update the display that is currently being worked on. Keep the other one
    % as is.
    if whichCompare == 1   % Left side
        % Update textures being drawn
        texArray1 = texArray;
        texLocationArray1 = texLocationArray;
        orientation1 = orientation;
        if autoRotate2 == 1
            radialLength2 = sqrt( 1 / ( ( sind(orientation2)/apHeight2 )^2 + ( cosd(orientation2)/apLength2 )^2 ) );
            actualSpeed2 = ((((maxLength(apNumber2)/radialLength2) - 1) * constant2) + baseSpeed2) * dirVal2;
            orientationLast2 = orientation2;
            orientation2 = orientationLast2 + actualSpeed2;
        end
        constant1 = constant;
        apNumber1 = apNumber;
        occluded1 = drawOutsideToggle;
        baseSpeed1 = baseSpeed;
        dirVal1 = dirVal;
        autoRotate1 = autoRotate;
        drawDotsToggle1 = drawDotsToggle;
        drawDotsNLine1 = drawDotsNLine;
    elseif whichCompare == 2   % Right side
        % Update textures being drawn
        texArray2 = texArray;
        texLocationArray2 = texLocationArray;
        orientation2 = orientation;
        if autoRotate1 == 1
            radialLength1 = sqrt( 1 / ( ( sind(orientation1)/apHeight1 )^2 + ( cosd(orientation1)/apLength1 )^2 ) );
            actualSpeed1 = ((((maxLength(apNumber1)/radialLength1) - 1) * constant1) + baseSpeed1) * dirVal1;
            orientationLast1 = orientation1;
            orientation1 = orientationLast1 + actualSpeed1;
        end
        constant2 = constant;
        apNumber2 = apNumber;
        occluded2 = drawOutsideToggle;
        baseSpeed2 = baseSpeed;
        dirVal2 = dirVal;
        autoRotate2 = autoRotate;
        drawDotsToggle2 = drawDotsToggle;
        drawDotsNLine2 = drawDotsNLine;
    end
    
    
end

% Update the arrays to draw
clear combinedTexArray
combinedTexArray = [texArray1 texArray2];
if occluded1 == 1 && occluded2 == 0
    combinedTexRotationArray = [orientation1 0 0 orientation2 0];
    combinedTexLocationArray = [texX1-(rect(3)/4) texY1 texX2-(rect(3)/4) texY2; (x0-rect(4)/2)-(rect(3)/4), 0, (x0+rect(4)/2)-(rect(3)/4),rect(4); (x0-rect(4)/2)-(rect(3)/4), 0, (x0+rect(4)/2)-(rect(3)/4),rect(4);...
        texX1+(rect(3)/4) texY1 texX2+(rect(3)/4) texY2; (x0-rect(4)/2)+(rect(3)/4), 0, (x0+rect(4)/2)+(rect(3)/4),rect(4)]';
elseif occluded1 == 0 && occluded2 == 1
    combinedTexRotationArray = [orientation1 0 orientation2 0 0];
    combinedTexLocationArray = [texX1-(rect(3)/4) texY1 texX2-(rect(3)/4) texY2; (x0-rect(4)/2)-(rect(3)/4), 0, (x0+rect(4)/2)-(rect(3)/4),rect(4);...
        texX1+(rect(3)/4) texY1 texX2+(rect(3)/4) texY2; (x0-rect(4)/2)+(rect(3)/4), 0, (x0+rect(4)/2)+(rect(3)/4),rect(4);(x0-rect(4)/2)+(rect(3)/4), 0, (x0+rect(4)/2)+(rect(3)/4),rect(4)]';
elseif occluded1 == 1 && occluded2 == 1
    combinedTexRotationArray = [orientation1 0 0 orientation2 0 0];
    combinedTexLocationArray = [texX1-(rect(3)/4) texY1 texX2-(rect(3)/4) texY2; (x0-rect(4)/2)-(rect(3)/4), 0, (x0+rect(4)/2)-(rect(3)/4),rect(4); (x0-rect(4)/2)-(rect(3)/4), 0, (x0+rect(4)/2)-(rect(3)/4),rect(4);...
        texX1+(rect(3)/4) texY1 texX2+(rect(3)/4) texY2; (x0-rect(4)/2)+(rect(3)/4), 0, (x0+rect(4)/2)+(rect(3)/4),rect(4);(x0-rect(4)/2)+(rect(3)/4), 0, (x0+rect(4)/2)+(rect(3)/4),rect(4)]';
elseif occluded1 == 0 && occluded2 == 0
    combinedTexRotationArray = [orientation1 0 orientation2 0];
    combinedTexLocationArray = [texX1-(rect(3)/4) texY1 texX2-(rect(3)/4) texY2; (x0-rect(4)/2)-(rect(3)/4), 0, (x0+rect(4)/2)-(rect(3)/4),rect(4);...
        texX1+(rect(3)/4) texY1 texX2+(rect(3)/4) texY2; (x0-rect(4)/2)+(rect(3)/4), 0, (x0+rect(4)/2)+(rect(3)/4),rect(4)]';
end

end





