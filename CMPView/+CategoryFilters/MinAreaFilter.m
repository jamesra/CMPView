classdef MinAreaFilter < CategoryFilterBase
    %MINAREA - Assigns all labeled regions smaller than specified area into
    %either unclassified pixels or nearest neighbor if surrounded
    
    properties
        MinArea = 32;
        AssignTo = 'Largest Border';
        
        Name = 'Min Area Cutoff';
    end
    
    properties 
        ValidAssigns = {'Unknown', ...
                        'Largest Border'};
    end
    
    methods
        function obj = MinAreaFilter(Controller)
          obj = obj@CategoryFilterBase(Controller);

          obj.MinArea = getpref('MinAreaFilter', 'MinArea', 32);
          obj.AssignTo = getpref('MinAreaFilter', 'AssignTo', 'Largest Border');
        end

        function [NewCategories] = Filter(obj, Collection, IndexImage)
            
            NewCategories = Collection.Categories; 
            
            for(iCat = 1:Collection.NumCategories)
                
                if(~(Collection.CategoryObjects(iCat).CanAddMembers && Collection.CategoryObjects(iCat).CanRemoveMembers))
                   continue;  
                end
                
                LabelMap = Collection.CategoryObjects(iCat).Regions; 
                if(isempty(LabelMap))
                    continue;
                end
                
                NumRegions = length(LabelMap);
                
                for(iRegion = 1:NumRegions)
                    Region = LabelMap{iRegion}; 
                
                    %This works because we know the Map is sorted
                    if(length(Region) > obj.MinArea)
                        break;
                    end

                    %Remove this region from the cluster
                    if(strcmp(obj.AssignTo, 'Unknown'))
                        NewCategories(Region) = 1;
                    elseif(strcmp(obj.AssignTo, 'Largest Border'))
                        B = Border(IndexImage, NewCategories(Region(1)), Region);

                        if(isempty(B))
                            continue;
                        end

                        %Figure out the category of the border indicies
                        BorderCats = IndexImage(B);

                        %Figure out which border is the most common
                        [UniqueBorderCats, ~, iUnique] = unique(BorderCats);

                        iReplacementCat = BorderCats(1);
                        if(length(UniqueBorderCats) > 1)
                            SortedCats = sort(BorderCats);

                            CatCount = zeros(length(UniqueBorderCats),1);
                            
                            for(iCat = 1:length(SortedCats))
                               CatCount(iUnique(iCat)) = CatCount(iUnique(iCat)) + 1; 
                            end

%                             iCatBeingCounted = 1;
%                             ExpectedValue = UniqueBorderCats(iCatBeingCounted);
%                             Count = 0; 
%                             
%                                 if(ExpectedValue == SortedCats(iCat))
%                                     Count = Count + 1; 
%                                 else
%                                     CatCount(iCatBeingCounted, :) = [UniqueBorderCats(iCatBeingCounted) Count];
%                                     Count = 0;
%                                     iCatBeingCounted = iCatBeingCounted + 1; 
%                                     ExpectedValue  = UniqueBorderCats(iCatBeingCounted);
%                                 end
%                             end
% 
%                             CatCount(iCatBeingCounted, :) = [UniqueBorderCats(iCatBeingCounted) Count];

                            %Figure out which category was the most common
                            [~, iMax] = max(CatCount(:,1));
                            iReplacementCat = UniqueBorderCats(iMax); 
                        end

                        NewCategories(Region) = iReplacementCat;
                    end
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
             
             setpref('MinAreaFilter', 'MinArea', obj.MinArea);
             setpref('MinAreaFilter', 'AssignTo', obj.AssignTo);
          end
          
          
       end
       
    end
    
end

