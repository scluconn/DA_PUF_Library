
% reliability analysis

clear all;
clc;

iDir = [pwd '/dataset/processedOutput/'];

N  = 64;
Br = 2;
nPUF = 8;
nMeas = 11;
tested_PUF = nPUF + 1; %nPUF + 1 means the overal reliability
%tested_PUF = 5; %tested PUF number
%tested_PUF = nPUF;
virtual_PUF = 0; %set to 1 to analyze virtual PUF

respFile = [iDir 'respA_' num2str(N) '_' num2str(nMeas) '_meas_Br_' num2str(Br) '_all.mat'];
respvFile = [iDir 'respAv_' num2str(N) '_' num2str(nMeas) '_meas_Br_' num2str(Br) '_all.mat'];

if (virtual_PUF == 0)
    load(respFile);
else
    load(respvFile);
    A = Av;
end

nChal = size(A,1);
%nChal = 5000;

reliability_array = zeros(nPUF+1,1);

for j = 1:nPUF+1
    misMatch = 0;
    for k = 1:nChal
        A_i = sum(A(k,j,1:nMeas));
        if A_i ~= 0 & A_i ~= nMeas
           misMatch = misMatch + 1;
        end
    end
    misMatch = misMatch/nChal;
    reliability_array(j) = misMatch;
    fprintf('PUF %i: %f \n', j, misMatch);    
end

new_reliability_array = sort(reliability_array);
diff_reliability = zeros(nPUF,1);

for i = 1:nPUF
    diff_reliability(i) = new_reliability_array(i+1) - new_reliability_array(i);
end

min(diff_reliability)

fprintf('\nDONE !!!\n');
%exit;