function [ scalars ] = ProjectOntoVector( vector, points )
%PROJECTONTOVECTOR - Given an N-dimensional vector and an array
% of N-dimensional points (Columns = coordinates, Rows = Points)
% Project the points onto the vector and return the resultsing 
% scalar values

[numPts, numCoords] = size(points);

%Extend vector length of the points array
vector = repmat(vector,numPts,1);

scalars = dot(vector, points, 2); 