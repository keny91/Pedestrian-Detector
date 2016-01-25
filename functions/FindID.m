function [ position, found ] = FindID( list ,ID )
%FINDID Summary of this function goes here
%   Detailed explanation goes here

    position = -1;
    found = false;
    Nelements = size(list,1);
    
    for i=1:1:Nelements
        if(list(i).ID == ID)
           found= true;
           position = i;
           break;
        end
    end

end

