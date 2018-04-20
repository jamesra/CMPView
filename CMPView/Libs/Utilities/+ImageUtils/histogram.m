
function bins = histogram(Image, varargin)
%DENOISE Returns the number of entries in each 'bin' spread between the min
%   and max values of the data.
%   Image - 1D or 2D array to histogram
%   [NumBins] - Number of bins in output
%   [MinVal] - Minimum value in histogram
%   [MaxVal] - Maximum value in histogram 

    numBins = 256;
    minVal = 0;
    maxVal = 0;
    
    optargin = size(varargin,2);
    
    [YDim, XDim] = size(Image); 
    
    %Parse the optional arguments
    if(optargin > 3)
        disp(['Too many arguments to histogram']); 
    end
    
    if(optargin > 2)
        maxVal = varargin{3};
    else
        maxVal = max(max(Image)); 
    end
    
    if(optargin > 1)
        minVal = varargin{2}; 
    else
        minVal = min(min(Image)); 
    end
    
    if(optargin > 0)
        numBins = varargin{1}; 
    else
        numBins = 256; 
    end
    
    %We divide by zero later if we don't check this
    if(maxVal == minVal)
        bins = (XDim * YDim); 
        return;
    end
    
    %Covert image to float
    MapImage = Image - minVal; 
    MapImage = single(MapImage) ./ single(maxVal - minVal); 
    MapImage = MapImage .* (numBins-1); 
    MapImage = MapImage + 1; %Correct for zero since we can't index zero
    MapImage = round(MapImage); 
        
    bins = zeros(numBins,1); 
    
    MapImage = int32(reshape(MapImage, XDim * YDim,1));  
    
    for(i = 1:length(MapImage))
        bins(MapImage(i)) = bins(MapImage(i)) + 1;
    end
    
    
end
