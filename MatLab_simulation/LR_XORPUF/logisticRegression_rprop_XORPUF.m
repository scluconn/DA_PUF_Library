
%**************************************************************************
% XORPUF modeling using Logistic Regression
% Author: D P Sahoo
% Last Update: 11 June 2014
%**************************************************************************
clear all;
clc;

%**************************************************************************
% Log file
fid = fopen('logFile.txt', 'w');
delete('accuracy.csv');

%**************************************************************************

chalSize1 = 64;    % Bit length of challenge
mu = 0;           % Mean of variation in delay parameters
sigma = 1;        % Standard deviation of variation in delay parameters
x =1;             % x - number of APUFs in x-XOR PUF

%generate x-XOR PUF
x_XPw = XORPUFgeneration(x,chalSize1,mu,sigma);

%generate challenge and response matricies 
nGeneration = 10000; %size of test set
challenge= randi([0 1], nGeneration, chalSize1);
challengePhi = Transform(challenge, nGeneration, chalSize1);
challengePhi = fliplr(challengePhi);
%%%%%Note that the way Durga defined the order of challenge bits is 
% C[n-1], C[n-2], ..., C[0]
%So, we need to use the fliplr function to correct the order of the data
%used Ha's code above. In Ha's code, the order is defined as 
% C[0], C[1], ...., C[n-1]


response = ComputeResponseXOR(x_XPw,x,challengePhi,nGeneration,chalSize1+1);
%testSetResponses(testSetResponses==0) = -1; % Convert (0,1) to (-1,1)




% Number of APUFs are being XORed
nAPUF = x; 
% delete(['modelingResults_' num2str(nAPUF) '_XORPUF.mat']);   % Delete old file
% 
% Prepare Challenge/Response of 2-XOR Arbiter PUF 
% load([pwd '/dataSet/challenge.mat']);
% load([pwd '/dataSet/response.mat']);


nChal = 2000;            % Number of challenges
C = challenge(1:nChal,:);
Resp = response(1:nChal,:);
clear challenge response;
chalSize = size(C,2);      % Bit-length of challenge

% Compute the XORAPUF output
R = zeros(nChal,1);   % Response of XORAPUF 
for k=1:nAPUF
    Rk = Resp(:,k);
    R = double(xor(Rk,R));
end
clear Rk;
R(R==0)=-1;

% Compute features from challenge (Parity vector of challenges)
%P = getParityVec(C,0);   % P(i,:) = (pn,pn-1,...,p0)
P = challengePhi;
nFeatures = size(P,2)*nAPUF; % Number of features for XORAPUF
nObservation = size(P,1);    % Total number of samples

%**************************************************************************
% Details of optimization technique
% Default Parameters
param.method            = 'Rprop+';    % Rprop method used
param.MaxIter           = 5000;      % Stop 0: Maximum number of iterations
param.mu_neg            = 0.5;         % Decrease factor [0.5]
param.mu_pos            = 1.2;         % Increase factor [1.2]
param.delta0            = 0.0123;      % Initial update-value
param.delta_min         = 0;           % Lower bound for step size
param.delta_max         = 50;          % Upper bound for step size
param.errorTol          = 10e-15;      % Error tolerance

delta = repmat(param.delta0,1,nFeatures);
%**************************************************************************
% trPercent: Percentage of total data to be used in traning
trPercent = [5 10 15 20 25 30 35 40 45 50] ;     
repeat = 1;

acMat        = zeros(length(trPercent),repeat);
precisionMat = zeros(length(trPercent),repeat); 
recallMat    = zeros(length(trPercent),repeat); 
fscoreMat    = zeros(length(trPercent),repeat);

% Modeling with various amount of Traing data
for i=1:length(trPercent)
    
    nTrainSample = int64(((nChal+1)*trPercent(i))/100);
    
    % Traing with ramdomly chosen set of samples
    for j=1:repeat
        
        % Split data into train and test set 
        %[trainX,trainY,testX,testY] = ramdonSplit(P,R,nTrainSample);
        [trainX,trainY,testX,testY] = unifiedRamdonSplit(P,R,trPercent(i));
        
        W0 = rand(1,nFeatures);          % Initial parameters value
        
        % Training
        [W grad] = getModelRPROP_XORPUF(trainX,trainY,W0,delta,nAPUF,param);
        fprintf(fid,'\n[%d %d] Max Grad = %g',i,j,max(abs(grad)));
        % Testing
        [Yp, ~] = classify(testX,W,nAPUF);
        testY(testY==-1)=0;
        [ac precision recall fscore] = accuracy(testY,Yp); 
        acMat(i,j) = ac;
        precisionMat(i,j) =  precision;
        recallMat(i,j) = recall; 
        fscoreMat(i,j) = fscore;
       
    end
    dlmwrite('accuracy.csv',acMat(i,:),'-append');
end

save(['modelingResults_' num2str(nAPUF) '_XORPUF.mat'],'acMat','precisionMat','recallMat','fscoreMat');
fprintf('DONE!!!');
fprintf(fid,'DONE!!!');
%exit;


