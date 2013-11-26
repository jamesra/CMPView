function [ Boundary ] = RegionBoundary( Region )
%REGIONBOUNDARY - Boundary pixels of the provided region.

[numPixels, numCoord] = size(Region);

minVal = min(Region);
maxVal = max(Region);

minRow = minVal(1); 
minCol = minVal(2);
maxRow = maxVal(1);
maxCol = maxVal(2); 

Boundary = zeros(((maxRow - minRow) + (maxCol - minCol)) * 2, 2);

index = 1; 

%BUG - Regionboundary does not find interior borders in the region
for(iRow = minRow:maxRow)
    matches = find(Region(:,1) == iRow);
    
    Boundary(index,:) = [iRow (min(Region(matches,2)) - 1) ];
    Boundary(index + 1,:) = [iRow (max(Region(matches,2)) + 1) ]; 
    index = index + 2; 
end

for(iCol = minCol:maxCol)
    matches = find(Region(:,2) == iCol);
    
    Boundary(index,:) = [(min(Region(matches,1)) - 1) iCol ];
    Boundary(index + 1,:) = [(max(Region(matches,1)) + 1) iCol]; 
    index = index + 2; 
end


