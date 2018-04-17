%We attack MXPUF based on Becker's attack for one PUF at x-XOR PUF and
%y-XOR PUF


clear all;
clc;

%We simulate (x,y)-MXPUF
%MXPUF parameter
chalSize = 20;    % Bit length of challenge
mu = 0;           % Mean of variation in delay parameters
sigma = 1;        % Standard deviation of variation in delay parameters
x =3;        % x - number of APUFs in x-XOR PUF
y =3;        % y - number of APUFs in y-XOR PUF
feedback_a =10;   % feedback position to connect the output of x-XOR PUF and 
                  % the y-XOR PUF,  0<=feedback_a<=chalSize-1 

%generate (x,y)-MXPUF

[x_XPw,y_XPw]=MXPUFgeneration(x,y,chalSize,mu,sigma);


%We attack MXPUF U times and MXPUF is a noisy PUF with noise of sigmaNoise
%and check whether all APUFs x-XOR PUF can be modeled or not 
% x-XORPUF is the upper part, y-XOR PUF is the lower part

U=10;

%Time Evaluation and sigmaNoise
Evaluations =6;
sigmaNoise = 0.2;
nTrS = 20000;
Size = chalSize+1;

%This array let us know how the occurence of found models matching some
%APUFs at x-XOR PUF: Xfound(1)->APUF(1), ..., Xfound(2) ->APUF(2).

%We computing the occurence of each computed models wi and wj
countX = zeros(U,1);
countY = zeros(U,1);
%This counter helps us to know how many different wi, wj built in U runs

currentX = 0;
currentY = 0;

x_XPw_p = transpose(x_XPw);

prediction_array = zeros(chalSize,x,U); 
Xfound = zeros(chalSize,x,U);
Threshold_found  = 0.95;

for feedback_a=1:chalSize
    
  if(feedback_a==chalSize/2) 
   %if((feedback_a==1)||(feedback_a==chalSize/2)||(feedback_a==chalSize)) 
     
    for k=1:U
    fprintf('feedback_a %d-th and run %d-th \n',feedback_a, k);
    %Generate Traing Set, i.e., set of challenges
    TrS= randi([0 1], nTrS, chalSize);
    [AResponse_TrS]= ComputeNoisyResponsesMXPUF(x_XPw,y_XPw,x,y,feedback_a,...
                                     TrS,nTrS,chalSize,mu,sigma,sigmaNoise,Evaluations);
    AResponse_TrS = transpose(AResponse_TrS)
    InformReliability = ComputeTheNoiseInformation(AResponse_TrS,nTrS,Evaluations);
    
    Phi_TrS = Transform(TrS, nTrS, chalSize);
    [lam,wModel] = CMAES(Phi_TrS,InformReliability,Size);
    
    % Compare wModel with APUFs at x-XOR PUF. 
        
    for i=1:x
         wp = zeros(1,Size);
         for j=1:Size
             wp(j)=x_XPw(i,j);
         end            
         result=CompareTwoModels(wp,wModel,Size);
         prediction_array(feedback_a,i,k)= result; 
         
         if(result>Threshold_found)
          Xfound(feedback_a,i,k) = 1;
         end
    end 
    
end 
    
   end
end    

%We compute the average accuracy of the attack
prediction_array_average = zeros(chalSize,x); 
%We know whether we can find any APUF at x-XOR PUF or not. 
Xfound_total = zeros(chalSize,x);

for feedback_a=1:chalSize
    for i=1:x
        for k=1:U
            prediction_array_average(feedback_a,i)= prediction_array_average(feedback_a,i) + abs(prediction_array(feedback_a,i,k)-0.5);
            Xfound_total(feedback_a,i)=Xfound_total(feedback_a,i)+Xfound(feedback_a,i,k);
        end
        prediction_array_average(feedback_a,i)= prediction_array_average(feedback_a,i)/U;
    end
end





