
% Convert a string to color string
function coloredString = colorizestring(color, string)
%colorizestring wraps the given string in html that colors that text.
    coloredString = ['<font color="', color, '">', string, '</font>'];
end