classdef RemoveIslands < CategoryFilterBase
    %MINAREA - Assigns all labeled regions smaller than specified area into
    %either unclassified pixels or nearest neighbor if surrounded
    
    properties        
        Name = 'Remove Islands';
        
        IgnoreLocked = false;  %Indicates if locked classes are counted when determining
                                    %if a region is surrounded by another
                                    %region
    end
    
    properties (Access = 'protected')
    end
    
    methods
        function obj = RemoveIslands(Controller)
          obj = obj@CategoryFilterBase(Controller); 
          
          obj.IgnoreLocked = getpref('RemoveIslands', 'IgnoreLocked', false);
        end
       
        function [NewCategories] = Filter(obj, Collection, IndexImage)
            
            NewCategories = Collection.Categories; 
            
            Unlocked = and([Collection.CategoryObjects(:).CanAddMembers], [Collection.CategoryObjects(:).CanRemoveMembers]);
            
            for(iCat = 1:Collection.NumCategories)
                
                LabelMap = Collection.CategoryObjects(iCat).Regions; 
                if(isempty(LabelMap))
                    continue;
                end
                
                if(~(Collection.CategoryObjects(iCat).CanAddMembers && Collection.CategoryObjects(iCat).CanRemoveMembers))
                   continue;  
                end
                
                NumRegions = length(LabelMap);
                
                for(iRegion = 1:NumRegions)
                    Region = LabelMap{iRegion}; 
                    
                    %Determine if this region is an island
                    
                    %Remove this region from the cluster
                    B = Border(IndexImage, iCat, Region);

                    %Figure out the category of the border indicies
                    BorderCats = IndexImage(B);
                    
                    if(obj.IgnoreLocked)
                        iUnlocked = Unlocked(BorderCats); 
                        BorderCats = BorderCats(iUnlocked); 
                    end

                    %If all border indicies belong to the same class,
                    %assign the label to that class
                    if(length(unique(BorderCats)) == 1)
                        %Don't add to the unassigned category
                        
                        if(Collection.CategoryObjects(BorderCats(1)).CanAddMembers)
                            IndexImage(Region) = BorderCats(1);  
                            NewCategories(Region) = BorderCats(1); 
                        end
                    end
                end
            end
        end
       
        function obj = ShowProperties(obj)
           Data = {obj.IgnoreLocked, ...
                  };
                   
           ColumnName = {'Ignore Locked Categories' ...
                       };
                   
           ColumnFormat = {'logical', ...
                           };

           ColumnEditable = [true];                                     
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
                 case 'Ignore Locked Categories'
                     obj.IgnoreLocked = event.NewData;
             end
             
             setpref('RemoveIslands', 'IgnoreLocked', obj.IgnoreLocked);
          end
           
        end
       
  
       
    end
    
end

