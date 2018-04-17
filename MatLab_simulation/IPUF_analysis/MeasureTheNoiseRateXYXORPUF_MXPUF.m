function [nrXP,nrMP,nrxXP,nryXP] = MeasureTheNoiseRateXYXORPUF_MXPUF( ...
                           sigma,chalSize,  ... %APUF configuration
                           x,y, feedback_a,  ... % feedback a, x-XOR PUF and y-XOR PUF parameter
                           sigmaNoise,Evaluations, Acceptance_Rate, nChallenges,  ... % parameters for measuring the noise
                           noise_Eva  ... %parameters for measuring the noise rate 
                           )

    nrXP = 0; % noise rate of (x+y)-XOR PUF
    nrMP = 0; % noise rate of (x,y)-MXPUF
    nrxXP =0; % noise rate of x-XOR PUF
    nryXP =0; % noise rate of y-XOR PUF   
    
    for nr_e=1:noise_Eva
        
        %Generate the x-XOR and y-XOR PUF
        
        %generate x-XOR PUF first. Note that the size of challenge to x-XOR PUF is
        %equal to chalSize.
        chalSize_xXORPUF = chalSize;
        x_XORw= XORPUFgeneration(x,chalSize_xXORPUF,0,sigma);

        %generate y-XOR PUF now. Note that the size of challenge to y-XOR PUF is
        %longer than the chalSize one bit 
        chalSize_yXORPUF = chalSize+1;
        y_XORw= XORPUFgeneration(y,chalSize_yXORPUF,0,sigma);
        
        nMeasureSet = nChallenges; %size of MeasureSet
        MeasureSet= randi([0 1], nMeasureSet, chalSize);
        
        [XP,MP,xXP,yXP] = MeasureXYXORPUF_MXPUF_xXPUF( ...
                   x,y,x_XORw,y_XORw, ...
                   feedback_a,chalSize_xXORPUF,chalSize_yXORPUF, ...
                   Evaluations,sigmaNoise,sigma, ...
                   nMeasureSet,MeasureSet ...
                   )
         REL = Acceptance_Rate;
         Threshold = Evaluations*REL;
         temp_nrMP = ComputeTheNoise(MP,nMeasureSet,Evaluations,Threshold);
         temp_nrXP = ComputeTheNoise(XP,nMeasureSet,Evaluations,Threshold);
         temp_nrxXP = ComputeTheNoise(xXP,nMeasureSet,Evaluations,Threshold);
         temp_nryXP = ComputeTheNoise(yXP,nMeasureSet,Evaluations,Threshold); 
         
         nrXP = nrXP + temp_nrXP/nMeasureSet; % noise rate of (x+y)-XOR PUF
         nrMP = nrMP + temp_nrMP/nMeasureSet; % noise rate of (x,y)-MXPUF
         nrxXP =nrxXP+ temp_nrxXP/nMeasureSet; % noise rate of x-XOR PUF
         nryXP =nryXP+ temp_nryXP/nMeasureSet; % noise rate of x-XOR PUF
         
    end   
    
         nrXP  = nrXP/noise_Eva; % noise rate of (x+y)-XOR PUF
         nrMP  = nrMP/noise_Eva; % noise rate of (x,y)-MXPUF
         nrxXP = nrxXP/noise_Eva; % noise rate of x-XOR PUF
         nryXP = nryXP/noise_Eva; % noise rate of x-XOR PUF
    
end