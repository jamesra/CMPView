function [ Points ] = Circle( radius )
%CIRCLE - Return a list of points which are within the radius of a circle

diameter = radius * 2; 
Footprint = uint8(zeros(diameter+1, diameter+1));

for(x = -radius:radius)
    for(y = -radius:radius)
        if(sqrt(x^2 + y^2) < radius)
           Footprint(x+radius+1, y+radius+1) = 1; 
        end
    end
end

[row, col] = find(Footprint > 0);

Points = [row, col];