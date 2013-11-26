classdef Viewer < handle
%VIEWER Summary of this class goes here
%   Detailed explanation goes here

   properties
       ParentFigure = [];
       Figure = []; 
       Controller = [];
   end
   
   properties (Dependent = true)
       Visible 
       Name; 
   end

   methods
       function obj = Viewer(Controller)
           
           obj.Controller = Controller;
           obj.ParentFigure = Controller.ParentFigure; 
           
           obj.Figure = figure('NumberTitle', 'off', ...
             'Toolbar', 'none',  ...
             'CloseRequestFcn', @(src,event)ViewerCloseFcn(obj,src,event), ...
             'MenuBar', 'none', ...
             'units', 'normalized');
       end
       
       function delete(obj)
          disp(strcat('Deleting  ', obj.Name));
          delete(obj.Figure);          
       end
         
       function ViewerCloseFcn(obj,src,event)
           obj.Visible = false;
       end
       
       function val = get.Visible(obj)
           val = false; 
           valStr = get(obj.Figure, 'Visible');  
           if(strcmpi(valStr, 'on'))
               val = true;
           end
       end
       
       function obj = set.Visible(obj, val)
           if(val)
               set(obj.Figure, 'Visible', 'on');
           else
               set(obj.Figure, 'Visible', 'off');
           end
       end
       
       function val = get.Name(obj)
           val = get(obj.Figure, 'Name');
       end
       
       function obj = set.Name(obj, val)
           set(obj.Figure, 'Name', val);
       end
   end
end 
