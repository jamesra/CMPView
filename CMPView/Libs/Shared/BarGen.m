function [ output_args ] = BarGen( AngleDegrees, Speed, BarWidth, BarSpacing, ForeColor, BackColor)
%BARGEN Summary of this function goes here
%   Detailed explanation goes here

    fig = figure; 
    set(fig, 'UserData', 1, ... //Set to 0 if program should terminate
                 'KeyPressFcn', {@KeyPressFcn, fig}, ...
                 'Renderer', 'OpenGL', ...
                 'DockControls', 'off', ...
                 'MenuBar', 'none', ...
                 'Name', 'Bar Generator', ...
                 'Toolbar', 'none'); 
             
    hAxes = axes('parent', fig, ...
                 'DrawMode', 'fast', ...
                 'units', 'normalized', ...
                 'Position', [0 0 1 1], ...
                 'XTick', [], ...
                 'YTick', [], ...
                 'Color', BackColor); 
                 
    xlim('manual');
    ylim('manual');

    if(AngleDegrees >= 0)
        AngleDegrees = mod(AngleDegrees,360);
    else
        AngleDegrees = -mod(-AngleDegrees,360);
    end
    
    AngleRadians = (AngleDegrees / 180) * pi;  %Range is from -pi to pi 
    
    set(hAxes, 'CameraUpVector', [cos(AngleRadians), sin(AngleRadians), 1]); 
   
    Offset = 0; 
    Continue = 1;
    
    %Figure out the slope of the line
  %  if(AngleDegrees == 90 || AngleDegrees == 270)
  %      Slope = 1;
  %  else
        Slope = tan(AngleRadians);
  %  end
    
    tic; %Start the clock
    
    while(Continue)
        drawnow; 
        cla
        
        %Figure out how wide the bars are
   %     set(hAxes, 'units', 'points')
   %     Position = get(hAxes, 'position'); 

     %   LineWidth = BarWidth * Position(4); 
    %    set(hAxes, 'units', 'normalized')
        
        t = toc; 
        Offset = mod(t,Speed) ./ Speed;
    %    disp(Offset) ;
        Continue = get(fig, 'UserData');
        
        XLim = get(hAxes, 'XLim');
        YLim = get(hAxes, 'YLim');
        
        %Find the starting and ending point of the line  
        StartX = -floor(Offset / BarSpacing ) / 10;
        for(Y = StartX-BarSpacing:BarSpacing:1-Offset)
            
            YStart = Y+Offset; 
            YEnd = Y+Offset+BarWidth; 
            patch([XLim(1) XLim(2) XLim(2) XLim(1)], [YStart YStart YEnd YEnd], ForeColor);
        end
        
        
        
    end
    
    delete(hAxes); 
    delete(fig); 

end

function KeyPressFcn(src, event, fig)
    set(fig, 'UserData', 0); 
end

