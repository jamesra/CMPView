classdef ListViews < Controls.Control
%LISTCATEGORIES Summary of this class goes here
%   Detailed explanation goes here

   properties
       hListViews = []; 
       
       lhCollectionsChanged = []; 
       lhCurrentCollectionChanged = []; 
       lhCurrentViewChanged = []; 
   end

   methods
       function obj = ListViews(Parent, Controller, Position)
            obj = obj@Controls.Control(Parent, Controller, Position);
            
            obj.hListViews = uicontrol('Style', 'listbox', ...
                                 'units', 'normalized', ...
                                 'parent', obj.Parent, ...
                                 'position', [0 0 1 1], ...
                                 'ButtonDownFcn', {@(src,event)listViews_ButtonDownFcn(obj,src,event)}, ... 
                                 'Callback', {@(src,event)listViews_Callback(obj,src,event)}, ...
                                 'value', 1); %Required for buttons to work on Mac

            cmenu = uicontextmenu();
            uimenu(cmenu, 'Label', 'Red', 'Callback', {@(src,event, iColor)listViews_ColorCallback(obj,src,event, 1)});
            uimenu(cmenu, 'Label', 'Green', 'Callback', {@(src,event, iColor )listViews_ColorCallback(obj,src,event, 2)});
            uimenu(cmenu, 'Label', 'Blue', 'Callback', {@(src,event, iColor)listViews_ColorCallback(obj,src,event, 3)});

            set(obj.hListViews, 'UIContextMenu', cmenu);

            obj.lhCollectionsChanged = addlistener(obj.Controller, 'CollectionsChanged', @(src,event)CollectionsChanged(obj,src,event));
            obj.lhCurrentCollectionChanged = addlistener(obj.Controller, 'CurrentCollectionChanged', @(src,event)CurrentCollectionChanged(obj,src,event));
            obj.lhCurrentViewChanged = addlistener(obj.Controller, 'CurrentViewChanged', @(src,event)CurrentViewChanged(obj,src,event));
       end
       
       function delete(obj)
           delete(obj.lhCollectionsChanged); 
           delete(obj.lhCurrentCollectionChanged); 
           delete(obj.lhCurrentViewChanged); 
       end
       
       %%%%%%%%%%%%%EVENTS%%%%%%%%%%%%%%%
       %When the collections change clear the listbox and wait for
       %CurrentCollectionCHanged to repopulate
       function obj = CollectionsChanged(obj,controller,event)
           set(obj.hListViews, 'String', []); 
           set(obj.hListViews, 'value', 1);
       end
       
       %When the selected collection changes
       function obj = CurrentCollectionChanged(obj,controller,event)
            obj.UpdateViews();
       end
       
        %When the category changes update the listbox
       function obj = CurrentViewChanged(obj,controller,event)
            set(obj.hListViews, 'value', obj.Controller.iCurrentView); 
       end
       
       %%%%%%%%%%%%%CALLBACKS%%%%%%%%%%%%%%%%%%%%%
        function obj = listViews_Callback(obj, src, event)
           value = get(obj.hListViews,'value');
           if(~isempty(value))
               obj.Controller.iCurrentView = value; 
           end
       end
       
       function obj = listViews_ButtonDownFcn(obj, src, event)
           
           
           
           
       end
       
       function obj = listViews_ColorCallback(obj, src, event, iColor)
           iCollection = obj.Controller.iCurrentCollection;
           
           iAttribute = get(obj.hListViews, 'value') - 3; 
           
           obj.Controller.Collections(iCollection).RGBAttributes(iColor) = iAttribute; 
           
           obj = UpdateViews(obj)
       end
       
       %%%%%%%%%%%%%FUNCTIONS%%%%%%%%%%%%%
       function obj = UpdateViews(obj)
           
           if(isempty(obj.Controller.Collections))
               return;
           end
           
            %Populate the list of views on the collection            
            %Figure out the current collection
            iCollection = obj.Controller.iCurrentCollection;
            
            ImageStrings = obj.Controller.Collections(iCollection).ImageStrings;
            
            iView = get(obj.hListViews,'value');
            if(isempty(iView) || iView > length(ImageStrings))
                iView = length(ImageStrings); 
            end
            
            set(obj.hListViews, 'String', ImageStrings); 
            set(obj.hListViews, 'value', iView); 
       end
       
       
   end
end 
