classdef HistogramView < Viewer
%HistogramViewer Shows histograms of each category
%   Detailed explanation goes here
    
    properties
        lhAddCategory = [];
        lhRemoveCategory = [];
        
        CategoryControls = []; %A control to display each category
        
        hMenuFile = []; %File menu to save histograms
        hMenuCategories = []; %Children of the category menu
        hMenuCategoryParent = []; %The category menu
        
        hPanelAttributeNames = [];
        hBtnAttributes = []; %Buttons used to display attribute names and pushed to sort
        hBtnAttributesEnabled = []; %Buttons used to indicate if attribute is used for clustering
        
        iSortAttribute = 0; %The attribute histograms are sorted on
        iSortPosition  = []; %Which order controls are placed in
    end
    
    methods
        function obj = HistogramView(Controller)
            obj = obj@Viewer(Controller);
            
            obj.Name = 'Histogram View';
           
            set(obj.Figure,'position', [.5 .1 .5 .5], ...
                           'Visible', 'on', ...
                           'Renderer', 'painters', ...
                           'ResizeFcn', @(src,event)FigureResized(obj,src,event));
                       
            obj.hMenuFile = uimenu('Parent', obj.Figure, ...
                                   'Label', 'File');
            uimenu('Parent', obj.hMenuFile, ...
                   'Label', 'Save Histograms', ...
                   'Callback', @(src, event)MenuFileSaveCallback(obj, src, event));
                       
            obj.hMenuCategoryParent = uimenu('Parent', obj.Figure, ...
                           'Label', 'Categories', ...
                           'Callback', @(src,event)CategoryParentMenuCallback(obj, src,event));
                       
            %Create panel to hold attribute names
            obj.hPanelAttributeNames = uipanel('Parent', obj.Figure, ...
                                               'Units',  'Normalized', ...   
                                               'Position', [0 0 1 1], ...
                                               'BorderType', 'none'); 
                       
            lh = addlistener(obj.Controller, 'CurrentCollectionChanged', @(src,event)CurrentCollectionChanged(obj, src,event));
            
            obj.Resize();
        end
        
        function delete(obj)
           delete(obj.CategoryControls);
           delete(obj.lhAddCategory);
           delete(obj.lhRemoveCategory);
        end
        
        function obj = CategoryParentMenuCallback(obj, src, event)
           obj.UpdateCategoryMenu();
        end

        %Create a menu to show/hide categories
        function obj = UpdateCategoryMenu(obj)
           delete(obj.hMenuCategories);
           obj.hMenuCategories = [];
           set(obj.hMenuCategoryParent, 'Children', []);
           
           for(iCat = 1:length(obj.CategoryControls))
              category = obj.CategoryControls(iCat).Category; 
              
              visible = 'on';
              if(~obj.CategoryControls(iCat).Visible)
                  visible = 'off';
              end
              
              obj.hMenuCategories(iCat) = uimenu('Parent', obj.hMenuCategoryParent, ...
                                                 'Checked', visible, ...
                                                 'Label', category.Name, ...
                                                 'Callback', @(src,event)CategoryMenuCallback(obj,src,event), ...
                                                 'UserData', obj.CategoryControls(iCat));
           end
        end
        
        %Menu command to show/hide a category
        function obj = CategoryMenuCallback(obj, src, event)
            hCtrl = get(src, 'UserData');
            visible = hCtrl.Visible;
            visible = ~visible; 
            hCtrl.Visible = visible; 
            
            checked = 'on'; 
            if(~visible)
                checked = 'off';
            end
            
            set(src, 'Checked', checked); 
            
            %Adjust the spacing of categories to show/hide the category
            Resize(obj);
        end
        
        %Save the histogram bins to a text file.  The text file is comma
        %seperated value string with the first value being the name of the
        %class, the second being the attribute followed by 256 numbers representing bin counts.
        %Attributes are seperated by a newlines
        function obj = MenuFileSaveCallback(obj, src, event)
            SaveStrings = {};
            
            [FileName, PathName] = uiputfile('*.txt', 'Select file name', [obj.Controller.DataPath filesep 'Histogram.txt']);

            % uiputfile returns a string if the user chose a file and the number 0 if
            % they did not
            if(~ischar(FileName))
                return;
            end
            
            obj.Controller.DataPath = PathName; %Save the last used path as default

            fid = fopen([PathName FileName], 'w+t');
            
            SaveStrings = {obj.CategoryControls.CSVBinCountString}; 
            
            disp(SaveStrings);
            
            for(iCat = 1:length(SaveStrings))
               CatString = SaveStrings{iCat}; 
               for(iAttribute = 1:length(CatString))
                  csvString = CatString{iAttribute};
                  
                  disp(csvString);
                  
                  fprintf(fid,'%s\n', csvString);
                  
               end
            end
            
            fclose(fid); 
            disp('Closing Histogram Save File') ;
        end
        
        %When the collection changes we recreate the controls
        function obj = CurrentCollectionChanged(obj, src,event)
            
            delete(obj.lhAddCategory);
            delete(obj.lhRemoveCategory);
            
            obj.lhAddCategory = []; 
            obj.lhRemoveCategory = []; 
            
            if(isempty(obj.Controller.Collections))
                return;
            end
            
            obj.lhAddCategory = addlistener(obj.Controller.CurrentCollection, 'AddedCategory', @(src,event)AddedCategory(obj,src,event));
            obj.lhRemoveCategory = addlistener(obj.Controller.CurrentCollection, 'RemovedCategory', @(src,event)RemovedCategory(obj,src,event));
           
            obj.UpdateAttributeNames(); 
            
            obj.UpdateCategoryControls();
            
            obj.Resize() ;
        end
        
        %This populates a short panel at the top of the figure with the names
        %of each attribute spaced evenly across it.  It leaves room on the
        %left for the title bar of each HistogramCtrl, which should be
        %2*fontheight in size
        function obj = UpdateAttributeNames(obj)
            %Delete the old attributes
            delete(obj.hBtnAttributes); 
            delete(obj.hBtnAttributesEnabled); 
            obj.hBtnAttributes = []; 
            obj.hBtnAttributesEnabled = []; 
            
            nAttributes = obj.Controller.CurrentCollection.NumAttributes;
            Names = obj.Controller.CurrentCollection.AttributeNames;
            
            xstep = 1 / nAttributes; 
            xAttributeWidth = xstep * .7; 
            xAttributeEnabledWidth = xstep - xAttributeWidth; 
            
            position = [0 0 xstep 1]; 
            for(i = 1:nAttributes)
                val = obj.Controller.CurrentCollection.GetAttributeEnabled(Names{i}); 
                               
                attributePosition = position; 
                attributeEnabledPosition = attributePosition; 
                attributePosition(3) = xAttributeWidth;
                
                attributeEnabledPosition(1) = attributeEnabledPosition(1) + xAttributeWidth; 
                attributeEnabledPosition(3) = xAttributeEnabledWidth; 
                
                obj.hBtnAttributes(i) = uicontrol('Parent', obj.hPanelAttributeNames, ...
                                                  'Units', 'Normalized', ...
                                                  'Style', 'pushbutton',...
                                                  'String', Names{i}, ...
                                                  'Position', attributePosition, ...
                                                  'UserData', i, ...    %Store the attribute index in the control
                                                  'Callback', @(src,event)AttributeSortCallback(obj,src,event));
                                              
                obj.hBtnAttributesEnabled(i) = uicontrol('Parent', obj.hPanelAttributeNames, ...
                                                  'Units', 'Normalized', ...
                                                  'Style', 'togglebutton',...
                                                  'String', 'Use', ...
                                                  'Position', attributeEnabledPosition, ...
                                                  'Value', val, ...
                                                  'UserData', i, ...    %Store the attribute index in the control
                                                  'Callback', @(src,event)AttributeEnabledCallback(obj,src,event));

                
                position(1) = position(1) + xstep; 
            end
           
        end
        
        %Sort the histogram controls according to the histogram selected
        function obj = AttributeSortCallback(obj, src, event)
            iSortNew = get(src,'UserData');
            
            %Hitting the button twice turns off sorting
            if(iSortNew == obj.iSortAttribute)
                obj.iSortAttribute = 0; 
            else
                obj.iSortAttribute = iSortNew;
            end
            
            obj.SortControls();
            obj.Resize(); 
        end
        
         %Sort the histogram controls according to the histogram selected
        function obj = AttributeEnabledCallback(obj, src, event)
            iAttribute = get(src,'UserData');      
            iNewValue = get(src, 'Value'); 
                        
            attributeName = obj.Controller.CurrentCollection.AttributeNames{iAttribute}; 
            
            
            obj.Controller.CurrentCollection.SetAttributeEnabled(attributeName, iNewValue);
                 
        end
        
        %Remove and recreate the histogram controls
        function obj = UpdateCategoryControls(obj)        
            delete(obj.CategoryControls);
            obj.CategoryControls = [];
            
            %Titlebar size
            titlesize = get(obj.hPanelAttributeNames, 'Position'); 
            titlesize = titlesize(4); %Height of the titlebar in normalized units         
            
            %Create category controls for each category
            nCats = obj.Controller.CurrentCollection.NumCategories;
            ystep = (1-titlesize) / nCats;
            position = [0 0 1 ystep];
            for(iCat = 1:nCats)
                ctrl = Controls.CategoryHistogramCtrl(obj.Figure, obj.Controller, position, obj.Controller.CurrentCollection.CategoryObjects(iCat));                
                position(2) = position(2) + ystep; 
                if(isempty(obj.CategoryControls))
                    obj.CategoryControls = ctrl;
                else
                    obj.CategoryControls(iCat) = ctrl; 
                end
            end
            
            obj.SortControls();
            obj.UpdateCategoryMenu();
            obj.Resize(); 
        end
        
        %Sort the controls according to the current iSortAttribute
        function obj = SortControls(obj)
            
            nControls = length(obj.CategoryControls);
            
            if(obj.iSortAttribute == 0)
                obj.iSortPosition = [1:nControls];
                return;
            end
            
            for(iCtrl = 1:nControls)
                binPeakIndex(iCtrl) = obj.CategoryControls(iCtrl).GetIndexOfPeakBin(obj.iSortAttribute); 
            end
            
            [sorted,iSorted] = sort(binPeakIndex); 
            
            obj.iSortPosition = iSorted; 
        end

        
        %Add a specific category to the view
        function obj = AddCat(obj, cat)
            ctrl = Controls.CategoryHistogramCtrl(obj.Figure, obj.Controller, [0 0 1 1], cat); 
            obj.CategoryControls(end+1) = ctrl;
            
            obj.SortControls(); 
            obj.Resize(); 
            obj.UpdateCategoryMenu();
        end
               
        %Remove a specific category from the view
        function obj = RemoveCat(obj, cat)
            for(iCat = 1:length(obj.CategoryControls))
               if(obj.CategoryControls(iCat).Category == cat)
                  delObj = obj.CategoryControls(iCat);
                  obj.CategoryControls(iCat) = []; 
                  delete(delObj); 
                  break; 
               end
            end
            
            obj.SortControls();
            obj.Resize();
            obj.UpdateCategoryMenu();
        end
        
        function val = NumVisibleCats(obj)
           val = 0; 
           if(~isempty(obj.CategoryControls))
               val = sum([obj.CategoryControls.Visible]);
           end
        end
        
        %Resize category controls to show all visible
        function obj = Resize(obj)
            
            %%%%%%%%Resize the Title Bar %%%%%%%%%%%%%%%
            set(obj.hPanelAttributeNames, 'units', 'pixels'); 
            position = [32 0 32 16];
            set(obj.hPanelAttributeNames, 'position', position); 
            
            %Get the font height
            set(obj.hPanelAttributeNames, 'FontUnits', 'pixels'); 
            fontHeight = get(obj.hPanelAttributeNames, 'FontSize'); 
            fontHeight = ceil(fontHeight) + 2;
            set(obj.hPanelAttributeNames, 'FontUnits', 'points'); 
            
            %Position the panel to leave room for the title bar of the
            %CategoryHistogramCtrl
            position = [fontHeight * 2 0 fontHeight fontHeight*2];
            set(obj.hPanelAttributeNames, 'Position', position); 
            set(obj.hPanelAttributeNames, 'Units', 'Normalized');
            
            %Adjust name panel so it is wide and short
            titleposition = get(obj.hPanelAttributeNames, 'Position'); 
            titleposition(3) = 1 - titleposition(1);
            titleposition(2) = 1-titleposition(4);
            set(obj.hPanelAttributeNames,'Position', titleposition); 
                        
            %Titlebar size
            titleheight = titleposition(4); %Height of the titlebar in normalized units
            
            %%%%%%%%% Position the Histrogram Controls %%%%%%%%%%
            nCats = obj.NumVisibleCats; 
            if(nCats > 0)
                ystep = (1-titleheight) / nCats;
                position = [0 0 1 ystep];
                for(iCat = 1:length(obj.CategoryControls))
                    iControl = obj.iSortPosition(iCat);
                    if(obj.CategoryControls(iControl).Visible)
                        obj.CategoryControls(iControl).Position = position; 
                        position(2) = position(2) + ystep;                        
                        obj.CategoryControls(iControl).Resize(); 
                    end
                end
            end
        end
        
        function obj = AddedCategory(obj,src,event)
           obj.AddCat(event.Object); 
        end
        
        function obj = RemovedCategory(obj, src, event)
           obj.RemoveCat(event.Object); 
        end
        
        function obj = FigureResized(obj, src, event)
           obj.Resize();  
        end
        
    end
end