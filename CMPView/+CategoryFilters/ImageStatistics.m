classdef ImageStatistics < CategoryFilterBase
    %MINAREA - Assigns all labeled regions smaller than specified area into
    %either unclassified pixels or nearest neighbor if surrounded
    
    properties
        MinArea = 32;
        AssignTo = 'Unknown';
        
        Name = 'Category Statistics';
    end
    
    methods
        function obj = ImageStatistics(Controller)
          obj = obj@CategoryFilterBase(Controller); 
        end
       
        function [NewCategories] = Filter(obj, Collection, IndexImage)
            NewCategories = [];

            disp('Class #: [# of Regions] [Total Area] (Mean Median StdDev)');
            
            for(iCat = 1:Collection.NumCategories)
                
                LabelMap = Collection.CategoryObjects(iCat).Regions; 
                if(isempty(LabelMap))
                    continue;
                end
                
                NumRegions = length(LabelMap);

                TotalArea = length(Collection.CategoryObjects(iCat).Members);
                
                NumberOfObjects = NumRegions;
                
                ObjectArea = zeros(1,NumberOfObjects);

                %Find groups of pixels below threshold
                for(iLabel = 1:NumRegions) 
                    Map = LabelMap{iLabel};
                    ObjectArea(iLabel) = length(Map);
                end
                
                if(0 == TotalArea)
                    continue;   
                end

                MeanArea = TotalArea / NumberOfObjects;
                MedianArea = median(ObjectArea);
                StdDevArea = std(ObjectArea); 

                disp([Collection.CategoryObjects(iCat).Name ': N='  num2str(NumberOfObjects) ' A=' num2str(TotalArea) 'px (' num2str(MeanArea) ' ' num2str(MedianArea) ' ' num2str(StdDevArea) ')']);
            end
            
        end
       
        function obj = ShowProperties(obj)
           Data = {obj.MinArea, ...
                   obj.AssignTo
                   };
                   
           ColumnName = {'Min Area' ...
                       'Assign To'};
                   
           ColumnFormat = {'numeric', ...
                           {'Unknown', 'Larget Neighbor'}, ...
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
          end
       end
       
    end
    
end

