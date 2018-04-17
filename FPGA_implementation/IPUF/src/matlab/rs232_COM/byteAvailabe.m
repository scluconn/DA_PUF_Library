function test = byteAvailabe(s)

% empty serial buffer
    if(s.BytesAvailable > 0)
        test = true;
    else 
        test = false;
    end

end