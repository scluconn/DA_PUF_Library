function r = start_puf(s,resp_size)

    global logFile;
    
    % test if system is active and responding
    if(~test_and_clear(s))
        fprintf(logFile,'\nstart_puf: conn. not active');
        r=-1;
        return;
    end
    
    % empty serial buffer
    emptyBuffer(s)
    
    % write start PUF evaluation command
    write_command(s,'S');
    
    % Test response 'Q'
    fprintf(logFile,'\nstart_puf: waiting for ack');
    while(1)
      if(byteAvailabe(s))
         if(fread(s,1,'uint8')=='Q')        
            break;
         else
             r = -1;
             fprintf(logFile,'\nstart_puf: received wrong response.');
             return;
         end
      end
    end
    
    %Empty serial buffer
    emptyBuffer(s);
    
    %Wait for response
    if(~wait_puf(s))
        fprintf(logFile,'\nstart_puf: evaluation is finished an expected way.');
        r= -1;
        return;
    end
    
    % read responses bytes
    r = fread(s,resp_size,'uchar');    
    fprintf(logFile,'\n');
end