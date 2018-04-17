function [AResponse,AResponseAPUFs] = ComputeNoisyResponsesXOR000(XORw,nUpper,nXOR,APhi,nRows,Size,ChalSize,sigma,sigmaNoise1,sigmaNoise2,Evaluations)


%We are given the APUF which has: XORw weight vectors, nXOR APUFs, APhi
%vectors computed from array of challenges and the array has nRows, Size
%columns. The APUF is created by a given sigma, mu and has ChalSize-bit
%challenge

%We need to create a noisy CRPs with sigmaNoise and for each Challenge, we
%evaluate it Evaluation times. It means that we have an array of responses
%AResponse having nRows and Evaluations column. Typically, AResponse[i,j]
%is the response of challange[i] of Evaluation[j]. 



% The function computes the array of responses for a given array of feature
% vectors APhi and weight vector w
% The response = 0 if  w*APhi >0, otherwise = 1;
%   Detailed explanation goes here
  
%Creating an array of noisy Responses AResponse with nRows rows and
%Evaluations columns. 

  AResponse = ones(nRows,Evaluations);
  AResponseAPUFs = ones(nXOR,nRows,Evaluations);

%
  for e=1:Evaluations
      
      %Create noise vectors 
      sigNoise1 = sigmaNoise1*sigma;
      sigNoise2 = sigmaNoise2*sigma;
      
      
      XORwNoise1= XORPUFgeneration(nXOR,ChalSize,0,sigNoise1);
      XORwNoise2= XORPUFgeneration(nXOR,ChalSize,0,sigNoise2);
      
      %Create a XOR affected by the noise newXORw
      newXORw = ones(nXOR,Size);
      
      %Create newXORw for the class1=A1,...,A(nUpper) with sigNoise1
      for j=1:Size
          for k=1:(nUpper)
              newXORw(k,j) = XORw(k,j) + XORwNoise1(k,j);
          end
      end
      
      %Create newXORw for the class2=A(nUpper+1),...,A(nXOR) with sigNoise2
      for j=1:Size
          for k=(nUpper+1):nXOR
              newXORw(k,j) = XORw(k,j) + XORwNoise2(k,j);
          end
      end      
      
      
      %Evaluate the responses
      
      for i=1:nRows
           %Outputs of each APUF instances 
            Sum = zeros(1,nXOR);
      
           %Compute the outputs of nXOR APUFs
            for j=1:Size
               for k = 1:nXOR
                  Sum(k) = Sum(k) + newXORw(k,j)*APhi(i,j);  
               end
            end     
      
           %Compute the output of XORPUF 
            Prod = 1;
            
            for k=1:nXOR
               Prod = Prod*Sum(k);
            end

            if(Prod>0)
               AResponse(i,e)=0;
            else 
               AResponse(i,e)=1;
            end
            
            %Compute the output of APUFs
            for k=1:nXOR
                if(Sum(k)>0)
                    AResponseAPUFs(k,i,e)=0;
                else 
                    AResponseAPUFs(k,i,e)=1;
                end
            end
            
       end
      
  end
  
   


end

