clear
hz = 60;
maxLength =2;
accRate = [.5 1 1.5 1.75 1.9 2.0 2.1 2.25 2.5 3.0 3.5];
hz=60;

% PPD stuff

        baseSpeed = 60/hz;

radialLength = zeros(1,92);
% Horizontal elliptical aperture

for i = 6: 6
    speed_ratio = accRate(i);
    orientation = -90;
    j = 0;
    while orientation < 90;
        j = j+1;
        radialLength(j) = sqrt( 1 / ( ( sind(orientation)/2)^2 + ( cosd(orientation)/1 )^2 ) );
        actualSpeed = baseSpeed + ((maxLength/radialLength(j))-1)*(speed_ratio-1)*baseSpeed
        orientation = orientation+actualSpeed;
    end
    
end
% actualSpeed = ((((maxLength./radialLength) ) * constant) + baseSpeed) 