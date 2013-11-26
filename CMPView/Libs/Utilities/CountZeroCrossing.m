function [ nZero ] = CountZeroCrossing( deriv )
%FINDZEROCROSSING - Returns the number of times a derivative passes through
%zero

nZero = 0; 
if(isempty(deriv))
    return;
end

count = length(deriv);
if(count < 2)
    return;
end

%Account for a starting zero in the input
if(deriv(1) == 0 && deriv(2) ~= 0)
    nZero = 1; 
end

for(i = 2:count)
    if(deriv(i - 1) < 0 && deriv(i) > 0)
        nZero = nZero + 1; 
    elseif(deriv(i - 1) > 0 && deriv(i) < 0)
        nZero = nZero + 1;
    elseif(deriv(i) == 0 && deriv(i-1) ~= 0)
        nZero = nZero + 1; 
    end
end

