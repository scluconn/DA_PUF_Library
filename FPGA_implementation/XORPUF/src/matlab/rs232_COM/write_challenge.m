function test = write_challenge(s,chal,nWord)

    global logFile;
    
    % Test if system is active and responding
    if(~test_and_clear(s))
        test = false;
        return;
    end
    
    % Empty serial buffer
    emptyBuffer(s)
    fprintf(logFile,'\nwrite_challenge: writing...');
    % Write challenge command C 
    write_command(s,'C');
    
    fwrite(s,nWord,'uint8');
    
    for i = 1:1:length(chal)  % chal(length(chal)) contains first challenge byte
         fwrite(s,chal(i),'uint8');
    end
    test = true;
end
