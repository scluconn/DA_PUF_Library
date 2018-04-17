
% Compute SAC property 

clear all;
clc;

iDir = [pwd '/dataset/processedOutput/'];


N  = 64;
nBitFlip = 1;
nBaseChal = 500;

nSAC = N - (nBitFlip-1);
SAC = zeros(1,nSAC);

%for i=1:nPUFinst
for i= 7 : 7
    
    respFile = [iDir 'respAg_' num2str(N) '_Br_' num2str(1) '_all.mat'];
    load(respFile);
    resp = Ag;
    clear Ag;
    
    baseResp =  resp(1:nBaseChal,i);
    restResp =  resp(nBaseChal+1:end,i);
    %clear resp;
    
    nRestResp =size(restResp,1); 
    sIndex = 1:nBaseChal:nRestResp;
    eIndex = nBaseChal:nBaseChal:nRestResp;
    
    for j=1:nSAC
      
        r_j = restResp(sIndex(j):eIndex(j),:);
        
        misMatch = sum( baseResp ~= r_j )/nBaseChal;
        SAC(:,nSAC - j+1) = misMatch; 
    end
    
     %AllAPUF{j}.sac = SAC(i,:);
end

save([outDir '/SAC.mat'],'SAC');

fprintf(logFid,'\nSaving Workspace\n');
fprintf('\nSaving Workspace\n');

save([outDir '/ches_2015_apuf_sac_' num2str(N) '_workspace.mat']);

fprintf('\nDONE !!!\n');
fprintf(logFid,'\nDONE !!!\n');



%exit;
