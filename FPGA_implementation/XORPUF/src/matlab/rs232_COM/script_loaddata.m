clear
response_files = {  'fpga1_responses_100.mat',
                    'fpga2_responses_100.mat',
                    'fpga3_responses_100.mat',
                    'fpga4_responses_100.mat',
                    'fpga5_responses_100.mat'
                  };
                
no_fpga = length(response_files);

load(response_files{1});
no_meas = size(resp,2);
r = zeros(no_chal,no_meas,no_fpga);
c = zeros(no_chal,no_meas,no_fpga);
for i = 1:no_fpga
    clear resp comp
    load(response_files{i});
    r(:,:,i) = resp;
    c(:,:,i) = comp;
end
clear resp comp