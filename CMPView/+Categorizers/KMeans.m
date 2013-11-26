classdef KMeans < Categorizer
%KMEANS Summary of this class goes here
%   Detailed explanation goes here

   properties
       Distance = 'sqEuclidean';
       OnlinePhase = 'off';
       Replicates = 4;
       Start = 'sample'; 
       MaxIter = 100000; 
       
       Name = 'K-Means (Matlab)'; 
   end

   methods
       function obj = KMeans(Controller)
          obj = obj@Categorizer(Controller); 
          
          obj.Distance =    getpref('KMeans', 'Distance', 'sqEuclidean');
          obj.OnlinePhase = getpref('KMeans', 'OnlinePhase', 'off');
          obj.MaxIter =     getpref('KMeans', 'MaxIter', 100000);
          obj.Replicates =  getpref('KMeans', 'Replicates', 4);
          obj.Start =       getpref('KMeans', 'Start', 'sample');
       end
       
       function [Categories] = Categorize(obj,Collection, Data)
           
           options = statset('Display', 'iter', ...
                             'MaxIter', obj.MaxIter);
                         
           if(Collection.NumAddCategories <= 1)
              disp('Not enough categories to add to, aborting K-means');
              nPoints = size(Data); 
              Categories = ones(nPoints(1),1); 
              return; 
           end
           
           [Categories] = kmeans(Data, ...
                                          Collection.NumAddCategories, ...
                                          'emptyaction', 'singleton', ...
                                          'distance', obj.Distance, ...
                                          'onlinephase', obj.OnlinePhase, ...
                                          'replicates', obj.Replicates, ...
                                          'start', obj.Start, ...
                                          'options', options);
       end
       
       
       function obj = ShowProperties(obj)
           Data = {obj.Distance ...
                   obj.OnlinePhase ...
                   obj.Replicates ...
                   obj.Start ...
                   obj.MaxIter};
                   
           ColumnName = {'Distance' ...
                       'Online Phase' ...
                       'Replicates' ...
                       'Start'  ...
                       'Max Iterations'};
                   
           ColumnFormat = {{'sqEuclidean' 'cityblock'	'cosine' 'correlation' 	'correlation'}, ...
                           {'on' 'off'}, ...
                           'numeric', ...
                           {'sample' 'uniform' 'cluster'}, ...
                           'numeric'};

           ColumnEditable = [true true true true true];                                     
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
                 case 'Online Phase'
                     obj.OnlinePhase = event.NewData; 
                 case 'Replicates'
                     obj.Replicates = event.NewData;
                 case 'Start'
                     obj.Start = event.NewData;
                 case 'Max Iterations'
                     obj.MaxIter = event.NewData;
             end
             
             setpref('KMeans', 'Distance',  obj.Distance);
             setpref('KMeans', 'OnlinePhase', obj.OnlinePhase);
             setpref('KMeans', 'MaxIter', obj.MaxIter);
             setpref('KMeans', 'Replicates', obj.Replicates);
             setpref('KMeans', 'Start', obj.Start);
          end
          
          
       end
   end
end 
