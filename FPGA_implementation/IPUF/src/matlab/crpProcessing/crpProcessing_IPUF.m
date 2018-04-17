
%**************************************************************************
% This script generates binary responses from raw decimal responses.
%**************************************************************************

clear all;
clc;
%**************************************************************************

iDir = [pwd '/dataset/output/'];
mkdir dataset processedOutput
oDir = [pwd '/dataset/processedOutput/'];

N = 64;
K = 7;  %Number of bits for storing individual responses and overall response
M = K-1;
nMeas = 1;
Br = 1;
APUF = 1; %APUF = 1, when APUFs are evaluated
convert_xor = 0; %set to 1 to convert 23 XOR PUF into x XOR PUF,where x < 23
nXORPUF = 2; %if convert_xor is set to 1, nXORPUF is the number of APUF in one x XOR PUF

xor_y = 0; %set to 1 to conver a (20,3) IPUF to a (20, 2) IPUF, and output the final output in Av
k1 = 21;
k2 = 22;

rawRespFile = [iDir 'resp_' num2str(N) '_' num2str(nMeas) '_meas_Br_' num2str(Br) '_all.mat'];
respAFile = [oDir 'respA_' num2str(N) '_' num2str(nMeas) '_meas_Br_' num2str(Br) '_all.mat'];
respAgFile = [oDir 'respAg_' num2str(N) '_Br_' num2str(Br) '_all.mat'];
respLFile = [oDir 'respL_' num2str(N) '_' num2str(nMeas) '_meas_Br_' num2str(Br) '_all.mat'];
respLgFile = [oDir 'respLg_' num2str(N) '_Br_' num2str(Br) '_all.mat'];
respAvFile = [oDir 'respAv_' num2str(N) '_' num2str(nMeas) '_meas_Br_' num2str(Br) '_all.mat'];

load(rawRespFile);

nChal = size(resp,1);    % No. of challenges


%**************************************************************************
% For APUF 
%**************************************************************************

if (APUF == 1)
    A = zeros(nChal,K,nMeas);    % Binary responses
    Ag = zeros(nChal,K);         % Golden responses
    Av = zeros(nChal, 1, nMeas); % Virtual respons, XORed in this program
    
    for i=1:nMeas
        %resp_i = resp(:,3:4,i);
        %resp_i(:,1) = resp_i(:,1) + 256 * resp(:,2,i) + 256*256*resp(:,1,i);
        %A(:,:,i) = arrayToBinVec_a(resp_i,[ K-1 1]);
        A(:,:,i) = arrayToBinVec_a(resp(:,:,i),[ K-1 1]);
    end
    
    % Golden responses
    for i=1:K
        A_i = A(:,i,:); 
        A_i = permute(A_i,[1 3 2]);
        Ag(:,i) = mode(A_i,2);
    end
    clear A_i;

    if (convert_xor == 1)
        A(:,1:nXORPUF,:) = A(:,21:20+nXORPUF,:);
        A(:,nXORPUF+1,:) = zeros(nChal,1,nMeas);
        for i = 1:nXORPUF
            A(:,nXORPUF+1,:) = mod(A(:,nXORPUF+1,:) + A(:,i,:), 2);
        end
    end     
    
    if (xor_y == 1)
        for i = k1:k2
            Av(:,1,:) = mod(Av(:,1,:) + A(:,i,:),2);
        end
        save(respAvFile,'Av');     % Save Virtual APUF responses over nMeas measurements
    end
    
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