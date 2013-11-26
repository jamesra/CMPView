classdef ImageViewer < Viewer
%IMAGEVIEW Summary of this class goes here
%   Detailed explanation goes here

   properties
%       ParentFigure = [];
%       Figure = []; 
       Panel = []; %Panel holding all controls
       hImageAxes = []; %Holds panel displaying image
       hImage = []; %ImageSC being displayed
       Buttons = []; %Array of psuedotoolbar buttons
       
       ImageSize = []; 
       ZoomFactor = 1; 
       
       hListViews = []; 
       
       hMenuFile = [];
       
       ViewCenter = []; %Where is the user view currently centered
       
       Mode = 'Pointer'; %What is the current function of the mouse
       
       lhCurrentCollectionChanged = []; 
       lhCurrentViewChanged = [];
       lhUpdatedImage = []; %Listens for updates to the collections categories
   end
   
   properties (Dependent = true)
       
   end

   methods
       function obj = ImageViewer(Controller)
            obj = obj@Viewer(Controller);
            import Controls.*
            
            obj.Name = 'Image Viewer'; 
            
            set(obj.Figure,'position', [0 .1 .5 .5], ...
                           'Visible', 'on', ...
                           'Renderer', 'painters');
         
            colormap('gray');
            
            obj.hMenuFile = uimenu('Parent', obj.Figure, ...
                                   'Label', 'File');

            uimenu('Parent', obj.hMenuFile, ...
                   'Label', 'Save Image', ...
                   'Callback', @(src, event)MenuFileSaveImageCallback(obj, src,event) );
            
            %Create a list of available views
%            hListImageTools = ListImageTools(obj.Figure, Controller, [.9 0 .1 .25]);
            hListViews = ListViews(obj.Figure, Controller, [.9 0 .1 1]);
                        
            obj.Panel = uipanel('units', 'normalized', ...
                        'position', [0 0 .9 1], ...
                        'BackgroundColor', [0 0 0], ...
                        'ButtonDownFcn', {@(src,event)Image_ButtonDownFcn(obj,src,event)}, ...
                        'ResizeFcn', {@(src,event)Image_ResizeFcn(obj,src,event)});

            %Create axes for displaying images
            obj.hImageAxes = axes('parent', obj.Panel, ...
                                      'units', 'normalized', ...
                                      'position', [0 0 1 .95], ...
                                      'DataAspectRatio', [1 1 1], ...
                                      'YDir', 'reverse',...
                                      'Color', [0 0 0]);

            obj.hImage = imagesc('parent', obj.hImageAxes, ...
                                 'CData', []);   

            obj.Buttons(1) = uicontrol('parent', obj.Panel, ...
                                     'Style', 'togglebutton', ...
                                     'units', 'normalized', ...
                                     'position', [0 .95 .5, .05],...
                                     'string', 'Pointer'); 

            obj.Buttons(2) = uicontrol('parent', obj.Panel, ...
                                     'Style', 'togglebutton', ...
                                     'units', 'normalized', ...
                                     'position', [.5 .95 .5, .05],...
                                     'string', 'Magnify');
                                 
            for(iBtn = 1:length(obj.Buttons))
               set(obj.Buttons(iBtn), 'Callback', {@(src,event)button_ButtonToggle(obj,src,event,iBtn)});
            end

