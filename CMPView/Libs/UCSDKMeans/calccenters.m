function [center, obj] = calccenters(data )
%CALCCENTERS returns a gmdistribution object for the data  in a class

center = mean(data);
sigma = std(data); 

obj = gmdistribution(center, sigma);
%obj = gmdistribution(center, sigma);


end

