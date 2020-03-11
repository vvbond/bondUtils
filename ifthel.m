function y = ifthel(test, out1, out2)
% Ternary operator.
    
    if ischar(test)
        test = any(strcmpi(test, {'on', 'yes', 'y'}));
    end
    
    if test
        if isa(out1, 'function_handle')
            y = out1();
        else
            y = out1;
        end
    else
        if isa(out2, 'function_handle')
            y = out2();
        else
            y = out2;
        end
    end
end