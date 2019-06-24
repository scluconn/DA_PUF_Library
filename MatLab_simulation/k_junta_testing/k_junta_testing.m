% Base on a lecture note: Property Testing of Functions, Junta Testing
% available at https://courses.cs.washington.edu/courses/cse522/14sp/lectures/lect16.pdf
% Please specify k_junta and epsilon below. The result of the testing will
% be printed to the screen.
% Notice that k_junta testing is a randomized algorithm with successful probability >= 2/3.
% Do repeat it for a few times.

clear all;
clc;



%We simulate (x,y)-IPUF
%IPUF parameter
chalSize = int32(64);    % Bit length of challenge
mu = 0;           % Mean of variation in delay parameters
sigma = 1;        % Standard deviation of variation in delay parameters

%IPUF generation
x_nXOR =1;        % x - number of APUFs in x-XOR PUF
y_nXOR =1;        % y - number of APUFs in y-XOR PUF
feedback_a = 32;   % feedback position to connect the output of x-XOR PUF and
% the y-XOR PUF,  0<=feedback_a<=chalSize-1

chalSize_xXORPUF = chalSize;
x_XORw= XORPUFgeneration(x_nXOR,chalSize_xXORPUF,mu,sigma);

chalSize_yXORPUF = chalSize+1;
y_XORw= XORPUFgeneration(y_nXOR,chalSize_yXORPUF,mu,sigma);

%APUF generation

APUF_XOR = 1;
chalSize_APUF = chalSize;
APUFw= XORPUFgeneration(APUF_XOR,chalSize_APUF,mu,sigma);

%XOR APUF generation

XORAPUF_XOR = 2;
chalSize_XORAPUF = chalSize;
XORAPUFw= XORPUFgeneration(XORAPUF_XOR,chalSize_XORAPUF,mu,sigma);

%Paremeter settings for k junta test
k_junta = int32(63);
epsilon = 0.2;
t = 12 * (k_junta + 1) / epsilon;

dimension = [1:chalSize]; %All possible input positions for k-junta testing
junta_cnt = int32(0);

Evaluations =1; %The number of evaluations of a single challenge.
sigmaNoise = 0; %The standard deviation of the noise. When sigmaNoise = 0, it means it is a perfectly reliable PUF.
nMeasureSet = 1; %The size of the challenge set of one evaluation.

%1 means testing IPUF, 0 means testing some known low junta function for
%the correctness of the program, 2 means 2XOR APUF, and 3 means APUF.
PUF = 1;

junta_upper_bound = 20; %This variable is only useful when PUF = 0. This is the upper bound of k-junta testing of low_junta_func.

counter_no = 0;
counter_yes = 0;

