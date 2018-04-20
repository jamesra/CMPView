function [ BorderIndicies, OutsideImageCount] = Border( LabelImage, LabelNumber, varargin)
%BORDER - Given a label image and label value returns the 
% indicies of pixels surrounding the label region. Border computes the
% 4-connected border by taking all pixels in LabelMap and adding all
%adjacent pixels not belonging to the target LabelNumber to a list. 
%The list is then filtered with the unique function and 1D indicies 
%of border pixels are returned.

    OutsideImageCount = 0;
    optargin = size(varargin,2);
    
    %Parse the optional arguments
    if(optargin > 1)
        disp(['Too many arguments to Border']); 
    end
    
    if(optargin > 0)
        iLabels = varargin{1}; 
    else
        iLabels = find(LabelImage == LabelNumber); 
    end

    [YDim, XDim] = size(LabelImage);
    
    [YList,XList] = ind2sub([YDim, XDim], iLabels);

    Border = zeros(length(iLabels),2);
    iBorder = 1; 

    for(i = 1:length(iLabels))

        X = XList(i); 
        Y = YList(i); 

        %Add the borders of this point
        if(InBounds(X,Y+1,XDim,YDim))
            if(LabelImage(Y+1, X) ~= LabelNumber)
                Border(iBorder,:) = [Y+1 X];
                iBorder = iBorder + 1; 
            end
        else
            OutsideImageCount = OutsideImageCount+ 1;
        end
        
        if(InBounds(X,Y-1,XDim,YDim))
            if(LabelImage(Y-1, X) ~= LabelNumber)
                Border(iBorder,:) = [Y-1 X];
                iBorder = iBorder + 1; 
            end
        else
            OutsideImageCount = OutsideImageCount+ 1;
        end

        if(InBounds(X+1,Y,XDim,YDim))
            if(LabelImage(Y, X+1) ~= LabelNumber)
                Border(iBorder,:) = [Y X+1];
                iBorder = iBorder + 1; 
            end
        else
            OutsideImageCount = OutsideImageCount+ 1;
        end

        if(InBounds(X-1,Y,XDim,YDim))
            if(LabelImage(Y, X-1) ~= LabelNumber)
                Border(iBorder,:) = [Y X-1];
                iBorder = iBorder + 1; 
            end
        else
            OutsideImageCount = OutsideImageCount+ 1;
        end
    end

    %Convert to index, remove duplicates
    Border = Border(1:iBorder-1,:); 
    BorderIndicies = sub2ind([YDim XDim], Border(:,1), Border(:,2));
    
    BorderIndicies = unique(BorderIndicies); 

end

