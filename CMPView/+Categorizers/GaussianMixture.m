classdef GaussianMixture < Categorizer
%GaussianMixture Summary of this class goes here
%   Detailed explanation goes here

   properties
       Replicates = 4;
       Start = 'sample'; 
       MaxIter = 10000000; 
       
       Name = 'Gaussian Mixture'; 
   end

   methods
       function obj = GaussianMixture(Controller)
          obj = obj@Categorizer(Controller); 
          
          obj.Replicates = getpref('GaussianMixture', 'Replicates', 4);
          obj.Start = getpref('GaussianMixture', 'Start', 'sample');
          obj.MaxIter = getpref('GaussianMixture', 'MaxIter', 10000000);
       end
       
       function [Categories] = Categorize(obj,Collection, Data)
           
    %       options = statset('Display', 'iter', ...
%                             'MaxIter', obj.MaxIter);
                         
           if(Collection.NumAddCategories <= 1)
              disp('Not enough categories to add to, aborting K-means');
              nPoints = size(Data); 
              Categories = ones(nPoints(1),1); 
              return; 
           end 
           
%       [Categories];           
        options = statset('Display','iter', ...
                          'MaxIter', obj.MaxIter, ...
                          'Robust', 'on');
                      
        %Locate and distable columns with zero variance
        [n,d] = size(Data); 
        varData = var(Data);
        I = find(varData < eps(max(varData))*n);
        if ~isempty(I)
            disp(['The following column(s) of data are effectively constant and have been ignored: %s.' num2str(I)]);
            Data(:,I) = [];
            if(isempty(Data))
                Categories = [];
                return
            end
        end
                      
        gmModel = gmdistribution.fit(Data, ...
                                     Collection.NumAddCategories, ...
                                     'Replicates', obj.Replicates, ...
                                     'options', options);
                                 
        Categories = cluster(gmModel, Data); 
                              
        
                                 
                                 
%                                          'emptyaction', 'singleton', ...
%                                          'distance', obj.Distance, ...
%                                          'onlinephase', obj.OnlinePhase, ...
%                                          'replicates', obj.Replicates, ...
%                                          'start', obj.Start, ...
%                                          'options', options);
       end
       
       
       function obj = ShowProperties(obj)
           Data = {obj.Replicates ...
                   obj.MaxIter};
                   
           ColumnName = {'Replicates' ...
                       'Max Iterations'};
                   
           ColumnFormat = {'numeric', ...
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
                 case 'Online Phase'
                     obj.OnlinePhase = event.NewData; 
                 case 'Replicates'
                     obj.Replicates = event.NewData;
                 case 'Start'
                     obj.Start = event.NewData;
                 case 'Max Iterations'
                     obj.MaxIter = event.NewData;
             end
             
             setpref('GaussianMixture', 'Replicates', obj.Replicates);
             setpref('GaussianMixture', 'Start', obj.Start);
             setpref('GaussianMixture', 'MaxIter', obj.MaxIter);
          end
          
          
       end
   end
end 
