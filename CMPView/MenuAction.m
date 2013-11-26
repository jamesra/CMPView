classdef MenuAction < Action
%MenuAction - Menu actions have the undo-redo ability of actions and live
%in the same queue.  They also extend the context menus of any objects the
%action can work against.  It allows the UI to be extended in a modular
%way without changing core code. 
   
   properties (Abstract = true)
       Name
   end

   methods (Abstract = true)
       obj = Undo(obj);
       obj = Redo(obj);
       obj = Execute(obj, Targets);
       menuitem = GetMenuItem(obj, Targets);
   end
   
   methods (Static = true)
       bool = CanAct(targets); %Returns true if the action can affect the target 
   end
       
end 
