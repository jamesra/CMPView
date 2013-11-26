function [ LabelMap ] = GetLabelMap( LabelImage )
%GETLABELDATA - Given an index image returns a data structure describing
%each labeled region.  The first column is the label value and the second
%column contains a cell array with all coordinates. 
     
    LabelValues = unique(LabelImage); 
    
    LabelMap = cell(length(LabelValues), 2); 
    
    for(iLabel = 1:length(LabelValues))
       LabelValue = LabelValues(iLabel);
       
       LabelIndicies = find(LabelImage == LabelValue);
       
       LabelMap(iLabel, :) = [LabelValue {LabelIndicies}];
    end
    

end

