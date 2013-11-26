function [ LabelMask ] = RecurseFill( InputMask, LabelMask, XDim, YDim, X, Y, TargetValue, LabelValue)
%RECURSEFILL - Recursive function that works on a single dimensional array
    
    if(~InBounds(X,Y,XDim,YDim))
        return;
    end
    
    i = sub2ind([YDim XDim], Y, X);

    %Prevent endless loops
    if(LabelMask(i) > 0)
        return; 
    end

    if(InputMask(i) == TargetValue)
        LabelMask(i) = LabelValue;

        LabelMask = RecurseFill(InputMask, LabelMask, XDim, YDim, X+1, Y, TargetValue, LabelValue); 
        LabelMask = RecurseFill(InputMask, LabelMask, XDim, YDim, X-1, Y, TargetValue, LabelValue); 
        LabelMask = RecurseFill(InputMask, LabelMask, XDim, YDim, X, Y+1, TargetValue, LabelValue); 
        LabelMask = RecurseFill(InputMask, LabelMask, XDim, YDim, X, Y-1, TargetValue, LabelValue);
    end
end

