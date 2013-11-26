classdef RemoveCategory < Action
%REMOVECATEGORY Summary of this class goes here
%   Detailed explanation goes here

   properties
       Name = 'Remove Category'; 
       Category = [];
       Collection = []; 
   end

   methods
       %Property change object to change the value of properties on the
       %targets
       function obj = RemoveCategory(category)
          obj.Targets = category;
          obj.Category = category; 
          obj.Collection = category.Collection; 
       end
       
       function result = Execute(obj, Targets)
           obj.Collection.RemoveCategory(obj.Category);
           result = true;
       end
       
       function Undo(obj)
           obj.Collection.AddCategoryObj(obj.Targets); 
           unassigned = obj.Collection.UnassignedCategory;
           
           %Remove members from the unassigned category
           [c, iCat, iUnassigned] = intersect(obj.Category.Members, unassigned.Members);
           unassigned.Members(iUnassigned) = []; 
       end
       
       function Redo(obj)
           for(i = 1:length(obj.Targets))
              target = obj.Targets(i);
              eval(['target.' obj.PropertyName ' = obj.NewValue;']);
           end
       end
       
       %This action is not designed to be put on a menu
       function menuitem = GetMenuItem(obj, Targets)
           menuitem = []; 
       end
   end
end 
