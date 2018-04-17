
%**************************************************************************
% Logistic Regression with Rprop optimization
%
% Author: D P Sahoo
% Last Update: 30th May
%**************************************************************************

% Read Training and Testing data
clear all;
clc;


%We simulate x-XORPUF
%MXPUF parameter
chalSize = 20;    % Bit length of challenge
mu = 0;           % Mean of variation in delay parameters
sigma = 1;        % Standard deviation of variation in delay parameters
x =3;        % x - number of APUFs in x-XOR PUF


%generate x-XOR PUF
x_XPw = XORPUFgeneration(x,chalSize,mu,sigma);

%generate Test Set and Training Set. 

nTest = 2000; %size of test set
testSetChallenges= randi([0 1], nTest, chalSize);
testSetPhi = Transform(testSetChallenges, nTest, chalSize);
testSetResponses = ComputeResponseXOR(x_XPw,x,testSetPhi,nTest,chalSize+1);
                   
                   
%Number of runs of CMAES (Nr) and the array of prediction accuracies for
%each run (PredAcc)
Nr = 10;
PredAcc = zeros(Nr,1);

               
                   
nTrain = 600; %size of training set

for nr=1:Nr
    
fprintf('run: %d \n',nr);       

trainSetChallenges= randi([0 1], nTrain, chalSize);
trainSetPhi = Transform(trainSetChallenges, nTrain, chalSize);
trainSetResponses = ComputeResponseXOR(x_XPw,x,trainSetPhi,nTrain,chalSize+1);
                  
%Compute the model of x-XORPUF x_XPw                   
[lamda,x_XPUF_w] = CMAES_XorPUF(x,chalSize,nTrain,trainSetPhi,trainSetResponses); 

%Since CMAES only works with 1-dimension array with x*(chalSize+1) components
%and output 1-dimension array with 1-dimension array with x*(chalSize+1)
%and our structure of x-dimension arry with (chalSize+1) component, we need
% to use the function splitXORPUF to get back x_XPw_p from the model x_XPUF_w
x_XPw_p = splitXORPUF(x_XPUF_w,x,chalSize);             

SetResponses_XPUF_w = ComputeResponseXOR(x_XPw_p,x,testSetPhi,nTest,chalSize+1);
           
PredAcc(nr) = ComputePredictionAccuracy(SetResponses_XPUF_w,testSetResponses,nTest);

fprintf('run: %d \n',nr);    
end                    

