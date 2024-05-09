% Initialize the aperture variables.

function [apTotal,apNumber,apTexture,apSize,gratingTexture,imSize,texX1,texY1,texX2,texY2,maxLength,gratingNumber,phaseValue,phaseHolder] =...
    texVars(w,PPD,rect,x0,y0,gray,white,black,inc)

% Aperture variables
apSize = 10*PPD;

% Which aperture do you want to use?
apNumber = 3;

% Total number of apertures
apTotal = 6;

% Which do you want to use? Sin wave grating or line. 
gratingNumber = 1;

%% Large aperture
apLength = apSize;
apHeight = apSize;
n = rect(4); % size of matrix, odd
n2 = floor(n/2) ;
[x,y] = meshgrid(-n2:n2);

Rl = apLength/2; % width
Rh = apHeight/2; % length
M = ((x - 0) / Rh) .^2    +   ((y - 0) / Rl) .^2     <= 1;
M = double(M) ; % convert from logical to double
alphaLayer = ~double(M)*255;
circleApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,4) = alphaLayer;
apTexture(1) = Screen('MakeTexture',w,circleApertureArray);

% Max length of the radius of this aperture
maxLength(1) = apHeight;

clear outlineArray

outlineArray = circleApertureArray;

% Create an outline texture
for k=1:size(outlineArray,1)-1
    for l=1:size(outlineArray,2)-1
        if outlineArray(k+1,l,4) == 0 && outlineArray(k,l,4) == 255
            outlineArray(k,l,1:3) = 0;
            outlineArray(k,l,4) = 255;
            outlineArray(size(outlineArray,1)-k,l,1:3) = 0;
            outlineArray(size(outlineArray,1)-k,l,4) = 255;
        elseif outlineArray(k,l+1,4) == 0 && outlineArray(k,l,4) == 255
            outlineArray(k,l,1:3) = 0;
            outlineArray(k,l,4) = 255;
            outlineArray(k,size(outlineArray,2)-l,1:3) = 0;
            outlineArray(k,size(outlineArray,2)-l,4) = 255;
        else
            outlineArray(k,l,4) = 0;
        end
    end
end
% figure()
% imshow(outlineArray(:,:,4))
outlineTexture(1) = Screen('MakeTexture',w,outlineArray);

clear Rl Rh M alphLayer circleApertureArray

%% Small aperture
apLength = round(apSize/2);
apHeight = round(apSize/2);
n = rect(4); % size of matrix, odd
n2 = floor(n/2) ;
[x,y] = meshgrid(-n2:n2);

Rl = apLength/2; % width
Rh = apHeight/2; % length
M = ((x - 0) / Rh) .^2    +   ((y - 0) / Rl) .^2     <= 1;
M = double(M) ; % convert from logical to double
alphaLayer = ~double(M)*255;
circleApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,4) = alphaLayer;
apTexture(2) = Screen('MakeTexture',w,circleApertureArray);

% Max length of the radius of this aperture
maxLength(2) = apHeight;

clear outlineArray

outlineArray = circleApertureArray;

% Create an outline texture
for k=1:size(outlineArray,1)-1
    for l=1:size(outlineArray,2)-1
        if outlineArray(k+1,l,4) == 0 && outlineArray(k,l,4) == 255
            outlineArray(k,l,1:3) = 0;
            outlineArray(k,l,4) = 255;
            outlineArray(size(outlineArray,1)-k,l,1:3) = 0;
            outlineArray(size(outlineArray,1)-k,l,4) = 255;
        elseif outlineArray(k,l+1,4) == 0 && outlineArray(k,l,4) == 255
            outlineArray(k,l,1:3) = 0;
            outlineArray(k,l,4) = 255;
            outlineArray(k,size(outlineArray,2)-l,1:3) = 0;
            outlineArray(k,size(outlineArray,2)-l,4) = 255;
        else
            outlineArray(k,l,4) = 0;
        end
    end
end
% figure()
% imshow(outlineArray(:,:,4))
outlineTexture(2) = Screen('MakeTexture',w,outlineArray);

clear Rl Rh M alphLayer circleApertureArray

%% Eliptical aperture
apLength = round(apSize/2);
apHeight = round(apSize);
n = rect(4); % size of matrix, odd
n2 = floor(n/2) ;
[x,y] = meshgrid(-n2:n2);

Rl = apLength/2; % width
Rh = apHeight/2; % length
M = ((x - 0) / Rh) .^2    +   ((y - 0) / Rl) .^2     <= 1;
M = double(M) ; % convert from logical to double
alphaLayer = ~double(M)*255;
elipseApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,4) = alphaLayer;
apTexture(3) = Screen('MakeTexture',w,elipseApertureArray);

