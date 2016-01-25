
addpath('.\data');
addpath('.\functions');


%% PARAMETERS
%  Load the video
video = VideoReader('./TownCentreXVID.avi');

peopleDetector = vision.PeopleDetector;
% Set up detector
peopleDetector.ClassificationThreshold = 0.7; % Change sensibility
currentID = 1;
MAXFramesOutOfScene = 200;
FramesRefreshTrayectory = 15;
thFrametoFrame = 30;



% ld = load(scaleDataFile, 'pedScaleTable');
% pedScaleTable = ld.pedScaleTable;


nframes = video.NumberOfFrames;
firstFrameAnalysis = true; %first time execution

activeBodies = []; % Those that are considered to be in scene even if they are not visible
inSceneBodies = []; % Those detected bodies that are now in scene


fid = fopen('./Logs/log2.txt','wt');  % OPEN writting log

%% FRAME DATA EXTRACTION

% [bboxes,scores] = step(peopleDetector,frame);




for theFrame=1:1:nframes
% for theFrame=1:1:nframes
%     Get data from frame


    frame =  read(video,theFrame);
    [centroids, bboxes, scores] = detectPeople(frame, 1,peopleDetector);   %% HERE WE USE THE BODY DETECTORS
    frameWidth = size(frame,2);
    frameHeight = size(frame,1);
    
    maxBodiesInScene= size(centroids,1);
    

    NdetectedBodies = size(centroids,1);
    if(firstFrameAnalysis)  % First execution just to speed up the process
        for i=1:1:NdetectedBodies

        %     it´s a new body in the scene -> Create instanc
            ObjectBody.ID = currentID;
            currentID=currentID+1;
            ObjectBody.Color = RandomColor();
            ObjectBody.Position = centroids(i,:);
            ObjectBody.Trayectory = [0 0];
            ObjectBody.PreviousPosition = ObjectBody.Position;
            ObjectBody.Score = scores(i);
            ObjectBody.previousRefreshPosition = ObjectBody.Position;
            ObjectBody.FramesOutOfScene = 0;
            ObjectBody.FramesWithoutRefresh = ObjectBody.Position;
            ObjectBody.Checked = 0;

%             The first time all detected bodies are considered as 
            activeBodies = [activeBodies ObjectBody];
            inSceneBodies = [inSceneBodies ObjectBody];
            
            
            
%             frame = insertObjectAnnotation(frame,'rectangle',bboxes(i,:),scores(i),'Color',ObjectBody.Color); % to see the sensibility of the decisor

        end
        
        firstFrameAnalysis = false;
        
        
   
      
%       else (firstFrameAnalysis == false)  
    else   % Case 2 a node already exists
        
        
%           3 POSIBILITIES

%             2.1  NEW BODY

%             2.2  BODY ASSIGNED TO PREVIOUS ELEMENT IN THE LIST

%             2.3  BODY NOT FOUND 

%               2.3.1 OCCLUSION CASE? we are still looking for it in the next frames

%               2.3.2 BODY DISCARDED, no longer on the list
        
        

        NdetectedBodies = size(centroids,1);
        NActiveBodies = size(activeBodies,2);
        NSceneBodies = size(inSceneBodies,2);

        % try to pair a previous object with a body detected in the actual
        % frame

        FoundCounter = 0;
        for SceneBody = 1:1:NSceneBodies
        % Analyze each detected body
            found=false;
%             NdetectedBodies = size(centroids,1);
            [found, id] = GetClosestBody( centroids, inSceneBodies(SceneBody).PreviousPosition ,thFrametoFrame);
            if (found)
                
                inSceneBodies(SceneBody).Checked = 1;
                inSceneBodies(SceneBody).PreviousPosition =  inSceneBodies(SceneBody).Position; % get old position
                inSceneBodies(SceneBody).Position = centroids(id,:); % set new position
                inSceneBodies(SceneBody).FramesWithoutRefresh = inSceneBodies(SceneBody).FramesWithoutRefresh + 1;
                inSceneBodies(SceneBody).FramesOutOfScene = 0;
                centroids(id,:) = [];  % no longer valid for election

%                 foundPrevious =1    debug

                    % refresf process
                if (inSceneBodies(SceneBody).FramesWithoutRefresh > FramesRefreshTrayectory)
                     inSceneBodies(SceneBody).Trayectory = FindTrayectoryLineal(inSceneBodies(SceneBody).previousRefreshPosition,inSceneBodies(SceneBody).Position);
                     inSceneBodies(SceneBody).previousRefreshPosition = inSceneBodies(SceneBody).Position;
                     inSceneBodies(SceneBody).FramesWithoutRefresh = 0;
                end
                    
        
            end
