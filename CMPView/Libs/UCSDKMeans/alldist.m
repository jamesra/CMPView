function centdist = alldist(centers, varargin)
% output: matrix of all pairwise distances
% input: data points (centers)
%        gmdistribution (optional) 

optargin = size(varargin, 2);
gmfits = [];
if(optargin == 1)
    gmfits = varargin{1}; 
end


k = size(centers,1);
centdist = zeros(k,k);
for j = 1:k
    if isempty(gmfits)
        centdist(1:j-1,j) = calcdist(centers(1:j-1,:),centers(j,:));
    else
        centdist(1:j-1,j) = calcdist(centers(1:j-1,:),centers(j,:), gmfits{j} ); 
    end
end

centdist = centdist+centdist';
    
end
    
    