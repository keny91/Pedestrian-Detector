function [ isClose ] = DistanceToPreviousFrame( position, previousPosition ,th)
%DistanceToPreviousFrame:  Summary of this function goes here
%   Detailed explanation goes here


dist = previousPosition - position;
distMod =  sqrt(dist(1).^2+dist(2).^2);


if(distMod < th)
    isClose = true;
    
else
    
    isClose=false;
    
end



end

