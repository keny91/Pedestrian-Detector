function [ boolean, elementID ] = CheckIfPresent( element, list )
%CHECKIFPRESENT Summary of this function goes here
%   Detailed explanation goes here
    elementID = -1;
    boolean = false;
    Nelements = size(list,1);
    
    for ia=1:1:Nelements
       step = round(element.FramesOutOfScene / 15); % same step as refresh trayectory
       if(DistanceToExpectedPoint(element.PreviousPosition , list(ia), element.Trayectory, 50, step))
           boolean= true;
           elementID = ia;
           break;
       end
        
        
    end




end

