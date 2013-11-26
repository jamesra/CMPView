function distances = calcdist(data,center, varargin)
%  input: vector of data points, single center or multiple centers
% output: vector of distances

optargin = size(varargin, 2);
gmfit = [];
if(optargin == 1)
    gmfit = varargin{1}; 
end

[n,dim] = size(data);
[n2,dim2] = size(center);

if (~isobject(gmfit))
    % Using repmat is slower than using ones(n,1)
        %   delta = data - repmat(center,n,1);
        %   delta = data - center(ones(n,1),:);
        % The following is fastest: not duplicating the center at all

        if n2 == 1
            distances = sum(data.^2, 2) - 2*data*center' + center*center';
        elseif n2 == n
            distances = sum( (data - center).^2 ,2);
        else
            error('bad number of centers');
        end

        % Euclidean 2-norm distance:
        distances = sqrt(distances);
else
        if isempty(data)
            distances = []; 
        else
            distances = mahal(gmfit, data);
        end
end


       

% Inf-norm distance:
% distances = max(abs(distances),[],2);
