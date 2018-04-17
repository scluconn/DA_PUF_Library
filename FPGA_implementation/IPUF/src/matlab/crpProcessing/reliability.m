
% reliability analysis

clear all;
clc;

iDir = [pwd '/dataset/processedOutput/'];

N  = 64;
Br = 1;
nPUF = 6;
nMeas = 5;
tested_PUF = nPUF + 1; %nPUF + 1 means the overal reliability
%tested_PUF = 5; %tested PUF number
%tested_PUF = nPUF;
analyze_av = 0; % set to 1 if we are analyzing a virtual PUF

respFile = [iDir 'respA_' num2str(N) '_' num2str(nMeas) '_meas_Br_' num2str(Br) '_all.mat'];
respAvFile = [iDir 'respAv_' num2str(N) '_' num2str(nMeas) '_meas_Br_' num2str(Br) '_all.mat'];


if analyze_av == 1
    
    load(respFile);
    nChal = size(A,1);

    %nChal = 5000; 

    for j = 1:nPUF+1
        misMatch = 0;
        for k = 1:nChal
            A_i = sum(A(k,j,1:nMeas));
            if A_i ~= 0 & A_i ~= nMeas
                misMatch = misMatch + 1;
            end
        end
        misMatch = misMatch/nChal;
        fprintf('PUF %i: %f \n', j, misMatch);    
    end

    
    load(respAvFile);
    nChal = size(Av,1);
    misMatch = 0;
    for k = 1:nChal
        A_i = sum(Av(k,1,1:nMeas));
        if A_i ~= 0 & A_i ~= nMeas
            misMatch = misMatch + 1;
        end
    end
    misMatch = misMatch/nChal;
    fprintf('Virtual PUF : %f \n', misMatch);    
else

    load(respFile);
    nChal = size(A,1);

    %nChal = 5000; 

    for j = 1:nPUF+1
        misMatch = 0;
        for k = 1:nChal
            A_i = sum(A(k,j,1:nMeas));
            if A_i ~= 0 & A_i ~= nMeas
                misMatch = misMatch + 1;
            end
        end
        misMatch = misMatch/nChal;
        fprintf('PUF %i: %f \n', j, misMatch);    
    end
       
end
    
fprintf('\nDONE !!!\n');
%exit;