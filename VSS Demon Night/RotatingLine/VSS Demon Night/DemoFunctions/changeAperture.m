% Toggles between different aperture types (parallelogram, square, ellipse,
% circle). Only the 'inside' aperture will change (as opposed to the outer
% circular aperture present when the center of the line is occluded). 

function [apNumber,apLength,apHeight] = changeAperture(apNumber,keycode,buttonA,apLength,apHeight,apSize)

% Toggle between apertures when they press 'a'
if keycode(buttonA)
    if apNumber == 1
        apNumber = 2;
        apLength = round(apSize/2);
        apHeight = round(apSize/2);
    elseif apNumber == 2
        apNumber = 3;
        apLength = round(apSize/2);
        apHeight = round(apSize);
    elseif apNumber == 3
        apNumber = 4;
        apLength = round(apSize);
        apHeight = round(apSize);
    elseif apNumber == 4
        apNumber = 5;
        apLength = round(apSize/2);
        apHeight = round(apSize);
    elseif apNumber == 5
        apNumber = 6;
        apLength = round(apSize/3);
        apHeight = round(apSize);
    elseif apNumber == 6
        apNumber = 1;
        apLength = apSize;
        apHeight = apSize;
    end
    KbReleaseWait;
end

end