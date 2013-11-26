classdef CollectionView < handle
%COLLECTIONVIEW - Lists all collections, thier attributes, and classes in
%   three columns across a panel

   properties
        ParentFigure = [];
        Controller = []; 
        hPanel = []; 
        
        %List boxes
        hListCollections = [];
%        hListViews = []; 
        hListCategories = [];  
        hListCategorizers = []; 
   end

   methods
       function obj = CollectionView(Controller, panel)
          import Controls.*
          
          obj.Controller = Controller; 
          obj.ParentFigure = Controller.ParentFigure; 
          obj.hPanel = panel; 
   
          obj.hListCollections = ListCollections(obj.hPanel, obj.Controller, [0 0 .33 1]); 

          obj.hListCategories = ListCategories(obj.hPanel, obj.Controller, [.33 0 .33 1]); 

          %obj.hListViews = ListViews(obj.hPanel, obj.Controller, [.66 0 .34 1]); 
          
          obj.hListCategorizers = CategorizerBtns(obj.hPanel, obj.Controller, [.66 0 .34 1]); 

          %Subscribe to collection changed events
%           lh = addlistener(obj.Controller, 'CollectionsChanged', @(src,event)CollectionsChanged(obj,src,event));
%           lh = addlistener(obj.Controller, 'CollectionChanged', @(src,event)CollectionChanged(obj,src,event));
%           lh = addlistener(obj.Controller, 'ViewChanged', @(src,event)ViewChanged(obj,src,event));
%           lh = addlistener(obj.Controller, 'CategoryChanged',
%           @(src,event)CategoryChanged(obj,src,event));
       end
   end
end 
