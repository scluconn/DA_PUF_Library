
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
%**************************************************************************
chalSize = 65;    % Bit length of challenge
mu = 0;           % Mean of variation in delay parameters
sigma = 1;     % Standard deviation of variation in delay parameters
nXOR =4;

%weight vector w of XORPUFw=(w1,...,wnXOR)=[w[1,1],...,w[1,ChalSize+1];...;w[nXOR,1],...,w[nXOR,ChalSize]]
%by using the XORPUFgeneration. 

XORw= XORPUFgeneration(nXOR,chalSize,mu,sigma);


%**************************************************************************
% Generate Challenges and compute Responses
%**************************************************************************


%Create the Traing Set of Challenge TrS (nTrS elements) and Test Set of 
%Challenge TeS (nTeS elements).

nTrS = 20000;
nTeS = 5000;

TrS= randi([0 1], nTrS, chalSize);
TeS= randi([0 1], nTeS, chalSize);

%Transform the arrays of challanges to the arrays of feature vectors
Phi_TrS = Transform(TrS, nTrS, chalSize);
Phi_TeS = Transform(TeS, nTeS, chalSize);


%Compute the responses for the Test sets Phi_TeS
Size = chalSize+1;

AResponse_TeS = ComputeResponseXOR(XORw,nXOR,Phi_TeS,nTeS,Size);

%Compute the arrays of responses for a given weight vector XORw and
%arrays of challenges

%Time Evaluation and sigmaNoise
Evaluations =10;
sigmaNoise = 0.5;

AResponse_TrS = ComputeNoisyResponsesXOR(XORw,nXOR,Phi_TrS,nTrS,Size,chalSize,sigma,sigmaNoise,Evaluations);

Threshold = 10;
Rate = ComputeTheNoise(AResponse_TrS,nTrS,Evaluations,Threshold);
InformReliability = ComputeTheNoiseInformation(AResponse_TrS,nTrS,Evaluations);



%Compute the model by using CMA-ES
[lam,wModel] = CMAES(Phi_TrS,InformReliability,Size);

%f = modelAcc_1(wModelp,Phi_TeS,AResponse_TeS);
f=modelAccHa(wModel,Phi_TeS,AResponse_TeS,Size,nTeS);


%We compute the CRP pairs for EACH APUF $i$ in XORPUF: XORw(i,:)
%We use the TeS CRP for building AResponseALLAPUFs(i,nTeS);
%Since XORPUF, all APUFs can use Phi_TeS array and ComputeResponseXOR where
%nXOR=1, XORw(i,:), Size

AResponseALLAPUFs = zeros(nXOR,nTeS);

for i=1:nXOR 
    AResponseALLAPUFs(i,:)=ComputeResponseXOR(XORw(i,:),1,Phi_TeS,nTeS,Size);
end



%Check the uniqueness of APUF(1) and APUF(2)
unquiness = zeros(1,nXOR-1);
for j=2:nXOR
count = 0; 
for i=1:nTeS
    if(AResponseALLAPUFs(1,i)==AResponseALLAPUFs(j,i))
        count=count+1;
    end
end
unquiness(j)= count/nTeS;
end

%Check the found wModel is equal to any APUF in the XORPUF?
matchingRate = zeros(1,nXOR);

for i=1:nXOR
    matchingRate(i)=modelAccHa(wModel,Phi_TeS,AResponseALLAPUFs(i,:),Size,nTeS);
end    


%We run CMAES many times (U times) and check whether all APUF can be modeled or not 

% U=10;
% 
% matchingRateMultipleTimes = zeros(U,nXOR);
% 
% for k=1:U
%     wModel = CMAES(Phi_TrS,InformReliability,Size);
%     for i=1:nXOR
%        matchingRateMultipleTimes(k,i)=modelAccHa(wModel,Phi_TeS,AResponseALLAPUFs(i,:),Size,nTeS);
%     end  
% end 

%We take out NModel from CMAES2 and check whether we can see APUFs there?

NModel = lam;



[lam1,wModel2] = CMAES2(Phi_TrS,InformReliability,lam,Size);
matchingRateMultiplerat2 = zeros(lam1,nXOR);

for i=1:lam1
    for j=1:nXOR
        matchingRateMultiplerat2(i,j)=modelAccHa(wModel2(i,:),Phi_TeS,AResponseALLAPUFs(j,:),Size,nTeS);
    end  
end
  
%%%% 


% AResponse_TrS = ComputeResponseXOR(XORw,nXOR,Phi_TrS,nTrS,Size);
% AResponse_TeS = ComputeResponseXOR(XORw,nXOR,Phi_TeS,nTeS,Size);

% 
% 
% %fprintf('[i,j] = [%f,%d]\n',APUF_w(65),4);



