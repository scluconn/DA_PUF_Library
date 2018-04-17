function [x_XPw,y_XPw] = MXPUFgeneration_bias(x,y,chalSize,mu,sigma)

  x_XPw = normrnd(mu,sigma,x,chalSize+1);

  temp = normrnd(mu+10, sigma, x, chalSize + 1);
  
  r = randi([0 4],1,chalSize+1);
  x_XPw(r > 3) = temp(r > 3);
  
  y_XPw = normrnd(mu,sigma,y,chalSize+2);
  
  temp = normrnd(mu+10, sigma, x, chalSize + 2);
  r = randi([0 4],1,chalSize+2);
  y_XPw(r > 3) = temp(r > 3);

  
end

