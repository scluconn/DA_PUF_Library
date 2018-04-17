
%**************************************************************************
% Generate all placement constraints for switch chain in arbiter puf.
% Type-A: Place either MUXes on a single slice and switches are placed 
% vertically.
%**************************************************************************

clear all;
clc;

%**************************************************************************
% User defined parameters
%**************************************************************************
nStage_1 = 64;     % Numner of switches on arbiter PUF
nStage_2 = nStage_1+1;     % Numner of switches on arbiter PUF
K1 = 1;
K2 = 1;

topModuleName_1 = 'iXAPUF/XAPUF_T/PUFList[%d].APUF/';
topModuleName_2 = 'iXAPUF/XAPUF_B/PUFList[%d].APUF/';
placementType = '';

%  topMouleName = '';
%  placementType = '_alone';

%**************************************************************************
% Constraint file name
filename = [ 'iXAPUF_' num2str(nStage_1)  '_a' num2str(K1) '_' num2str(K2) '_equal_weight.ucf' ];
fid=fopen(filename,'w');
if(fid==-1)
   disp('File cannot be created.'); 
end
%**************************************************************************

%CJ
%23 PUFs
X = [10 30 32 34 36 38 40 44 46 48 50 52 54 56 60 62 64 66 68 70 72 74 76];  % X coordinate (even)

%perfect 23APUF
seed_list = [98, 16, 76, 86, 88, 77, 39, 101, 90, 79, 102, 47, 70, 81, 91, 85, 57, 96, 59, 60, 84, 62, 63];

j=1;

prefix = ['INST "' num2str(topModuleName_1)];

for k=1:K1

    xStart = X(j);
    yStart = 2;
    seed = seed_list(j);
        
    %fname = ['placementType_RAND'];
    fname = ['placementType_ABCD'];
    %feval(fname,xStart,yStart, fid, prefix, k, nStage_1,seed)
    
    %special case for (1,1) IPUF
    %feval(fname,xStart,yStart, fid, prefix, k, nStage_1,seed_list(11))
    feval(fname,10,yStart, fid, prefix, k, nStage_1)
    
    j = j+1;
    
end

prefix = ['INST "' num2str(topModuleName_2)];

for k=1:K2

    xStart = X(j);
    yStart = 2;
    seed = seed_list(j);
        
    %fname = ['placementType_RAND'];
    fname = ['placementType_DDDD'];
    %feval(fname, xStart, yStart, fid, prefix, k, nStage_2, seed)
    
    %special case for (1,1) IPUF
    %feval(fname,xStart,yStart, fid, prefix, k, nStage_2,seed_list(14))
    feval(fname,44,yStart, fid, prefix, k, nStage_2)
    
    j = j+1;
    
end

fclose(fid);

cprintf('*green','\nUCF file successfully generated.\n\n');