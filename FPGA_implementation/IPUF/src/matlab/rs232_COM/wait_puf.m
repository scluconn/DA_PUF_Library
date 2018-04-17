function test = wait_puf(s)

    global logFile;
     % test if system is active and responding
    if(~test_and_clear(s))
        test=false;
        return;
    end
    
    % empty serial buffer
    emptyBuffer(s);
    
    % write wait PUF command and wait for finish
    test = false;
    fwrite(s,'W');
    fprintf(logFile,'\nwait_puf: PUF is being evaluated...');
    while(1)
       if(byteAvailabe(s))
           poll = fread(s,1,'uchar');
           poll= cast(poll,'char');
           if(poll=='F')
               test = true;
               break;       
           else
               if(poll=='E')
                    emptyBuffer(s);
                    fwrite(s,'W');   
               else
                     emptyBuffer(s);
                     fwrite(s,'W');
               end   
           end 
       end
    end
    fprintf(logFile,'\nFinished!');    
end