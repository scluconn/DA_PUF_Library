function [x_XPw,y_XPw, bias_pos_x, bias_pos_y] = MXPUFgeneration_bias_sigma_controlled_position(x,y,chalSize,mu,sigma, num_biased_weight)

  threshold = 3;
  x_XPw = normrnd(mu,sigma,x,chalSize+1);
  bias_pos_x = zeros(chalSize+1,1);
  bias_pos_y = zeros(chalSize+2,1);

  temp = normrnd(mu, 6*sigma, x, chalSize + 1);
  
  r = randi([0 7],1,chalSize+1);
  x_XPw(r > 3) = temp(r > 3);
  bias_pos_x (r > 3) = 1;
  
  flag = 0;
  
  while flag == 0
      r = randi([0 7],1,chalSize+2);
      temp = normrnd(mu, 6*sigma, y, chalSize + 2);
      cnt = 0;
      sprintf("new")
      for i = chalSize/2+1 : chalSize+2 
          if abs(temp(i)) > threshold && r(i) > 3
              i
              cnt = cnt + 1;
          end
      end
      if cnt == num_biased_weight
          flag = 1;
      end
  end
  
  store_y = normrnd(mu,sigma,y,chalSize+2);
  y_XPw = store_y;
  %y_XPw = normrnd(mu,sigma,y,chalSize+2);
  y_XPw(r > 3) = temp(r > 3);
  bias_pos_y (r > 3) = 1;
  
end