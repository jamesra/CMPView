classdef Threshold < Categorizer
%MASK Places all attributes with a specified value into a single class

   properties
        MaskValue = 0;
        Operator = '='; 
        Name = 'Threshold';
   end

   methods
       function obj = Threshold(Controller)
          obj = obj@Categorizer(Controller); 
          
          obj.Operator =   getpref('Threshold', 'Operator', '=');
          obj.MaskValue =  getpref('Threshold', 'MaskValue', 0);
       end
       
       %Mask simply finds all items which match the specified value for
       %each attribute and assigns them to a category.  Category 1 if they
       %do not match the mask and category 2 if they do.
       function [Categories] = Categorize(obj,Collection, Data)
           
           nPoints = size(Data);
           nAttributes = nPoints(2);
           Categories = ones(nPoints(1),1);
           MaskValues = repmat(obj.MaskValue, nAttributes, 1);       
                      
           iMatches = [,]; 
           
           %I couldn't get find to work on rows of a dataset, so I use find
           %on each column 
           %find any data points that match the mask. 
           for(i = 1:nAttributes)
               
               if(MaskValues(i) >= 1)
                   MaskValues(i) = MaskValues(i) / 255;
               end
                   
               
               %On the first pass test every pixel
               if(i == 1)
                  switch(obj.Operator)
                   case '>'
                    bMatches = Data(:,i) > MaskValues(i); 
                   case '>='
                    bMatches = Data(:,i) >= MaskValues(i); 
                   case '='
                    bMatches = Data(:,i) == MaskValues(i); 
                   case '<='
                    bMatches = Data(:,i) <= MaskValues(i); 
                   case '<'
                    bMatches = Data(:,i) < MaskValues(i); 
                  end
                  
                  iMatches = find(bMatches); 
               else
                  bMatches = iMatches;  
                  
                  switch(obj.Operator)
                   case '>'
                    bMatches = Data(bMatches,i) > MaskValues(i); 
                   case '>='
                    bMatches = Data(bMatches,i) >= MaskValues(i); 
                   case '='
                    bMatches = Data(bMatches,i) == MaskValues(i); 
                   case '<='
                    bMatches = Data(bMatches,i) <= MaskValues(i); 
                   case '<'
                    bMatches = Data(bMatches,i) < MaskValues(i); 
                  end
                  
                  %Only check rows which were matched during the last
                   %iteration
                  iMatches = iMatches(bMatches); 
               end
               
               %{'>', '>=', '=', '<=', '<'}
           end
           
           %Assign all matching points to a different category
           Categories(iMatches) = 2; 
           
       end
       
       function obj = ShowProperties(obj)
           Data = {obj.MaskValue ...
                   obj.Operator};
                   
           ColumnName = {'Mask Value', ...
                         'Operator'};
                   
           ColumnFormat = {'numeric', ...
                           {'>', '>=', '=', '<=', '<'}};

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
                 case 'Mask Value'
                     obj.MaskValue = event.NewData;
                 case 'Operator'
                     obj.Operator = event.NewData; 
             end
             
             setpref('Threshold', 'Operator', obj.Operator);
             setpref('Threshold', 'MaskValue', obj.MaskValue);
          end
       end
   end
end 
