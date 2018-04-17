function [AResponse,APUFsResponse,AReliabilityRate] = ComputeNoisyResponsesXOR_FixedBit(XORw,nXOR,APhi,nRows,Size,ChalSize,sigma,sigmaNoise,Evaluations,nMeasurement)


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
  APUFsResponse = zeros(nXOR,nRows,Evaluations);  
  sigNoise = sigmaNoise*sigma;
  

%
  for e=1:Evaluations
      
      %Create a noise vector based on XORPUFgeneration with sigNoise
      XORwNoise= XORPUFgeneration(nXOR,ChalSize,0,sigNoise);
      %Create a XOR affected by the noise newXORw
      newXORw = zeros(nXOR,Size);
      for k=1:nXOR
          for  j=1:Size
              newXORw(k,j) = XORw(k,j) + XORwNoise(k,j);
          end
      end
      %Evaluate the responses
      
      for i=1:nRows
           %Outputs of each APUF instances 
            Sum = zeros(1,nXOR);
            
           %Compute the output of APUF A1 with Majority Voting 
           %nMeasurement is the number of evaluations to produce one bit
           %Use the counters Count0 and Count1 to compute the majority
           %value. Array M contains all nMeasuremnt computed values. It may
           %be used for fixed bit. Actually M is equivalent to (Count0,
           %Count1)
           
            M  =  zeros(nMeasurement,1);
            Count0 = 0;
            Count1 = 1;
            
            for m=1:nMeasurement 
                %Create noise based on XORPUFgeneration with sigNoise
                APUFnoise = XORPUFgeneration(1,ChalSize,0,sigNoise);
                %Update the APUF A1 with noise
                for j=1:Size
                  newXORw(1,j) = XORw(1,j) + APUFnoise(j);  
                end
                %Compute the response for each measurement m
                SumAPUF = 0;
                for j=1:Size
                    SumAPUF= newXORw(1,j)*APhi(i,j)+SumAPUF;
                end
                %Compute the response 
                if (SumAPUF>0)
                    M(m) = 0;
                    Count0 = Count0+1;
                else 
                    M(m) = 1;
                    Count1 = Count1+1;
                end                
            end 
           
            %Compute the respone following FixedBit based on Count0 and
            %Count1
            % APUFsResponse = zeros(nXOR,nRows,Evaluations);
            %Since Count1>0 means this is a noisy challenge or
            %reliable challenge with value = 1, we fix the value of r = 1 if Count1>0 
            
            if(Count1>0)
                   APUFsResponse(1,i,e) = 1;
                   Sum(1) = -1;
            else                
                   APUFsResponse(1,i,e) = 0;
                   Sum(1) = 1;
            end     
            
      
           %Compute the outputs of nXOR-1 APUFs A2, .., A(nXOR)
            for k=2:nXOR
               for j = 1:Size
                  Sum(k) = Sum(k) + newXORw(k,j)*APhi(i,j);  
               end
               if(Sum(k)>0)
                  APUFsResponse(k,i,e) = 0; 
               else
                  APUFsResponse(k,i,e) = 1; 
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
       end
      
  end
  
%AResponse(i,e) =>XORPUF
%APUFsResponse(k,i,e) =>APUFs A1,...,AnXOR
%We want to compute the reliability rate for XORPUF and A1,..,AnXOR

AReliabilityRate = zeros(1,nXOR+1);

%Compute the reliability rate of A1, ..,AnXOR
 for i=1:nXOR
     T = zeros(nRows,Evaluations);
     for j=1:nRows
         for e=1:Evaluations
            T(j,e)=APUFsResponse(i,j,e);
         end
     end         
     [UY,A0, A1, AReliabilityRate(i)] = ReliabilityRate(T, nRows, Evaluations);
 end
%Compute the reliability rate of XORPUF
 [UY,A0, A1, AReliabilityRate(nXOR+1)] = ReliabilityRate(AResponse, nRows, Evaluations);
 
 Count0A1=0;
 for i=1:nRows
    if(APUFsResponse(1,i,1)==0)
        Count0A1=Count0A1+1;
    end
 end    
 fprintf('BIAS: %f\n',Count0A1/nRows);
end

