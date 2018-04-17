U = ones(1,3)
W = ones(1,3)
T = zeros(2,3)
T(1,:)=U
T(2,:)=W
X = T*transpose(U)

C = ones(1,10)
A = C(1:5)
B = C(6:10)
D = U/2;

E = U - W;
F=sum(E);

K=CompareTwoModels(U,W,3)

mu = 0
sigma = 1
chalSize = 64
Size = chalSize+1
w1=normrnd(mu,sigma,1,Size);
w2=normrnd(mu,sigma,1,Size);
K=CompareTwoModels(w1,w2,Size);