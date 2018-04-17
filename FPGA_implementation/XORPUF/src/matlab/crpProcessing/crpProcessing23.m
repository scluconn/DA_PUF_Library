
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
K = 24;  %Number of bits for storing individual responses and overall response
M = K-1;
nMeas = 11;
Br = 1;
APUF = 1; %APUF = 1, when APUFs are evaluated
convert_xor = 1; %set to 1 to convert 23 XOR PUF into x XOR PUF,where x < 23
discrete_select = 1; % set to 1 to select APUFs with discrete index to form an XOR PUF, index in select_index_list
select_index_list = [6, 12, 14, 16, 17, 18, 19, 21, 22, 23]; %these APUFs have noise rate around 0.0075
nXOR_selected = 2;
k1 = 1; %if convert_xor is set to 1, it XORs k1 PUF to k2 PUF as one XOR PUF and save it in Av
k2 = 5;

rawRespFile = [iDir 'resp_' num2str(N) '_' num2str(nMeas) '_meas_Br_' num2str(Br) '_all.mat'];
respAFile = [oDir 'respA_' num2str(N) '_' num2str(nMeas) '_meas_Br_' num2str(Br) '_all.mat'];
respAgFile = [oDir 'respAg_' num2str(N) '_Br_' num2str(Br) '_all.mat'];
respLFile = [oDir 'respL_' num2str(N) '_' num2str(nMeas) '_meas_Br_' num2str(Br) '_all.mat'];
respLgFile = [oDir 'respLg_' num2str(N) '_Br_' num2str(Br) '_all.mat'];
respAvFile = [oDir 'respAv_' num2str(N) '_' num2str(nMeas) '_meas_Br_' num2str(Br) '_all.mat'];
respAvgFile = [oDir 'respAvg_' num2str(N) '_Br_' num2str(Br) '_all.mat'];

load(rawRespFile);
nChal = size(resp,1);    % No. of challenges

%**************************************************************************
% For APUF
%**************************************************************************

if (APUF == 1)
    A = zeros(nChal,K,nMeas);    % Binary responses
    Ag = zeros(nChal,K);         % Golden responses
    for i=1:nMeas
        resp_i = resp(:,3:4,i);
        resp_i(:,1) = resp_i(:,1) + 256 * resp(:,2,i) + 256*256*resp(:,1,i);
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
    
    if (convert_xor == 1)
        if (discrete_select == 0)
            new_PUF_size = k2-k1+2;
            Av = zeros(nChal,new_PUF_size,nMeas);    % Binary responses
            Avg = zeros(nChal,new_PUF_size);         % Golden responses
            Av(:,1:new_PUF_size-1,:) = A(:,k1:k2,:);
            for i = 1:nChal
                for j = 1:nMeas
                    Av(i,new_PUF_size,j) = mod(sum(Av(i,1:new_PUF_size-1,j)),2);
                end
            end
            
            % Golden responses
            for i=1:new_PUF_size
                A_i = Av(:,i,:);
                A_i = permute(A_i,[1 3 2]);
                Avg(:,i) = mode(A_i,2);
            end
            clear A_i;
            
            % Save all processed CRPs
            save(respAvFile,'Av');     % Virtual APUF responses over nMeas measurements
            save(respAvgFile,'Avg');   % Virutal APUF golden response

        else
            new_PUF_size = nXOR_selected + 1;
            Av = zeros(nChal,new_PUF_size,nMeas);    % Binary responses
            Avg = zeros(nChal,new_PUF_size);         % Golden responses
            Av(:,1:new_PUF_size-1,:) = A(:,select_index_list(1:nXOR_selected),:);
            for i = 1:nChal
                for j = 1:nMeas
                    Av(i,new_PUF_size,j) = mod(sum(Av(i,1:new_PUF_size-1,j)),2);
                end
            end

            % Golden responses
            for i=1:new_PUF_size
                A_i = Av(:,i,:);
                A_i = permute(A_i,[1 3 2]);
                Avg(:,i) = mode(A_i,2);
            end
            clear A_i;

            % Save all processed CRPs
            save(respAvFile,'Av');     % Virtual APUF responses over nMeas measurements
            save(respAvgFile,'Avg');   % Virutal APUF golden response
            
        end
    end
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
