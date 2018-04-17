
%**************************************************************************
% Use this script to generate the challeges required for the analysis of 
% SAC property.
% 
% Last Update: 02/09/2015
%**************************************************************************

clear all;
clc;

% Parameters
N = 64;             % Size of APUF
nBaseChal = 500;   % No. of base chal
nBitFlip = 1; 

nSAC = N-nBitFlip+1;
nChal = nBaseChal*nSAC;

%**************************************************************************
% FILE NAMES
%**************************************************************************
oDir = [pwd '/dataset/input/'];
baseChalFile = [oDir 'chalBase_' num2str(N) '_' num2str(nBaseChal) '.mat'];
chalBiFile = [oDir 'chal_' num2str(N) '_' num2str(nChal) '_BF' num2str(nBitFlip) 'b.mat'];
chalFile = [oDir 'chal_' num2str(N) '_' num2str(nChal) '.mat'];

%**************************************************************************
% GENERATE CHALLENGE
%**************************************************************************

% Generate base challenges
chalB = randi([0,1],nBaseChal,N);


% Generate all challenges
chalBi = zeros(nChal,N);   % Binary Challenge

sIndx = 1:nBaseChal:nChal;
eIndx = nBaseChal:nBaseChal:nChal;

for k=1:nSAC
    
    c1 = chalB;
    
    % nBitFlip start at k-th bit position of a challenge
    for z=0:(nBitFlip-1)      
        c1(:,k+z) = ~c1(:,k+z);
    end
    
    chalBi(sIndx(k):eIndx(k),:) = c1; 
end

chalBi = [chalB; chalBi];          % Combine base challenges with derived one. 

% Convert binary challenge into 8-bit vectors
chal = binToByte(chalBi);

% Save challenges
save(baseChalFile,'chalB');
save(chalBiFile,'chalBi');
save(chalFile,'chal');

fprintf('\nDONE!!!\n');
