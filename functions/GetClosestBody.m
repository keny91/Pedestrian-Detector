function [ isClose , elementID] = GetClosestBody( listPositions, previousPosition ,th)
%DistanceToPreviousFrame:  Summary of this function goes here
%   Detailed explanation goes here

listSize=size(listPositions,1);
minDist = 10000;




for index =1:1:listSize
    dist = previousPosition - listPositions(index,:);
    distMod =  sqrt(dist(1).^2+dist(2).^2);
    if (minDist>distMod)
        minDist = distMod;
        elementID = index;        
    end
end


if(minDist < th)
    isClose = true;
    
else
    isClose=false;
    elementID = -1;
    
end



end

