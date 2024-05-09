% Change which part of the line is occluded by changing the texutre arrays that are drawn.

function [drawOutsideToggle,texArray,texLocationArray,texRotationArray] =...
    drawOutside(drawOutsideToggle,texArray,texLocationArray,texRotationArray,...
    buttonO,keycode,apTexture,rect,x0,apNumber,apTotal)

if keycode(buttonO)
    if drawOutsideToggle == 1
        drawOutsideToggle = 0;
    elseif drawOutsideToggle == 0
        drawOutsideToggle = 1;
    end    
    KbReleaseWait;
end

if drawOutsideToggle == 0   % Draw inside aperture
    texArray(2) = apTexture(apNumber);
    texLocationArray(:,2) = [x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]';
    
    % If there is a third texture slot delete it
    if size(texArray,2) == 3
        texArray(3) = [];
    end
    if size(texLocationArray,2) == 3
        texLocationArray(:,3) = [];
    end
    if size(texRotationArray,2) == 3
        texRotationArray(3) = [];
    end
    
elseif drawOutsideToggle == 1   % Draw outside aperture
    
    texArray(2:3) = [apTexture(apTotal*2+1),apTexture(apNumber+apTotal)];
    texLocationArray(:,2:3) = [x0-rect(4)/2, 0, x0+rect(4)/2,rect(4);x0-rect(4)/2, 0, x0+rect(4)/2,rect(4)]';
    texRotationArray(3) = 0;
    
end

end

