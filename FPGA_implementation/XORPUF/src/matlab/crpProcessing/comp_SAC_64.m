
% Compute SAC property 

clear all;
clc;

iDir = [pwd '/dataset/processedOutput/'];


N  = 64;
nBitFlip = 2;
nBaseChal = 10;
Br = [4];
nPUFinst = length(Br);

nSAC = N - (nBitFlip-1);
SAC = zeros(nPUFinst,nSAC);

for i=1:nPUFinst
    
    respFile = [iDir 'respLg_' num2str(N) '_Br_' num2str(Br(i)) '_all.mat'];
    load(respFile);
    resp = Rg;
    clear Rg;
    
    baseResp =  resp(1:nBaseChal,i);
    restResp =  resp(nBaseChal+1:end,i);
    %clear resp;
    
    nRestResp =size(restResp,1); 
    sIndex = 1:nBaseChal:nRestResp;
    eIndex = nBaseChal:nBaseChal:nRestResp;
    
    for j=1:nSAC
        
        r_j = restResp(sIndex(j):eIndex(j),:);
        
        misMatch = sum( baseResp ~= r_j )/nBaseChal;
        SAC(:,j) = misMatch; 
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