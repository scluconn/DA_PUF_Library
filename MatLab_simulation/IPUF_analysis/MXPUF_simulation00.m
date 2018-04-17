
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
chalSize = 65;    % Bit length of challenge
mu = 0;           % Mean of variation in delay parameters
sigma = 1;        % Standard deviation of variation in delay parameters
x_nXOR =20;        % x - number of APUFs in x-XOR PUF
y_nXOR =2;        % y - number of APUFs in y-XOR PUF
feedback_a =1;   % feedback position to connect the output of x-XOR PUF and 
                  % the y-XOR PUF,  0<=feedback_a<=chalSize-1 

%generate x-XOR PUF first. Note that the size of challenge to x-XOR PUF is
%equal to chalSize.
chalSize_xXORPUF = chalSize;
x_XORw= XORPUFgeneration(x_nXOR,chalSize_xXORPUF,mu,sigma);

%generate y-XOR PUF now. Note that the size of challenge to y-XOR PUF is
%longer than the chalSize one bit 
chalSize_yXORPUF = chalSize+1;
y_XORw= XORPUFgeneration(y_nXOR,chalSize_yXORPUF,mu,sigma);

%We want to measure the noise rate of (x,y)-MXPUF and (x+y)-XOR PUF
%For (x+y)-XOR PUF, we do the simple trick to by assigned value 0 to the 
%challenge bit where the feedback_a is, i.e., the challenge to y-XOR PUF is
% c=(c0,..,c(i),0-feedback_a,c(i+1),...,c(n-1)).

%We define the parameter of noise rate (sigmaNoise) for each APUF and number of
%evaluations Evaluation

%Time Evaluation and sigmaNoise
Evaluations =10;
sigmaNoise = 0.1;

%We generate the set of challenge for measuring the noise (MeasureSet)

nMeasureSet = 10000; %size of MeasureSet
MeasureSet= randi([0 1], nMeasureSet, chalSize);

%%%%%
%%%%%
%We measure (x+y)-XOR PUF and (x,y)-MXPUF  at the same time
%%%%%
%%%%%

[Output_xyXORPUF, Output_xyMXPUF]= MeasureXYXORPUF_MXPUF( ...
                  x_nXOR,y_nXOR,x_XORw,y_XORw, ...
                  feedback_a,chalSize_xXORPUF,chalSize_yXORPUF, ...
                  Evaluations,sigmaNoise,sigma, ...
                  nMeasureSet,MeasureSet ...
                  );

%We compute the noise rate of output of MX and XOR PUF to compare
%Threshold says how we define a reliable output. In this case, if the 
%reliability is >=REL, then we SAY that the challenge-response is reliable
REL = 0.8;
Threshold = Evaluations*REL;
noiseRate_MXPUF = ComputeTheNoise(Output_xyMXPUF,nMeasureSet,Evaluations,Threshold);
noiseRate_XORPUF = ComputeTheNoise(Output_xyXORPUF,nMeasureSet,Evaluations,Threshold);







