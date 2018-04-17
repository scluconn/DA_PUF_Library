
clear all;
clc;


%We simulate (x,y)-MXPUF
%MXPUF parameter
chalSize = 64;    % Bit length of challenge
mu = 0;           % Mean of variation in delay parameters
sigma = 1;        % Standard deviation of variation in delay parameters
x =3;        % x - number of APUFs in x-XOR PUF
y =3;        % y - number of APUFs in y-XOR PUF
feedback_a =32;   % feedback position to connect the output of x-XOR PUF and 
                  % the y-XOR PUF,  0<=feedback_a<=chalSize-1 

%generate (x,y)-MXPUF

[x_XPw,y_XPw]=MXPUFgeneration(x,y,chalSize,mu,sigma);

%generate Test Set  

nTest = 20000; %size of test set
testSetChallenges= randi([0 1], nTest, chalSize);
testSetResponses = ComputeResponseMXPUF( ...
                       x_XPw,y_XPw,x,y,feedback_a, ...
                       testSetChallenges,nTest,chalSize ...
                       );
                   
%We compute the SAC property of MXPUF by simulation

%Array containing the SAC value for position i=0,...,chalSize-1
SAC = zeros(chalSize,1);
                   
for i=1:chalSize
      %Generating the flipping challenge set 
      flippingSetChallenges = zeros(nTest,chalSize)
      
      %For each challenge, flip challenge bit c[i] 
      for j=1:nTest
          for k=1:chalSize
              if(k~=i)
                 flippingSetChallenges(j,k)= testSetChallenges(j,k);
              else
                 flippingSetChallenges(j,k)= mod(testSetChallenges(j,k)+1,2);
              end
          end
      end 
      %Compute the response of flipping challenge set
      flippingSetResponses = ComputeResponseMXPUF( ...
                       x_XPw,y_XPw,x,y,feedback_a, ...
                       flippingSetChallenges,nTest,chalSize ...
                       );
      %Compute the SAC, i.e., the flipping rate
      count = 0;
      for j=1:nTest
          if(flippingSetResponses(j)~=testSetResponses(j))
              count=count+1
          end
      end
      SAC(i)= count/nTest;
end
                   
