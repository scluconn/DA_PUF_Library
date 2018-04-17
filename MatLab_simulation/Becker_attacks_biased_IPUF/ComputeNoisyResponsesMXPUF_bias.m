function [AResponse] = ComputeNoisyResponsesMXPUF_bias(x_XPw,y_XPw,x,y,fb_a, bias_pos_x, bias_pos_y,...
                                     AChallenge,nChallenge,chalSize,mu,sigma,sigmaNoise,Evaluations)

 AResponse = zeros(Evaluations,nChallenge);

 for e=1:Evaluations  
     
      %Create a noise vector 
      sigNoise = sigmaNoise*sigma;
      
      %generate (x,y)-MXPUF

      [x_XPw_Noise,y_XPw_Noise]=MXPUFgeneration(x,y,chalSize,mu,sigNoise);
      
      [Lg_x_XPw_Noise,Lg_y_XPw_Noise]=MXPUFgeneration(x,y,chalSize,mu,6*sigNoise);
      
      %Create a MXPUF affected by the noise [x_XPw_Noise,y_XPw_Noise]
      %new_x_XPw = x_XPw + x_XPw_Noise;
      %new_y_XPw = y_XPw + y_XPw_Noise;
      
      for i = 1: chalSize+1
          if bias_pos_x == 1
              new_x_XPw(i) = x_XPw(i) + Lg_x_XPw_Noise(i);
          else
              new_x_XPw(i) = x_XPw(i) + x_XPw_Noise(i);
          end
      end
      
     for i = 1: chalSize+2
          if bias_pos_y == 1
              new_y_XPw(i) = y_XPw(i) + Lg_y_XPw_Noise(i);
          else
              new_y_XPw(i) = y_XPw(i) + y_XPw_Noise(i);
          end
      end
      
      %Evaluate the responses
    
      AResponse(e,:)= ComputeResponseMXPUF( ...
                                           new_x_XPw,new_y_XPw,x,y,fb_a, ...
                                           AChallenge,nChallenge,chalSize ...
                                           )
       
  end  
end

