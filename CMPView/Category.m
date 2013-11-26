classdef Category < handle
%CATEGORY Summary of this class goes here
%   Detailed explanation goes here

   properties 
       Collection = [];
       UnassignedOnly = false;        

       Members = []; %Row indicies of collection members who belong.
                     %This isn't SetObservable because I wanted to
                     %selectively fire the event
                     
       Regions = []; %Within a category there may be distinct regions.  The easiest one to consider is 
                     %all of the adjacent pixels.  The definition is
                     %flexible.  If this array is empty all members are
                     %considered part of the same region.  If not empty it
                     %is a cell array where each cell contains an array of
                     %members
                     %Regions are stored from smallest area to largest.
                     %The set method takes care of this.
   end
   
   properties (SetObservable = true) %Other controls change display based on these properties
       Color = [.5 .5 .5]; %What color the category should be
       Locked = false;      
       Name = []; 
   end
     
   properties (Dependent = true)
      CanAddMembers
      CanRemoveMembers
      FullName %The name of the category including status information
      LockedColor %Color to use when category is locked
      StatusColor %Color that should be used considering the categories current state.
   end
      
   events (NotifyAccess = protected)
      MembersChanged %Membership in the category just changed 
      RegionsChanged %Region assignments for members just changed
   end

   methods
       function obj = Category(Name, DataCollection, Members)
           obj.Name = Name; 
           obj.Collection = DataCollection;
           obj.Members = Members; 
       end
              
       function val = get.FullName(obj)
           val = obj.Name;
           if(obj.Locked)
               val = strcat(val, ' [Locked]'); 
           end
       end
       
       %Color to use when category is locked or has another status
       function val = get.StatusColor(obj)
           if(obj.Locked)
               val = obj.LockedColor;
           else
               val = obj.Color; 
           end
       end
       
       %Color to use when category is locked
       function val = get.LockedColor(obj)
           hsv = rgb2hsv(obj.Color);
           hsv(3) = hsv(3) / 3;
           val = hsv2rgb(hsv); 
       end
       
       %Update the members. Send notification if they aren't equal
       function obj = set.Members(obj, value)
          shouldNotify = false; %Never name this notify

          if(length(obj.Members) ~= (value))
              shouldNotify = true; 
          elseif(~isequal(obj.Members,value))
              shouldNotify = true; 
          end

          obj.Members = value;
          
          if(shouldNotify)
              notify(obj, 'MembersChanged'); 
          end
       end
       
       %Update the regions for members. Send notification if they aren't equal
       function obj = set.Regions(obj, value)
          shouldNotify = false; %Never name this notify
          
          nRegions = length(value);

          if(length(obj.Regions) ~= length(value))
              shouldNotify = true; 
          else
              for(iRegion = 1:nRegions)
                  if(~isequal(value{iRegion}, obj.Regions{iRegion}))
                      shouldNotify = true;
                      break;
                  end
              end
          end
          
          %Always sort regions from smallest area to largest
          RegionSize = zeros(1, nRegions);
          for(iRegion = 1:nRegions)
              RegionSize(iRegion) = length(value{iRegion});
          end
          
          [~, iSorted] = sort(RegionSize); 

          obj.Regions = value(iSorted);
          
          if(shouldNotify)
              notify(obj, 'RegionsChanged'); 
          end
       end
       
       %Return true if members can be added
       function val = get.CanAddMembers(obj)
           val = true; 
           if([obj.Locked] || [obj.UnassignedOnly])
               val = false; 
           end
       end
       
       function val = get.CanRemoveMembers(obj)
           val = true; 
           if(obj.Locked)
               val = false; 
           end
       end
               

       %Create a context menu, or append a passed context menu
       function cmenu = GetContextMenu(obj, cmenu)
           
           if(nargin < 2)
               cmenu = uicontextmenu();
           end
           
           cmenu = obj.Collection.Controller.GetContextMenu(obj,cmenu); 
           
           %The Unassigned category is special and should not deleted
           if(strcmp(obj.Name, 'Unassigned'))
               
           else
               checked = 'off';
               if(obj.Locked)
                   checked = 'on';
               end
               uimenu(cmenu, 'Label', 'Locked', ...
                             'Checked', checked, ...
                             'Callback', @(src,event)MenuLock(obj,src,event));
                     
               uimenu(cmenu, 'Label', 'Rename', ...
                             'Callback', @(src,event)MenuRename(obj, src,event));

               uimenu(cmenu, 'Label', 'Remove', ...
                             'Callback', @(src,event)MenuRemove(obj,src,event));
                         
               uimenu(cmenu, 'Label', 'Color', ...
                             'Callback', @(src, event)MenuColor(obj, src, event));
    
               if(~isempty(obj.Collection.UnassignedCategory.Members))
                   uimenu(cmenu, 'Label', 'Add Unassigned', ...
                                 'Callback', @(src,event)MenuAddUnassigned(obj, src,event));
               end
           end
       end
       
       function obj = ShowRenameUI(obj)
            name = inputdlg({'Enter new name for class:'}, 'Rename', 1, {obj.Name}); 
            action = Actions.PropertyChange('Name', name{1});
            obj.Collection.Controller.Do(action, obj); 
       end
       
       function obj = ShowColorUI(obj)
            color = uisetcolor(obj.Color); 
            action = Actions.PropertyChange('Color', color);
            obj.Collection.Controller.Do(action, obj);
       end
       
       function obj = MenuLock(obj, src, event)
            action = Actions.PropertyChange('Locked', ~obj.Locked);
            obj.Collection.Controller.Do(action, obj); 
    %        obj.Locked = ~obj.Locked;
       end
       
       function obj = MenuRemove(obj, src, event)
            obj.Collection.RemoveCategory(obj); 
       end
       
       function obj = MenuRename(obj, src, event)
           obj.ShowRenameUI();
       end
       
       function obj = MenuColor(obj, src, event)
            obj.ShowColorUI();
       end
       
       function obj = MenuAddUnassigned(obj, src, event)
            obj.Collection.AddUnassigned(obj); 
       end
   end
end 