for iteration = 1 : 100
    
    for r = 1: t
        Chal_1 = randi([0 1], 1, chalSize);
        Chal_2 = randi([0 1], 1, chalSize);
        for loop_cnt = 1:chalSize
            if dimension(loop_cnt) == 0
                Chal_2(1, loop_cnt) = Chal_1(1,loop_cnt);
            end
        end
        if (PUF == 1) %(1,1)-IPUF
            [Output_xyXORPUF1, Output_xyMXPUF1]= MeasureXYXORPUF_MXPUF( ...
                x_nXOR,y_nXOR,x_XORw,y_XORw, ...
                feedback_a,chalSize_xXORPUF,chalSize_yXORPUF, ...
                Evaluations,sigmaNoise,sigma, ...
                nMeasureSet,Chal_1 ...
                );
            [Output_xyXORPUF2, Output_xyMXPUF2]= MeasureXYXORPUF_MXPUF( ...
                x_nXOR,y_nXOR,x_XORw,y_XORw, ...
                feedback_a,chalSize_xXORPUF,chalSize_yXORPUF, ...
                Evaluations,sigmaNoise,sigma, ...
                nMeasureSet,Chal_2 ...
                );
        elseif (PUF == 0) %Known low junta function to test the correctness of this program
            Output_xyMXPUF1 = low_junta_func(Chal_1, junta_upper_bound);
            Output_xyMXPUF2 = low_junta_func(Chal_2, junta_upper_bound);
        elseif (PUF == 2) %2-XOR APUF
            Phi_XORAPUF1 = Transform(Chal_1,nMeasureSet,chalSize_XORAPUF);
            Output_xyMXPUF1 = ComputeResponseXOR(XORAPUFw,XORAPUF_XOR,Phi_XORAPUF1,nMeasureSet,chalSize_XORAPUF+1);
            Phi_XORAPUF2 = Transform(Chal_2,nMeasureSet,chalSize_XORAPUF);
            Output_xyMXPUF2 = ComputeResponseXOR(XORAPUFw,XORAPUF_XOR,Phi_XORAPUF2,nMeasureSet,chalSize_XORAPUF+1);
        else %PUF = 3 Function under test is APUF
            Phi_APUF1 = Transform(Chal_1,nMeasureSet,chalSize_APUF);
            Output_xyMXPUF1 = ComputeResponseXOR(APUFw,APUF_XOR,Phi_APUF1,nMeasureSet,chalSize_APUF+1);
            Phi_APUF2 = Transform(Chal_2,nMeasureSet,chalSize_APUF);
            Output_xyMXPUF2 = ComputeResponseXOR(APUFw,APUF_XOR,Phi_APUF2,nMeasureSet,chalSize_APUF+1);
        end
        
        if Output_xyMXPUF1 ~= Output_xyMXPUF2
            search_order = dimension((Chal_1 - Chal_2) ~= 0);
            old_flip_num = int32(size(search_order,2));
            search_order = search_order(randperm(old_flip_num));
            
            flip_num = idivide(old_flip_num , 2, 'floor');
            while flip_num >= 1
                test_Chal = Chal_1;
                for index = 1:flip_num
                    test_Chal(1,search_order(index)) = 1 - test_Chal(1,search_order(index));
                end
                if PUF == 1
                    [Output_xyXORPUF_test, Output_xyMXPUF_test]= MeasureXYXORPUF_MXPUF( ...
                        x_nXOR,y_nXOR,x_XORw,y_XORw, ...
                        feedback_a,chalSize_xXORPUF,chalSize_yXORPUF, ...
                        Evaluations,sigmaNoise,sigma, ...
                        nMeasureSet,test_Chal ...
                        );
                elseif (PUF == 0) %low junta function
                    Output_xyMXPUF_test = low_junta_func(test_Chal, junta_upper_bound);
                elseif (PUF == 2) %2-XOR APUF
                    Phi_XORAPUF = Transform(test_Chal,nMeasureSet,chalSize_XORAPUF);
                    Output_xyMXPUF_test = ComputeResponseXOR(XORAPUFw,XORAPUF_XOR,Phi_XORAPUF,nMeasureSet,chalSize_XORAPUF+1);
                else %Function under test is APUF
                    Phi_APUF = Transform(test_Chal,nMeasureSet,chalSize_APUF);
                    Output_xyMXPUF_test = ComputeResponseXOR(APUFw,APUF_XOR,Phi_APUF,nMeasureSet,chalSize_APUF+1);
                end
                
                if Output_xyMXPUF_test ~= Output_xyMXPUF1
                    Output_xyMXPUF2 = Output_xyMXPUF_test;
                    old_Chal = Chal_2;
                    Chal_2 = test_Chal;
                    search_order = search_order(1:flip_num);
                    new_flip_num = idivide(flip_num, 2, 'floor');
                    old_flip_num = flip_num;
                else
                    Output_xyMXPUF1 = Output_xyMXPUF_test;
                    old_Chal = Chal_1;
                    Chal_1 = test_Chal;
                    search_order = search_order(flip_num+1:old_flip_num);
                    new_flip_num = idivide(old_flip_num-flip_num, 2, 'floor');
                    old_flip_num = old_flip_num - flip_num;
                end
                flip_num = new_flip_num;
            end
            if PUF == 1
                [Output_xyXORPUF1, Output_xyMXPUF1]= MeasureXYXORPUF_MXPUF( ...
                    x_nXOR,y_nXOR,x_XORw,y_XORw, ...
                    feedback_a,chalSize_xXORPUF,chalSize_yXORPUF, ...
                    Evaluations,sigmaNoise,sigma, ...
                    nMeasureSet,Chal_1 ...
                    );
                [Output_xyXORPUF2, Output_xyMXPUF2]= MeasureXYXORPUF_MXPUF( ...
                    x_nXOR,y_nXOR,x_XORw,y_XORw, ...
                    feedback_a,chalSize_xXORPUF,chalSize_yXORPUF, ...
                    Evaluations,sigmaNoise,sigma, ...
                    nMeasureSet,Chal_2 ...
                    );
            elseif (PUF == 0)
                Output_xyMXPUF1 = low_junta_func(Chal_1,junta_upper_bound);
                Output_xyMXPUF2 = low_junta_func(Chal_2,junta_upper_bound);
            elseif (PUF == 2) %2-XOR APUF
                Phi_XORAPUF1 = Transform(Chal_1,nMeasureSet,chalSize_XORAPUF);
                Output_xyMXPUF1 = ComputeResponseXOR(XORAPUFw,XORAPUF_XOR,Phi_XORAPUF1,nMeasureSet,chalSize_XORAPUF+1);
                Phi_XORAPUF2 = Transform(Chal_2,nMeasureSet,chalSize_XORAPUF);
                Output_xyMXPUF2 = ComputeResponseXOR(XORAPUFw,XORAPUF_XOR,Phi_XORAPUF2,nMeasureSet,chalSize_XORAPUF+1);
            else %Function under test is APUF
                Phi_APUF1 = Transform(Chal_1,nMeasureSet,chalSize_APUF);
                Output_xyMXPUF1 = ComputeResponseXOR(APUFw,APUF_XOR,Phi_APUF1,nMeasureSet,chalSize_APUF+1);
                Phi_APUF2 = Transform(Chal_2,nMeasureSet,chalSize_APUF);
                Output_xyMXPUF2 = ComputeResponseXOR(APUFw,APUF_XOR,Phi_APUF2,nMeasureSet,chalSize_APUF+1);
            end
            junta_cnt = junta_cnt + 1;
            dimension(search_order(1)) = 0;
        end
        if junta_cnt > k_junta
            counter_no = counter_no + 1;
            fprintf("not %d-junta\n",k_junta);
            break;
        end
    end
    if junta_cnt <= k_junta
        counter_yes = counter_yes + 1;
        fprintf("This is a %d-junta\n",k_junta);
    end
    
end
fprintf("%d-junta testing: No %d, Yes %d\n", k_junta, counter_no, counter_yes);