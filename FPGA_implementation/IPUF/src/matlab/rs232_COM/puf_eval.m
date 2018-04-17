function r = puf_eval(s,c,chal_size,resp_size,nWord)
    
    global logFile;
    
    % Test if system is active and responding
    if(~test_and_clear(s))
        fprintf(logFile,'\npuf_eval: conn. is not active.');
        r = -1;
        return;
    end
    
    
    % Test challenge length
    if(length(c)~=chal_size)
        fprintf(logFile,'\npuf_eval: wrong challenge length.');
        r = -1;
        return;
    end
    
    % test challenge byte values
    c = cast(c,'uint8');
    if(min(c) < 0 || max(c) > 255)
        fprintf(logFile,'\npuf_eval: challenge values exceed byte range.');
        r = -1;
        return;
    end
    
    % send challenge bytes
    write_challenge(s,c,nWord);
    
    % test if written challenge is correct
    tc = read_challenge(s,chal_size);
    size(tc);
    size(c);
    if(sum(c==tc')~=chal_size)
        fprintf(logFile,'\npuf_eval: challenge verification failed.');
        r = -1;
        return;
    end
    % start PUF evaluation and get response.
    r = start_puf(s,resp_size);  
end