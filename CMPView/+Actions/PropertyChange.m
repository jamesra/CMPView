classdef PropertyChange < Action
%PROPERTYCHANGE Summary of this class goes here
%   Detailed explanation goes here
properties
       Name = 'Property Change';

       PropertyName = [];
       
       OldValue = {};
       NewValue = [];
   end

   methods
       
       %Property change object to change the value of properties on the
       %targets
       function obj = PropertyChange(Property, value)
          obj.PropertyName = Property;
          obj.NewValue = value;
       end
       
       function result = Execute(obj, Targets)
           obj.Targets = Targets;
           for(i = 1:length(Targets))
              target = Targets(i);
              
              obj.OldValue{i} = eval(['target.' obj.PropertyName]);
              eval(['target.' obj.PropertyName ' = obj.NewValue;']);
           end
           
           result = true; 
       end
       
       function Undo(obj)
           
           for(i = 1:length(obj.Targets))
              target = obj.Targets(i);
              eval(['target.' obj.PropertyName ' = obj.OldValue{i};']);
           end
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
