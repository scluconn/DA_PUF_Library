
%**************************************************************************
% Logistic Regression with Rprop optimization
%
% Author: D P Sahoo
% Last Update: 30th May
%**************************************************************************

% Read Training and Testing data
clear all;
clc;


%We simulate (x,y)-MXPUF
%MXPUF parameter
chalSize = 64;    % Bit length of challenge
mu = 0;           % Mean of variation in delay parameters
sigma = 1;        % Standard deviation of variation in delay parameters
x =1;        % x - number of APUFs in x-XOR PUF
y =1;        % y - number of APUFs in y-XOR PUF
feedback_a =33;   % feedback position to connect the output of x-XOR PUF and 
                  % the y-XOR PUF,  0<=feedback_a<=chalSize-1 

%generate (x,y)-MXPUF

[x_XPw,y_XPw]=MXPUFgeneration(x,y,chalSize,mu,sigma);

%generate Test Set and Training Set. 

nTest = 2000; %size of test set
testSetChallenges= randi([0 1], nTest, chalSize);
testSetResponses = ComputeResponseMXPUF( ...
                       x_XPw,y_XPw,x,y,feedback_a, ...
                       testSetChallenges,nTest,chalSize ...
                       );
                   
                   
%Number of runs of CMAES (Nr) and the array of prediction accuracies for
%each run (PredAcc)
Nr = 2;
PredAcc = zeros(Nr,1);

               
                   
nTrain = 200000; %size of training set

for nr=1:Nr
   
fprintf('run: %d \n',nr);    

trainSetChallenges= randi([0 1], nTrain, chalSize);
trainSetResponses = ComputeResponseMXPUF( ...
                       x_XPw,y_XPw,x,y,feedback_a, ...
                       trainSetChallenges,nTrain,chalSize ...
                       );  
%Compute the model of MXPUF_w                   
[lamda,MXPUF_w] = CMAES_MXPUF(x,y,feedback_a, ... 
                     chalSize,nTrain,trainSetChallenges,trainSetResponses); 
                 
[x_XPw_p,y_XPw_p] = splitMXPUF(MXPUF_w,x,y,chalSize);             

SetResponses_MXPUF_w = ComputeResponseMXPUF( ...
                       x_XPw_p,y_XPw_p,x,y,feedback_a, ...
                       testSetChallenges,nTest,chalSize ...
                       );  
                   
PredAcc(nr) = ComputePredictionAccuracy(SetResponses_MXPUF_w,testSetResponses,nTest);             

fprintf('run: %d \n',nr);    
end                    

