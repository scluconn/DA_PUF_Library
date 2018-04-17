
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
nXOR = 6;

%weight vector w of XORPUFw=(w1,...,wnXOR)=[w[1,1],...,w[1,ChalSize+1];...;w[nXOR,1],...,w[nXOR,ChalSize]]
%by using the XORPUFgeneration. 

XORw= XORPUFgeneration(nXOR,chalSize,mu,sigma);

%**************************************************************************
% Generate Challenges and compute Responses
%**************************************************************************


%Create the Traing Set of Challenge TrS (nTrS elements) and Test Set of 
%Challenge TeS (nTeS elements).

nTrS = 270000;
nTeS = 500;

%Compute the responses for the Test sets Phi_TeS
Size = chalSize+1;

%Test data we need only one time generation
TeS= randi([0 1], nTeS, chalSize);
Phi_TeS = Transform(TeS, nTeS, chalSize);
AResponse_TeS = ComputeResponseXOR(XORw,nXOR,Phi_TeS,nTeS,Size);

%For checking the APUF with generated model 
AResponseALLAPUFs = zeros(nXOR,nTeS);
for i=1:nXOR 
    AResponseALLAPUFs(i,:)=ComputeResponseXOR(XORw(i,:),1,Phi_TeS,nTeS,Size);
end


%Compute the arrays of responses for a given weight vector XORw and
%arrays of challenges

%Time Evaluation and sigmaNoise
Evaluations =11;
%noise rate fits real experiments
sigmaNoise = 0.0055;
Threshold = 10;

%We run CMAES many times (U times) and check whether all APUF can be modeled or not 

U=6;

matchingRateMultipleTimes = zeros(U,nXOR);


for k=1:U
    TrS= randi([0 1], nTrS, chalSize);
    Phi_TrS = Transform(TrS, nTrS, chalSize);
    AResponse_TrS = ComputeNoisyResponsesXOR(XORw,nXOR,Phi_TrS,nTrS,Size,chalSize,sigma,sigmaNoise,Evaluations);
    reliability = zeros(nTrS,1);
    for i = 1 : nTrS
        temp = sum(AResponse_TrS(i,:));
        if temp == 0 || temp == Evaluations
            reliability(i) = 1;
        end
    end
    rel = 1- sum(reliability)/nTrS;
    
    InformReliability = ComputeTheNoiseInformation(AResponse_TrS,nTrS,Evaluations);
    [lam,wModel] = CMAES(Phi_TrS,InformReliability,Size);
    
    for i=1:nXOR
       matchingRateMultipleTimes(k,i)=modelAccHa(wModel,Phi_TeS,AResponseALLAPUFs(i,:),Size,nTeS);
    end
    
end 

for k=1:U
    for i=1:nXOR
         if((matchingRateMultipleTimes(k,i)>0.9)||(matchingRateMultipleTimes(k,i)<0.1))
             matchingRateMultipleTimes(k,i) = 1;
         else 
             matchingRateMultipleTimes(k,i) = 0;
         end 
    end 
end