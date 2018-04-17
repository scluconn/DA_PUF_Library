function chal = read_challenge(s,chal_size)

    global logFile;
    
    % Test if system is active and responding
    if(~test_and_clear(s))
        chal = -1;
        return;
    end
    
    % Empty serial buffer
    emptyBuffer(s);
    if(byteAvailabe(s))
          emptyBuffer(s);
    end
    %fclose(s);
    %fopen(s);
    % write read_challenge command
    write_command(s,'V');
    fprintf(logFile,'\nread_challenge: reading...');
    
    while(1)
        if(byteAvailabe(s))
            t=fread(s,1,'uint8');
            t=cast(t,'char');
            if(t=='B') 
                chal = fread(s,chal_size,'uint8');
                break;
            end    
        end
    end
    %fprintf('\nDone!!!');
end