%             for nBody = 1:1: NdetectedBodies
% %                 traker = nBody - FoundCounter; 
%                   traker = nBody; 
%                 if (DistanceToPreviousFrame( centroids(traker,:), inSceneBodies(SceneBody).PreviousPosition ,thFrametoFrame))
%                     inSceneBodies(SceneBody).Checked = 1;
%                     inSceneBodies(SceneBody).PreviousPosition =  inSceneBodies(SceneBody).Position; % get old position
%                     inSceneBodies(SceneBody).Position = centroids(traker,:); % set new position
%                     inSceneBodies(SceneBody).FramesWithoutRefresh = inSceneBodies(SceneBody).FramesWithoutRefresh + 1;
%                     inSceneBodies(SceneBody).FramesOutOfScene = 0;
%                     centroids(traker,:) = [];  % no longer valid for election
%                     FoundCounter = FoundCounter +1;
% 
%                     % refresf process
%                     if (inSceneBodies(SceneBody).FramesWithoutRefresh > FramesRefreshTrayectory)
%     %                     inSceneBodies(SceneBody).Trayectory = getTrayectory();
%                           inSceneBodies(SceneBody).previousRefreshPosition = inSceneBodies(SceneBody).Position;
%                           inSceneBodies(SceneBody).FramesWithoutRefresh = 0;
%                     end
%                     brokeStatementSearchBodies = 1
%                     break;
% 
%                 end
%                 
%             end    
        end
        
%         Those unchecked will be transfered to another list

        FoundCounter = 0;
        for SceneBody = 1:1:NSceneBodies
            traker = SceneBody - FoundCounter;
            if(inSceneBodies(traker).Checked == 0)
                found =false;
                position= -1;
                [ position, found ] = FindID( activeBodies ,inSceneBodies(traker).ID );
                if (found)
%                     DO NOTHING, is already there                   
                else    
                    activeBodies = [activeBodies inSceneBodies(traker)]; 
                end
                inSceneBodies(traker) = [];
                FoundCounter = FoundCounter +1;
            end
            
        end

        
        
        
                    
%         Only work with the remaining unpaired centroids         
%         Check if still active            
             
        



        FoundCounter = 0;
        NActiveBodies = size(activeBodies,2);
           
                % MIRAR LA LISTA ANTERIOR Y VER POR ID CUALES ESTAN
                % PRESENTES EN ESTA TB -> ++ FRAMES
                for nBody = 1:1: NActiveBodies
                    
                    found =false;
                    traker = nBody - FoundCounter;
                    [ found, elementID ] =CheckIfPresent(activeBodies(traker),centroids);
                       if(found)
                           activeBodies(traker).FramesOutOfScene = 0;
%                            activeBodies = [activeBodies inSceneBodies(traker)];
                           activeBodies(traker).previousRefreshPosition = centroids(elementID,:);
                           activeBodies(traker).Position = centroids(elementID,:);
                           activeBodies(traker).FramesOutOfScene = 0;
                           activeBodies(traker).FramesWithoutRefresh = 0;
                           centroids(elementID,:)= [];
%                            FoundCounter=FoundCounter+1;
                           inSceneBodies = [inSceneBodies activeBodies(traker)];
                       
                       else
                           % increase frames without appeaing if not
                           % detected
                           activeBodies(traker).FramesOutOfScene = activeBodies(traker).FramesOutOfScene + 1;
                           %  discard if above the limit 
                           if (activeBodies(traker).FramesOutOfScene>=MAXFramesOutOfScene)
                               activeBodies(traker) = [];
                               FoundCounter = FoundCounter +1;
                           end
                           
                       end
                end
            
                % LOS QUE VUELVEN A ESTAR PRESENTES -> NO ESTAN HEMOS
                % CREADO AUN NUEVOS NODOS -> COMPROBAMOS QUE LOS NO
                % EMPAREJADOS PUEDEN PERTENECER A OTRA COSA
                % 
                
                
                    % LOS QUE NO ESTEN PRESENTES EN ESTA Y EXISTIERAN EN LA
                    % LISTA COMIENZA LA CUENTA ATRAS PARA ELLOS
                    
                    %  ELIMINAR LOS QUE LLEGUEN A X FRAMES
                    
                    %añadir los de la escena a la lista
                    
                    
