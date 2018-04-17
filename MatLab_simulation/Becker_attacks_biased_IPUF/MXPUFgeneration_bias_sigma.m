function [x_XPw,y_XPw, bias_pos_x, bias_pos_y] = MXPUFgeneration_bias_sigma(x,y,chalSize,mu,sigma)

  x_XPw = normrnd(mu,sigma,x,chalSize+1);
  bias_pos_x = zeros(chalSize+1,1);
  bias_pos_y = zeros(chalSize+2,1);

  temp = normrnd(mu, 6*sigma, x, chalSize + 1);
  
  r = randi([0 7],1,chalSize+1);
  x_XPw(r > 3) = temp(r > 3);
  bias_pos_x (r > 3) = 1;
  
  y_XPw = normrnd(mu,sigma,y,chalSize+2);
  
  temp = normrnd(mu, 6*sigma, x, chalSize + 2);
  r = randi([0 7],1,chalSize+2);
  y_XPw(r > 3) = temp(r > 3);
  bias_pos_y (r > 3) = 1;
  
end

