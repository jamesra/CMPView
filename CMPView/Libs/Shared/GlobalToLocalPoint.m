function [ point ] = GlobalToLocalPoint( gpoint, hControl )
%GLOBALTOLOCALPOINT - Takes a point relative to the figure and returns a
%point relative to the control passed. 

%Walk up each parent control until we reach the figure.
while(hControl ~= gcf)
    set(hControl, 'units', 'pixels'); 
    position = get(hControl, 'position');
    gpoint(1) = gpoint(1) - position(1); 
    gpoint(2) = gpoint(2) - position(2); 
    set(hControl, 'units', 'normalized'); 
    
    hControl = get(hControl, 'parent'); 

end

point = gpoint; 
