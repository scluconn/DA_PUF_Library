
%**************************************************************************
% Convert a array of decimal into a binary vector/matrix. Each decimal value id
% represented by a 8-bit binary value.
%
% Author: D P Sahoo
% Last update: 6/6/2015
%**************************************************************************

function [B] = arrayToBinVec_a(D,S)
    
    % Input 1D or 2D array
    % D is array of #Bits representation for each column
    
    n = size(D,1);
    m = size(D,2);
    
    nBits = sum(S);
    B = zeros(n,nBits);
    
    e=0;
    for i=1:m
        s = e + 1;
        e = sum(S(1:i));
        
        d_i = D(:,i);
        b_i = de2bi(d_i,S(i));
        b_i = fliplr(b_i);
        B(:,s:e) = b_i;
    end
    
end