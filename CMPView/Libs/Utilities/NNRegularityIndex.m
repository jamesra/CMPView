function [ RegularityIndex, NearestIndicies ] = NNRegularityIndex( Points )
%Indicies is the indicies of the node which is closest to the node with the
%matching index in the array

numPts = length(Points(:,1)); 
%{
Dist = squareform(pdist(Points));
ind = sub2ind(size(Dist), 1:length(Dist), 1:length(Dist));
Dist(ind) = inf;
NearestNeighbors = min(Dist);
RegularityIndex = mean(NearestNeighbors) / std(NearestNeighbors); 
%}
    

D = delaunay(Points(:, 2), Points(:,1)); 

%Determine where the shortest edges lie

%Precompute the distances
iNodeA = 1; 
iNodeB = 2; 
Distance12 = ((Points(D(:, iNodeA),1) - Points(D(:,iNodeB),1)).^2) + ((Points(D(:, iNodeA),2) - Points(D(:,iNodeB),2)).^2);
Distance12 = sqrt(Distance12); 
iNodeB = 3;
Distance13 = ((Points(D(:, iNodeA),1) - Points(D(:,iNodeB),1)).^2) + ((Points(D(:, iNodeA),2) - Points(D(:,iNodeB),2)).^2);
Distance13 = sqrt(Distance13); 
iNodeA = 2; 
Distance23 = ((Points(D(:, iNodeA),1) - Points(D(:,iNodeB),1)).^2) + ((Points(D(:, iNodeA),2) - Points(D(:,iNodeB),2)).^2);
Distance23 = sqrt(Distance23);

NearestNeighbor = ones(numPts, 1) * inf;

NearestIndicies = zeros(numPts, 1); 

for(i = 1:length(Distance12))
    [NearestNeighbor(D(i,1)), iMin1] = min([NearestNeighbor(D(i,1)) Distance12(i) Distance13(i)]); 
    [NearestNeighbor(D(i,2)), iMin2] = min([Distance12(i) NearestNeighbor(D(i,2)) Distance23(i)]); 
    [NearestNeighbor(D(i,3)), iMin3] = min([Distance13(i) Distance23(i) NearestNeighbor(D(i,3)) ]); 
    
    %Record the index of the nearest node
    if(iMin1 ~= 1)
        NearestIndicies(D(i,1)) = D(i,iMin1);
    end
    
    if(iMin2 ~= 2)
        NearestIndicies(D(i, 2)) = D(i, iMin2); 
    end
    
    if(iMin3 ~= 3)
        NearestIndicies(D(i, 3)) = D(i, iMin3); 
    end
end

RegularityIndex = mean(NearestNeighbor) / std(NearestNeighbor); 