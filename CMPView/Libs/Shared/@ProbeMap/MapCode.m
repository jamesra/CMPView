function [ ProbeName ] = MapCode( thisObj, ProbeCode )
%MAPCODE - Returns the ProbeName for the given probe code

ProbeName = [];
    
if(isempty(thisObj.NameMap))
    return;
end

NumProbes = length(thisObj.NameMap);

for(iProbe = 1:NumProbes)
   if(strcmpi(thisObj.NameMap{iProbe, 1}, ProbeCode))
       ProbeName = thisObj.NameMap{iProbe, 2};
       ProbeName = [ProbeName ' (' ProbeCode ')' ]; 
       return;
   end
end
