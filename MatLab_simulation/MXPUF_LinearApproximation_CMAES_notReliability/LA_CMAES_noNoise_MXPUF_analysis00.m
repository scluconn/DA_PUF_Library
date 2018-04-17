
%**************************************************************************
% Logistic Regression with Rprop optimization
%
% Author: D P Sahoo
% Last Update: 30th May
%**************************************************************************

% Read Training and Testing data
clear all;
clc;


%We attack (x,y)-MXPUF by using Linear Approximation, i.e., we approximate
% (x,y)-MXPUF by a y-XOR PUF. 

%Step 1:  generating the testing set, i.e., CRP of MXPUF
%Step 2:  generating the training set, i.e., CRP of MXPUF
%Step 3:  using the training set to train the model of y-XOR PUF
%Step 4:  using the testing set for checking the accuracy. 





%We simulate (x,y)-MXPUF
%MXPUF parameter
chalSize = 64;    % Bit length of challenge
mu = 0;           % Mean of variation in delay parameters
sigma = 1;        % Standard deviation of variation in delay parameters
x =1;        % x - number of APUFs in x-XOR PUF
y =1;        % y - number of APUFs in y-XOR PUF
feedback_a = 63;   % feedback position to connect the output of x-XOR PUF and 
                  % the y-XOR PUF,  0<=feedback_a<=chalSize-1 

%generate (x,y)-MXPUF

[x_XPw,y_XPw]=MXPUFgeneration(x,y,chalSize,mu,sigma);


%STEP 1: TEST SET generation. 
%generate Test Set 

nTest = 200; %size of test set
testSetChallenges= randi([0 1], nTest, chalSize);
testSetResponses = ComputeResponseMXPUF( ...
                       x_XPw,y_XPw,x,y,feedback_a, ...
                       testSetChallenges,nTest,chalSize ...
                       );
%This is for computing the responses of y-XOR PUF.                   
testSetPhi = Transform(testSetChallenges, nTest, chalSize);                   
                   
                   
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
%Compute the model of y-XOR PUF
trainSetPhi = Transform(trainSetChallenges, nTrain, chalSize); 

[lamda,y_XPUF_w] = CMAES_XorPUF(x+y,chalSize,nTrain,trainSetPhi,trainSetResponses); 

%[lamda,y_XPUF_w] = CMAES_MXPUF(x, y, feedback_a, chalSize,nTrain,trainSetPhi,trainSetResponses); 
                   
%Since CMAES only works with 1-dimension array with x*(chalSize+1) components
%and output 1-dimension array with 1-dimension array with x*(chalSize+1)
%and our structure of x-dimension arry with (chalSize+1) component, we need
% to use the function splitXORPUF to get back x_XPw_p from the model x_XPUF_w
y_XPw_p = splitXORPUF(y_XPUF_w,y,chalSize);             

SetResponses_XPUF_w = ComputeResponseXOR(y_XPw_p,y,testSetPhi,nTest,chalSize+1);
           
PredAcc(nr) = ComputePredictionAccuracy(SetResponses_XPUF_w,testSetResponses,nTest);

PredAcc(nr) = abs(PredAcc(nr)-0.5);


fprintf('run: %d \n',nr);                       
                   
  
end                    

% the average of prediction accuracy over Nr attacks
Average = 0;
for i = 1: Nr
   Average = Average + PredAcc(i);    
end    

Average = Average/Nr;




