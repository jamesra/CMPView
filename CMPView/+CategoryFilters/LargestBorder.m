classdef LargestBorder < CategoryFilterBase
%LARGESTBORDER - Walks through all unassigned regions
%   smallest to largest.  If there is a border with an unlocked class larger
%   than the border with locked classes, and the area of the adjacent region
%   is larger than the region tested the region is assigned to the unlocked class
    
    properties
        Name = 'Move to Largest Border';
        MinArea = 0;
        AssignTo = ''; 
    end
    
    properties 
        ValidAssigns = {'Unknown', ...
                        'Largest Border'};
                    
    end
    
    methods
        function obj = LargestBorder(Controller)
          obj = obj@CategoryFilterBase(Controller);

          obj.MinArea = getpref('LargestBorder', 'MinArea', 32);
          obj.AssignTo = getpref('LargestBorder', 'AssignTo', 'Largest Border');
        end

        function [NewCategories] = Filter(obj, Collection, IndexImage)

            [YDim, XDim] = size(IndexImage); 
            NewCategories = Collection.Categories;          

            Unlocked = and([Collection.CategoryObjects(:).CanAddMembers], [Collection.CategoryObjects(:).CanRemoveMembers]);

            UnlockedCatNumbers = find(Unlocked); 
            CatObjects = Collection.CategoryObjects(Unlocked);

            %Holds the next index to be read from each region, or zero if
            %no regions remain in category
            iCatNextRegionIndex = ones(length(UnlockedCatNumbers), 1);

            %Initialize the region sizes
            RSize = zeros(length(UnlockedCatNumbers), 2);            
            RSize(:,2) = UnlockedCatNumbers; 
            for(iRegion = 1:length(UnlockedCatNumbers))
                NextRegion = CatObjects(iRegion).Regions{iCatNextRegionIndex(iRegion)};
                RSize(iRegion,1) = length(NextRegion);
            end
            
            iAvailableCategories = find(iCatNextRegionIndex);
            
            %Walk through each region in order of smallest to largest. 
            while(sum(iCatNextRegionIndex) > 0)

                %Find the next region to test, exclude categories we've
                %already processed
                 
                [~,iMin] = min(RSize(:, 1));
                
                CategoryNumber = RSize(iMin, 2);
                
                Region = CatObjects(iMin).Regions{iCatNextRegionIndex(iMin)};
               
                [y,x] = ind2sub(size(IndexImage), Region(1)); 
                
                %Update the region with any earlier changes
                [~,NewRegionCoords] = IterFill(IndexImage, [], XDim, YDim, x,y, IndexImage(Region(1)), 1); 
                
                Region = sub2ind(size(IndexImage), NewRegionCoords(:,2), NewRegionCoords(:,1));

                B = Border(IndexImage, NewCategories(Region(1)), Region);
                
                if(~isempty(B))
                    %Figure out the category of the border indicies
                    BorderCats = IndexImage(B);
                    
                    %Removed locked categories from consideration
                    iUnlocked = Unlocked(BorderCats); 
                    BorderCats = BorderCats(iUnlocked); 
                    
                    %If surrounded by locked categories we have nothing
                    %to do
                    if(~isempty(BorderCats))
                        
                        %Find our original AreaToBorderRatio...
                        OriginalAreaToBorderRatio = len(Region) / len(B); 
                        
                        %Figure out which border is the most common
                        [UniqueBorderCats, ~, iUnique] = unique(BorderCats);
                        
                        ReplacementCategoryNumber = BorderCats(1);
                        if(length(UniqueBorderCats) > 1)
                            SortedCats = sort(BorderCats);
                            CatCount = zeros(length(UniqueBorderCats),2);
                            CatCount(:,2) = UniqueBorderCats; 
                            for(iCat = 1:length(SortedCats))
                               CatCount(iUnique(iCat),1) = CatCount(iUnique(iCat),1) + 1; 
                            end
                            
                            [~, iMaxUnlocked] = max(CatCount(:,1));
                            ReplacementCategoryNumber = CatCount(iMaxUnlocked,2);                        
                        end
                        
                         %   TotalLockedBorder = sum(CatCount(iLocked,1));
%                            TotalUnlockedBorder = sum(CatCount(iUnlocked,1)); 
                            
 %                           UnlockedCatCount = CatCount(iUnlocked,:);
                            
%                            [~, iMaxUnlocked] = max(UnlockedCatCount(:,1));
                           
                        NewCategories(Region) = ReplacementCategoryNumber;
                            
                        %Update the IndexImage used to find Borders
                        IndexImage(Region) = ReplacementCategoryNumber; 

                        %Update region sizes here so the algorithm
                        %doesn't use pre-merge sizes
                        [y,x] = ind2sub(size(IndexImage), Region(1)); 
                        [~,NewRegionCoords] = IterFill(IndexImage, [], XDim, YDim, x,y, ReplacementCategoryNumber, 1);

                        NewRegion = sub2ind([YDim XDim], NewRegionCoords(:,2), NewRegionCoords(:,1));
                        
                        iUnlockedRegion = find(UnlockedCatNumbers == ReplacementCategoryNumber);
                        
                        UpdatedRegions = RegionObj.UpdateRegions(NewRegion, CatObjects(iUnlockedRegion).Regions);
                        CatObjects(iUnlockedRegion).Regions = UpdatedRegions;
                    end
                end

                iCatNextRegionIndex(iMin) = iCatNextRegionIndex(iMin) + 1;
                if(iCatNextRegionIndex(iMin) >  length(CatObjects(iMin).Regions))
                    iCatNextRegionIndex(iMin) = []; 
                    iAvailableCategories(iMin) = [];
                    CatObjects(iMin) = []; 
                    RSize(iMin, :) = []; 
                else
                    RSize(iMin,1) = length(CatObjects(iMin).Regions{iCatNextRegionIndex(iMin)});
                end
                
            end
        end
        
        
        
       
        function obj = ShowProperties(obj)
           Data = {obj.MinArea, ...
                   obj.AssignTo
                   };
                   
           ColumnName = {'Min Area' ...
                       'Assign To'};
                   
           ColumnFormat = {'numeric', ...
                           obj.ValidAssigns, ...
                           'numeric', ...
                           'numeric'};

           ColumnEditable = [true true];                                     
           hFig = figure('NumberTitle', 'off', ...
             'Toolbar', 'none',  ...
             'MenuBar', 'none', ...
             'units', 'normalized', ...
             'Name', [obj.Name ' Properties']);
    
           hTable = uitable('Parent', hFig, ...
                            'Data', Data, ...
                            'ColumnFormat', ColumnFormat, ...
                            'ColumnName', ColumnName, ...
                            'ColumnEditable', ColumnEditable, ...
                            'Units', 'Normalized', ...
                            'Position', [0 0 1 1], ...
                            'CellEditCallback', @(src,event)CellEditCallback(obj,src,event));
                                   
        end
       
        function obj = CellEditCallback(obj, src,event)
          if(isempty(event.Error))
             Index = event.Indices(2); 
             ColumnNames = get(src, 'ColumnName');
             Propname = ColumnNames{Index}; 
             
             switch Propname
                 case 'Min Area'
                     obj.MinArea = event.NewData;
                 case 'Assign To'
                     obj.AssignTo = event.NewData; 
             end
             
             setpref('LargestBorder', 'MinArea', obj.MinArea);
             setpref('LargestBorder', 'AssignTo', obj.AssignTo);
          end
          
          
       end
       
    end
    

end

