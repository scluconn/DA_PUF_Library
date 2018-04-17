
% frequence of each element
%uEle = unique(xx);
%y = hist(xx,uEle);

%This can be done by following:
y1 = tabulate(resp(:,1,1));
y2 = tabulate(resp(:,2,1));

xx1 = arrayToBinVec(resp(:,1,1));
xx2 = arrayToBinVec(resp(:,2,1));
xx3 = arrayToBinVec(resp(:,3,1));

xx = [xx1 xx2 xx3];
sum(xx)/nChal