classdef ImageViewerCtrl < Control
    %IMAGEVIEWERCTRL Displays an image providing basic interactivity
    
    properties
       Panel = []; %Panel holding all controls
       hImageAxes = []; %Holds panel displaying image
       hImage = []; %ImageSC being displayed
       Buttons = []; %Array of psuedotoolbar buttons
       
       ImageSize = []; 
       ZoomFactor = 1; 
       
       ViewCenter = []; %Where is the user view currently centered
       
       Mode = 'Pointer'; %What is the current function of the mouse
    end
    
    properties (Constant = true)
       AvailableModes = {'Pointer', 'Magnify'};
        
    end
    
    methods
        function obj = ImageViewerCtrl(Parent, Controller, Position)
            obj = obj@Control(Parent, Controller, Position);
            
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
            
            set(obj.hImageAxes, 'ButtonDownFcn', {@(src,event)Image_ButtonDownFcn(obj,src,event)});
            set(obj.hImage, 'ButtonDownFcn', {@(src,event)Image_ButtonDownFcn(obj,src,event)});
        end
        
        %The current visible rectangle of the image
       function rect = VisibleRect(obj)
           xlim = get(obj.hImageAxes, 'XLim');
           ylim = get(obj.hImageAxes, 'YLim'); 
           rect = [xlim(1) ylim(1) xlim(2) ylim(2)]; 
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