% Max length of the radius of this aperture
maxLength(3) = apHeight;

clear outlineArray

outlineArray = elipseApertureArray;

% Create an outline texture
for k=1:size(outlineArray,1)-1
    for l=1:size(outlineArray,2)-1
        if outlineArray(k+1,l,4) == 0 && outlineArray(k,l,4) == 255
            outlineArray(k,l,1:3) = 0;
            outlineArray(k,l,4) = 255;
            outlineArray(size(outlineArray,1)-k,l,1:3) = 0;
            outlineArray(size(outlineArray,1)-k,l,4) = 255;
        elseif outlineArray(k,l+1,4) == 0 && outlineArray(k,l,4) == 255
            outlineArray(k,l,1:3) = 0;
            outlineArray(k,l,4) = 255;
            outlineArray(k,size(outlineArray,2)-l,1:3) = 0;
            outlineArray(k,size(outlineArray,2)-l,4) = 255;
        else
            outlineArray(k,l,4) = 0;
        end
    end
end
% figure()
% imshow(outlineArray(:,:,4))
outlineTexture(3) = Screen('MakeTexture',w,outlineArray);

clear Rl Rh M alphLayer circleApertureArray elipseApertureArray

%% Square aperture
apLength = round(apSize);
apHeight = round(apSize);
n = floor(rect(4));

Rl = apLength/2;
Rh = apHeight/2;

alphaLayer = ones(n,n);
for i=1:n
    for j=1:n
        if (i>((n/2)-Rl) && i<((n/2)+Rl)) && (j>((n/2)-Rh) && j<((n/2)+Rh))
            alphaLayer(i,j) = 0;
        end
    end
end
alphaLayer = alphaLayer.*255;

elipseApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,4) = alphaLayer;
apTexture(4) = Screen('MakeTexture',w,elipseApertureArray);

% Max length of the radius of this aperture
maxLength(4) = apHeight;

clear outlineArray

outlineArray = elipseApertureArray;

% Create an outline texture
for k=1:size(outlineArray,1)-1
    for l=1:size(outlineArray,2)-1
        if outlineArray(k+1,l,4) == 0 && outlineArray(k,l,4) == 255
            outlineArray(k,l,1:3) = 0;
            outlineArray(k,l,4) = 255;
            outlineArray(size(outlineArray,1)-k,l,1:3) = 0;
            outlineArray(size(outlineArray,1)-k,l,4) = 255;
        elseif outlineArray(k,l+1,4) == 0 && outlineArray(k,l,4) == 255
            outlineArray(k,l,1:3) = 0;
            outlineArray(k,l,4) = 255;
            outlineArray(k,size(outlineArray,2)-l,1:3) = 0;
            outlineArray(k,size(outlineArray,2)-l,4) = 255;
        else
            outlineArray(k,l,4) = 0;
        end
    end
end
% figure()
% imshow(outlineArray(:,:,3))
outlineTexture(4) = Screen('MakeTexture',w,outlineArray);

clear Rl Rh M alphLayer circleApertureArray elipseApertureArray

%% Rectangular aperture
apLength = round(apSize/2);
apHeight = round(apSize);

n = floor(rect(4));

Rl = apLength/2; % width
Rh = apHeight/2; % length

alphaLayer = ones(n,n);
for i=1:n
    for j=1:n
        if (i>((n/2)-Rl) && i<((n/2)+Rl)) && (j>((n/2)-Rh) && j<((n/2)+Rh))
            alphaLayer(i,j) = 0;
        end
    end
end
alphaLayer = alphaLayer.*255;

elipseApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,4) = alphaLayer;
apTexture(5) = Screen('MakeTexture',w,elipseApertureArray);

% Max length of the radius of this aperture
maxLength(5) = apHeight;

clear outlineArray

outlineArray = elipseApertureArray;

% Create an outline texture
for k=1:size(outlineArray,1)-1
    for l=1:size(outlineArray,2)-1
        if outlineArray(k+1,l,4) == 0 && outlineArray(k,l,4) == 255
            outlineArray(k,l,1:3) = 0;
            outlineArray(k,l,4) = 255;
            outlineArray(size(outlineArray,1)-k,l,1:3) = 0;
            outlineArray(size(outlineArray,1)-k,l,4) = 255;
        elseif outlineArray(k,l+1,4) == 0 && outlineArray(k,l,4) == 255
            outlineArray(k,l,1:3) = 0;
            outlineArray(k,l,4) = 255;
            outlineArray(k,size(outlineArray,2)-l,1:3) = 0;
            outlineArray(k,size(outlineArray,2)-l,4) = 255;
        else
            outlineArray(k,l,4) = 0;
        end
    end
