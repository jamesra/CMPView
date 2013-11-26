classdef Control < handle
%CONTROL Generic parent class of controls
%   

   properties
       Controller = [];
       Parent = []; %The panel we create that all child controls live within
   end
   
   properties (Dependent = true)
        Position;
        Visible;
   end

   methods
       function obj = Control(Parent, Controller, Position)
           obj.Parent = uipanel('Parent', Parent, ...
                                'Units', 'Normalized', ...
                                'Position', Position, ...
                                'BorderType', 'none', ...
                                'BorderWidth', 0);
                                
           obj.Controller = Controller; 
       end
       
       function delete(obj)
           %obj.Parent is already deleted by Matlab it appears, however,
           %when we delete a CategoryHistogramControl we need to delete the
           %parent or it remains on the view obscuring the histograms we
           %care about
           disp( ['Deleting: ' num2str(obj.Parent)]);
           try
            delete(obj.Parent);  
            obj.Parent = []; 
           catch e
               disp(['Error deleting parent window for control: ' num2str(obj.Parent)]);
           end
       end
         
       
       function val = get.Position(obj)
           val = get(obj.Parent, 'Position'); 
       end
       
       function obj = set.Position(obj, val)
          set(obj.Parent, 'Position', val);  
       end
       
       function val = get.Visible(obj)
          valStr = get(obj.Parent, 'Visible');
          val = true;
          if(strcmpi(valStr,'off'))
              val = false; 
          end
       end
       
       function obj = set.Visible(obj,val)
          valStr = 'off'; 
          if(val)
              valStr = 'on';
          end
          set(obj.Parent, 'Visible', valStr);
       end
   end
end 
