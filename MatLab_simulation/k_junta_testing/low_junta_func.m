function f = low_junta_func(input, dim)
    f = mod(sum(input(1:dim)),2);
end