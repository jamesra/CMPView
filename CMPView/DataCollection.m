classdef DataCollection < handle
%DATACOLLECTION - Holds datapoints that need to be clustered
%Datapoints can be pixel data, pixel data abstracted in objects, any numeric
%data that fits in an 2D matrix.

   properties
      Attributes = [];  %mxn matrix where rows are items to cluster and 
                        %columns are the different attributes of items
                        
      AttributeNames = {}; %Friendly names of the columns
       
      Categories = []; %Single dimensional list of numbers corresponding
                              %to category assignment for each row in
                              %Attributes
                              
      AttributesEnabled = []; %Single dimensional list of bools indicating which
                             %attributes will be included when clustering
      
      CategoryObjects = [];  %Category objects, the first object in this list is the static 'unassigned' category
                             %The 'Unassigned' category contains indicies
                             %that correspond to rows not in any category
   end
   
   properties (SetObservable = true)
      Name = 'Data Collection'; %String describing the collection
   end
   
   properties (SetAccess = protected)
      NextName = 0;    %The next name to use for an added class
   end

   %Properties I don't save.  When a collection is loaded from disk it has
   %to be added to the controller to be useful.  The controller then calls
   %the set.Controller method which initializes the collection
   properties (Transient = true)
       
       Controller = []; %Set by the controller, nobody else should adjust this
   end
   
   properties (Transient = true, SetAccess = protected)
       Initialized = false; %This is used to ensure the object has a valid Controller
                            %reference if it was loaded from disk.
                            %Tested when a collection is assigned to the
                            %object
       
       lhCategoryPropSetEvents = []; %Listeners to Category propset events
   end
   
   properties (Dependent = true)
       NumAttributes %Total number of attributes
       NumCategories %Total number of categories
       NumAddCategories %Number of categories available to add to
       NumDataPoints %The total number of data points in the collection
       UnassignedCategory % The category object containing unassigned objects
   end
   
   events (NotifyAccess = protected)
       AddedCategory
       RemovedCategory
       UpdatedImage %Fired when changes require refreshing the collection image
   end
   
   methods (Static = true)
       
       %loadobj expects children to instantiate thier class before this
       %code runs
       function obj = loadobj(obj)