end
% figure()
% imshow(outlineArray(:,:,4))
outlineTexture(5) = Screen('MakeTexture',w,outlineArray);

clear Rl Rh M alphLayer circleApertureArray elipseApertureArray

%% Parallelogram aperture
apLength = round(apSize/3);
apHeight = round(apSize);

n = floor(rect(4));
alphaLayer = ones(n,n).*255;

xAp(1) = length(alphaLayer)/2 - apHeight/2;
yAp(1) = length(alphaLayer)/2;
xAp(2) = length(alphaLayer)/2 + apHeight/2;
yAp(2) = length(alphaLayer)/2 - apLength;
xAp(3) = length(alphaLayer)/2 - apHeight/2;
yAp(3) = length(alphaLayer)/2 + apLength;
xAp(4) = length(alphaLayer)/2 + apHeight/2;
yAp(4) = length(alphaLayer)/2;

% Found solution at: https://www.mathworks.com/matlabcentral/answers/67664-how-to-make-triangle-for-a-synthetic-image-in-gray-scale
xCoords = [xAp(1) xAp(2) xAp(4) xAp(3)];
yCoords = [yAp(1) yAp(2) yAp(4) yAp(3)];
mask = poly2mask(xCoords, yCoords, length(alphaLayer), length(alphaLayer));
alphaLayer(mask) = 0; % or whatever value you want.

elipseApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,4) = alphaLayer;
apTexture(6) = Screen('MakeTexture',w,elipseApertureArray);

% Max length of the radius of this aperture
maxLength(6) = apHeight;

clear outlineArray

outlineArray = elipseApertureArray;

% Create an outline texture
for k=1:size(outlineArray,1)-1
    for l=1:size(outlineArray,2)-1
        if outlineArray(k+1,l,4) == 0 && outlineArray(k,l,4) == 255
            outlineArray(k,l,1:3) = 0;
            outlineArray(k,l,4) = 255;
            outlineArray(size(outlineArray,1)-k,l,1:3) = 0;
            outlineArray(size(outlineArray,1)-k,l,4) = 255;
        elseif outlineArray(k,l+1,4) == 0 && outlineArray(k,l,4) == 255
            outlineArray(k,l,1:3) = 0;
            outlineArray(k,l,4) = 255;
            outlineArray(k,size(outlineArray,2)-l,1:3) = 0;
            outlineArray(k,size(outlineArray,2)-l,4) = 255;
        else
            outlineArray(k,l,4) = 0;
        end
    end
end

% figure()
% imshow(outlineArray(:,:,4))
outlineTexture(6) = Screen('MakeTexture',w,outlineArray);

clear Rl Rh M alphLayer circleApertureArray elipseApertureArray

%% ~Large aperture
apLength = apSize;
apHeight = apSize;
n = rect(4); % size of matrix, odd
n2 = floor(n/2) ;
[x,y] = meshgrid(-n2:n2);

Rl = apLength/2; % width
Rh = apHeight/2; % length
M = ((x - 0) / Rh) .^2    +   ((y - 0) / Rl) .^2     <= 1;
M = double(M) ; % convert from logical to double
alphaLayer = ~double(M)*255;
circleApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,4) = double(M)*255;
apTexture(7) = Screen('MakeTexture',w,circleApertureArray);

clear Rl Rh M alphLayer circleApertureArray

%% ~Small aperture
apLength = round(apSize/2);
apHeight = round(apSize/2);
n = rect(4); % size of matrix, odd
n2 = floor(n/2) ;
[x,y] = meshgrid(-n2:n2);

Rl = apLength/2; % width
Rh = apHeight/2; % length
M = ((x - 0) / Rh) .^2    +   ((y - 0) / Rl) .^2     <= 1;
M = double(M) ; % convert from logical to double
alphaLayer = ~double(M)*255;
circleApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
circleApertureArray(:,:,4) = double(M)*255;
apTexture(8) = Screen('MakeTexture',w,circleApertureArray);

clear Rl Rh M alphLayer circleApertureArray

%% ~Eliptical aperture
apLength = round(apSize/2);
apHeight = round(apSize);
n = rect(4); % size of matrix, odd
n2 = floor(n/2) ;
[x,y] = meshgrid(-n2:n2);

