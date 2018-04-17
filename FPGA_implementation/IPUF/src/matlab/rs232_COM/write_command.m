function write_command(s,ch)

    global logFile;
   
    % write test command: C
    val=cast(ch,'uint8');
    %fprintf(logFile,'\nWrite_commands: Byte to be written: %d',val);
    fwrite(s,val,'uint8'); 
end