
function [x_XPw] = splitXORPUF(XPUF_w,x,chalSize)
  
    %We define MXPUF_w= [x_XPw,y_XPw]
 
    x_XPw = zeros(x,chalSize+1); 
    
    %get x_XPw     
    for i=1:x
        for j=1:(chalSize+1)
            x_XPw(i,j) = XPUF_w((i-1)*(chalSize+1) + j);
        end
    end 
   

end