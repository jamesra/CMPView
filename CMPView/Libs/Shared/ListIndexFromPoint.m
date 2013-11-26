function [ index ] = ListIndexFromPoint( hList)
%LISTINDEXFROMPOINT - Given a listbox control and a point, returns the
%index of the item in the listbox the mouse is currently over, or returns
%NaN if the mouse is not over an item.
%The offsets to y and the fontsize are based on voodoo and experimentation
%with the behavior of the MatLab listbox control on windows. 

index = NaN;

set(gcf, 'units', 'pixels');
cp = get(gcf, 'currentpoint'); 
localpoint = GlobalToLocalPoint( cp, hList);
set(gcf, 'units', 'normalized'); 

x = localpoint(1);
y = localpoint(2);

units = get(hList, 'Units'); 
set(hList, 'Units', 'pixels'); 
set(hList, 'FontUnits', 'pixels'); 

y = round(y); 
y = y + 2; %Adjust y to account for border

fontHeight = get(hList, 'FontSize'); 
fontHeight = ceil(fontHeight) + 2;

set(hList, 'FontUnits', 'points'); 

pos = get(hList, 'Position'); 
extent = get(hList, 'extent');

y = pos(4) - y; 

index = y / fontHeight; 
index = floor(index) + 1; 

set(hList, 'Units', units); 

if(index > length(get(hList, 'string')))
    index = NaN; 
else
    indexmap = get(hList, 'UserData');
    if(~isempty(indexmap))
        index = indexmap(index); 
    end
end