% Change texture (line/grating)
% Change the texture between the grating and the line.

function [gratingNumber,texArray] = changeTexture(gratingNumber,keycode,buttonG,texArray,gratingTexture,drawDotsNLine,drawDotsToggle)

if keycode(buttonG)
    if gratingNumber == 1
        gratingNumber = 2;
    elseif gratingNumber == 2
        gratingNumber = 1;
    end
    KbReleaseWait;
end

if drawDotsToggle == 1
    if drawDotsNLine == 1
        gratingNumber = 1;
    elseif drawDotsNLine == 0
        gratingNumber = 3;
    end
end

texArray(1) = gratingTexture(gratingNumber);

end