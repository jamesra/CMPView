%Given a pixel coordinate, returns the position of the pixel coordinate in
%the controls normalized units
function val = PixelsToNormalUnits(hObject, PixelCoord)

    startingPos = get(hObject, 'position'); 
    startingUnits = get(hObject, 'Units'); 
    
    set(hObject, 'Units', 'normalized');
    startingNormalPos = get(hObject, 'position');
    
    set(hObject, 'Units', 'Pixels');    
    set(hObject, 'position', [0 0 PixelCoord(1) PixelCoord(2)]);
    set(hObject, 'Units', 'Normalized');
    endingNormalPos = get(hObject, 'position');
    
    val = [(endingNormalPos(3) - startingNormalPos(3)) (endingNormalPos(4) - startingNormalPos(4))];
    
    set(hObject, 'Units', startingUnits);
    set(hObject, 'Position', startingPos);