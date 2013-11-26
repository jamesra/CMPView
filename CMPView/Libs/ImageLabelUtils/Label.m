function [ LabelImage, MaxLabelValue, LabelMap ] = Label( BinaryImage, varargin)
    %LABEL - Takes index image as input.  Returns label image with a seperate
    %label for each connected component
    %BinaryImage - Input image
    %[LabelImage] - Label Image if labels already exist for part of the
    %image, [] creates an new label image
    %[StartingLabelValue] - Number to use for first label 

    [YDim, XDim] = size(BinaryImage);
    
    optargin = size(varargin,2);
    
    %Parse the optional arguments
    if(optargin > 2)
        disp(['Too many arguments to Label']); 
    end
    
    if(optargin > 0)
        LabelImage = double(varargin{1}); 
    else
        LabelImage = zeros(YDim, XDim); 
    end
    
    if(optargin > 1)
        StartingLabelValue = varargin{2}; 
    else
        StartingLabelValue = max(max(LabelImage)) + 1; 
    end
    
    
   
    iLabel = StartingLabelValue; 
    LabelMap = {};

    for(x = 1:XDim)
        for(y = 1:YDim)
            if(LabelImage(y,x) == 0)
                [LabelImage, newLabelCoords] = ImageUtils.IterFill(BinaryImage, LabelImage, XDim, YDim, x, y, BinaryImage(y,x), iLabel);
                
                if(isempty(newLabelCoords))
                    continue; 
                end
                
                iLabelCoords = sub2ind([YDim XDim], newLabelCoords(:,2), newLabelCoords(:,1)); 
                
                if(isempty(LabelMap))
                    LabelMap = [iLabel {iLabelCoords}];
                else
                    LabelMap(end+1,:) = [iLabel {iLabelCoords}];
                end
                
                %LabelImage(iLabelCoords) = iLabel; 
                
                iLabel = iLabel + 1; 
            end
        end
    end
    
    MaxLabelValue = iLabel;

end

