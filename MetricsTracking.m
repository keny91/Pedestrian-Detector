

addpath('.\data');
addpath('.\functions');



selectedID = input('Select the ID of the GT person you would like to track\n','s');
selectedID = str2num(selectedID);

FrameNumber=0;
allFramesCollected = 0;
FirstFrameFound = 0;
FramesWithoutClue = 0;
% ActualFrame = -1;
FrameLimit = 100;
endDocGT = 0;
endDoc = 0;
ActualFrame = 0;
firstFrame = 0;
startingFrame = -1;
GTPositionInFrame=[];
PairThreshold = 40;

% initialize evaluation parameters
unpairedGTsamples = 0;
diffIDPaired = 0;

fid2 = fopen('./Logs/TownCentre-groundtruth.top','r');  % OPEN GT
   
while(~allFramesCollected && ~endDocGT)
     
    [LineGT , endDocGT] = GetNextLineLogGT( fid2 );
    
    
        if(LineGT{1} == selectedID) % ID
            
            XBodyMean = (LineGT{9} + LineGT{11})/2;
            YBodyMean = (LineGT{10} + LineGT{12})/2;
            if (FirstFrameFound == 0)
                startingFrame = LineGT{2};
                FirstFrameFound = 1;
                GTPositionInFrame = [XBodyMean YBodyMean];
                
%                 GTPositionInFrame= [GTPositionInFrame(:) [XBodyMean YBodyMean] ]

            else
                
                GTPositionInFrame= [GTPositionInFrame; [XBodyMean YBodyMean]];
            end    
             ActualFrame = LineGT{2}; 
             FramesWithoutClue = 0;
             
%              GTPositionInFrame= [GTPositionInFrame(1,:) [XBodyMean YBodyMean]];
             
               xlabel('Xpixels');
               ylabel('Ypixels');
%                Zlabel('Frames');
               scatter3(XBodyMean,YBodyMean,LineGT{2},3,[0 0 0.5]); 
               % if you need the drawn points to remain visible,
               % otherwise remove:
               hold on ;
%                pause ;
            
               endFrame = LineGT{2};
               
        else
            if(LineGT{2}~= ActualFrame && FirstFrameFound == 1) % if we are now in a different frame
                
                FramesWithoutClue = FramesWithoutClue+1;
                ActualFrame = LineGT{2};
                
                if(FramesWithoutClue>FrameLimit)
                    allFramesCollected =1;
                end
            end
        end
        
        
        
%         Get the next line
end


if (FirstFrameFound == 0)
    disp('ID NOT FOUND');
end



fclose(fid2);  % close writting log


   
    startingFrame
    endFrame

    

    ActualFrame = -1;
    endDoc = 0;
    ReachedPoint = 0;
    table = [];
    pairing_matrix = zeros(size(GTPositionInFrame,1),4);
    
fid1 = fopen('./Logs/log.txt','r');  % OPEN writting log
endDoc
    while (endDoc == 0)
        if(ReachedPoint==0)
            [Line , endDoc] = GetNextLineLog( fid1 );
            endDoc
        end
        
        
        if (Line{1} == startingFrame +1) % there is a difference of +1 frame86
             
            ReachedPoint = 1;
            ActualFrame = Line{1};      
        end
        
        if(ReachedPoint)
            
%             While we remain in the same frame, we store every position
%             information
            while(ActualFrame == Line{1})
                table = [table ; [Line{3} Line{4} Line{2}]];
                [Line , endDoc] = GetNextLineLog( fid1 );
            end
            
%            All experiment samples have been extracted
             RelativeFrame = ActualFrame - startingFrame;
             NSamples = size(table,1);
             minDist2Sample = 10000;
             
             % Compare all elements
              for j = 1:NSamples
                dx = table(j,1) - GTPositionInFrame(RelativeFrame,1); 
                dy = table(j,2) - GTPositionInFrame(RelativeFrame,2);
                dx = double(dx);
                dy = double(dy);
                 distance = abs(((dx^2) + (dy^2)).^(1/2)); % modulus
% 
                if ((distance < minDist2Sample) && (distance < PairThreshold))  % if is closer than any other previous
                    minDist2Sample = distance;
                    selected_Sample = j;  
                    pairing_matrix(RelativeFrame,1) = table(j,1); % X
                    pairing_matrix(RelativeFrame,2) = table(j,2); % Y
                    pairing_matrix(RelativeFrame,3) = table(j,3); % ID 
                    pairing_matrix(RelativeFrame,4) = distance; % distance


                end
% %             end  % END monument search 
% 
              end
              
              
              % OPTIONAL PLOT
                scatter3(pairing_matrix(RelativeFrame,1),pairing_matrix(RelativeFrame,2),ActualFrame,3,[0.5 0 0]);
                hold on ;
                
                
%               COunt if unpaired
              if(minDist2Sample == 10000)
                  unpairedGTsamples = unpairedGTsamples+1;
              end
              
              
              % skip to next frame analysis
              
              ActualFrame = ActualFrame +1;
        end
        
        
        
        
        % check if we are done with the analysis
        if(ActualFrame > endFrame +1)
                 
                  break;
        end
    
    end
        
            

%                 find closer point
%                 pick its ID
%                 EXTRACT : 1 NUMBER OF POINTS WHERE THERE IS NO
%                 EQUIVALENCE
%                 2: MATRIX OF EACH DISTANCE
%                 3: 


fclose(fid1);  % close writting log
%  count different IDs
 y = sort(pairing_matrix(:,3));
 p = find([true;diff(y)~=0;true]);
 values = y(p(1:end-1));
 DifferentIDs = diff(p);

% unpaired samples 
unpairedGTsamples




              
        
        
  

