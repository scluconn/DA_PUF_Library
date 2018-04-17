%We attack MXPUF based on Becker's attack for one PUF at y-XOR PUF and
%y-XOR PUF. We do the linear approximation attack. 


clear all;
clc;

%We simulate (x,y)-MXPUF
%MXPUF parameter
chalSize = 20;    % Bit length of challenge
mu = 0;           % Mean of variation in delay parameters
sigma = 1;        % Standard deviation of variation in delay parameters
x =0;        % x - number of APUFs in x-XOR PUF
y =6;        % y - number of APUFs in y-XOR PUF
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

prediction_array = zeros(chalSize,x,U); 
Yfound = zeros(chalSize,y,U);
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
    
    
    %Since we focus on linear approximation attack at y-XOR PUF, we need to
    %modify the challenge
    
    TrSp = zeros(nTrS,chalSize+1);
    for i=1:nTrS
        for j=1:(feedback_a-1)
            TrSp(i,j)= TrS(i,j);
        end
        TrSp(i,feedback_a)= 0;
        for j=(feedback_a+1):(chalSize+1)
            TrSp(i,j) = TrS(i,j-1);
        end                
    end
    
    Phi_TrSp = Transform(TrSp, nTrS, chalSize+1);
    [lam,wModel] = CMAES(Phi_TrSp,InformReliability,Size+1);
    
    % Compare wModel with APUFs at y-XOR PUF. 
        
    for i=1:y
         wp = zeros(1,Size+1);
         for j=1:(Size+1)
             wp(j)=y_XPw(i,j);
         end            
         result=CompareTwoModels(wp,wModel,Size+1);
         prediction_array(feedback_a,i,k)= result; 
         
         if((result>Threshold_found)||(result<(1-Threshold_found)) )
          Yfound(feedback_a,i,k) = 1;
         end
    end 
    
    
    end 
  end   
    
end    

%We compute the average accuracy of the attack
prediction_array_average = zeros(chalSize,y); 
%We know whether we can find any APUF at y-XOR PUF or not. 
Yfound_total = zeros(chalSize,y);

for feedback_a=1:chalSize
    for i=1:y
        for k=1:U
            prediction_array_average(feedback_a,i)= prediction_array_average(feedback_a,i) + abs(prediction_array(feedback_a,i,k)-0.5);
            Yfound_total(feedback_a,i)=Yfound_total(feedback_a,i)+Yfound(feedback_a,i,k);
        end
        prediction_array_average(feedback_a,i)= prediction_array_average(feedback_a,i)/U;
    end
end

prediction_array_3 = zeros(3,y,U);

for i=1:y
    for k=1:U
        prediction_array_3(1,i,k) =  prediction_array(1,i,k);
        prediction_array_3(chalSize/2,i,k) =  prediction_array(chalSize/2,i,k);
        prediction_array_3(chalSize,i,k) =  prediction_array(chalSize,i,k);
    end 
end



