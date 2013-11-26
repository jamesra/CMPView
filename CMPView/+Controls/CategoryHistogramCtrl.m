classdef CategoryHistogramCtrl < Controls.Control
%CATEGORYHISTOGRAMCTRL - Displays one histogram for each Category attribute in a row 

   properties
       Category = [];      
       
       hAxes = []; %One histogram for each attribute
       hBar = []; %handle for each bar plot
       
       hTitle = []; %handle to text on left of control naming the category
       
       lhMembersChanged = []; 
       lhCategoryPropSet = [];
       
       nBins = 128;
   end
   
   properties (Dependent = true)
       CSVBinCountString = []; %Comma seperated value string of bin counts 
   end
   
   methods
       function obj = CategoryHistogramCtrl(Parent, Controller, Position, Category)
            obj = obj@Controls.Control(Parent, Controller, Position);
            
            obj.Category = Category; 
            
            %We don't listen for the Control.CollectionChanged event
            %because our parent should destroy us when that happens
            obj.lhMembersChanged = addlistener(obj.Category, 'MembersChanged', @(src,event)MembersChanged(obj,src,event));
            obj.lhCategoryPropSet = addlistener(obj.Category, {'Name', 'Color', 'Locked'}, 'PostSet', @(src,event)CategoryPropSet(obj,src,event));
            
            obj.CreateHistograms(); 
            obj.UpdateHistograms();
       end
       
       function delete(obj)
            delete(obj.lhMembersChanged);
            delete(obj.lhCategoryPropSet); 
            delete(obj.hBar);
            delete(obj.hAxes); 
            delete(obj.hTitle); 
            obj.lhMembersChanged = [];
       end
       
       function obj = UpdateTitleText(obj)
           cla(obj.hTitle);
           
           text('units', 'normalized', ...
                'Rotation', 90, ...
                'Position', [0 .5], ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'top', ...
                'Color', [0 0 0], ...
                'string', obj.Category.Name, ...
                'parent', obj.hTitle);
            
           percentage = length(obj.Category.Members) / obj.Category.Collection.NumDataPoints;
           percentage = percentage * 100; 
            
           text('units', 'normalized', ...
                'Rotation', 90, ...
                'Position', [.45 .5], ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'top', ...
                'Color', [0 0 0], ...
                'string', [num2str(percentage, '%4.2f') '%'], ...
                'parent', obj.hTitle);
       end
       
       function obj = CreateHistograms(obj)
           nAttributes = obj.Category.Collection.NumAttributes;
           
           %Create a title bar with category name
           obj.hTitle = axes('parent', obj.Parent, ...
                             'XTick', [], ...
                             'YTick', [], ...
                             'XTickMode', 'manual', ...
                             'YTickMode', 'manual', ...
                             'XTickLabelMode', 'manual', ...
                             'YTickLabelMode', 'manual');
                         
           obj.UpdateTitleText(); 
           
           %Create an axes for each histogram
           xStep = 1 / nAttributes; 
           position = [0 0 xStep 1];          
           for(i = 1:nAttributes)
               
               position(1) = position(1) + xStep; 
               obj.hAxes(i) = axes('units', 'normalized', ...
                            'position', position, ...
                            'parent', obj.Parent, ...
                            'XTick', [], ...
                            'YTick', [], ...
                            'XTickMode', 'manual', ...
                            'YTickMode', 'manual', ...
                            'XTickLabelMode', 'manual', ...
                            'YTickLabelMode', 'manual', ...
                            'YScale', 'log');
                        
           end
           
           obj.Resize();
       end
       
       function obj = UpdateHistograms(obj)
           
           binStep = 1/(obj.nBins-1);
           HistogramBins = -binStep:binStep:1+binStep;
           Collection = obj.Category.Collection;

           for(i = 1:Collection.NumAttributes)
               vals = Collection.Attributes(obj.Category.Members, i); %Get data points
               
               binCount = histc(vals', HistogramBins);
               
               try
                   if(i < len(obj.hBar))
                       delete( obj.hBar(i) ); %Attempt to delete if it exists
                   end
               catch
               end
               
               obj.hBar(i) = bar(obj.hAxes(i), binCount);
               set(obj.hAxes(i), 'XLim', [-1 length(HistogramBins)-1]);
               set(obj.hAxes(i), 'Color', obj.Category.StatusColor);
               set(obj.hAxes(i), 'XTickLabel', []);
               set(obj.hAxes(i), 'YTickLabel', []);
               set(obj.hAxes(i), 'XTick', []);
               set(obj.hAxes(i), 'YTick', []); 
               
               set(obj.hBar(i), 'BarWidth', 1); 
               set(obj.hBar(i), 'EdgeColor', 'none');
               set(obj.hBar(i), 'FaceColor', [0 0 0]);
           end
       end
       
       function obj = Resize(obj)
           %%%%%%%%Resize the Title Bar %%%%%%%%%%%%%%%
            set(obj.hTitle, 'units', 'pixels'); 
            position = [32 0 32 16];
            set(obj.hTitle, 'position', position); 
            
            %Get the font height
            %We use parent because the default font size of axes and panels
            %are different, and the HistogramView uses a panel to gauge
            %font size
            set(obj.Parent, 'FontUnits', 'pixels');
            fontHeight = get(obj.hTitle, 'FontSize'); 
            fontHeight = ceil(fontHeight) + 2;
            set(obj.Parent, 'FontUnits', 'points'); 
            
            %Position the panel to leave room for the title bar of the
            %CategoryHistogramCtrl
            position = [0 0 fontHeight * 2.5 fontHeight];
            set(obj.hTitle, 'Position', position); 
            set(obj.hTitle, 'Units', 'Normalized');
            
            %Adjust name panel so it is tall and narrow
            titleposition = get(obj.hTitle, 'Position'); 
            titleposition(1) = 0;
            titleposition(2) = 0; 
            titleposition(4) = 1 - titleposition(2);
            titlewidth = titleposition(3); 
            set(obj.hTitle,'Position', titleposition);
            
            %Reposition all histograms to the right of the title bar
            nAttributes = obj.Category.Collection.NumAttributes;
            
            xstep = (1-titlewidth) / nAttributes;
            position = [titlewidth 0 xstep 1];
            for(iCtrl = 1:length(obj.hAxes))
                set(obj.hAxes(iCtrl), 'position', position);                 
                position(1) = position(1) + xstep;
            end
       end
       
       
       
       function obj = MembersChanged(obj,src,event)
           obj.UpdateHistograms();
           obj.UpdateTitleText();
       end
       
       %Update UI if Category properties change.  Must update addlistener
       %if adding new properties
       function obj = CategoryPropSet(obj, src, event)
           switch src.Name
               case 'Name'
                   obj.UpdateTitleText();
               case 'Color'
                   for(iCtrl = 1:length(obj.hAxes))
                       set(obj.hAxes(iCtrl), 'Color', event.AffectedObject.StatusColor);
                   end
               case 'Locked'
                   for(iCtrl = 1:length(obj.hAxes))
                       set(obj.hAxes(iCtrl), 'Color', event.AffectedObject.StatusColor);
                   end
           end
       end
       
       %Returns a cell array of strings for each attribute.  Each string is
       %a csv list with the first entry being the class, the second entry
       %being the attribute, and 256 entries representing bin counts
       function val = get.CSVBinCountString(obj)
           val = {};

           Collection = obj.Category.Collection;
           AttributeNames = Collection.AttributeNames; 
           HistogramBins = 0:1/255:1;
            
            for(i = 1:Collection.NumAttributes)
               vals = Collection.Attributes(obj.Category.Members, i); %Get data points
               binCount = histc(vals', HistogramBins);
               
               csvString = [obj.Category.Name ',' AttributeNames{i}];
               for(iBin = 1:length(binCount))
                   csvString = strcat(csvString, [',' num2str(binCount(iBin))]);
               end
               
               val{i} = csvString;
            end
       end
       
       %For the given attribute, return the index of the bin with the
       %highest count
       function val = GetIndexOfPeakBin(obj, iAttribute)
           binCounts = get(obj.hBar(iAttribute), 'ydata');
           [MaxVal, iMax] = max(binCounts);
           val = iMax; 
       end
   end
end 
