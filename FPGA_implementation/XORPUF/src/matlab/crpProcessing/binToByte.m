
% Binary vector to Bytes.
% Consider 8-bits group from right.

function [byteSet] = binToByte(binMat)
    
    m = size(binMat,2); 
    n = size(binMat,1); 
    
    nByte = ceil(m/8);
    byteSet = zeros(n,nByte);
    
    
    for i=1:nByte
        
        sIndx = (i-1)*8 + 1;
        eIndx = i*8;
        
        x = binMat(:, sIndx:eIndx);
        x = fliplr(x);
        y = bi2de(x);
        byteSet(:,i) = y;
    end
    
    
end