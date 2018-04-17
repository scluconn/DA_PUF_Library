% S1 = load('XORPUF_x_6_20bit_20000Challenges.mat');
% S2 = load('MXPUF_x_5_y_1_20bit_20000Challenges_feedback10.mat');
% S3 = load('MXPUF_x_4_y_2_20bit_20000Challenges.mat');
% S4 = load('MXPUF_x_3_y_3_20bit_20000Challenges_feedback10.mat');
% 
% S = zeros(10,4);
% 
% for i=1:10
%     S(i,1)=S1.PredAcc(i);
%     S(i,2)=S2.PredAcc(i);
%     S(i,3)=S3.PredAcc(i);
%     S(i,4)=S4.PredAcc(i);    
% end
% % 
% % fprintf('%d',S.Result(1,:));
%  %set(gca,'fontsize',10);
%  %set('LineWidth',10)
%  plot(S);
% legend('6-XOR APUF','(5,1)-MXPUF','(4,2)-MXPUF','(3,3)-MXPUF');


S1 = load('reliability_XP_MP_xXP_yYP_y_22.mat');
plot(S1.Result);
legend('(x+y)-XOR APUF','(x,y)-MXPUF','x-XOR APUF','y-XOR APUF');
