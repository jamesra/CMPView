function [ LabelImage, coords ] = IterFill(  IndexImage, LabelImage, XDim, YDim, X, Y, TargetValue, LabelValue )
%ITERFILL Iterative Implementation of flood fill algorithm used by FloodFill and
%Label functions
%Label image contains the region number for each pixel.  A zero indicates
%the pixel has not yet been associated with a region
%Label value is the value to assign to the label image for the pixels
%within the region

    coords = [];
    
    %If the point is out of bounds then return
    if(~ImageUtils.InBounds(X,Y,XDim,YDim))
        return;
    end
    
    if(isempty(LabelImage))
       LabelImage = zeros(YDim, XDim);
    end
    
    %If this point is already checked then return
    if(LabelImage(Y,X) > 0)
       return; 
    end
    
    %Check if the point belongs in the region
    if(IndexImage(Y,X) ~= TargetValue)
        return; 
    end

    minX = 1;
    minY = 1;

    QueueSize = 500;    
    
    %Pre-allocate queue for speed
    pointqueue = zeros(QueueSize, 2); 
    
    iQueueStart = 1;
    iQueueEnd = 2;
    pointqueue(iQueueStart, :) = [X Y];
    
    coords = zeros(QueueSize, 2); 
    iCoord = 1; 
    
    while(iQueueStart ~= iQueueEnd)
        startX = pointqueue(iQueueStart,1);
        startY = pointqueue(iQueueStart,2);  
        
        iQueueStart = iQueueStart + 1;

        if(~ImageUtils.InBounds(startX,startY,XDim,YDim))
            continue;
        end
        
        if(LabelImage(startY,startX) > 0)
           continue; 
        end
        
        %Check if we should add this pixel to our region
        if(IndexImage(startY,startX) ~= TargetValue)
            continue; 
        end
        
        LabelImage(startY,startX) = LabelValue;
        coords(iCoord,:) = [startX startY];
        iCoord = iCoord + 1;
        
        if(startY+1 <= YDim)
            if(ComparePoint(LabelImage, startX, startY + 1, LabelValue) == 0)
                pointqueue(iQueueEnd,:) = [startX startY+1];
                iQueueEnd = iQueueEnd + 1; 
            end
        end

        if(startY-1 > 0)
            if(ComparePoint(LabelImage, startX, startY - 1, LabelValue) == 0)
                pointqueue(iQueueEnd,:) = [startX startY-1];
                iQueueEnd = iQueueEnd + 1; 
            end 
        end
        
         %look left
       testx = startX - 1; 
       while(testx > minX)
            if(LabelImage(startY, testx) ~= 0)
                break; 
            elseif(IndexImage(startY, testx) ~= TargetValue)
                break;
            else
                LabelImage(startY, testx) = LabelValue;
                coords(iCoord, :) = [testx startY];
                iCoord = iCoord + 1; 
      
                if(startY+1 <= YDim)
                    if(LabelImage(startY + 1, testx) == 0)
                        pointqueue(iQueueEnd,:) = [testx startY+1];
                        iQueueEnd = iQueueEnd + 1; 
                    end
                end
            
                if(startY-1 > 0)
                    if(LabelImage(startY - 1, testx) == 0)
                        pointqueue(iQueueEnd,:) = [testx startY-1];
                        iQueueEnd = iQueueEnd + 1; 
                    end 
                end
            end

            testx = testx - 1;
            
            %Figure out if we need to expand the coords array
            if(iCoord >= length(coords))
               coords = [coords; zeros(500, 2)];
            end
            
            %Figure out if we should make the queue bigger
            if(iQueueEnd + 3 >= length(pointqueue))
               %Double the size of the queue and remove the entries that have
               %been dequeued
               QueueSize = QueueSize * 2;
                
               pointqueue = [pointqueue(iQueueStart:end,:); zeros(iQueueEnd-iQueueStart,2)];  
               iQueueEnd = (iQueueEnd - iQueueStart) + 1; 
               iQueueStart = 1; 
            end
        end

        %look right
        testx = startX + 1; 
        while(testx < XDim)
            if(LabelImage(startY, testx) ~= 0)
                break; 
            elseif(IndexImage(startY, testx) ~= TargetValue)
                break;
            else
                LabelImage(startY, testx) = LabelValue;
                coords(iCoord, :) = [testx startY];
                iCoord = iCoord + 1; 
               
                if(startY+1 <= YDim)
                    if(LabelImage(startY + 1, testx) == 0)
                        pointqueue(iQueueEnd,:) = [testx startY+1];
                        iQueueEnd = iQueueEnd + 1; 
                    end
                end
       
                if(startY-1 > 0)
                    if(LabelImage(startY - 1, testx) == 0)
                        pointqueue(iQueueEnd,:) = [testx startY-1];
                        iQueueEnd = iQueueEnd + 1; 
                    end 
                end
            end

            testx = testx + 1;
            
            %Figure out if we need to expand the coords array
            if(iCoord >= length(coords))
               coords = [coords; zeros(500, 2)];
            end
            
            %Figure out if we should make the queue bigger
            if(iQueueEnd + 3 >= length(pointqueue))
               %Double the size of the queue and remove the entries that have
               %been dequeued
               QueueSize = QueueSize * 2;
                
               pointqueue = [pointqueue(iQueueStart:end,:); zeros(iQueueEnd-iQueueStart,2)];  
               iQueueEnd = (iQueueEnd - iQueueStart) + 1; 
               iQueueStart = 1; 
            end
        end
%         
%         while(IndexImage(iY,iX) == TargetValue)
%             LabelImage(iY,iX) = LabelValue;
%             coords(iCoord,:) = [iX iY];
%             iCoord = iCoord + 1;
%             
%             %Figure out if we need to expand the coords array
%             if(iCoord >= length(coords))
%                coords = [coords; zeros(500, 2)];
%             end
%             
%             if(iY + 1 <= YDim)
%                 if(LabelImage(iY+1, iX) == 0)
%                     queue(iQueueEnd,:) = [iX iY+1]; 
%                     iQueueEnd = iQueueEnd + 1;
%                 end
%             end
%             
%             if(iY - 1 >= 1)
%                 if(LabelImage(iY-1, iX) == 0)
%                     queue(iQueueEnd,:) = [iX iY-1]; 
%                     iQueueEnd = iQueueEnd + 1;
%                 end
%             end
%             
%             
%             iX = iX + 1;
%             if(iX > XDim)
%                 break;
%             end
%             
%             %Figure out if we should make the queue bigger
%             if(iQueueEnd + 3 >= length(queue))
%                %Double the size of the queue and remove the entries that have
%                %been dequeued
%                QueueSize = QueueSize * 2;
%                 
%                queue = [queue(iQueueStart:end,:); zeros(iQueueEnd-iQueueStart,2)];  
%                iQueueEnd = (iQueueEnd - iQueueStart) + 1; 
%                iQueueStart = 1; 
%             end
%             
%        end
        
%         if(IndexImage(startY,startX) == TargetValue && startX - 1 >= 1)
%             if(LabelImage(iY, startX-1) == 0)
%                 queue(iQueueEnd,:) = [startX-1 iY];
%                 iQueueEnd = iQueueEnd + 1;
%             end
%         end
        
    end
    
    coords = coords(1:iCoord-1,:); 
end