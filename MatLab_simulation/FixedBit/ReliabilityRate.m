function [AReliabilityRate,A0, A1, reliabilityRate] = ReliabilityRate(AResponse, nRows, nCollums)

%This function computes the ReliabilityRate for an array with nRows and
%nCollum. Each collum corresponds to one measurement of a given challenge
%ci or (AResponse(i,j) and we compute the Repeatibility for each challenge
%(AReliabilityRate)
%and ReliabibilityRate (reliabilityRate) over all challenges

AReliabilityRate = zeros (nRows,1);
A0               = zeros (nRows,1);
A1               = zeros (nRows,1);
reliabilityRate  = 0;
  
  for i=1:nRows
      for j=1:nCollums
         if ( AResponse(i,j) == 1)
             A1(i) = A1(i)+1;
         else 
             A0(i) = A0(i)+1;
         end
      end
  end
  
  for i=1:nRows
      for j=2:nCollums
         if (AResponse(i,j) == AResponse(i,1))
           AReliabilityRate(i) = AReliabilityRate(i)+1;
         end
      end
  end

  for i=1:nRows
      if(AReliabilityRate(i)==(nCollums-1))
          reliabilityRate = reliabilityRate+1;
      end
  end
  
  reliabilityRate = reliabilityRate/nRows;
end

