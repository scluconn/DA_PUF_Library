
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
nXOR =2;
nMeasurement = 10; % The number of measurements for majority voting and fixed bit
nReliability = 10; % The number of measurements for computing repeatability information
sigmaNoise = 0.01; % The sigma for the noise, noise follows a normal distribution N(0,sigmaNoise)

%weight vector w of XORPUFw=(w1,...,wnXOR)=[w[1,1],...,w[1,ChalSize+1];...;w[nXOR,1],...,w[nXOR,ChalSize]]
%by using the XORPUFgeneration. 

XORPUFw= XORPUFgeneration(nXOR,chalSize,mu,sigma);



%**************************************************************************
% Generate Challenges and compute Responses for analysis
%**************************************************************************

%Parameters 

nChallenge = 70000; % The number of challenges used for analysis
Size = chalSize+1;
NroundAttack = 100; 
Found = zeros(NroundAttack,nXOR);
ReliabilityAPUFs = zeros(NroundAttack,nXOR+1);


%We want run CMAES NroundAttack times on XORPUF with A1 enhanced (majority voting to improve 
%the reliability. The A2, .., AnXOR are convential APUF
%Two arrays Found and ReliabilityAPUFs used to track what model Ai is found and the reliability
%of all A1, ...,AnXOR and XORPUF in the attack 



for nr=1:NroundAttack 
     fprintf('run %d-th \n',nr);  
  %Generate a challengeSet where we store all challenges for analysis
     challengeSet= randi([0 1], nChallenge, chalSize);

  %Compute the corresponding parity vactor Phi_challengeSet for response
  %computation
     Phi_challengeSet = Transform(challengeSet, nChallenge, chalSize);
  %Generate data with 
  %XORPUFw, nXOR,chalSize,mu,sigma,sigma,sigmaNoise,nReliability,nMeasurement 
  %AResponseXOR is the array of responses of XORPUF for the challenge set
  %Phi_challengeSet
  %APUFsResponse are the arrays of responses of A1, ...,AnXOR
  %AReliabilityRate is the arrays of reliability of A1,..,AnXOR and XORPUF
     [AResponseXOR,APUFsResponse,AReliabilityRate] = ...     
     ComputeNoisyResponsesXOR_MajorityVoting(     ...
     XORPUFw,nXOR,Phi_challengeSet,nChallenge,Size,chalSize, ...
     sigma,sigmaNoise,nReliability,nMeasurement);     

  %Update ReliabilityAPUFs based on AReliabilityRate
     for i=1:(nXOR+1)
         ReliabilityAPUFs(nr,i)= AReliabilityRate(i);
     end
     
  %Process the data in AResponseXOR to have the repeatability information
  %as InformReliability by using ComputeTheNoiseInformation function and
  %then use the CMAES to build the model
  InformReliability = ComputeTheNoiseInformation(AResponseXOR,nChallenge,nReliability);
  [lam,wModel] = CMAES(Phi_challengeSet,InformReliability,Size);
  
  %Generate a challengeSet where we store all challenges for analysis
     nChallengeTest  = 1000;
     challengeSetTest= randi([0 1], nChallengeTest, chalSize);
     Phi_challengeSetTest = Transform(challengeSetTest, nChallengeTest, chalSize);
   
  %Compute the matching rate between A1,...,AnXOR with the found model wModel
     AResponseALLAPUFs = zeros(nXOR,nChallengeTest);
     
     for i=1:nXOR
         AResponseALLAPUFs(i,:)= ComputeResponseXOR( ...
             XORPUFw(i,:),1,Phi_challengeSetTest,nChallengeTest,Size);
     end
     
     for i=1:nXOR
         Found(nr,i)=modelAccHa( ...
          wModel,Phi_challengeSetTest,AResponseALLAPUFs(i,:),Size,nChallengeTest);
     end 
       %InformReliability = ExtractData();
  %CMA-ES to get the model
   %[lam,wModel] 
  
  %Update the Found and  ReliabilityAPUFs tables
     fprintf('run %d-th \n',nr);
end 

FoundEncode = zeros(NroundAttack,nXOR);

for nr=1:NroundAttack
    for i=1:nXOR
         if((Found(nr,i)>0.9)||(Found(nr,i)<0.1))
             FoundEncode(nr,i) = 1;
         else 
             FoundEncode(nr,i) = 0;
         end 
    end 
end


% Result = Found + ReliabilityAPUFs 
Result = zeros(NroundAttack,3*nXOR+1); 

for nr=1:NroundAttack
    for i=1:nXOR
        Result(nr,i) = Found(nr,i);
    end
    for i=(nXOR+1):(2*nXOR)
        Result(nr,i) = FoundEncode(nr,i-nXOR);
    end
    for i=(2*nXOR+1):(3*nXOR+1)
        Result(nr,i) = ReliabilityAPUFs(nr,i-2*nXOR);
    end
    
end


SeenAPUFs  = zeros(nXOR,1);

for nr=1:NroundAttack
    for j=1:nXOR 
        if(FoundEncode(nr,j)==1)
           SeenAPUFs(j) = SeenAPUFs(j)+1;
        end
    end     
end     

[ARank,AOccurence] = ComputeRankingModel(FoundEncode, ReliabilityAPUFs, NroundAttack, nXOR);






%Compute the corresponding set of responses to challengeSet for the APUF's
%instance APUFw (nXOR=1)
%AResponse_challengeSet = ComputeResponseXOR(APUFw,nXOR,Phi_challengeSet,nChallenge,Size);

%Evaluations = nMeasurement*nReliability;
%AResponse = ComputeNoisyResponsesXOR(APUFw,nXOR,Phi_challengeSet,nChallenge,Size,chalSize,sigma,sigmaNoise,Evaluations);



%[AResponse,APUFsResponse,AReliabilityRate] = ComputeNoisyResponsesXOR_FixedBit(XORPUFw,nXOR,Phi_challengeSet,nChallenge,Size,chalSize,sigma,sigmaNoise,nReliability,nMeasurement);


%Compute three different matrices for majorityVoting, Fixed Bits and normal
%measurement without majority voting and fixed bit 

% [Avoting,AfixedBit,Anormal] = FilterMatrices(AResponse,nChallenge, nMeasurement,nReliability);
% 
% %Analysis of Anormal
% [AnormalReliabilityRate,AnormalA0,AnormalA1,AnormalRate] = ReliabilityRate(Anormal,nChallenge,nReliability);
% 
% %Analysis of Avoting
% [AvotingReliabilityRate,AvotingA0,AvotingA1,AvotingRate] = ReliabilityRate(Avoting,nChallenge,nReliability);
% 
% %Analysis of AfixedBit
% [AfixedBitReliabilityRate,AfixedBitA0,AfixedBitA1,AfixedRate] = ReliabilityRate(AfixedBit,nChallenge,nReliability);
% 
% fprintf('Anormal: %f, Avoting %f, AfixedBit %f \n',AnormalRate,AvotingRate,AfixedRate);


%A = [0 0 0 0 0 0; 1 1 1 1 1 1; 1 1 0 1 0 0; 0 0 1 1 1 0];

%[Av,Af,An]= FilterMatrices(A,4,3,2);
%[B1,B2,B3,r] = ReliabilityRate(A,4,3);














