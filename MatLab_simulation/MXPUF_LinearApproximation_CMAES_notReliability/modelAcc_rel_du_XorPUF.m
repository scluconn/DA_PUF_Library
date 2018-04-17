
function f = modelAcc_rel_du_XorPUF(PUF_w,x,chalSize,APhi,AResponse,nChallenge)

    x_XPw = splitXORPUF(PUF_w,x,chalSize);

    AResponse_XPUF_w_model = ComputeResponseXOR(x_XPw,x,APhi,nChallenge,chalSize+1);

    h_tilde = AResponse_XPUF_w_model;
    h       = AResponse;
    r = corrcoef(h,h_tilde,'rows','complete');
    f = r(1,2);
end