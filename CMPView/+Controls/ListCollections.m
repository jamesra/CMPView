classdef ListCollections < Controls.Control
%LISTCATEGORIES Summary of this class goes here
%   Detailed explanation goes here

   properties
       hListCollections = []; 
       
       lhCollectionsChanged = [];
       lhCurrentCollectionChanged = [];
       
       lhCollectionsPropSet = []; 
   end

   methods
       function obj = ListCollections(Parent, Controller, Position)
            obj = obj@Controls.Control(Parent, Controller, Position);
            
            obj.hListCollections = uicontrol('Style', 'listbox', ...
                                 'units', 'normalized', ...
                                 'parent', obj.Parent, ...
                                 'position', [0 0 1 1], ...
                                 'ButtonDownFcn', {@(src,event)listCollections_ButtonDownFcn(obj,src,event)}, ... 
                                 'Callback', {@(src,event)listCollections_Callback(obj,src,event)}, ...
                                 'value', 1); %Required for buttons to work on Mac);

            obj.lhCollectionsChanged = addlistener(obj.Controller, 'CollectionsChanged', @(src,event)CollectionsChanged(obj,src,event));
            obj.lhCurrentCollectionChanged = addlistener(obj.Controller, 'CurrentCollectionChanged', @(src,event)CurrentCollectionChanged(obj,src,event));
       end
       
       function delete(obj)
           delete(obj.lhCollectionsChanged);
           delete(obj.lhCurrentCollectionChanged);
       end
       
       function obj = UpdateListeners(obj)
           
          delete(obj.lhCollectionsPropSet);
          obj.lhCollectionsPropSet = [];   

          if(~isempty(obj.Controller.Collections))
              obj.lhCollectionsPropSet = addlistener(obj.Controller.Collections, {'Name'}, 'PostSet', @(src,event)CollectionPropSet(obj,src,event));
          end
       end
       
       %%%%%%%%%%%%%EVENTS%%%%%%%%%%%%%%%
       %When the collections change clear the listbox and repopulate
       function obj = CollectionsChanged(obj,controller,event)
            obj.Update();
            obj.UpdateListeners();
       end
       
       %When the selected collection changes
       function obj = CurrentCollectionChanged(obj,controller,event)
            set(obj.hListCollections, 'value', obj.Controller.iCurrentCollection);
       end
       
       %Just reload the list if a name changes
       function obj = CollectionPropSet(obj,src,event)
           switch src.Name
               case 'Name'
                   obj.Update();
           end
       end
       
       %%%%%%%%%%%%%CALLBACKS%%%%%%%%%%%%%%%%%%%%%
       function obj = listCollections_Callback(obj, src, event)
           %Ensure the hListCollection box value property is correct
           value = get(obj.hListCollections,'value');
           if(~isempty(value))
              obj.Controller.iCurrentCollection = value;   
           end
       end
       
       function obj = listCollections_ButtonDownFcn(obj, src, event)
            index = ListIndexFromPoint(obj.hListCollections);

            %Create context menu  for classes list box
            cmenu = uicontextmenu;

            if(~isnan(index))
                cmenu = obj.Controller.GetContextMenu(obj.Controller.Collections(index)); 
                cmenu = obj.Controller.Collections(index).GetContextMenu();
            else
%                uimenu(cmenu, 'Label', 'Add Collection', 'Callback', @(src,event)MenuAddCategory(obj,src,event));
            end

            set(obj.hListCollections, 'UIContextMenu', cmenu);
       end
       
       %%%%%%%%%%%%%%FUNCTIONS%%%%%%%%%%%%%%%%%%%%
       function obj = Update(obj)
            %Construct a string with each collections name
            listCollections = {}; 
            
            for(i = 1:length(obj.Controller.Collections))
                listCollections{i} = obj.Controller.Collections(i).Name;
            end
            
            set(obj.hListCollections,'String', listCollections);
            
            %Ensure the hListCollection box value property is correct
            value = get(obj.hListCollections,'value');
            if(isempty(value) || value > length(obj.Controller.Collections) || value < 1)
                value = length(obj.Controller.Collections); 
            end
            set(obj.hListCollections, 'value', value);
       end
       
   end
end 