%            set(obj.Panel, ); 
            set(obj.hImageAxes, 'ButtonDownFcn', {@(src,event)Image_ButtonDownFcn(obj,src,event)});
            set(obj.hImage, 'ButtonDownFcn', {@(src,event)Image_ButtonDownFcn(obj,src,event)});

            info.DragPoint = [];
            info.ParentFigure = obj.ParentFigure; 
            guidata(obj.Figure, info);
            
            obj.lhCurrentCollectionChanged = addlistener(obj.Controller, 'CurrentCollectionChanged', @(src,event)CollectionChanged(obj,src,event));
            obj.lhCurrentViewChanged = addlistener(obj.Controller, 'CurrentViewChanged', @(src,event)ViewChanged(obj,src,event));
       end
       
       function delete(obj)
           delete(obj.lhCurrentCollectionChanged);
           delete(obj.lhCurrentViewChanged); 
           delete(obj.lhUpdatedImage); 
       end
       
       
       
       %When the view changes update the image we are displaying
       function obj = ViewChanged(obj,src,event)
           obj.LoadImage();
       end
       
       %When the view changes update the image we are displaying
       function obj = CollectionChanged(obj,src,event)
           delete(obj.lhUpdatedImage);
           obj.lhUpdatedImage = []; 
           
           if(isempty(obj.Controller.Collections))
               return;
           end
           
           obj.lhUpdatedImage = addlistener(obj.Controller.CurrentCollection, 'UpdatedImage', @(src,event)UpdatedImage(obj,src,event));
           
           obj.LoadImage();
       end
       
       %The collection has updated categories. Find out if we need to
       %update our view
       function obj = UpdatedImage(obj, src, event)
           obj.LoadImage(); 
       end
       
       %Fetches the image we are currently displaying
       %The optional argument is a rectangle [xmin ymin width height]
       %which is used to crop the image
       function obj = LoadImage(obj, varargin)

           %Fetch the image from the collection
           iCollection = obj.Controller.iCurrentCollection;
           iView = obj.Controller.iCurrentView;

           img = obj.Controller.Collections(iCollection).Image(iView);
           
           %Save the original size a prepare the crop
           obj.ImageSize = size(img); 
           MaxY = obj.ImageSize(1);
           MaxX = obj.ImageSize(2);
           
           rect = [0 0 MaxX MaxY]; 
           if(nargin == 2)
              rect = varargin(1); 
           end            
           
           set(obj.hImage,'CData', img);

           
           %Crop the displayed portion to match the requested rectangle
           XLim = get(obj.hImageAxes, 'XLim');
           if(XLim == [0 1])
               set(obj.hImageAxes, 'XLim', [rect(1) rect(3)]);
               set(obj.hImageAxes, 'YLim', [rect(2) rect(4)]); 
               set(obj.hImage, 'YData', [ MaxY 1]);
           end
       end
       
       function val = AxesSize(obj)
           %Determine the size of the axes in pixels
           set(obj.hImageAxes, 'Units', 'Pixels');
           AxesPosition = get(obj.hImageAxes, 'Position');
           set(obj.hImageAxes, 'Units', 'Normalized'); 

           val.Width = AxesPosition(3);
           val.Height = AxesPosition(4);
       end
       
       function obj = ViewPoint(obj, point)
           obj.ViewCenter = point; 
           AxesSize = obj.AxesSize; 

           %Adjust what we can see of the image
           Width = AxesSize.Width / obj.ZoomFactor;
           Height = AxesSize.Height / obj.ZoomFactor;

           yLim = [(point(1) - (Height / 2)) (point(1) + (Height / 2))];
           xLim = [(point(2) - (Width / 2)) (point(2) + (Width / 2))];

           set(obj.hImageAxes, 'XLim', xLim);
           set(obj.hImageAxes, 'YLim', yLim);
       end
       
       function obj = button_ButtonToggle(obj,src,event,iBtn)  
            for(iButton = 1:length(obj.Buttons))
                set(obj.Buttons(iButton), 'value', 0);
            end

            Max = get(obj.Buttons(iBtn), 'Max');
            set(obj.Buttons(iBtn), 'value', Max);
            obj.Mode = get(obj.Buttons(iBtn), 'string');
       end
       
       function obj = Image_ResizeFcn(obj,src,event)
           
           %Reposition the controls to keep buttons a constant size
           panelSize = get(obj.Panel, 'position'); 
           HeightScale = 1 / panelSize(4);

           txtExtent = get(obj.Buttons(1), 'Extent'); 

           txtExtent(4) = txtExtent(4) * HeightScale; 

           for(iButton = 1:length(obj.Buttons))
               pos = get(obj.Buttons(iButton), 'position');
               pos(4) = txtExtent(4);
               pos(2) = 1 - txtExtent(4); 
               set(obj.Buttons(iButton), 'position', pos);
           end

           axespos = [0 0 1 (1 - txtExtent(4))];
           set(obj.hImageAxes, 'position', axespos); 
           
           %TODO: Adjust the limits of the image to ensure it takes advantage of
           %new space
           
       end
       
       function obj = Image_ButtonDownFcn(obj, src, event)
    
           Selection = get(gcf, 'SelectionType');

           point = get(obj.hImageAxes, 'CurrentPoint');
           point = [point(1,2) point(1,1)];

           switch obj.Mode; 
               case 'Pointer'
                   obj.ViewPoint(point); 
               case 'Magnify'
                   Magnify(obj, point, Selection);
               case 'Drag'
                   %{
                   imageIndex = get(handles.ImagesList, 'Value');
                   CPoints = GetTransformedPoints(handles.CPLibrary, imageIndex); 
                   iPoint = FindCPoint(obj, point, CPoints);
                   disp(iPoint);
                   %}
          end
      end
       
      
      function MenuFileSaveImageCallback(obj, src, event)
          
          imsave(obj.hImage);           
          
      end
      
      function Magnify( obj, point, Selection )
        %MAGNIFY Summary of this function goes here
        %   Detailed explanation goes here

            point = get(obj.hImageAxes, 'CurrentPoint');
            point = [point(1,2) point(1,1)];

            AxesSize = obj.AxesSize();

            Aspect = AxesSize.Width / AxesSize.Height; 

            XLim = get(obj.hImageAxes, 'XLim');
            YLim = get(obj.hImageAxes, 'YLim');
            Width = XLim(2) - XLim(1); 
            Height = YLim(2) - YLim(1);

            ImgSize = obj.ImageSize; 
            
            ImgHeight = ImgSize(1); 
            ImgWidth = ImgSize(2);
            

            if(point(1) < 0)
                point(1) = 0;
            elseif(point(1) > ImgHeight)
                point(1) = ImgHeight; 
            end

            if(point(2) < 0)
                point(2) = 0;
            elseif(point(2) > ImgWidth)
                point(2) = ImgWidth;
            end
            
            obj.ViewCenter = point; 

            if(strcmp(Selection, 'normal')) %Zoom in
                Width = Width / 4;
                
                obj.ZoomFactor = ImgWidth / (Width * 2); 
        
                Height = Width/ Aspect; 

                XLim(1) = point(2) - Width;
                XLim(2) = point(2) + Width;
                YLim(1) = point(1) - Height;
                YLim(2) = point(1) + Height;

                set(obj.hImageAxes, 'XLim', XLim);
                set(obj.hImageAxes, 'YLim', YLim);

            elseif(strcmp(Selection, 'alt')) %Zoom out
     %           Width = Width * 1.4142; 
     %           Height = Height * 1.4142; 
                                
                XLim(1) = XLim(1) - Width;
                XLim(2) = XLim(2) + Width;
                YLim(1) = YLim(1) - Height;
                YLim(2) = YLim(2) + Height;

                if((Width * 2) > ImgWidth && (Height * 2) > ImgHeight)
                    XLim = [0 ImgWidth];
                    YLim = [0 ImgHeight]; 
                end
                
                obj.ZoomFactor = ImgWidth / (XLim(2)-XLim(1)); 
                obj.ZoomFactor

                set(obj.hImageAxes, 'XLim', XLim);
                set(obj.hImageAxes, 'YLim', YLim);

                XData = get(obj.hImage, 'XData');
                YData = get(obj.hImage, 'YData');

                if(XLim(1) < 0)
                    XLim(1) = 0;
                end
                if(YLim(1) < 0)
                    YLim(1) = 0;
                end
                if(XLim(2) > ImgWidth)
                    XLim(2) = ImgWidth;
                end
                if(YLim(2) > ImgHeight)
                    YLim(2) = ImgHeight;
                end

                if(XData(1) > XLim(1) && ...
                   XData(2) < XLim(2) || ...
                   YData(2) > YLim(1) && ... %Reversed YData comparison because coord system is inverted in Y
                   YData(1) < YLim(2))
                    %Reload the image if we are zooming out past the data we've
                    %already loaded
                    disp('Reload image for zoom out');
                    
                    set(obj.hImageAxes, 'XLim', [0 ImgSize(2)]);
                    set(obj.hImageAxes, 'YLim', [0 ImgSize(1)]);
                    
                    obj.ZoomFactor = 1; 
                    obj.ViewCenter = [(ImgSize(1) / 2) (ImgSize(2) / 2)]; 
                end
            end
      end             
   end
end 
