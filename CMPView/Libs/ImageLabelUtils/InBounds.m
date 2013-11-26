function [ retVal ] = InBounds( X,Y,XDim,YDim )
%INBOUNDS Returns true if the point is inside the given dimensions,
%otherwise false

    retVal = false;

    if(X < 1)
        return;
    end

    if(X > XDim)
        return;
    end

    if(Y < 1)
        return;
    end

    if(Y > YDim)
        return;
    end

    retVal = true;
    return;


end

