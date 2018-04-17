%We compute the SAC_MXPUF 
%pi = 

n=64
x = 3 
y = 3
j = 31
SAC = zeros(n,1);
for i=0:(n-1)
   A = (1+(1-2*i/n)^x)/2 
   B = (1-(1-2*i/(n+1))^y)/2
   C = (1-(1-2*i/n)^x)/2
   D = (1-(1-2*abs(i-j)/(n+1))^y)/2
   SAC(i+1) = A*B + C*D
   fprintf('run: %f \n',SAC(i+1)); 
end   

   fprintf('influential bits %f \n', sum(SAC))