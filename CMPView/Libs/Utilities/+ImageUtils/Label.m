function [ LabelImage, MaxLabelValue, LabelMap ] = Label( BinaryImage, varargin)
    %LABEL - Takes index image as input.  Returns label image with a seperate
    %label for each connected component
    %---Input Arguments--- (BinaryImage, [LabelImage | LabelIndicies],
    %BinaryImage - Input image
    %[LabelImage] - If 2D input this is a label image showing which regions
    %have been previously labeled
    %               If 1D input this is a list of indicies we should
    %               attempt to label on the input image
    %[StartingLabelValue] - Number to use for first label 
    %---Output Arguments--- 
    % LabelImage
    % MaxLabelValue
    % LabelMap - A cell array indexed with a label value, the cell contains
    %            the indicies of every pixel with that value

    [YDim, XDim] = size(BinaryImage);
    
    optargin = size(varargin,2);
    
    %Parse the optional arguments
    if(optargin > 2)
        disp(['Too many arguments to Label']); 
    end
    
    Indicies = []; 
    iNextLabelMapIndex = 1; 
    if(optargin > 0)
        %A 2D array is a mask image, a 1D array is a list of indicies to
        %search
        
        LabelImageSize = size(varargin{1});
        
        if(length(LabelImageSize) == 1 || ...
                    LabelImageSize(1) == 1 || ...
                    LabelImageSize(2) == 1 )
           
           Indicies = varargin{1};
           LabelImage = ones(YDim, XDim);
           LabelImage(Indicies) = 0;
           iNextLabelMapIndex = 2; 
        else
           LabelImage = double(varargin{1});
           Indicies = find(LabelImage > 0); 
        end
        
    else
        LabelImage = zeros(YDim, XDim); 
    end
    
    if(optargin > 1)
        StartingLabelValue = varargin{2}; 
    else
        StartingLabelValue = max(max(LabelImage)) + 1; 
    end
       
    iLabel = StartingLabelValue; 
    
    

    if(~isempty(Indicies))
        LabelMap = cell(length(Indicies),2);
        while(~isempty(Indicies))
            [y x] = ind2sub([YDim, XDim], Indicies(1));
            if(LabelImage(y,x) == 0)
                [LabelImage, newLabelCoords] = ImageUtils.IterFill(BinaryImage, LabelImage, XDim, YDim, x, y, BinaryImage(y,x), iLabel);
                
                if(isempty(newLabelCoords))
                    continue; 
                end

                iLabelCoords = sub2ind([YDim XDim], newLabelCoords(:,2), newLabelCoords(:,1)); 
                                
%                if(isempty(LabelMap))
%                    LabelMap = [iLabel {iLabelCoords}];
%                else
                LabelMap(iNextLabelMapIndex,:) = [iLabel {iLabelCoords}];
                iNextLabelMapIndex = iNextLabelMapIndex + 1; 
%                end

                %LabelImage(iLabelCoords) = iLabel; 

                iLabel = iLabel + 1; 
                
                %Remove the indicies we've found
                Indicies = setdiff(Indicies, iLabelCoords); 
            else
                Indicies(1) = []; 
            end
            
        end

    else
        LabelMap = cell(XDim*YDim,2);
        for(x = 1:XDim)
            for(y = 1:YDim)
                if(LabelImage(y,x) == 0)
                    [LabelImage, newLabelCoords] = ImageUtils.IterFill(BinaryImage, LabelImage, XDim, YDim, x, y, BinaryImage(y,x), iLabel);

                    if(isempty(newLabelCoords))
                        continue; 
                    end

                    iLabelCoords = sub2ind([YDim XDim], newLabelCoords(:,2), newLabelCoords(:,1)); 

            %        if(isempty(LabelMap))
            %            LabelMap = [iLabel {iLabelCoords}];
            %        else
                        LabelMap(iNextLabelMapIndex,:) = [iLabel {iLabelCoords}];
                        iNextLabelMapIndex = iNextLabelMapIndex + 1; 
            %        end

                    %LabelImage(iLabelCoords) = iLabel; 

                    iLabel = iLabel + 1; 
                end
            end
        end
    end
    
    LabelMap(iNextLabelMapIndex:end,:) = [];
    
    MaxLabelValue = iLabel;

end

