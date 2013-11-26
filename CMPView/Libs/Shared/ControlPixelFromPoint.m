function [ point ] = ControlPixelFromPoint( hControl )
%CONTROLPIXELFROMPOINT Summary of this function goes here
%   Detailed explanation goes here

%LISTINDEXFROMPOINT - Given a  control, returns the
%relative location of the mouse over the control. 
%NaN if the mouse is not over the control.

point = NaN;

set(gcf, 'units', 'pixels');
cp = get(gcf, 'currentpoint'); 
localpoint = GlobalToLocalPoint( cp, hControl);
set(gcf, 'units', 'normalized'); 

point = [localpoint(1) localpoint(2)];

point