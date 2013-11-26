classdef ProgressReporter < Controls.Control
    %PROGRESSREPORTER Helper class for reporting progress to a UI
    
    properties
        Subject = ''; 
        Percentage = 0; %Progress on the subject, from zero to one
        Description = '';
    end
    
    properties (Access = Protected)
        hSubjectLabel = [];
        hPercentage = [];
        hDescription = []; 
        
    end
    
    methods
        
        function obj = ProgressReporter(Parent, Controller, Position)
          obj = obj@Controls.Control(Parent, Controller, Position);
          
          
        end
                
    end
    
end

