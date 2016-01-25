function [  unused_cores, pairing_matrix, FA, Undetected, Detected] = PairProcess( SamplesGT , SamplesExperiment, threshold )
%EVALUATION: known a list of monuments we will compare the proximity of the
%cluster cores to this monuments



%%% PARAMETERS



%   Detailed explanation goes here

% PLOT in 3 diferent colours:
%     Green: Optimal estimation
%     Orange/Yellow: Suboptimal estimation
%     Red: This core does not have a proper estimation

% 1_ In meter find which cluster is closer

NExpSamples = sum(SamplesExperiment(:,1)~=0); % number of cores
NSamplesGT = sum(SamplesGT(:,1)~=0);  % number of interest points in the city:

% this matrix represent:
%     Pairing_matrix(1), pairing_matrix(2) coordinatesXY of the core
%     Pairing_matrix(3), pairing_matrix(4) coordinatesXY of the associated
%     monument
%     pairing_matrix(5) distance between both points
%     pairing_matrix(6) asociated monument from a numered list

pairing_matrix = zeros(NExpSamples,4);

% minDist2Sample = threshold;
% distance = 0;  % value outside the threshold
selected_Sample = 0;  % This Variable will be 0 if the method 

% PROBLEM: we might pair a node with  when another could be
% closer to that GT location 


%%%%%%%%%%%%%%%%%% Creating a Matrix to ease the evaluation  %%%%%%%%%%%%%%%%%%

for i = 1:NExpSamples % evalueate all cores 
   minDist2Sample = threshold;  % reset distance for each new core
   selected_Sample = 0;
   pairing_matrix(i,1) = SamplesExperiment(i,2); % ID of samples
   pairing_matrix(i,2) = SamplesGT(i,2);
   
    for j = 1:NSamplesGT % compare to all monuments 
        dx = SamplesGT(j,3) - SamplesExperiment(i,3); 
        dy = SamplesGT(j,4) - SamplesExperiment(i,4);
        distance = abs((dx^2 + dy^2).^(1/2)); % modulus
        
        if ((distance < minDist2Sample) && (distance < threshold))  % if is closer than any other previous
            minDist2Sample = distance;
            selected_Sample = j;  
            pairing_matrix(i,3) = minDist2Sample; % Distance
%             pairing_matrix(i,4) = SamplesGT(j,2);
%             pairing_matrix(i,5) = minDist2Sample; % register minimun distance
%             pairing_matrix(i,6) = selected_Sample;
            pairing_matrix(i,4) = selected_Sample;
            
        end
    end  % END monument search
    
%      At this point we have j registers made 
%      Right now more than 1 monument can be assigned to the same monument   
%      Now we have selected the minimal distance posible for that monument



    
  
    
end    





%%%%%%%%%%%%%%%%%%%%%  Exporting Unidentified Cores %%%%%%%%%%%%%%%%%%%%%
% Matrix is now completed

%we create a 2 by n_unasigned for the unasined cores
%run and see if we can delete c and v
[r] = find(pairing_matrix(:,4)==0);
n_unasigned = size (r,1);
unused_cores = zeros(n_unasigned,2);

for k=1:1:n_unasigned
    
    %security check
    if ((pairing_matrix(r(k),3) == 0) && (pairing_matrix(r(k),4) == 0))
    unused_cores(k,1) = SamplesExperiment(r(k),3);
    unused_cores(k,2) = SamplesExperiment(r(k),4);
    end

end

% [n] = find(pairing_matrix(:,1)~=0);
asignated = size(pairing_matrix,1)-n_unasigned;
FA = n_unasigned;
Undetected = NSamplesGT- asignated;
Detected = asignated;
%%%%%%%%%%%%%%%%%%%%%  Final valoration  %%%%%%%%%%%%%%%%%%%%%
        
% Apply modifications to de result here

% The max puntuation will be achived depending on the number of mnuments
% identified
% NOTES: if the value is over 100 mean that we are assigning more m


% 
% 
% % 5_ Print in a document 
% 
% 
% fid = fopen('./evaluation.txt','wt'); 
% fprintf(fid,'%4s %8i \n\n','valoration:  ',valoration);
% fprintf(fid,'%4s %8s %16s %16s %16s %16s %16s\n','num','coreX','coreY','monuX','monuY','distance','Monument');
% for i = 1:NExpSamples
%     fprintf(fid,'%d :   %f        %f       %f      %f      %f      %f\n',i,pairing_matrix(i,:));
%     % fprintf(fid,'%f\n',cores_COOR(i,2));  % The format string is applied to each element of a
% 
% end
% fclose(fid);
% 
% 
% 
% fid = fopen('monument_asignation.txt','wt'); 
%     fprintf(fid,'%4s %8s %16s  %16s \n','num','monuX','monuY','Nºcores asignated');
% 
%     n_asignated = zeros(NSamplesGT,1);
% for i=1:NSamplesGT
%     n_asignated(i) = size(find(pairing_matrix(:,6)==i),1);
%     fprintf(fid,'%d :   %f        %f       %f   \n',i,SamplesGT(i,1),SamplesGT(i,2),n_asignated);
%     
% end
% fclose(fid);
% % 
% % fid = fopen('./monument_asignation.txt','wt'); 
% % fprintf(fid,'%4s %8i \n\n','valoration:  ',valoration);
% % fprintf(fid,'%4s %8s %16s %16s %16s %16s %16s\n','num','coreX','coreY','monuX','monuY','distance','Monument');
% % for i = 1:NExpSamples
% %     fprintf(fid,'%d :   %f        %f       %f      %f      %f      %f\n',i,pairing_matrix(i,:));
% %     % fprintf(fid,'%f\n',cores_COOR(i,2));  % The format string is applied to each element of a
% % 
% % end
% % fclose(fid);



end