% Code that increases the velocity, from v1 to v2, over a fixed distance

clear all
close all

Screen('Preference', 'SkipSyncTests', 1);

buttonEscape = KbName('Escape');

[w,rect] = Screen('OpenWindow',1,[128 128 128]);
x0 = rect(3)/2;
y0 = rect(4)/2;

% Variables
distance = 1000;
v1 = 5;
v2 = 20;
speed(1) = v1;

% Acceleration
acc = (v2^2 - v1^2) /  (2*distance);

% Location
x1(1) = 0;
y1 = y0-10;
x2 = 40;
y2 = y0+10;

counter = 1;
[keyIsDown, secs, keycode] = KbCheck;
while ~keycode(buttonEscape)
    [keyIsDown, secs, keycode] = KbCheck;
    
    Screen('FillRect',w,[0 0 0],[x1(counter),y1,x2,y2]);
    
    if x1(counter) <= x1(1)+distance
        counter = counter+1;
        x1(counter) = x1(counter-1) + (speed(counter-1));
        x2 = x1(counter)+40;
    end
    if speed(counter-1)<v2
        speed(counter) = speed(counter-1) + acc;
    end
    
    text = num2str(speed(counter-1));
    width=RectWidth(Screen('TextBounds',w,text));
    Screen('DrawText',w,text,x0-width/2,y0-200,[0 0 0]);
    Screen('Flip',w);
    
end

Screen('CloseAll');
