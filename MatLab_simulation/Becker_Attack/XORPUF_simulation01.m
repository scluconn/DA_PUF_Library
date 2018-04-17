
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
chalSize = 64;    % Bit length of challenge
mu = 0;           % Mean of variation in delay parameters
sigma = 1;     % Standard deviation of variation in delay parameters
nXOR =3;

%weight vector w of XORPUFw=(w1,...,wnXOR)=[w[1,1],...,w[1,ChalSize+1];...;w[nXOR,1],...,w[nXOR,ChalSize]]
%by using the XORPUFgeneration. 

XORw= XORPUFgeneration(nXOR,chalSize,mu,sigma);


%**************************************************************************
% Generate Challenges and compute Responses
%**************************************************************************


%Create the Traing Set of Challenge TrS (nTrS elements) and Test Set of 
%Challenge TeS (nTeS elements).

nTrS = 5000;
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
Evaluations =6;
sigmaNoise = 0.2;
Threshold = 10;


%We run CMAES many times (U times) and check whether all APUF can be modeled or not 

U=3;

matchingRateMultipleTimes = zeros(U,nXOR);
NoiseRate  = zeros(U,nXOR+1);

for k=1:U
    fprintf('run %d-th \n',k);
    TrS= randi([0 1], nTrS, chalSize);
    Phi_TrS = Transform(TrS, nTrS, chalSize);
    [AResponse_TrS,AResponseAPUFs_TrS]= ComputeNoisyResponsesXOR00(XORw,nXOR,Phi_TrS,nTrS,Size,chalSize,sigma,sigmaNoise,Evaluations);
    InformReliability = ComputeTheNoiseInformation(AResponse_TrS,nTrS,Evaluations);
    [lam,wModel] = CMAES(Phi_TrS,InformReliability,Size);
    
    for i=1:nXOR
       matchingRateMultipleTimes(k,i)=modelAccHa(wModel,Phi_TeS,AResponseALLAPUFs(i,:),Size,nTeS);
    end  
    
    %COMPUTE THE NOISY RATE OF APUFs and XOR PUFS
    
%%%%%Compute the noise Rate in each APUFs from AResponseAPUFs_TrS(nXOR,nRows,evaluation)
%%%% ReliabilityArray(i,j)==1 ==> APUF i, challenge cj is NON-reliable,
%%%% otherwise not.
    ReliabilityArray = zeros(nXOR,nTrS);
    for k1=1:nXOR
      for i=1:nTrS
         count1 = 0; count0=0;
         
         for e=1:Evaluations
             if(AResponseAPUFs_TrS(k1,i,e)==1)
                 count1=count1+1;
             else 
                 count0=count0+1;
             end
         end  
         
         if((count1<Evaluations)&&(count1>0))
             ReliabilityArray(k1,i)=1;
         end
      end    
    end
    
   for k1=1:nXOR
       for i=1:nTrS
         if (ReliabilityArray(k1,i)==1)
            NoiseRate(k,k1)=NoiseRate(k,k1)+1;
         end
       end
       NoiseRate(k,k1) = NoiseRate(k,k1)/nTrS;
   end
    
   
   %Compute the noise Rate in XORPUF
    ReliabilityXORPUF = zeros(nTrS,1);
    for i=1:nTrS
         count1 = 0; count0=0;
         
         for e=1:Evaluations
             if(AResponse_TrS(i,e)==1)
                 count1=count1+1;
             else 
                 count0=count0+1;
             end
         end  
         
         if((count1<Evaluations)&&(count1>0))
             ReliabilityXORPUF(i)=1;
         end
    end  
    
    for i=1:nTrS
        if (ReliabilityXORPUF(i)==1)
            NoiseRate(k,nXOR+1)=NoiseRate(k,nXOR+1)+1;
        end
    end
    NoiseRate(k,nXOR+1) = NoiseRate(k,nXOR+1)/nTrS; 
    fprintf('run %d-th \n',k);
end 

% for k=1:U
%     for i=1:nXOR
%          if((matchingRateMultipleTimes(k,i)>0.99)||(matchingRateMultipleTimes(k,i)<0.01))
%              matchingRateMultipleTimes(k,i) = 1;
%          else 
%              matchingRateMultipleTimes(k,i) = 0;
%          end 
%     end 
% end
% 
% 
% Result = matchingRateMultipleTimes + NoiseRate 
% Result = zeros(U,2*nXOR+1);
% 
% for k=1:U
%     for i=1:nXOR
%         Result(k,i) =  matchingRateMultipleTimes(k,i);
%     end
%     for i=(nXOR+1):(2*nXOR+1)
%         Result(k,i) =  NoiseRate(k,i-nXOR);
%     end
%     
% end
% 
% [ARank,AOccurence] = ComputeRankingModel(matchingRateMultipleTimes, NoiseRate, U, nXOR);


%%Compute the noise Rate in each APUF from ReliabilityArray 


 



% AResponse_TrS = ComputeResponseXOR(XORw,nXOR,Phi_TrS,nTrS,Size);
% AResponse_TeS = ComputeResponseXOR(XORw,nXOR,Phi_TeS,nTeS,Size);

% 
% 
% %fprintf('[i,j] = [%f,%d]\n',APUF_w(65),4);



