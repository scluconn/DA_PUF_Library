
%**************************************************************************
% This script generates binary responses from raw decimal responses.
%**************************************************************************

clear all;
clc;
%**************************************************************************

iDir = [pwd '/dataset/output/'];
oDir = [pwd '/dataset/processedOutput/'];
mkdir dataset processedOutput

N = 64;
K = 9;  %Number of bits for storing individual responses and overall response
M = K-1;
nMeas = 11;
Br = 2;
APUF = 1; %APUF = 1, when APUFs are evaluated


rawRespFile = [iDir 'resp_' num2str(N) '_' num2str(nMeas) '_meas_Br_' num2str(Br) '_all.mat'];
respAFile = [oDir 'respA_' num2str(N) '_' num2str(nMeas) '_meas_Br_' num2str(Br) '_all.mat'];
respAgFile = [oDir 'respAg_' num2str(N) '_Br_' num2str(Br) '_all.mat'];
respLFile = [oDir 'respL_' num2str(N) '_' num2str(nMeas) '_meas_Br_' num2str(Br) '_all.mat'];
respLgFile = [oDir 'respLg_' num2str(N) '_Br_' num2str(Br) '_all.mat'];

load(rawRespFile);

nChal = size(resp,1);    % No. of challenges

%**************************************************************************
% For APUF 
%**************************************************************************

if (APUF == 1)
    A = zeros(nChal,K,nMeas);    % Binary responses
    Ag = zeros(nChal,K);         % Golden responses
    for i=1:nMeas
        resp_i = resp(:,1:2,i);
        A(:,:,i) = arrayToBinVec_a(resp_i,[ K-1 1]);
    end

    % Golden responses
    for i=1:K
        A_i = A(:,i,:); 
        A_i = permute(A_i,[1 3 2]);
        Ag(:,i) = mode(A_i,2);
    end
    clear A_i;

    % Save all processed CRPs
    save(respAFile,'A');     % APUF responses over nMeas measurements
    save(respAgFile,'Ag');   % APUF golden response
end

%**************************************************************************
% For LSPUF 
%**************************************************************************

if (APUF == 0)
    R = zeros(nChal,M,nMeas);    % Binary responses
    Rg = zeros(nChal,M);         % Golden responses
    for i=1:nMeas
        resp_i = resp(:,3:4,i);
        R(:,:,i) = arrayToBinVec_a(resp_i,[ 1 8]);
    end


    % Golden responses
    for i=1:M
        R_i = R(:,i,:); 
        R_i = permute(R_i,[1 3 2]);
        Rg(:,i) = mode(R_i,2);
    end
    
    %Save all processed CRPS
    save(respLFile,'R');     % LSPUF responses over nMeas measurements
    save(respLgFile,'Rg');   % LSPUF golden response
end


fprintf('\nDONE!!!\n');