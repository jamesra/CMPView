function [ LabelImage] = FloodFill( Image, LabelImage, X,Y, iLabel )
%FLOODFILLFloodFill is a wrapper function which invokes the IterFill
%function.  It creates the output image if it does not exist.  The
%flood fill routines work on any image type, not just binary, so
%FloodFill determines the pixel value of the X,Y position so IterFill
%knows which values are a match for the flood fill operation.

    [YDim, XDim] = size(Image);
    
    if(isempty(LabelImage))
        LabelImage = zeros(YDim, XDim);
    end
    
    LabelImage = IterFill(Image, LabelImage, XDim, YDim, X, Y, Image(Y,X), iLabel); 
end

