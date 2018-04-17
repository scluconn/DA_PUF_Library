function test = test_and_clear(s)
    
     global logFile;
    
    % Open serial port when not yet open
    if(~strcmp(s.Status,'open'))
        fopen(s);
    end
    
    %Empty receive buffer
    emptyBuffer(s);
    
    % write test command: A = Active ?
    write_command(s,'A');
    %fprintf(logFile,'\ntest_and_clear: waiting...');
    while(1)
        if(byteAvailabe(s))
            break;        
        end
    end
    fprintf(logFile,'\ntest_and_clear: Ok.');
    % check test response: Y = 'Yes'
    test = true;
    t=fread(s,1,'uchar');
    test = test & (t == 'Y');   
end