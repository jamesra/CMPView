function [ result ] = ComparePoint(image, x, y, value )
%COMPAREPOINT - Returns true if point in image matches value

[maxY, maxX] = size(image); 
minX = 1;
minY = 1;

result = -1;

if(x > maxX || x < minX)
    return; 
elseif(y < minY || y > maxY)
    return;
else
    result = image(y, x) == value; 
    return;
end
