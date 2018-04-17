
function [parityVec] = getParityVec(C,b)

    % C: set of challenges
    % C(i,1): msb
    % b = 0: C(i,:) \in {0,1}^n
    % b = 1: C(i,:) \in {-1,1}^n
    
    n = size(C,2);
    m = size(C,1);
    if(b==0)
        C(C==0)= -1;
    end

    parityVec = zeros(m,n+1);
    parityVec(:,1) = ones(m,1);
    for i=2:n+1
        parityVec(:,i) = prod(C(:,1:i-1),2);    
    end

end