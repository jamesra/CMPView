
classdef Rename < MenuAction
%RENAME - Renames any object with a 'Name' property

   properties
       Name = 'Rename';
       
       OldName = [];
       NewName = []; 
   end

   methods
       
       function result = Execute(obj, Targets)
           target = Targets;
          
           obj.Targets = Targets; 
           
           obj.OldName = target.Name; 
           name = inputdlg({'Enter new name:'}, 'Rename', 1, {obj.Name}); 
           obj.NewName = name{1}; 
           target.Name = obj.NewName;
           
           result = true; 
       end
       
       function Undo(obj)
           obj.Targets.Name = obj.OldName; 
       end
       
       function Redo(obj)
           obj.Targets.Name = obj.NewName; 
       end
       
       function menuitem = GetMenuItem(obj, Targets)
           menuitem = uimenu('Label', obj.Name);
       end
   end
   
   methods (Static = true)
       
       %An object can be renamed if it has a public name property
       function result = CanAct(Targets)
           result = false; 
           
           %Can't rename more than one object at once
           if(length(Targets) > 1)
               return; 
           end
           
           meta = findprop(Targets, 'Name');
           
           if(isempty(meta))
               return;
           end
           
           if(meta.Constant)
               return; 
           end
           
           %Categories have a special instance called 'unassigned' so the
           %rename code stays within that class.
           if(isa(Targets, 'Category'))
               return;
           end
           
           if(strcmpi(meta.GetAccess,'public'))
               result = true; 
               return;
           end
       end
   end
end 
