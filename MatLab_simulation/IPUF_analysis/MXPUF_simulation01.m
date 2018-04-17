
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
feedback_a =32;   % feedback position to connect the output of x-XOR PUF and 
                  % the y-XOR PUF,  0<=feedback_a<=chalSize-1 


%We want to measure the noise rate of (x,y)-MXPUF and (x+y)-XOR PUF
%For (x+y)-XOR PUF, we do the simple trick to by assigned value 0 to the 
%challenge bit where the feedback_a is, i.e., the challenge to y-XOR PUF is
% c=(c0,..,c(i),0-feedback_a,c(i+1),...,c(n-1)).

%We define the parameter of noise rate (sigmaNoise) for each APUF and number of
%evaluations Evaluation

%Time Evaluation and sigmaNoise
Evaluations =10;
sigmaNoise = 0.05;
Acceptance_Rate = 1; %How we define the reliable challenge-response

nChallenges = 2000; % How many challenges are used to measure the noise rate
noise_Eva   = 1; %How many evaluations for compute the average noise rate



Result = zeros(chalSize,4); %We measure the noise rate of XP, MP, xXP and yXP when
                            % varying the feedback positions

for feedback=1:chalSize
    
      [nrXP,nrMP,nrxXP,nryXP]=    MeasureTheNoiseRateXYXORPUF_MXPUF( ...
                           sigma,chalSize,  ... %APUF configuration
                           x_nXOR,y_nXOR, feedback,  ... % feedback a, x-XOR PUF and y-XOR PUF parameter
                           sigmaNoise,Evaluations, Acceptance_Rate, nChallenges,  ... % parameters for measuring the noise
                           noise_Eva  ... %parameters for measuring the noise rate 
                           )
        Result(feedback,1) = nrXP;
        Result(feedback,2) = nrMP;
        Result(feedback,3) = nrxXP;
        Result(feedback,4) = nryXP;        
        
end    
                            


% [nrXP,nrMP,nrxXP,nrxXP] = MeasureTheNoiseRateXYXORPUF_MXPUF( ...
%                            sigma,chalSize,  ... %APUF configuration
%                            x_nXOR,y_nXOR, feedback_a,  ... % feedback a, x-XOR PUF and y-XOR PUF parameter
%                            sigmaNoise,Evaluations, Acceptance_Rate, nChallenges,  ... % parameters for measuring the noise
%                            noise_Eva  ... %parameters for measuring the noise rate 
%                            )






