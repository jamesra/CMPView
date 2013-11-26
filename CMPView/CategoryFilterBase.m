classdef CategoryFilterBase < handle
%Filter - Parent class of all image filter algorithms
%         The filter method returns a 1-D category assignment array of the same
%         size as the passed index image
   properties
       Controller
   end
   
   properties (Abstract = true)
       Name
   end
   
   methods 
       function obj = CategoryFilterBase(Controller)
            obj.Controller = Controller;
       end
   end
   
   methods (Abstract = true)
       [NewCategories] = Filter(obj, Collection, IndexImage);
       obj = ShowProperties(obj); 
   end
end 
