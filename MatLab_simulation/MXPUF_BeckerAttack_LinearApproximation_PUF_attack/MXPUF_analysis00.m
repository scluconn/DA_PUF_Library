%We attack MXPUF based on Becker's attack for one PUF at y-XOR PUF and
%y-XOR PUF. We do the linear approximation attack. 


clear all;
clc;

%We simulate (x,y)-MXPUF
%MXPUF parameter
chalSize = 64;    % Bit length of challenge
mu = 0;           % Mean of variation in delay parameters
sigma = 1;        % Standard deviation of variation in delay parameters
x =1;        % x - number of APUFs in x-XOR PUF
y =1;        % y - number of APUFs in y-XOR PUF
feedback_a =33;   % feedback position to connect the output of x-XOR PUF and 
                  % the y-XOR PUF,  0<=feedback_a<=chalSize-1 

%generate (x,y)-MXPUF

[x_XPw,y_XPw]=MXPUFgeneration(x,y,chalSize,mu,sigma);


%We attack MXPUF U times and MXPUF is a noisy PUF with noise of sigmaNoise
%and check whether all APUFs x-XOR PUF can be modeled or not 
% x-XORPUF is the upper part, y-XOR PUF is the lower part

U=1;

%Time Evaluation and sigmaNoise
Evaluations =6;
sigmaNoise = 0.2;
nTrS = 200000;
Size = chalSize+1;

%This array let us know how the occurence of found models matching some
%APUFs at x-XOR PUF: Xfound(1)->APUF(1), ..., Xfound(2) ->APUF(2).

prediction_array = zeros(chalSize,U); 
Yfound = zeros(chalSize,y,U);

Threshold_found  = 0.95;


%%%%
%%%% Challenge and Response Sets for testing the accuracy of the models

nTest = 200; %size of test set
testSetChallenges= randi([0 1], nTest, chalSize);
testSetResponses = ComputeResponseMXPUF( ...
                       x_XPw,y_XPw,x,y,feedback_a, ...
                       testSetChallenges,nTest,chalSize ...
                       );

%Since we focus on linear approximation attack at y-XOR PUF, we need to
%modify the challenge
    
             
                   
AAA = zeros(1,U);                    


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
    [lam,wModel] = CMAES(Phi_TrSp,InformReliability,chalSize+2);
    
    %We need to modify the challenge for testSet for found wModel
    %nTest = 2000; %size of test set
    %testSetChallenges= randi([0 1], nTest, chalSize);
    
    TestSp = zeros(nTest,chalSize+1);
    for i=1:nTest
        for j=1:(feedback_a-1)
            TestSp(i,j)= testSetChallenges(i,j);
        end
        TestSp(i,feedback_a)= 0;
        for j=(feedback_a+1):(chalSize+1)
            TestSp(i,j) = testSetChallenges(i,j-1);
        end                
    end
    

    
    %Compare the wModel with MXPUF
    %Step1: compute the response of wModel. 
     
    %Compute the Phi vector from Challenge vector
    APhi_TestSp = Transform(TestSp, nTest,chalSize+1);
    Size  = chalSize+2;
    WModel_Responses = ComputeResponseAPUF(wModel,APhi_TestSp,nTest,Size);
    
    %Compare the wModel and MXPUF 
    
    count  = 0;
    for i= 1:nTest 
        if(WModel_Responses(i)==testSetResponses(i))
            count= count+1;        
        end 
    end

    prediction_array(feedback_a,k)= abs( (count/nTest) - 0.5);
    AAA(k)  = abs( (count/nTest) - 0.5);
end 
 
Average = 0;
for k = 1:U
    Average = Average + AAA(k);
end
Average = Average/U;
                   

% for feedback_a=1:chalSize
%   if(feedback_a==chalSize/2)  
%   if((feedback_a==1)||(feedback_a==chalSize/2)||(feedback_a==chalSize))   
%     for k=1:U
%     fprintf('feedback_a %d-th and run %d-th \n',feedback_a, k);
%     Generate Traing Set, i.e., set of challenges
%     TrS= randi([0 1], nTrS, chalSize);
%     [AResponse_TrS]= ComputeNoisyResponsesMXPUF(x_XPw,y_XPw,x,y,feedback_a,...
%                                      TrS,nTrS,chalSize,mu,sigma,sigmaNoise,Evaluations);
%     AResponse_TrS = transpose(AResponse_TrS)
%     InformReliability = ComputeTheNoiseInformation(AResponse_TrS,nTrS,Evaluations);
%     
%     
%     Since we focus on linear approximation attack at y-XOR PUF, we need to
%     modify the challenge
%     
%     TrSp = zeros(nTrS,chalSize+1);
%     for i=1:nTrS
%         for j=1:(feedback_a-1)
%             TrSp(i,j)= TrS(i,j);
%         end
%         TrSp(i,feedback_a)= 0;
%         for j=(feedback_a+1):(chalSize+1)
%             TrSp(i,j) = TrS(i,j-1);
%         end                
%     end
%     
%     Phi_TrSp = Transform(TrSp, nTrS, chalSize+1);
%     [lam,wModel] = CMAES(Phi_TrSp,InformReliability,Size+1);
%     
%     We need to modify the challenge for testSet for found wModel
%     nTest = 2000; %size of test set
%     testSetChallenges= randi([0 1], nTest, chalSize);
%     
%     TestSp = zeros(nTest,chalSize+1);
%     for i=1:nTest
%         for j=1:(feedback_a-1)
%             TestSp(i,j)= testSetChallenges(i,j);
%         end
%         TestSp(i,feedback_a)= 0;
%         for j=(feedback_a+1):(chalSize+1)
%             TestSp(i,j) = testSetChallenges(i,j-1);
%         end                
%     end
%     
% 
%     
%     Compare the wModel with MXPUF
%     Step1: compute the response of wModel. 
%      
%     Compute the Phi vector from Challenge vector
%     APhi_TestSp = Transform(TestSp, nTest,chalSize+1);
%     Size  = chalSize+2;
%     WModel_Responses = ComputeResponseAPUF(wModel,APhi_TestSp,nTest,Size);
%     
%     Compare the wModel and MXPUF 
%     
%     count  = 0;
%     for i= 1:nTest 
%         if(WModel_Responses(i)==testSetResponses(i))
%             count= count+1;        
%         end 
%     end
%     
%     prediction_array(feedback_a,k)= abs( (count/nTest) - 0.5);
%     AAA(k)  = abs( (count/nTest) - 0.5);
%     
%     
%     end 
%   end   
%     
% end    
% 
% We compute the average accuracy of the attack
% prediction_array_average = zeros(chalSize); 
% 
% for feedback_a=1:chalSize
%         for k=1:U
%             prediction_array_average(feedback_a)= prediction_array_average(feedback_a) + prediction_array(feedback_a,k);
%         end
%         prediction_array_average(feedback_a)= prediction_array_average(feedback_a)/U;
% end






