
% uniformity analysis

clear all;
clc;

iDir = [pwd '/dataset/processedOutput/'];

N  = 64;
Br = 1;
nPUF = 2;
offset = 0;
    
golden_respFile = [iDir 'respAg_' num2str(N) '_Br_' num2str(Br) '_all.mat'];
load(golden_respFile);
nChal = size(Ag,1);

for i = 1:nPUF+1    
    ones = sum(Ag(:,i))/nChal;
    fprintf('PUF %i, %f \n', i+offset, ones);
end

fprintf('\nDONE !!!\n');
%exit;