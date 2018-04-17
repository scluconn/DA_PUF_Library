function f = ComputePredictionAccuracy(A1,A2,nRows)
    f=0;
  
    for i=1:nRows
       if(A1(i)==A2(i))
           f = f+1;
       end
    end
    f = f/nRows;
end