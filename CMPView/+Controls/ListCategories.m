classdef ListCategories < Controls.Control
%LISTCATEGORIES Summary of this class goes here
%   Detailed explanation goes here

   properties
       hListCategories = [];
       
       lhAddCategoryEvent = []; 
       lhRemoveCategoryEvent = []; 
       
       lhCollectionChanged = []; 
       lhCurrentCollectionChanged = []; 
       lhCurrentCategoryChanged = [];
       lhCategoriesPropSet = []; 
   end

   methods
       function obj = ListCategories(Parent, Controller, Position)
            obj = obj@Controls.Control(Parent, Controller, Position);
            
            obj.hListCategories = uicontrol('Style', 'listbox', ...
                                 'units', 'normalized', ...
                                 'parent', obj.Parent, ...
                                 'position', [0 0 1 1], ...
                                 'ButtonDownFcn', {@(src,event)listCategories_ButtonDownFcn(obj,src,event)}, ... 
                                 'Callback', {@(src,event)listCategories_Callback(obj,src,event)}, ...
                                 'KeyPressFcn', {@(src,event)listCategories_KeyPressFcn(obj,src,event)}, ... 
                                 'value', 1); 
                             
%            obj.lhCollectionChanged = addlistener(obj.Controller, 'CollectionsChanged', @(src,event)CollectionsChanged(obj,src,event));
            obj.lhCurrentCollectionChanged = addlistener(obj.Controller, 'CurrentCollectionChanged', @(src,event)CurrentCollectionChanged(obj,src,event));
            obj.lhCurrentCategoryChanged = addlistener(obj.Controller, 'CurrentCategoryChanged', @(src,event)CurrentCategoryChanged(obj,src,event));                      
       end
       
       function delete(obj)
           delete(obj.lhCollectionChanged); 
           delete(obj.lhCurrentCollectionChanged); 
           delete(obj.lhCurrentCategoryChanged); 
           delete(obj.lhAddCategoryEvent);
           delete(obj.lhRemoveCategoryEvent); 
       end
       
       function obj = UpdateListeners(obj)
           
          %Dispose of old event listeners and create new ones.  They need
          %to be set to null because this method can be called twice if the
          %user deletes the last collection and then creates a new one
          delete(obj.lhAddCategoryEvent);
          delete(obj.lhRemoveCategoryEvent); 
          delete(obj.lhCategoriesPropSet);
          obj.lhCategoriesPropSet = [];   
          obj.lhAddCategoryEvent = [];
          obj.lhRemoveCategoryEvent = []; 

          if(~isempty(obj.Controller.CurrentCollection))
              obj.lhCategoriesPropSet = addlistener(obj.Controller.CurrentCollection.CategoryObjects, {'Name', 'Locked'}, 'PostSet', @(src,event)CategoryPropSet(obj,src,event));

              %Create new event listeners
              obj.lhAddCategoryEvent = addlistener(obj.Controller.CurrentCollection, 'AddedCategory', @(src,event)AddRemoveCategory(obj,src,event));
              obj.lhRemoveCategoryEvent = addlistener(obj.Controller.CurrentCollection, 'RemovedCategory', @(src,event)AddRemoveCategory(obj,src,event));
      
          end
       end
       
       %%%%%%%%%%%%%EVENTS%%%%%%%%%%%%%%%
       %When the collections change clear the listbox and repopulate
%       function obj = CollectionsChanged(obj,controller,event)
%            obj.UpdateListeners(); 
%            obj.UpdateCategories();
%       end
       
       %When the selected collection changes
       function obj = CurrentCollectionChanged(obj,controller,event)
            obj.UpdateListeners(); 
            obj.UpdateCategories();           
       end
       
        %When the category changes update the listbox
       function obj = CurrentCategoryChanged(obj,controller,event)
            set(obj.hListCategories, 'value', obj.Controller.iCurrentCategory); 
       end
       
       function obj = AddRemoveCategory(obj, src, event)
            obj.UpdateListeners();
            obj.UpdateCategories(); 
       end
       
       %Update UI if Category properties change.  Must update addlistener
       %if adding new properties
       function obj = CategoryPropSet(obj, src, event)
           switch src.Name
               case 'Name'
                   obj.UpdateCategories();
               case 'Locked'
                   obj.UpdateCategories();
           end
       end
       
       %%%%%%%%%%%%%CALLBACKS%%%%%%%%%%%%%%%%%%%%%
        function obj = listCategories_Callback(obj, src, event)
           index = get(obj.hListCategories,'value');
  
           if(~isempty(index))
               obj.Controller.iCurrentCategory = index; 
           end
       end
       
       function obj = listCategories_ButtonDownFcn(obj, src, event)
%            index = get(obj.hListCategories,'Value');
            index = ListIndexFromPoint(obj.hListCategories);
           
            %Create context menu  for classes list box
            cmenu = uicontextmenu;

            if(~isnan(index))
                obj.Controller.iCurrentCategory = index; 
                cmenu = obj.Controller.CurrentCollection.CategoryObjects(index).GetContextMenu();
            else
                uimenu(cmenu, 'Label', 'Add Class', 'Callback', @(src,event)MenuAddCategory(obj,src,event));
            end

            set(obj.hListCategories, 'UIContextMenu', cmenu);
       end
       
       function obj = listCategories_KeyPressFcn(obj, src, event)
           index = get(obj.hListCategories,'value');
  
           if(~isempty(index))
               switch lower(event.Key)
                   case 'space'
                        obj.Controller.CurrentCollection.CategoryObjects(index).Locked = ~obj.Controller.CurrentCollection.CategoryObjects(index).Locked;
                   case 'return'
                        obj.Controller.CurrentCollection.CategoryObjects(index).ShowRenameUI();
                   case 'delete'
                       %Do not delete the unassigned category.
                       if(~obj.Controller.CurrentCollection.CategoryObjects(index).UnassignedOnly)
                            obj.Controller.CurrentCollection.RemoveCategory(obj.Controller.CurrentCollection.CategoryObjects(index)); 
                       end
                   case 'c'
                        obj.Controller.CurrentCollection.CategoryObjects(index).ShowColorUI();
                   case 'add'
                        obj.Controller.CurrentCollection.AddCategory();
                   case 'equal'
                        obj.Controller.CurrentCollection.AddCategory();
                   case 'u'
                        obj.Controller.CurrentCollection.AddUnassigned(obj.Controller.CurrentCollection.CategoryObjects(index)); 
               end
           end
       end
    
       function obj = MenuAddCategory(obj, src, event)
            obj.Controller.CurrentCollection.AddCategory();
       end
       
       %%%%%%%%%%%%%FUNCTIONS%%%%%%%%%%%%%
       function obj = UpdateCategories(obj)           
            
            %Populate the list of views on the collection   
            iCat = get(obj.hListCategories,'value');
            
            %Figure out the current collection.  If it is empty then clear
            %the list, otherwise repopulate with new collection.
            if(isempty(obj.Controller.CurrentCollection))
                set(obj.hListCategories, 'String', []);
            else
                CategoryStrings = {obj.Controller.CurrentCollection.CategoryObjects.FullName};
                set(obj.hListCategories, 'String', CategoryStrings);

                if(isempty(iCat) || iCat > length(CategoryStrings))
                    iCat = length(CategoryStrings); 
                end
            end
            
            set(obj.hListCategories, 'value', iCat); 
       end
   end
end 
