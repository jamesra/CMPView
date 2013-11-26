classdef Template
%TEMPLATE Summary of this class goes here
%   Detailed explanation goes here

   properties
   end

   methods
       function obj = Template(Controller)
          obj = obj@Categorizer(Controller); 
       end
       
       function [Categories] = Categorize(obj,Collection, Data)
           
           %Figure out how many attributes and Rows the data has
           [numRows, numAttributes] = size(Data); 
           
           %Create an output array where we assign all rows of data to
           %class 1
           Categories = ones(numRows,1); 

       end
       
       
       function obj = ShowProperties(obj)
           disp(['Template has no properties to edit']);
       end
   end
end 
