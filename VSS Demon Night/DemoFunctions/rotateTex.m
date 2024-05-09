% Rotates the inner texture by manipulating the rotation array [t1r t2r...tnr]

function [autoRotate,orientation] = rotateTex(autoRotate,orientation,keycode,buttonR,buttonLeft,buttonRight)

if keycode(buttonR)
    if autoRotate == 1
        autoRotate = 0;
    elseif autoRotate == 0
        autoRotate = 1;
    end
    KbReleaseWait;
end

if autoRotate == 0
    
    if keycode(buttonLeft)
        orientationLast = orientation;
        orientation = orientationLast - 1;
    end
    if keycode(buttonRight)
        orientationLast = orientation;
        orientation = orientationLast + 1;
    end

end

end