Rl = apLength/2; % width
Rh = apHeight/2; % length
M = ((x - 0) / Rh) .^2    +   ((y - 0) / Rl) .^2     <= 1;
M = double(M) ; % convert from logical to double
alphaLayer = ~double(M)*255;
elipseApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,4) = double(M)*255;
apTexture(9) = Screen('MakeTexture',w,elipseApertureArray);

clear Rl Rh M alphLayer circleApertureArray elipseApertureArray

%% ~Square aperture
apLength = round(apSize);
apHeight = round(apSize);
n = floor(rect(4));

Rl = apLength/2;
Rh = apHeight/2;

alphaLayer = ones(n,n);
for i=1:n
    for j=1:n
        if (i>((n/2)-Rl) && i<((n/2)+Rl)) && (j>((n/2)-Rh) && j<((n/2)+Rh))
            alphaLayer(i,j) = 0;
        end
    end
end
alphaLayer = ~alphaLayer.*255;

elipseApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,4) = alphaLayer;
apTexture(10) = Screen('MakeTexture',w,elipseApertureArray);

clear Rl Rh M alphLayer circleApertureArray elipseApertureArray

%% ~Rectangular aperture
apLength = round(apSize);
apHeight = round(apSize);
n = floor(rect(4));

Rl = apLength/4;
Rh = apHeight/2;

alphaLayer = ones(n,n);
for i=1:n
    for j=1:n
        if (i>((n/2)-Rl) && i<((n/2)+Rl)) && (j>((n/2)-Rh) && j<((n/2)+Rh))
            alphaLayer(i,j) = 0;
        end
    end
end
alphaLayer = ~alphaLayer.*255;

elipseApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,4) = alphaLayer;
apTexture(11) = Screen('MakeTexture',w,elipseApertureArray);

clear Rl Rh M alphLayer circleApertureArray elipseApertureArray

%% ~Parallelogram aperture
apLength = round(apSize/3);
apHeight = round(apSize);

n = floor(rect(4));
alphaLayer = zeros(n,n);

xAp(1) = length(alphaLayer)/2 - apHeight/2;
yAp(1) = length(alphaLayer)/2;
xAp(2) = length(alphaLayer)/2 + apHeight/2;
yAp(2) = length(alphaLayer)/2 - apLength;
xAp(3) = length(alphaLayer)/2 - apHeight/2;
yAp(3) = length(alphaLayer)/2 + apLength;
xAp(4) = length(alphaLayer)/2 + apHeight/2;
yAp(4) = length(alphaLayer)/2;

% Found solution at: https://www.mathworks.com/matlabcentral/answers/67664-how-to-make-triangle-for-a-synthetic-image-in-gray-scale
grayImage = alphaLayer;
xCoords = [xAp(1) xAp(2) xAp(4) xAp(3)];
yCoords = [yAp(1) yAp(2) yAp(4) yAp(3)];
mask = poly2mask(xCoords, yCoords, length(alphaLayer), length(alphaLayer));
grayImage(mask) = 255; % or whatever value you want.

elipseApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,4) = alphaLayer;
apTexture(12) = Screen('MakeTexture',w,elipseApertureArray);

clear Rl Rh M alphLayer circleApertureArray elipseApertureArray

%% Large circular aperture (Outer aperture)
apLength = round(apSize*(3/2));
apHeight = round(apSize*(3/2));
n = rect(4); % size of matrix, odd
n2 = floor(n/2) ;
[x,y] = meshgrid(-n2:n2);

Rl = apLength/2; % width
Rh = apHeight/2; % length
M = ((x - 0) / Rh) .^2    +   ((y - 0) / Rl) .^2     <= 1;
M = double(M) ; % convert from logical to double
alphaLayer = ~double(M)*255;
elipseApertureArray(:,:,1) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,2) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,3) = zeros(length(alphaLayer))+gray;
elipseApertureArray(:,:,4) = alphaLayer;
apTexture(13) = Screen('MakeTexture',w,elipseApertureArray);

%% Inside texture variables
% Size variables
imSize = round(apSize*(3/2));

texX1 = x0-imSize/2;
texY1 = y0-imSize/2;
texX2 = x0+imSize/2;
texY2 = y0+imSize/2;

% Line texture
gratingArray = zeros(imSize)+gray;
gratingArray(:,round(imSize/2)) = 0;
gratingTexture(1) = Screen('MakeTexture', w, gratingArray);

clear gratingArray Rl Rh M alphLayer circleApertureArray elipseApertureArray

% Create the grating
phaseValue = 10;
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

% Line texture
holderArray = zeros(imSize)+gray;
gratingTexture(3) = Screen('MakeTexture', w, holderArray);
    
    



end