%          obj.Attributes = saved.Attributes; 
%          obj.Name = saved.Name; 
%          obj.AttributeNames = saved.AttributeNames;
%          obj.Categories = saved.Categories; 
%          obj.CategoryObjects = saved.CategoryObjects; 
%          obj.NextName = saved.NextName; 

           %Create category objects for each category
            %Resubscribe to category events
           
           %Matlab2008a cannot save member objects.  In this case recreate
           %the category objects
           if(isempty(obj.CategoryObjects))
               cats = unique([obj.Categories; 1]); %Add one to the array in case there are no unassigned objects
               cats = sort(cats);
               for(iCat = 1:length(cats))
                   obj.AddCategory();
                   newCat = obj.CategoryObjects(end); 

                   %FIX: Remove after Matlab lets me save CategoryObjects
                   if(iCat == 1)
                      newCat.Name = 'Unassigned';
                      obj.NextName = 1;
                      newCat.UnassignedOnly = true;
                      newCat.Color = [.25 .25 .25];
                   end

                   newCat.Members = find(obj.Categories == cats(iCat));
               end
           else
              %Recreate listeners for events
              for(iCat = 1:length(obj.CategoryObjects))
                    if(isempty(obj.lhCategoryPropSetEvents))
                        obj.lhCategoryPropSetEvents = addlistener(obj.CategoryObjects(iCat), {'Color', 'Locked'}, 'PostSet', @(src,event)CategoryPropSet(obj,src,event));
                    else
                        obj.lhCategoryPropSetEvents(end + 1) = addlistener(obj.CategoryObjects(iCat), {'Color', 'Locked'}, 'PostSet', @(src,event)CategoryPropSet(obj,src,event));
                    end
              end
           end
       end
   end
   
   methods
              
       %Constructor expects either 2-D matrix or reshapes 3-D image data to
       %2-D matrix
       %Data - The data that will be used for clustering
       %Names - Cell array describing columns of data
       function obj = DataCollection(Controller, Data, Names)
           if nargin > 0
               %Classes created through the constructor do not need to be
               %initialized later, only objects loaded from disk. 
               obj.Initialized = true; 
               
               obj.Controller = Controller; 
               obj.AttributeNames = Names;
               [d1,d2,d3] = size(Data);
               if(d3 > 1)
                   obj.Attributes = reshape(Data, d1*d2, d3);
               else
                   obj.Attributes = Data;
               end

               %Assign all data to the same category
               [numDatum, numAttributes] = size(obj.Attributes);
               obj.AttributesEnabled = true(1, numAttributes); 
               obj.Categories = uint16(ones(numDatum,1));
               
               %Create unassigned object category
               obj.AddCategory();
               UnassignedCat = obj.CategoryObjects(end);
               UnassignedCat.UnassignedOnly = true;
               UnassignedCat.Color = [.5 .5 .5];
               UnassignedCat.Members = find(obj.Categories == 1);
           end
       end
       
       function delete(obj)
          delete(obj.lhCategoryPropSetEvents);
          obj.lhCategoryPropSetEvents = []; 
          delete(obj.CategoryObjects); 
          obj.CategoryObjects = []; 
       end
             
       function OrphanCat = Orphans(obj)
          OrphanCat = obj.CategoryObjects(1); 
       end
              
       %Creates a new category object and adds it to collection
       function obj = AddCategory(obj)
           %Create an empty category
           if(obj.NextName == 0)
                newCat = Category('Unassigned', obj, []);
                newCat.UnassignedOnly = true; 
           else
                newCat = Category(num2str(obj.NextName), obj, []);
           end
           obj.NextName = obj.NextName + 1;

           %cmap = CreateUniqueColormap(obj.NumCategories + 1);          
           %newCat.Color = cmap(obj.NumCategories + 1, :); 
           
           hsvColor = [rand(1) 1 ((rand(1) / 2) + 0.5)];
           rgbColor = hsv2rgb(hsvColor);
           newCat.Color = rgbColor;
           
           if(isempty(obj.CategoryObjects))
               obj.CategoryObjects = newCat;
               obj.lhCategoryPropSetEvents = addlistener(newCat, {'Color', 'Locked'}, 'PostSet', @(src,event)CategoryPropSet(obj,src,event));
           else
               obj.CategoryObjects(end + 1) = newCat;
               obj.lhCategoryPropSetEvents(end + 1) = addlistener(newCat, {'Color', 'Locked'}, 'PostSet', @(src,event)CategoryPropSet(obj,src,event));
           end
           
           notify(obj, 'AddedCategory', ObjectEventData(newCat));
       end
       
       function obj = RemoveCategory(obj, CatObj)
           CatInd = find(obj.CategoryObjects == CatObj);
           if(~isempty(CatInd))
               oldCat = obj.CategoryObjects(CatInd);
               lh = obj.lhCategoryPropSetEvents(CatInd);
               obj.CategoryObjects(CatInd) = []; 
               obj.lhCategoryPropSetEvents(CatInd) = [];
               
               delete(lh); 
               
               if(~isempty(CatObj.Members))
                   oldInd = obj.Categories(CatObj.Members(1)); 
                   obj.Categories(CatObj.Members) = 1; %one is the category index of orphan rows
                   obj.Orphans.Members = cat(1, obj.Orphans.Members, CatObj.Members);
                   %We need to move all category indicies greater than the
                   %value we just deleted down by one.  Otherwise the mapping
                   %from Categories to CategoryObjects is no longer correct.

                   DecrementInd = find(obj.Categories > oldInd); 
                   obj.Categories(DecrementInd) = obj.Categories(DecrementInd) - 1; 
               end

               notify(obj, 'RemovedCategory', ObjectEventData(oldCat));
               
               assert(obj.Initialized == true, 'DataCollection.Initialized == false');
               if(obj.IsImageMappingCategories(obj.Controller.iCurrentView))
                    notify(obj, 'UpdatedImage'); 
               end
           end
       end   
       
       %Enable or disable the use of an attribute
       function obj = SetAttributeEnabled(obj, attributeName, newState)
           i = strcmp(obj.AttributeNames, attributeName); 
           obj.AttributesEnabled(i) = newState; 
       end
       
       %Reveal which attributes are enabled
       function isEnabled = GetAttributeEnabled(obj, attributeName)
           i = strcmp(obj.AttributeNames, attributeName); 
           isEnabled = obj.AttributesEnabled(i);
           return
       end
   
       %Tell listeners to update the image if it is dependent upon category
       %properties
       function obj = CategoryPropSet(obj, src,event)
           if(obj.Initialized)
               if(obj.IsImageMappingCategories(obj.Controller.iCurrentView))
                  notify(obj, 'UpdatedImage'); 
               end
           end
       end
       