%                  % FOR THOSE WHICH REMAIN
% 
%                     ObjectBody.ID = currentID;
%                     currentID=currentID+1;
%                     ObjectBody.Color = RandomColor();
%                     ObjectBody.Position = centroids(nBody,:);
%                     ObjectBody.Trayectory = [0 0];
%                     ObjectBody.PreviousPosition = [0 0];
%                     ObjectBody.Score = Scores(nBody);
%                     ObjectBody.previousRefreshPosition = [0 0];
%                     ObjectBody.FramesOutOfScene = 0;
%                     ObjectBody.FramesWithoutRefresh = 0;
%                     ObjectBody.Checked = 0;
% 
%                     inSceneBodies = [inSceneBodies ObjectBody];
%     %                 activeBodies = [activeBodies ObjectBody];
%     
%     

        NdetectedBodies = size(centroids,1);
        for nBody = 1:1: NdetectedBodies

            ObjectBody.ID = currentID;
                    currentID=currentID+1;
                    ObjectBody.Color = RandomColor();
                    ObjectBody.Position = centroids(nBody,:);
                    ObjectBody.Trayectory = [0 0];
                    ObjectBody.PreviousPosition = [0 0];
                    ObjectBody.Score = scores(nBody);
                    ObjectBody.previousRefreshPosition = ObjectBody.Position;
                    ObjectBody.FramesOutOfScene = 0;
                    ObjectBody.FramesWithoutRefresh = 0;
                    ObjectBody.Checked = 0;

                    inSceneBodies = [inSceneBodies ObjectBody];
                    activeBodies = [activeBodies ObjectBody];
        end

        




    end


    
% 
%         NdetectedBodies = size(inSceneBodies,2);
%         for nBody = 1:1: NdetectedBodies
%             
%             frame = paintCircle(ObjectBody.Position, frame, ObjectBody.Color);
%             frame = insertObjectAnnotation(frame,'rectangle',bboxes(nBody,:),inSceneBodies(nBody).ID,'Color',inSceneBodies(nBody).Color);
%             fprintf(fid,'%s   %f,%f,%f\n',theFrame,inSceneBodies(i).ID, inSceneBodies(i).Position(1) ,inSceneBodies(i).Position(2));  % results to log
%         end  
%     
%         
%         
        NdetectedBodies = size(inSceneBodies,2);
        for nBody = 1:1: NdetectedBodies
%             inSceneBodies(nBody).Checked = 0;  % reset check
%             frame = paintCircle(ObjectBody.Position, frame, ObjectBody.Color);
%             frame = paintCircle(ObjectBody.Position+ObjectBody.Trayectory/1, frame, ObjectBody.Color);
%             frame = paintCircle(ObjectBody.Position+ObjectBody.Trayectory/2, frame, ObjectBody.Color);
%             frame = paintCircle(ObjectBody.Position+ObjectBody.Trayectory/3, frame, ObjectBody.Color);
%             frame = paintCircle(ObjectBody.Position+ObjectBody.Trayectory/4, frame, ObjectBody.Color);
%             frame = insertObjectAnnotation(frame,'rectangle',bboxes(nBody,:),inSceneBodies(nBody).ID,'Color',inSceneBodies(nBody).Color);
%             fprintf(fid,'%d,%d,%f,%f\n',theFrame,inSceneBodies(nBody).ID, inSceneBodies(nBody).Position(1) ,inSceneBodies(nBody).Position(2));  % results to log
%         end  
            inSceneBodies(nBody).Checked = 0;  % reset check
            frame = paintCircle(inSceneBodies(nBody).Position, frame, inSceneBodies(nBody).Color);
            frame = paintCircle(inSceneBodies(nBody).Position+inSceneBodies(nBody).Trayectory/1, frame, inSceneBodies(nBody).Color);
            frame = paintCircle(inSceneBodies(nBody).Position+inSceneBodies(nBody).Trayectory/2, frame, inSceneBodies(nBody).Color);
            frame = paintCircle(inSceneBodies(nBody).Position+(inSceneBodies(nBody).Trayectory/3)*2, frame, inSceneBodies(nBody).Color);
            frame = paintCircle(inSceneBodies(nBody).Position+inSceneBodies(nBody).Trayectory/4, frame, inSceneBodies(nBody).Color);
            frame = insertObjectAnnotation(frame,'rectangle',bboxes(nBody,:),inSceneBodies(nBody).ID,'Color',inSceneBodies(nBody).Color);
            fprintf(fid,'%d,%d,%f,%f\n',theFrame,inSceneBodies(nBody).ID, inSceneBodies(nBody).Position(1) ,inSceneBodies(nBody).Position(2));  % results to log
        end 
        
        if(theFrame == 25 || theFrame == 30 || theFrame == 35)
            figure('Name',strcat('Frame ', num2str(theFrame)) ,'NumberTitle','off')
            imshow(frame);
        end
    
    
    
end
       


fclose(fid);  % close writting log
