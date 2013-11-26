classdef Categorizer < handle
%CATEGORIZER - Parent class of all clustering algorithms

   properties
       Controller
   end
   
   properties (Abstract = true)
       Name
   end
   
   methods 
       function obj = Categorizer(Controller)
            obj.Controller = Controller;
       end
   end
   
   methods (Abstract = true)
       [Categories] = Categorize(obj,Collection, Data);
       obj = ShowProperties(obj); 
   end
end 
