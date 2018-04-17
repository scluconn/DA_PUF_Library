
% uniqueness within a board

clear all;
clc;

iDir = [pwd '/dataset/processedOutput/'];

N  = 64;
Br = 1;
nPUF = 2;
offset = 0;   

golden_respFile = [iDir 'respAg_' num2str(N) '_Br_' num2str(Br) '_all.mat'];
load(golden_respFile);
nChal = size(Ag,1);

misMatch_matrix = zeros(nPUF, nPUF);
    
for i = 1:nPUF-1
    for j = i+1:nPUF
        A_i = mod(Ag(:,i) + Ag(:,j),2);
        misMatch = sum(A_i)/nChal;
        if (misMatch > 0.62 | misMatch < 0.38)
           misMatch_matrix(i,j) = 1;
           misMatch_matrix(j,i) = 1;
           fprintf('%i, %i, %f \n', i, j, misMatch);
        end
    end
end

count_misMatch = zeros(1, nPUF);

for i = 1:nPUF
    count_misMatch(i) = sum(misMatch_matrix(i,:));
    %fprintf('%i, %i\n', i, count_misMatch(i));
end

remaining_PUF_list = ones(1,nPUF);

fprintf('eliminating, %i\n', sum(count_misMatch));

while sum(count_misMatch) ~= 0
    [temp, j] = max(count_misMatch);
    remaining_PUF_list(j) = 0;
    misMatch_matrix(j,:) = zeros(1,nPUF);
    misMatch_matrix(:,j) = zeros(nPUF, 1);
    for i = 1:nPUF
        count_misMatch(i) = sum(misMatch_matrix(i,:));
        %fprintf('%i, %i\n', i, count_misMatch(i));
    end
end

for i = 1:nPUF
    if remaining_PUF_list(i) == 1
       fprintf('%i, ', i+offset);
    end
end

fprintf('\n');
fprintf('\nDONE !!!\n');
%exit;