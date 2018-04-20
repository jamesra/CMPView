function [ DenoiseImage ] = Denoise( LabelImage, MinArea, varargin )
%DENOISE Remove connected labeled regions smaller than a specified area
%   LabelImage - Index image to denoise
%   area - threshold for removing regions with an area smaller than this
%   value
%   [LabelData] - A 2D matrix where the first column is label values and
%   the second column is a matrix containing all coordinates of label
%   members.

    DenoiseImage = LabelImage; 
    optargin = size(varargin,2);
    LabelMap = []; 
    
    [YDim, XDim] = size(LabelImage); 
    
    %Parse the optional arguments
    if(optargin > 1)
        disp(['Too many arguments to Denoise']); 
    end
    
    if(optargin > 0) 
        LabelMap = varargin(1); 
    else
        LabelMap = GetLabelMap(LabelImage); 
    end
    
    [nLabels, nColumns] = size(LabelMap); 
    
    for(iLabel = 1:nLabels)
       
        if(length(LabelMap{iLabel,2}) < MinArea)
            %Remove the small area
            BorderIndicies = Border(DenoiseImage, iLabel, LabelMap{iLabel, 2});
            
            %Figure out which label has the largest border, use Denoise
            %image so we don't accidentally add a region below threshold
            %and make it too large
            BorderLabels = DenoiseImage(BorderIndicies); 
            
            maxBorderLabel = max(BorderLabels); 
            
            LabelCount = histogram(BorderLabels,maxBorderLabel, 1, maxBorderLabel);
            
            [LargestBorderLabel, iLargestBorderLabel] = max(LabelCount); 
           
            DenoiseImage(LabelMap{iLabel,2}) = iLargestBorderLabel;
        end  
    end
end

