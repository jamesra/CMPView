classdef HistoPlotView  < Viewer
    %HISTOPLOTVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        lhCurrentViewChanged = [];
        lhCurrentCollectionChanged = []; 
        lhUpdatedImage = []; 
        hAxes = []; 
    end
    
    methods
        function obj = HistoPlotView(Controller)
           obj = obj@Viewer(Controller);
            
           obj.Name = 'Histoplot View';
           
           set(obj.Figure, 'position', [.5 .5 .45 .45], ...
                           'Visible',  'on', ...
                           'Renderer', 'OpenGL', ...
                           'ResizeFcn', @(src,event)FigureResized(obj,src,event));
                       
           obj.hAxes = axes('parent', obj.Figure);
           
           set(obj.hAxes, 'NextPlot', 'add');
           
           set(obj.hAxes, 'Position', [0.025 0.05 .95 .95]); 
           set(obj.hAxes, 'ActivePositionProperty', 'position');
           
           obj.lhCurrentCollectionChanged = addlistener(obj.Controller, 'CurrentCollectionChanged', @(src,event)CurrentCollectionChanged(obj, src,event));
           obj.lhCurrentViewChanged = addlistener(obj.Controller, 'CurrentViewChanged', @(src,event)ViewChanged(obj,src,event));
           
           
        end
        
        %When the collection changes we recreate the controls
        function obj = CurrentCollectionChanged(obj, src, event)
            
            delete(obj.lhUpdatedImage);
            
            obj.lhUpdatedImage = []; 
            
            if(isempty(obj.Controller.Collections))
                return;
            end
            
            obj.lhUpdatedImage = addlistener(obj.Controller.CurrentCollection, 'UpdatedImage', @(src,event)UpdatedImage(obj,src,event));
                       
            set(obj.hAxes, 'XTickLabel', obj.Controller.CurrentCollection.AttributeNames);
            
            obj.Draw();
        end
        
        function obj = ViewChanged(obj, src, event)
        %    obj.Draw(); 
            
        end
        
        function obj = Draw(obj)
                        
           %Fetch the image from the collection
           
           iCollection = obj.Controller.iCurrentCollection;
           
           CurrentCollection = obj.Controller.Collections(iCollection);
           
           nAttributes = size(CurrentCollection.Attributes,2);
           
           %Classes = CurrentCollection.Categories; 
           %Attributes = CurrentCollection.Attributes; 
           
           %obj.hAxes = axes('parent', obj.Figure); 
           
           %LabelMap = CurrentCollection.GetLabelMap();
           
           cla(obj.hAxes);
           
           hold on
           for(iCat = 1:CurrentCollection.NumCategories)
               
               if(~CurrentCollection.CategoryObjects(iCat).CanRemoveMembers)
                   continue; 
               end
               
               if(~CurrentCollection.CategoryObjects(iCat).CanAddMembers)
                   continue;
               end
        
               LabelMap = CurrentCollection.CategoryObjects(iCat).Regions; 
               Color = CurrentCollection.CategoryObjects(iCat).Color;
               
               nRegions = length(LabelMap); 

%                regionClass = zeros(nRegions, 1); 
%                medianRegion = zeros(nRegions, nAttributes);
%                lineWidth = zeros(nRegions, 1); 
%                lockmap = [CurrentCollection.CategoryObjects.Locked];
%                cmap = [CurrentCollection.CategoryObjects.StatusColor];
%                cmap = reshape(cmap, 3, length(CurrentCollection.CategoryObjects))'; %Yes, the apostrophe is required
%                color = zeros(nRegions, 3); 

               
               for iRegion = 1:nRegions
                   iPixels = LabelMap{iRegion};
                  % lineWidth(iRegion) = length(iPixels); 
                   
                   %if(lineWidth(iRegion) > 1)
                   %color(iRegion, :) = cmap(iCat,:); 
                   %medianRegion(iRegion, :) = median(CurrentCollection.Attributes(iPixels,:));
                   medianRegion = median(CurrentCollection.Attributes(iPixels,:));

                   plot(obj.hAxes, 1:nAttributes, ...
                        medianRegion, ...
                        'linewidth', sqrt(length(iPixels)), ...
                        'Color', Color);
                   %end

               end
               

           end
           
           %plot(obj.hAxes, 1:nAttributes, medianRegion, 'linewidth', lineWidth, 'ColorOrder', color );
           
          % CurrentCollection.Attributes(LabelMap{2,2},:)

           
          % plot(obj.hAxes, Classes, Attributes);
        end
                
        %Resize category controls to show all visible
        function obj = Resize(obj)
        %   obj.Draw(); 
        end
        
        %The collection has updated categories. Find out if we need to
       %update our view
       function obj = UpdatedImage(obj, src, event)
           %obj.Draw(); 
       end
        
       function obj = FigureResized(obj, src, event)
       %   obj.Resize();
       end
        
    end
    
end