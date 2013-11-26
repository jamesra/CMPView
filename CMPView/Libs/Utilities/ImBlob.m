function [ OutputImage ] = ImBlob( InputImage, Radius )

    dbstop if error; 
    
    %IMBLOB filter an image whose pixels range from zero to one 
    %with the specified neighborhood and histogram size
    %NeighborhoodRadius - Number of pixels away from center pixel we need to include


    [YDim, XDim] = size(InputImage);
    NeighborhoodDimension = (Radius * 2) + 1; 
    OutputImage = zeros(YDim, XDim); 

    %Create a 1D representation of the image
    Image1D = reshape(InputImage, YDim * XDim,1);
    
    UpdateCounter = 0;
    UpdateIncrement = 1 / (YDim * XDim);
    
    NextUpdateMessage = 1; %What percentage to print a message for
    
    %Walk the image, populating the bins and 
    for(iY = 1:YDim)
        %Find start and end values for iX
        YStart = iY-Radius; 
        YEnd = iY+Radius; 
        if(YStart < 1)
            YStart = 1; 
        end

        if(YEnd > YDim)
            YEnd = YDim;
        end
        
        numValuesPerRow = length(YStart:YEnd); 
        
        Values = []; 
        means = [];
        sums = []; 

        %Populate the bins with the initial neighborhood
        for(iX = 1-Radius:0)
            iXAdd = iX + Radius;
            iValuesToAdd = ((iXAdd-1)*YDim)+YStart:((iXAdd-1)*YDim)+YEnd;
            ValuesToAdd = Image1D(iValuesToAdd);

            Values = [Values; ValuesToAdd];
        end

        sums =  sum(InputImage(YStart:YEnd,:), 1);
        
        for(iX = 1:XDim)
            %Find the offset of column to add and the column to remove from the
            %neighborhood
            iXEnd = iX - (Radius+1);
            iXAdd = iX + Radius;
            iValuesToAdd = []; 
            if(iXAdd <= XDim)
                iValuesToAdd = ((iXAdd-1)*YDim)+YStart:((iXAdd-1)*YDim)+YEnd;
            end

            ValuesToAdd = Image1D(iValuesToAdd); 
            
            %Remove old values
            
            if(iXEnd > 0)
                Values = [Values(numValuesPerRow+1:end); ValuesToAdd];
            else 
                Values = [Values; ValuesToAdd];
            end
            
            iXEnd = iXEnd+1; 
            if(iXEnd <= 0)
                iXEnd = 1;
            end

            if(iXAdd > XDim)
                iXAdd = XDim;
            end
                        
            s = sums(iXEnd:iXAdd);
            m = sum(s) / length(Values);
          %  mm = mean(means(iXEnd:iXAdd));

            %f = func(Values);
            %OutputImage(iY,iX) = f;
            
            %m = mean(means); 
            d = Values - m;
            
            v = sum(d .* d) / (length(Values)-1);
            
            %assert(v >= f - eps(f) && v <= f + eps(f));
            
            OutputImage(iY,iX) = v; 
            
            UpdateCounter = UpdateCounter + UpdateIncrement;
            
            if(UpdateCounter > NextUpdateMessage)
               disp(['Filter progress: ' num2str(UpdateCounter * 100)]);
               NextUpdateMessage = (floor(UpdateCounter * 100)+1) / 100; 
            end
        end
    end
end

