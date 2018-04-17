
function f = modelAcc_rel_du_MXPUF(MXPUF_w,x,y,fb_a,chalSize, ... 
                             AChallenge,AResponse,nChallenge)

    [x_XPw,y_XPw] = splitMXPUF(MXPUF_w,x,y,chalSize);

    AResponse_MXPUF_w_model = ComputeResponseMXPUF( ...
                       x_XPw,y_XPw,x,y,fb_a, ...
                       AChallenge,nChallenge,chalSize ...
                       );

    h_tilde = AResponse_MXPUF_w_model;
    h       = AResponse;
    r = corrcoef(h,h_tilde,'rows','complete');
    f = r(1,2);
end