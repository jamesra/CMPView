function [ Mask ] = Threshold( Image, minVal, maxVal)
%THRESHOLD Binarizes an image

    [YDim, XDim] = size(Image);
    Mask = zeros(YDim * XDim, 1); 
    Image = int32(reshape(Image, XDim * YDim,1));
    
    indAboveMin = find(Image >= minVal);
    indBelowMax = find(Image <= maxVal); 
    
    validInd = intersect(indAboveMin, indBelowMax); 
    
    Mask(validInd) = 1; 
    
    Mask = reshape(Mask, YDim, XDim); 
end

