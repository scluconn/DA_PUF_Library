function [Avoting,AfixedBit,Anormal] = FilterMatrices(AMeasurement, nRows, nMeasurement,nReliability)
% This functions will filter out three matrices for analysis based on
% majority votings (Avoting), fixed bits (AfixedBit) and normal approach (Anormal). 
%Note that nCollums should be equal = nMeasurement * nReliability

%Anormal is AMeasurement with first nReliability collums 
Anormal = zeros(nRows,nReliability);

  for i=1:nRows
      for j=1:nReliability
          Anormal(i,j) = AMeasurement(i,j); 
      end
  end
%Avoting is computed based on AMeasurement for each Avoting(i,j) 
%= majorityvoting (AMeasurement(i,(j-1)*nMeasurement+1),...,AMeasuremnt(i,(j-1)*nMeasurement+nMeasurement))  

A0 = zeros(nRows,nReliability);
A1 = zeros(nRows,nReliability);

for i = 1:nRows
    for j=1:nReliability
       hL = (j-1)*nMeasurement +1;
       hH = (j-1)*nMeasurement +nMeasurement;
       for h= hL:hH
           if (AMeasurement(i,h)==0)
               A0(i,j) = A0(i,j)+1;
           else 
               A1(i,j) = A1(i,j)+1;
           end
       end
    end
end 

Avoting = zeros(nRows,nReliability);
AfixedBit = zeros(nRows,nReliability);

for i = 1:nRows
    for j=1:nReliability
       % Create Avoting 
        if(A0(i,j)>A1(i,j))
            Avoting(i,j) = 0;
        else 
            Avoting(i,j) = 1;
        end
       % Create AfixedBit
        if(A1(i,j)==0) %noisy challenge
            AfixedBit(i,j) = 0; %assigne reponse-1 to output
        else   % reliable challenge
            AfixedBit(i,j) = 1; % response-1    
        end        
%         if((A0(i,j)<nMeasurement)&(A0(i,j)>0)) %noisy challenge
%             AfixedBit(i,j) = 0; %assigne reponse-1 to output
%         else   % reliable challenge
%             if(A0(i,j)==nMeasurement)
%                 AfixedBit(i,j)=0; % response-0
%             else
%                 AfixedBit(i,j)=1; % response-1
%             end
%         end 
    end
end


end

