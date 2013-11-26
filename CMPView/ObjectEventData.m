classdef ObjectEventData < event.EventData
%OBJECTEVENTDATA - Event data that includes a passed object

   properties
       Object = [];
   end

   methods
       function obj = ObjectEventData( Object)
          obj.Object = Object;  
       end
   end
end 
