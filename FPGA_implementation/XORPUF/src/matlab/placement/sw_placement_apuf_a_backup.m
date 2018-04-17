
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
nStage = 64;     % Numner of switches on arbiter PUF

%23 PUFs
X = [10 30 32 34 36 38 40 44 46 48 50 52 54 56 60 62 64 66 68 70 72 74 76];  % X coordinate (even)

Type = ['ABCD', 'ADAD', 'BCBC', 'BDBD', 'CDCD', 'BBBB', 'CCCC', 'DDDD'];

nPAUF = 8;

topModuleName = 'XAPUF/PUFList[%d].APUF/';
placementType = '';

%  topMouleName = '';
%  placementType = '_alone';

prefix = ['INST "' num2str(topModuleName)];

%**************************************************************************
% Constraint file name
filename = [ 'APUF_' num2str(nStage)  '_a8_equal.ucf' ];
fid=fopen(filename,'w');
if(fid==-1)
   disp('File cannot be created.'); 
end
%**************************************************************************

offset = 96;

%good 23APUF
seed_list = [98, 16, 76, 86, 88, 77, 39, 101, 90, 79, 102, 47, 70, 81, 91, 85, 57, 96, 59, 60, 84, 62, 63];

for k=1:nPAUF

    xStart = X(k);
    yStart = 2;
    %yStart = Y(k);
    
    %seed = k + offset;
    %seed = seed_list(k);
    fname = ['placementType_' Type(4*k-3:4*k)];
    %fname = ['placementType_1'];
    %fname = ['placementType_' num2str(k)];
    %if k == 1
    %    fname = ['placementType_DCBA'];
    %else
    %    fname = ['placementType_RAND'];
    %end
    %fname = ['placementType_RAND'];
    %feval(fname,xStart,yStart, fid, prefix, k, nStage, seed)
    feval(fname,xStart,yStart, fid, prefix, k, nStage)
    
end


fclose(fid);

cprintf('*green','\nUCF file successfully generated.\n\n');
