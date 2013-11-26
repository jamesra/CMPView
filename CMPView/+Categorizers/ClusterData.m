classdef ClusterData < Categorizer
%KMEANS Summary of this class goes here
%   Detailed explanation goes here

   properties
       Distance = 'seuclidean';
       Linkage = 'weighted';
       Cutoff = 1; 
       Depth = 1; 
       
       Name = 'Heirarchical'; 
   end

   methods
       function obj = ClusterData(Controller)
          obj = obj@Categorizer(Controller); 
          
          obj.Distance = getpref('ClusterData', 'Distance', 'seuclidean');
          obj.Linkage = getpref('ClusterData', 'Linkage', 'weighted');
          obj.Cutoff = getpref('ClusterData', 'Cutoff', 1);
          obj.Depth = getpref('ClusterData', 'Depth', 1);
       end
       
       function [Categories] = Categorize(obj,Collection, Data)
           
           if(Collection.NumAddCategories <= 1)
              disp('Not enough categories to add to, aborting K-means');
              nPoints = size(Data); 
              Categories = ones(nPoints(1),1); 
              return; 
           end
           
           [Categories] = clusterdata(Data, ...
                                          'criterion', 'distance', ...
                                          'maxclust', Collection.NumAddCategories, ...
                                          'linkage', obj.Linkage, ...
                                          'distance', obj.Distance, ...
                                          'cutoff', obj.Cutoff, ...
                                          'depth', obj.Depth);
       end
       
       
       function obj = ShowProperties(obj)
           Data = {obj.Distance ...
                   obj.Linkage ...
                   obj.Cutoff ...
                   obj.Depth};
                   
           ColumnName = {'Distance' ...
                       'Linkage' ...
                       'Cutoff' ...
                       'Depth'};
                   
           ColumnFormat = {{'euclidean' 'seuclidean' 'cityblock' 'minkowski' 'correlation' 	'hamming'}, ...
                           {'average' 'centroid' 'complete' 'median' 'single' 'ward' 'weighted'}, ...
                           'numeric', ...
                           'numeric'};

           ColumnEditable = [true true true true];                                     
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
                 case 'Cutoff'
                     obj.Cutoff = event.NewData; 
                 case 'Depth'
                     obj.Depth = event.NewData;
                 case 'Linkage'
                     obj.Linkage = event.NewData;
             end
             
             setpref('ClusterData', 'Distance', obj.Distance);
             setpref('ClusterData', 'Linkage', obj.Linkage);
             setpref('ClusterData', 'Cutoff', obj.Cutoff);
             setpref('ClusterData', 'Depth', obj.Depth);
          end
          
          
       end
   end
end 
