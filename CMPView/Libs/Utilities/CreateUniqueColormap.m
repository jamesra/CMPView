function [ cmap ] = CreateUniqueColormap( numColors )
%CREATEUNIQUECOLORMAP - Generates a colormap in which no two colors are
%alike

%numSteps = numColors^(1/2);
numSteps = numColors^(1/2);
%Reduce the number of steps by 1 because we start the FOR loops below at
%zero
numHueSteps = numSteps * 2;
numValSteps = numSteps / 2; 

numHueSteps = ceil(numHueSteps);
numValSteps = ceil(numValSteps);

hueStepfraction = 1 / numHueSteps;
valStepfraction = 1 / numValSteps;

cmap = zeros(numColors, 3);
iColor = 1;

for iVal = numValSteps:-1:1
    valcomp = ((iVal * valStepfraction) / 2) + .5;
    satcomp = 1;
    for iHue = 1:numHueSteps
        %Generate a hue values which are then offset slightly based on the
        %val step to generate differences between different iVal iterations
        huecomp = (iHue * hueStepfraction) - ((iVal - 1) * (valStepfraction / numValSteps));
        cmap(iColor, :) = [huecomp satcomp valcomp];
        iColor = iColor + 1;
    end
end

cmap = hsv2rgb(cmap);

cmap = abs(cmap); %Temp bug fix for negative RGB Values

cmap = [0 0 0; cmap; 1 1 1];