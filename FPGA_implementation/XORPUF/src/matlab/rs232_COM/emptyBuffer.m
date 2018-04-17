function emptyBuffer(s)

% empty serial buffer
    if(s.BytesAvailable > 0)
        fread(s,s.BytesAvailable);
    end

end