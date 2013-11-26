function [ RegionPoints, mask ] = FindRegion( point, mask )
%FINDREGION - Given a starting point, FindRegion returns an array of all 
%             points that are bounded by the provided mask. 

minX = 1;
minY = 1;

[maxY, maxX] = size(mask); 

x = point(1); 
y = point(2);

if(ComparePoint(mask, x, y, 0) == 0)
    RegionPoints = zeros(300 * 200, 2);
    iRegionPoint = 1;
else
    RegionPoints = []; 
    return
end

pointqueue = [x y]; 
    
while(~isempty(pointqueue))
    testx = pointqueue(1,1); 
    testy = pointqueue(1,2); 
    
    startx = testx; 
    
    %remove point from the queue
    pointqueue(1,:) = [];
    
    if(ComparePoint(mask, testx, testy, 0) == 0)
        
       mask(testy, testx) = 0;

       RegionPoints(iRegionPoint, :) = [testx testy];
       iRegionPoint = iRegionPoint + 1; 
       
       if(ComparePoint(mask, testx, testy + 1, 0) == 0)
           pointqueue = [pointqueue; testx testy+1];
       end
       
       if(ComparePoint(mask, testx, testy - 1, 0) == 0)
           pointqueue = [pointqueue; testx testy-1]; 
       end

       %look left
       testx = startx - 1; 
       while(testx > minX)
            if(testx > maxX)
                break; 
            elseif(testy < minY || testy > maxY)
                break; 
            elseif(mask(testy, testx) == 0)
                break; 
            else
                mask(testy, testx) = 0;
                RegionPoints(iRegionPoint, :) = [testx testy];
                iRegionPoint = iRegionPoint + 1; 
      
                if(ComparePoint(mask, testx, testy + 1, 0) == 0)
                   pointqueue = [pointqueue; testx testy+1];
                end
       
                if(ComparePoint(mask, testx, testy - 1, 0) == 0)
                   pointqueue = [pointqueue; testx testy-1]; 
                end 
            end

            testx = testx - 1;
        end

        %look right
        testx = startx + 1; 
        while(testx < maxX)
            if(testx < minX)
                break; 
            elseif(testy < minY || testy > maxY)
                break; 
            elseif(mask(testy, testx) == 0)
                break; 
            else
                mask(testy, testx) = 0;
                RegionPoints(iRegionPoint, :) = [testx testy];
                iRegionPoint = iRegionPoint + 1; 
               
                if(ComparePoint(mask, testx, testy + 1, 0) == 0)
                    pointqueue = [pointqueue; testx testy+1];
                end
       
                if(ComparePoint(mask, testx, testy - 1, 0) == 0)
                    pointqueue = [pointqueue; testx testy-1]; 
                end
            end

            testx = testx + 1;
        end
    end
end

%Eliminate empty region points
RegionPoints(iRegionPoint:end, :) = []; 
RegionPoints = sortrows(RegionPoints); 
