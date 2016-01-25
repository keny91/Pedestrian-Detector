function [ Line , endDoc] = GetNextLineLogGT( file )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    endDoc = false;
    tline = fgets(file);
    Line= -1;
    if (ischar(tline))
        Line = textscan(tline,'%d %d %d %d %f %f %f %f %f %f %f %f','Delimiter',',','EmptyValue',-Inf);
        
        
    else
        endDoc = true;
    end
    


end

