classdef Controller < handle
%CONTROLLER Summary of this class goes here
%   Detailed explanation goes here

   properties 
       Collections = []; 
       ImageFilters = []; 
       ParentFigure = [];
       ProbeNames = []; 
       
       Actions = {}; %Names of the actions classes
       
       ActionList = []; %Queue of all logged actions
       iLastAction = 0; %Which action was the last one performed.  If you do a bunch of undo's then 
       
       Categorizers = []; %Available categorizers
       
       DataPath = [];  %Path where the data is stored, default save/load directory
       
       %Active items
       iCurrentCollection = 0;  %Needs to be zero to fire CurrentCollectionChanged event when first collection is added
       iCurrentView = 1; 
       iCurrentCategory = 1;
       

   end
   
   properties ( Dependent = true)
       CurrentCollection; %Returns the object instead of an index
       
       
   end
   
   events (NotifyAccess = protected)
       CollectionsChanged
       
       CurrentCollectionChanged
       CurrentViewChanged
       CurrentCategoryChanged
   end

   methods
       function obj = Controller(ParentFigure)
           obj.ParentFigure = ParentFigure;
       end
       
%       %%%%%%%%%%%%%%%Property Access methods%%%%%%%%%%%
        function obj = set.iCurrentCollection(obj, value)
            if(obj.iCurrentCollection ~= value)
                obj.iCurrentCollection = value; 
                notify(obj, 'CurrentCollectionChanged');
            end
        end
        
        function obj = set.iCurrentView(obj,value)
            if(obj.iCurrentView ~= value)
                obj.iCurrentView = value;
                notify(obj, 'CurrentViewChanged');
            end
        end
        
        function obj = set.iCurrentCategory(obj, value)
            if(obj.iCurrentCategory ~= value)
                obj.iCurrentCategory = value; 
                notify(obj, 'CurrentCategoryChanged');
            end
        end
        
        %Helper function to return object instead of index
        function value = get.CurrentCollection(obj)
            if(obj.iCurrentCollection > length(obj.Collections) || obj.iCurrentCollection <= 0)
                value = []; 
            else
                value = obj.Collections(obj.iCurrentCollection); 
            end
        end
        
        %%%%%%%%%%%%%%%Progress Reporting%%%%%%%%%%%%%%%%
        
%        function obj = ReportProgress(
        
      
        %%%%%%%%%%%%%%%Functions%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %Add collection is called whenever a collection is added and give
        %it the selection
        %This can occur when we load a series of images, load a saved
        %collection from disk, or create a new collection from an old one
        function obj = AddCollection(obj, value)    
            if(isempty(obj.Collections))
                obj.Collections = value;
            else
                obj.Collections(end + 1) = value;
            end
            
            value.Controller = obj;
            
            notify(obj, 'CollectionsChanged');
            
            obj.iCurrentCollection = length(obj.Collections); 
        end
        
        %TODO: This is going to be unstable since it is not tested.
        function obj = RemoveCollection(obj, value)
            ind = find(obj.Collections == value);
            obj.Collections(ind) = []; 
            delete(value); 
            
            notify(obj, 'CollectionsChanged');
            
            %Decrement the current selection if it would have changed from
            %the deletion
            if(obj.iCurrentCollection >= ind)
                obj.iCurrentCollection = obj.iCurrentCollection - 1; 
            end
        end     
        
        %Categorize the current collection using the provided Categorizer
        function obj = Categorize(obj, Categorizer)
            Collection = obj.Collections(obj.iCurrentCollection);
            Collection.Categorize(Categorizer);
        end
        
        %Categorize the current collection using the provided Categorizer
        function obj = Filter(obj, ImageFilter)
            Collection = obj.Collections(obj.iCurrentCollection);
            Collection.Filter(ImageFilter);
        end
        
        %Load the context menu for the target object
        function cmenu = GetContextMenu(obj, Targets, cmenu)
            
            if(nargin < 3 || isempty(cmenu))
                cmenu = uicontextmenu;
            end
  
            for(i = 1:length(obj.Actions))
                
                ActionName = obj.Actions{i};
                canAct = eval([ActionName '.CanAct(Targets)']);
                
                if(canAct)
                   action = eval([ActionName '()']);  %Create the action
                   menuitem = action.GetMenuItem(Targets); 
                   if(isempty(menuitem))
                       continue; 
                   end
                   
                   set(menuitem, 'Parent', cmenu);
                   set(menuitem, 'UserData', {action, Targets}); 
                   set(menuitem, 'Callback', @(src, event)MenuCallback(obj, src, event));
                end
            end
        end
        
        function obj = Do(obj, action, targets)
           result = action.Execute(targets);
           if(~result)
               return;
           end
           
           %Add action to undo queue
           obj.iLastAction = obj.iLastAction + 1; 
           obj.ActionList(obj.iLastAction:end) = []; %Remove any items past this action from queue
           
           if(isempty(obj.ActionList))
               obj.ActionList = action;
           else
               obj.ActionList(obj.iLastAction) = action;
           end
           
           %Limit the undo list at 20 items. 
           if(length(obj.ActionList) > 20)
               obj.ActionList = obj.ActionList(2:end); 
               obj.iLastAction = obj.iLastAction - 1; 
           end
        end
        
        function obj = Undo(obj)
           
           if(obj.iLastAction > 0)
               action = obj.ActionList(obj.iLastAction);
               action.Undo(); 
           
               obj.iLastAction = obj.iLastAction - 1 ;
           end
        end
        
        function obj = Redo(obj, action, targets)
           if(length(obj.ActionList) > obj.iLastAction)
               action = obj.ActionList(obj.iLastAction+1);
               action.Redo(); 
           
               obj.iLastAction = obj.iLastAction + 1;
           end
        end
        
        function MenuCallback(obj, src, event)
           tag = get(src, 'UserData');
           action = tag{1}; 
           targets = tag{2};
           obj.Do(action, targets);
        end
   end
   

end
