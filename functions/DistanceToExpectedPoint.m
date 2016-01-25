function [ isClose ] = DistanceToExpectedPoint( position, previousPosition , trayectory ,th, steps)
%DistanceToPreviousFrame:  Summary of this function goes here
%   Position: where the object is in the present
%   previousPosition: last knownposition of the object
%   trayectory: direction the object was heading


ExpectedPosition = previousPosition + trayectory*steps;

dist = ExpectedPosition - position;
distMod =  sqrt(dist(1).^2+dist(2).^2);


if(distMod < th)
    isClose = true;
    
else
    
    isClose=false;
    
end



end

