function [ average ] = AverageRegion( Region, Image )
%AVERAGEREGION - Given a region and an image returns the average value of
%all pixels in that region

[numPixels, numCoord] = size(Region);

pixelValues = zeros(1,numPixels); 

for( iPixel = 1:numPixels )
    pixelValues(iPixel) = Image(Region(iPixel, 2), Region(iPixel, 1));
end

average = mean(pixelValues); 