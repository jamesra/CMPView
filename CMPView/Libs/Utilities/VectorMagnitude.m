function [ M ] = VectorMagnitude( V )
%VECTORLENGTH - Given a vector, return magnitude length L

M = sum(V .^ 2);
M = sqrt(M); 