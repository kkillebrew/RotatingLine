% Toggle modulation - toggle on/off modulation of speed to cancle
% effect

function [constant,constantHolder,toggleModulation] = modulateSpeed(constant,constantHolder,toggleModulation,buttonM,keycode,buttonLeft,buttonRight)

% Toggle on/off modulation
if keycode(buttonM)
    if toggleModulation == 0
        toggleModulation = 1;
        constant = constantHolder;
    elseif toggleModulation == 1
        toggleModulation = 0;
        constant = 0;
    end
    KbReleaseWait;
end

if toggleModulation == 1
    if keycode(buttonLeft)
        if constantHolder > 0
            constantHolder = constantHolder - .05;
        end
    elseif keycode(buttonRight)
        if constantHolder < 10
            constantHolder = constantHolder + .05;
        end
    end
    constant = constantHolder;
end

end