
%**************************************************************************
% Convert a array of decimal into a binary vector/matrix. Each decimal value id
% represented by a 8-bit binary value.
%
% Author: D P Sahoo
% Last update: 6/6/2015
%**************************************************************************

function [B] = arrayToBinVec(D)
    
    n = size(D,1);
    m = size(D,2);
    
    nBits = m*8;
    B = zeros(n,nBits);
    
    for i=1:m
        s = (i-1)*8 + 1;
        e = i*8;
        
        d_i = D(:,i);
        b_i = de2bi(d_i,8);
        b_i = fliplr(b_i);
        B(:,s:e) = b_i;
    end
    
end