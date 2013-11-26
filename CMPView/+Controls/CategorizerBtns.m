classdef CategorizerBtns < Controls.Control
%LISTCATEGORIZERS Summary of this class goes here
%   Detailed explanation goes here

   properties
       Buttons = [];
   end

   methods
       function obj = CategorizerBtns(Parent, Controller, Position)
          obj = obj@Controls.Control(Parent, Controller, Position);
          
          %We want to create a button for every categorizer we can find
          Categorizers = Controller.Categorizers; 
          nCats = length(Categorizers); 
          
          %Figure out how far apart the buttons are on the y axis
          spacing = 1 / nCats; 
          
          for(iCat = 1:nCats)
             btnPos = [ 0 0 1 1];
             btnPos(2) = btnPos(2) + (spacing * (iCat - 1));
             btnPos(4) = spacing;
              
             obj.Buttons(iCat) = uicontrol(obj.Parent, 'Style', 'pushbutton', ...
                                       'Units', 'Normalized', ...
                                       'Position', btnPos, ...
                                       'String', Categorizers{iCat}.Name, ...
                                       'Callback', @(src,event)BtnCallback(obj, src,event), ...
                                       'UserData', Categorizers{iCat});
          end
       end
       
       function obj = BtnCallback(obj, src, event)
          %figure out which categorizer was selected
          Categorizer = get(src, 'UserData');
          obj.Controller.Categorize(Categorizer);
       end
   end
end 
