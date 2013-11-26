classdef Action < handle
%ACTION - Executes user commands while saving undo-redo information.
%Requires object to manually log changes into the action.
%Implement a version of this class if you want to use undo-redo
   
   properties (Abstract = true)
       Name
   end

   properties
       Targets = []; %Objects the action was performed upon.
   end

   methods (Abstract = true)
       obj = Undo(obj);
       obj = Redo(obj);
       result = Execute(obj, Targets);
   end
       
end 
