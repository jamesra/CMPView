classdef Measure < handle
%Measure - Parent class of all algorithms which measure the distance
%between an arbitrary number of distributions

   properties
       Controller
   end
   
   properties (Abstract = true)
       Name
   end
   
   methods 
       function obj = Measure(Controller)
            obj.Controller = Controller;
       end
   end
   
   methods (Abstract = true)
       %Categories - A 1xN matrix with labels for each row in Data
       %Data - A MXN matrix of samples and observed attributes
       %Distances - A NXN matrix showing the distance between each category
       [Distances] = MeasureDistance(obj,Collection, Categories, Data);
       obj = ShowProperties(obj); 
   end
end 
