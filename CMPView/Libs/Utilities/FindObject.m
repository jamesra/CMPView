function [ obj ] = FindObject( Objects, x, y )
%FINDOBJECT - Returns the index of the object located at the points given

pos = zeros(length(Objects), 2);

for(iObj  = 1:length(Objects))
    pos(iObj, :) = get(Objects(iObj), 'Center');
end

diff = [pos(:,2) - x pos(:,1) - y];
diff = diff .^ 2; 
dist = diff(:, 1) + diff(:, 2);
dist = sqrt(dist);

index = 1:length(Objects); 
index = index'; 
dist = [index dist]; 
dist = sortrows(dist, 2); 

for(iObj  = 1:length(Objects))
    index = dist(iObj, 1); 
    
    region = get(Objects(index), 'Region');
    
    matches = find(region(:,2) == x);
    
    if(isempty(matches))
        continue;
    end
    
    match = find(region(matches, 1) == y);
    
    if(~isempty(match))
        obj = Objects(index); 
        return;
    end
end

obj = [];