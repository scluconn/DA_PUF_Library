
function [x_XPw,y_XPw] = splitMXPUF(MXPUF_w,x,y,chalSize)
  
    %We define MXPUF_w= [x_XPw,y_XPw]
 
    x_XPw = zeros(x,chalSize+1);
    y_XPw = zeros(y,chalSize+2);
    
    %get x_XPw     
    for i=1:x
        for j=1:(chalSize+1)
            x_XPw(i,j) = MXPUF_w((i-1)*(chalSize+1) + j);
        end
    end 
    
    %get y_XPw     
    for i=1:y
        for j=1:(chalSize+2)
            y_XPw(i,j) = MXPUF_w( x*(chalSize+1)+(i-1)*(chalSize+2) + j);
        end
    end     
    

end