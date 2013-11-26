classdef UCSDKMeans < Categorizer
%KMEANS Summary of this class goes here
%   Detailed explanation goes here

   properties
       Distance = 'mahal';
       Replicates = 1;
       
       Name = 'K-Means (optimized)'; 
   end

   methods
       function obj = UCSDKMeans(Controller)
          obj = obj@Categorizer(Controller); 
          
          obj.Distance =    getpref('UCSDKMeans', 'Distance', 'mahal');
          obj.Replicates =  getpref('UCSDKMeans', 'Replicates', 4);
       end
       
       function [Categories] = Categorize(obj,Collection, Data)
                                    
           if(Collection.NumAddCategories <= 1)
              disp('Not enough categories to add to, aborting K-means');
              nPoints = size(Data); 
              Categories = ones(nPoints(1),1); 
              return; 
           end
         
        method = 3; 
        switch lower(obj.Distance)
            case 'mahal'
                method = 3;
            case 'sqeuclidean'
                method = 2; 
        end
        
%       [Categories];
        BestCenters = [];
        BestCategories = [];
        BestQuality2 = []; 
        
        for i = 1:obj.Replicates
            
            [Centers,Categories,mindist,q2,quality] = UCSDkmeans(Data, ...
                                     Collection.NumAddCategories, ...
                                     method);
                                 
            if isempty(BestCategories)
                BestCategories = Categories; 
                BestCenters = Centers;
                BestQuality2 = q2; 
            else
                if q2 < BestQuality2
                    BestCategories = Categories; 
                    BestCenters = Centers;
                    BestQuality2 = q2; 
                end
            end            
        end
        
        Categories = BestCategories; 
                                 
%                                          'emptyaction', 'singleton', ...
%                                          'distance', obj.Distance, ...
%                                          'onlinephase', obj.OnlinePhase, ...
%                                          'replicates', obj.Replicates, ...
%                                          'start', obj.Start, ...
%                                          'options', options);
       end
       
       
       function obj = ShowProperties(obj)
           Data = {obj.Distance ...
                   obj.Replicates};
                   
           ColumnName = {'Distance' ...
                       'Replicates'};
                   
           ColumnFormat = {{'sqEuclidean' 'mahal'}, ...
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
                 case 'Distance'
                     obj.Distance = event.NewData;
                 case 'Replicates'
                     obj.Replicates = event.NewData;
             end
             
             setpref('UCSDKMeans', 'Distance', obj.Distance);
             setpref('UCSDKMeans', 'Replicates', obj.Replicates);
          end
       end
   end
end 
