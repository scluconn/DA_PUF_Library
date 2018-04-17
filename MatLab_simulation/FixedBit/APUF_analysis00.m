
%**************************************************************************
% Logistic Regression with Rprop optimization
%
% Author: D P Sahoo
% Last Update: 30th May
%**************************************************************************

% Read Training and Testing data
clear all;
clc;

%******************APUF **********
%**************************************************************************
% Create a Simulated model for Arbiter PUF
%** ************************************************************************
chalSize = 65;    % Bit length of challenge
mu = 0;           % Mean of variation in delay parameters
sigma = 1;     % Standard deviation of variation in delay parameters
nXOR =1;

%weight vector w of XORPUFw=(w1,...,wnXOR)=[w[1,1],...,w[1,ChalSize+1];...;w[nXOR,1],...,w[nXOR,ChalSize]]
%by using the XORPUFgeneration. 

%Generate one APUF instance by using the function XORPUFgeneration with
%nXOR =1 
APUFw= XORPUFgeneration(nXOR,chalSize,mu,sigma);


%**************************************************************************
% Generate Challenges and compute Responses for analysis
%**************************************************************************

%Parameters 

nChallenge = 10000; % The number of challenges used for analysis
nMeasurement = 100; % The number of measurements for majority voting and fixed bit
nReliability = 10; % The number of measurements for computing repeatability information
sigmaNoise = 0.8; % The sigma for the noise, noise follows a normal distribution N(0,sigmaNoise)

Size = chalSize+1;

%Generate a challengeSet where we store all challenges for analysis
challengeSet= randi([0 1], nChallenge, chalSize);

%Compute the corresponding parity vactor Phi_challengeSet for response
%computation
Phi_challengeSet = Transform(challengeSet, nChallenge, chalSize);

%Compute the corresponding set of responses to challengeSet for the APUF's
%instance APUFw (nXOR=1)
%AResponse_challengeSet = ComputeResponseXOR(APUFw,nXOR,Phi_challengeSet,nChallenge,Size);

Evaluations = nMeasurement*nReliability;
AResponse = ComputeNoisyResponsesXOR(APUFw,nXOR,Phi_challengeSet,nChallenge,Size,chalSize,sigma,sigmaNoise,Evaluations);


%Compute three different matrices for majorityVoting, Fixed Bits and normal
%measurement without majority voting and fixed bit 

[Avoting,AfixedBit,Anormal] = FilterMatrices(AResponse,nChallenge, nMeasurement,nReliability);

%Analysis of Anormal
[AnormalReliabilityRate,AnormalA0,AnormalA1,AnormalRate] = ReliabilityRate(Anormal,nChallenge,nReliability);

%Analysis of Avoting
[AvotingReliabilityRate,AvotingA0,AvotingA1,AvotingRate] = ReliabilityRate(Avoting,nChallenge,nReliability);

%Analysis of AfixedBit
[AfixedBitReliabilityRate,AfixedBitA0,AfixedBitA1,AfixedRate] = ReliabilityRate(AfixedBit,nChallenge,nReliability);

fprintf('Anormal: %f, Avoting %f, AfixedBit %f \n',AnormalRate,AvotingRate,AfixedRate);


%A = [0 0 0 0 0 0; 1 1 1 1 1 1; 1 1 0 1 0 0; 0 0 1 1 1 0];

%[Av,Af,An]= FilterMatrices(A,4,3,2);
%[B1,B2,B3,r] = ReliabilityRate(A,4,3);














