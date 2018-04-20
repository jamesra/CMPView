classdef RegionObj
    %REGIONOBJ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
    end
    
    methods(Static)
        function Regions = UpdateRegions(NewRegion, Regions)
            %Given a region and a cell array of regions sorted by size, 
            %removes all regions in the array that intersect
            %the NewRegion and inserts the new region in the
            %correct position
            NewRegionSize = length(NewRegion);
            
            iR = 1; 
            while(iR <= length(Regions))
                if(sum(ismember(NewRegion, Regions{iR})) > 0)
                    Regions(iR) = [];
                    continue; 
                end

                %The new region must be larger than all of
                %the regions we merged with, so we can
                %break from the loop when we find the right
                %position to insert

                if(length(Regions{iR}) > NewRegionSize)
                    Regions = {Regions{1:iR-1} NewRegion Regions{iR:end}};
                    break; 
                end

                iR = iR + 1; 
            end
            
            %If it is larger than all of the regions we still need to
            %insert it
            if(NewRegionSize > length(Regions{end}))
                 Regions = {Regions{:} NewRegion};
            end
        end
        
        function Region = FindBestMerge(IndexImage, StartRegion, ViableBorders)
            %Given an index image and a region, determine if there are
            %adjacent regions we can combine with which reduces the overall
            %Area / Border ratio
            
            
        end
    end
    
end

