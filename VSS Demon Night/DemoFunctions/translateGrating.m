% Translate grating - translate the sine wave grating across the screen.
% Only useable while the grating is present (not line). Mainly used for
% auto demo presentation and the DEI displays.

function [gratingTexture,phaseValue,phaseCount,phaseHolder] = translateGrating(translateDEI,phaseValue,phaseCount,phaseHolder,gratingTexture,imSize,inc,gray,w)

if translateDEI == 1
    
    if phaseCount == 1   % Count up
        if phaseValue <= 100 
            phaseValue = phaseValue + 2;
        elseif phaseValue > 100
            phaseCount = 2;
        end
    elseif phaseCount == 2
        if phaseValue >= 2 
            phaseValue = phaseValue - 2;
        elseif phaseValue < 2
            phaseCount = 1;
        end
    end
    
    % Create the grating
    wavelength = .03;
    phaseHolder=(phaseValue/30)*2*pi;
    
    [x,y]=meshgrid(-imSize/2:imSize/2,-imSize/2:imSize/2);
    angle=pi/180; % 30 deg orientation.
    f=wavelength*2*pi; % cycles/pixel
    a=cos(angle)*f;
    b=sin(angle)*f;
    m=sin(a*x+b*y+phaseHolder);
    
    gratingArray = gray+inc*m;
    gratingTexture(2) = Screen('MakeTexture', w, gratingArray);
        
end