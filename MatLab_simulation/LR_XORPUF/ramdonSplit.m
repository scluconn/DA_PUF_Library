
function [trainX,trainY,testX,testY] = ramdonSplit(C,R,nTrainSample)
    
    n = size(C,1);
    permIndex  = randperm(n);
    trainIndex = permIndex(1:nTrainSample);
    testIndex  = permIndex(nTrainSample+1:end);
    trainX = C(trainIndex,:);
    trainY = R(trainIndex,:);
    testX  = C(testIndex,:);
    testY  = R(testIndex,:);
end