%       function obj = set.Categories(obj, Value)
%           obj.Categories = Value;  
%       end

       %Add unassigned objects to the specified Category
       function obj = AddUnassigned(obj, Category)
            NewIndex = find(obj.CategoryObjects == Category);
            ChangingMembers = obj.UnassignedCategory.Members;
            Category.Members = cat(1, Category.Members, obj.UnassignedCategory.Members);
            obj.UnassignedCategory.Members = [];
            
            obj.Categories(ChangingMembers) = NewIndex;
            
            iChanged = find(obj.CategoryObjects == Category);
            obj.UpdateLabelMap([1 iChanged]);
            
            assert(obj.Initialized == true, 'DataCollection.Initialized == false');
            if(obj.IsImageMappingCategories(obj.Controller.iCurrentView))
               notify(obj, 'UpdatedImage'); 
            end
            
       end
       
       %Calls the filter passing all unlocked classes as an index image to
       %the filter.  Filter returns a new assignment for each pixel, but
       %locked pixels are ignored
       function obj = Filter(obj, FilterObj)
        
           CategoryIndexImage = obj.CategoryIndexImage();
           
           %Remove locked pixels from the label image
%            iRows = []; 
%            for(iCat = 1:length(obj.CategoryObjects))
%                if ~(obj.CategoryObjects(iCat).CanRemoveMembers || obj.CategoryObjects(iCat).CanAddMembers)
%                    iRows = cat(1, iRows, obj.CategoryObjects(iCat).Members);
%                end
%            end
           
           %CategoryIndexImage(iRows) = 1;
           
           NewCategories = FilterObj.Filter(obj, CategoryIndexImage);
           
           if(isempty(NewCategories))
               return; 
           end
           
           iChangedCategories = obj.Categories ~= NewCategories;
           
           ChangedCategories = []; 
                      
           if(~isempty(iChangedCategories))
               %Remove unchangeable indicies from the results
               %ChangeSet = 1:length(NewCategories);
               %ChangeSet(iRows) = [];
               
               OldChanged = unique(obj.Categories(iChangedCategories));
               NewChanged = unique(NewCategories(iChangedCategories));
               ChangedCategories = unique([OldChanged; NewChanged]);
               
               obj.Categories = NewCategories;

               obj.UpdateCategoryObjects(ChangedCategories);
           end
           
           %Update the regions for each category if needed
           obj.UpdateLabelMap(ChangedCategories);
       end
       
       %Calls the categorizer and reassigns categories for each row of attributes.
       %If a category is categorized it is expected that every member of
       %the category will be reassigned. 
       function obj = Categorize(obj, Categorizer)
           iRows = []; %Rows to be clustered
           CategoryMapping = []; %Mapping of Category Indicies returned by Categorizer
                                 %to DataCollection categories
                                 
           %Assemble the list of rows to pass to the Categorizer
           for(iCat = 1:length(obj.CategoryObjects))
               if(obj.CategoryObjects(iCat).CanRemoveMembers)
                   iRows = cat(1, iRows, obj.CategoryObjects(iCat).Members);
                   
                   %The unassigned category can remove but not add members,
                   %so check before adding category to the list of
                   %accepting categories
                   if(obj.CategoryObjects(iCat).CanAddMembers)
                       CategoryMapping = cat(1,CategoryMapping,iCat);                    
                   end
               end
           end
                    
           %Just making things pretty
           iRows = sort(iRows); 

           %Pass the active rows to the categorizer
           iAttributesToInclude = find(obj.AttributesEnabled); 
           
           inputData = obj.Attributes(iRows, iAttributesToInclude);
           
           NewCategories = Categorizer.Categorize(obj, inputData);
        
           %Count the number of categories we can add to
           nUnlockedCats = length(CategoryMapping);
          
           %Figure out how many categories we ended up with after
           %Categorization.  Some categorizers create new categories
           numNewCategories = length(unique(NewCategories));
           
           %If we need more category objects then create them and add them
           %to the category mapping
           if(numNewCategories > nUnlockedCats)
               nNewCats = numNewCategories - nUnlockedCats; 
               for(iCat = 1:nNewCats)
                   obj.AddCategory(); 
                   CategoryMapping = cat(1, CategoryMapping,  obj.NumCategories);
               end
           end
           
            DataCategories = CategoryMapping(NewCategories);
           
           %Update the categories that objects are assigned to
           obj.Categories(iRows) = DataCategories;
           
           %We shouldn't have any orphans if we just categorized
           obj.Orphans.Members = []; 
           
           %%%%%%%Update the CategoryObjects%%%%%%%
           for(i = 1:length(CategoryMapping))
              iCat = CategoryMapping(i);
              obj.CategoryObjects(iCat).Members = find(obj.Categories == iCat);
           end
           
           assert(obj.Initialized == true, 'DataCollection.Initialized == false');
           if(obj.IsImageMappingCategories(obj.Controller.iCurrentView))
             notify(obj, 'UpdatedImage'); 
           end
           
           %Update the regions for each category if needed
           obj.UpdateLabelMap(unique(DataCategories));
           obj.Orphans.Regions = []; 
           
       end
       
       function obj = UpdateCategoryObjects(obj,varargin)                        
           
            optargin = size(varargin,2);

            %Parse the optional arguments
            if(optargin > 1)
                disp(['Too many arguments to UpdateLabelMap']); 
            end

            if(optargin > 0)
                ChangedCategories = varargin{1};
            else
                ChangedCategories = [1:obj.NumCategories]; 
                
                if(obj.NumCategories == 1)
                   obj.Categories{1}.Regions = [];  
                end
            end
           
            %%%%%%%Update the CategoryObjects%%%%%%%
           
           for(iCategoryNumber = ChangedCategories')
              obj.CategoryObjects(iCategoryNumber).Members = find(obj.Categories == iCategoryNumber);
           end
           
           if(obj.IsImageMappingCategories(obj.Controller.iCurrentView))
             notify(obj, 'UpdatedImage');
           end
       end
              
       %%%%%%%%%%%%PROPERTY ACCESSORS%%%%%%%%%%%%%%%%
       function val = get.NumAttributes(obj)
          val = size(obj.Attributes, 2);  
       end
       
       function val = get.UnassignedCategory(obj)
          val = obj.CategoryObjects(1); %The unassigned category is always the first item in the list 
       end
       
       %Returns the number of categories currently available in the
       %collection
       function nCat = get.NumCategories(obj)
           %Two approaches, the second should be faster as long as the two
           %return the same result
%           nCat = unique(AttributeCategories);
            nCat = length(obj.CategoryObjects);
       end
       
       function nCat = get.NumAddCategories(obj)
           nCat = 0; 
           for(iCat = 1:length(obj.CategoryObjects))
               if(obj.CategoryObjects(iCat).CanAddMembers)
                   nCat = nCat+1; 
               end
           end
       end
       
       function val = get.NumDataPoints(obj) %The total number of data points in the collection
           val = length(obj.Categories);
       end
       
       %When a collection is loaded from disk it has
       %to be added to the controller to be useful.  The controller then calls
       %the set.Controller method which initializes the collection
       function obj = set.Controller(obj, val)
           obj.Controller = val;  %Assign the new controller; 
           
           obj.Initialized = true; 
       end
       
       function obj = MenuRemove(obj, src, event)
            obj.Controller.RemoveCollection(obj); 
       end

       function obj = MenuRename(obj, src, event)
            name = inputdlg({'Enter new name for collection:'}, 'Rename', 1, {obj.Name}); 
            obj.Name = name{1}; 
       end
   end

       %Create a context menu, or append a passed context menu
  methods (Sealed = true)
       function cmenu = GetContextMenu(obj, cmenu)

           if(nargin < 2)
               cmenu = uicontextmenu();
           end

           %The Unassigned category is special and should not deleted
           uimenu(cmenu, 'Label', 'Rename', ...
                'Callback', @(src,event)MenuRename(obj, src,event));

           uimenu(cmenu, 'Label', 'Remove', ...
                'Callback', @(src,event)MenuRemove(obj,src,event));
       end
   end
   
   methods (Abstract = true)
       %Each collection provides a list of views.
       Strings = ImageStrings(obj); %Description of images returned by Image
       bool = IsImageMappingCategories(obj, idx); %Returns true if the image matching
                                                  %the index changes with a
                                                  %new categorization
       img = Image(obj, idx); %returns an image at index
       img = CategoryIndexImage(obj); %returns a label image where each pixel is assigned
                              %a number according to class membership
       img = UpdateLabelMap(obj, varargin); 
   end
   
   events
        Change
   end
end 
