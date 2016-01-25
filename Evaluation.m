addpath('.\data');
addpath('.\functions');

fid1 = fopen('./Logs/log.txt','r');  % OPEN writting log
fid2 = fopen('./Logs/TownCentre-groundtruth.top','r');  % OPEN GT

% ALLOCATE FOR SPEED
tableLog = zeros(40,4);
tableGT = zeros(40,4);
FrameCount =0;
TH = 100;
LogLineCount= 0;
ElementCount = 0;
% for Experiment log frameCount + 1
% for GT log frameCount
LogLineCountGT = 0;
ElementCountGT = 0;

% [Line , endDoc] = GetNextLineLog( fid1 )
% tline = fgets(fid1);
% while ischar(tline)


% Evaluation date
totalSamples = 0;
totalGTSamples = 0;
ExperimentMatches = 0;
FalseAlarms = 0;
Undetecteds = 0;




% First call of frames
[LineGT , endDocGT] = GetNextLineLogGT( fid2 );
LogLineCountGT = LogLineCountGT +1;
[Line , endDoc] = GetNextLineLog( fid1 );
LogLineCount = LogLineCount +1;


while (1)



%     We recover every data available in the frame
%      Our Experiment´s Log

    ElementCount = 0;
    while (endDoc~=1 && Line{1} == FrameCount+ 1)
    
        totalSamples = totalSamples+1;
        ElementCount = ElementCount+1;
        tableLog(ElementCount,1)= Line{1};  % Frame Number
        tableLog(ElementCount,2)= Line{2};  % ID
        tableLog(ElementCount,3)= Line{3};  % X position
        tableLog(ElementCount,4)= Line{4};  % Y position
        
        [Line , endDoc] = GetNextLineLog( fid1 );
        LogLineCount = LogLineCount +1;
        
    end   
    
    %      GT Log
    ElementCountGT = 0;
    while (endDocGT~=1  && LineGT{2} == FrameCount)
    
        totalGTSamples = totalGTSamples +1;
        ElementCountGT = ElementCountGT+1;
        tableGT(ElementCountGT,1)= LineGT{2} +1; % Frame Number +1
        tableGT(ElementCountGT,2)= LineGT{1}; % ID
        
        XBodyMean = (LineGT{9} + LineGT{11})/2;
        tableGT(ElementCountGT,3)= XBodyMean;   % X position
        YBodyMean = (LineGT{10} + LineGT{12})/2;
        tableGT(ElementCountGT,4)= YBodyMean; % y position
        
        [LineGT , endDocGT] = GetNextLineLogGT( fid2 );
        LogLineCountGT = LogLineCountGT +1;
        
    end   
    
    if(endDocGT)
        break;
    end
%        Comparative tables have been created




         % if not-> we start the evaluation of the frame
     
        [ unused_cores, pairing_matrix, FA, Undetected, Detected] = PairProcess( tableGT , tableLog, TH);
%         Overall GT samples
          NGTSamples = sum(tableGT(:,1)~=0);
          totalGTSamples = totalGTSamples + NGTSamples;
%         Expected Samples
          NSamples = sum(tableLog(:,1)~=0);
          totalSamples = totalSamples + NSamples;
          
%         Which ones are found properly

%         FA
          FalseAlarms = FalseAlarms + FA;
          
%         Undetected Cases
          Undetecteds = Undetecteds + Undetected;
          
          Undetected = 0;
          FA = 0;
%         reset tables and line markers

          FrameCount =FrameCount+ 1;
            tableLog = zeros(40,4);
            tableGT = zeros(40,4);
          
%           break;
end



[ F ,recall , precision] = F_value( totalSamples, FalseAlarms, totalGTSamples , Undetecteds )












fclose(fid1);  % close writting log
fclose(fid2);  % close writting log