% Draws dots on the edges of the occluder. Only usable if the occluder is
% an ellipse and while using the line. If drawing on outside can switch between drawing along the
% edge of the inner occluder or outer occluder.

% Pressing the 'd' key will toggle through the different options (draw on
% inside, draw on outside) and pressing 'l' will toggle on and off the
% line.

% When drawing the dots you can

function [drawDotsNLine,drawDotsToggle,gratingNumber] = drawDots(drawDotsNLine,drawDotsToggle,gratingNumber,drawOutsideToggle,buttonL,buttonD,keycode)

if keycode(buttonD)
    if drawDotsToggle == 0  % No dots
        drawDotsToggle = 1;
    elseif drawDotsToggle == 1   % Dots on inside
        if drawOutsideToggle == 1
            drawDotsToggle = 2;
        elseif drawOutsideToggle == 0
            drawDotsToggle = 0;
            gratingNumber = 1;
        end
    elseif drawDotsToggle == 2   % Dots on inside
        if drawOutsideToggle == 1
            drawDotsToggle = 3;
        elseif drawOutsideToggle == 0
            drawDotsToggle = 0;
            gratingNumber = 1;
        end
    elseif drawDotsToggle == 3   % Dots on outside
        drawDotsToggle = 0;
        gratingNumber = 1;
    end
    KbReleaseWait;
end

if keycode(buttonL)
    if drawDotsNLine == 0
        drawDotsNLine = 1;
    elseif drawDotsNLine == 1
        drawDotsNLine = 0;
    end
    KbReleaseWait;
end

end