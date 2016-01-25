function [ frame ] = paintCircle( position, frame, color)
%PAINTCIRCLE Summary of this function goes here
%   Detailed explanation goes here

    Fradius = 5;
%     pos = [position(1) position(2) 2 2];
    
    shapeInserter = vision.ShapeInserter('Shape','Circles','Fill',true,'FillColor','Custom','CustomFillColor',color);
    circle = int32([position Fradius]);
    
    frame = step(shapeInserter, frame, circle);
end

