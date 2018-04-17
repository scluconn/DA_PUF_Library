function [XP,MP] = MeasureXYXORPUF_MXPUF( ...
                   x,y,xXORw,yXORw, ...
                   fb_a,chalX,chalY, ...
                   E,sigmaNoise,sig, ...
                   nMSet,MSet ...
                   )

               
               
% In this function, we want to compute the noise rate of (x+y)-XOR PUF
% and (x,y)-MXPUF. 
% We have the following parameters as inputs:
% 1. x-XOR and y-XOR PUFs: x,y, xXORw, yXORw
% 2. feedback a, challenge sizes of x-XOR and y-XOR: fb_a, chalX, chalY
% 3. Noise configuration and number of evaluation: E, sigNoise
% 4. Configuration of APUF simulation: sig
% 5. Set of challenges for measurement and its cardinality:  MSet and nMSet

% The output of measurements for XOR PUF and MXPUF are XP and MP,
% respectively. Since there are nMSet challenges and we measure one
% challenge E times. XP (xor puf) and MP (mxpuf) are the matrices of size of 
% [nMSet-rows, E-columns]

%Initialize the XP and MP
XP = zeros(nMSet,E);
MP = zeros(nMSet,E);

%We evaluate the XORPUF and MXPUF E times 

 for e=1:E
  %Generate the noise 
  %Create noise vectors for x-XOR PUF and y-XOR PUF
      sigNoise = sigmaNoise*sig;
      xXORwNoise= XORPUFgeneration(x,chalX,0,sigNoise);
      yXORwNoise= XORPUFgeneration(y,chalY,0,sigNoise);
      %Create a XOR affected by the noise newXORw
      xnewXORw = ones(x,chalX+1);
      ynewXORw = ones(y,chalY+1);
      
      for j=1:(chalX+1)
          for k=1:x
              xnewXORw(k,j) = xXORw(k,j) + xXORwNoise(k,j);
          end
      end
      
      for j=1:(chalY+1)
          for k=1:y
              ynewXORw(k,j) = yXORw(k,j) + yXORwNoise(k,j);
          end
      end
      %%%
      %Evaluate the responses of (x+y)-XOR PUF. Note that the challenge of
      % y-XOR PUF will be c=(c0,...,c(i),fb_a =0,c(i+1),...,c(n-1))
      %%%
       
      %Compute the Phi_xXORPUF based on MSet,nMSet,chalX and Transform
      %function
      Phi_xXORPUF = Transform(MSet,nMSet,chalX);
      %Compute the response of xXORPUF based on Phi_xXORPUF,xnewXORw and
      %ComputeResponseXOR function with Size = chalX+1
      response_xXORPUF = ComputeResponseXOR(xnewXORw,x,Phi_xXORPUF,nMSet,chalX+1);
      
      %Compute the Phi_yXORPUF based on MSet,nMSet,chalY and Transform
      %function. Note that c=(c0,...,c(i),fb_a =0,c(i+1),...,c(n-1))
      
      %Create the challenge set for yXOR PUF
      yXORPUF_MSet = zeros(nMSet,chalY);
      for r=1:nMSet
          for c=1:(fb_a-1)
              yXORPUF_MSet(r,c) = MSet(r,c);
          end
      end 

      for r=1:nMSet
          for c=(fb_a+1):chalY
              yXORPUF_MSet(r,c) = MSet(r,c-1);
          end
      end      
      %Compute the Phi_yXORPUF based on yXORPUF_MSet,nMSet,chalY and Transform
      %function
      Phi_yXORPUF = Transform(yXORPUF_MSet,nMSet,chalY);
      %Compute the response of yXORPUF based on Phi_yXORPUF,ynewXORw and
      %ComputeResponseXOR function with Size = chalY+1
      response_yXORPUF = ComputeResponseXOR(ynewXORw,y,Phi_yXORPUF,nMSet,chalY+1);      
     
      %Compute the response of (x+y)-XOR PUF based on response_xXORPUF and 
      %response_yXORPUF for the evaluation e
      
      for r=1:nMSet
          XP(r,e) = mod(response_xXORPUF(r)+response_yXORPUF(r),2);
      end
      
      %%%
      %Evaluate the responses of (x,y)-MXPUF. Note that the challenge of
      % y-XOR PUF will be c=(c0,...,c(i),fb_a =response_xXORPUF,c(i+1),...,c(n-1))
      % We do not need to compute the response_xXORPUF, since it has been
      % done before. 
      %%%      
      
       %Create the challenge set for yXOR PUF
      yXORPUF_MXPUF_MSet = zeros(nMSet,chalY);
      for r=1:nMSet
          for c=1:(fb_a-1)
              yXORPUF_MXPUF_MSet(r,c) = MSet(r,c);
          end
      end 

      for r=1:nMSet
          for c=(fb_a+1):chalY
              yXORPUF_MXPUF_MSet(r,c) = MSet(r,c-1);
          end
      end   
      
      for r=1:nMSet
          yXORPUF_MXPUF_MSet(r,fb_a)=response_xXORPUF(r);
      end
      %Compute the Phi_yXORPUF based on yXORPUF_MSet,nMSet,chalY and Transform
      %function
      Phi_yXORPUF_MXPUF = Transform(yXORPUF_MXPUF_MSet,nMSet,chalY);
      %Compute the response of yXORPUF based on Phi_yXORPUF,ynewXORw and
      %ComputeResponseXOR function with Size = chalY+1
      response_yXORPUF_MXPUF = ComputeResponseXOR(ynewXORw,y,Phi_yXORPUF_MXPUF,nMSet,chalY+1);      
      
      %In case of MXPUF, the response of y-XOR PUF is the output of MXPUF
      for r=1:nMSet
          MP(r,e) = response_yXORPUF_MXPUF(r);
      end
      
     
 end    

end

