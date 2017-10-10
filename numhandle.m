classdef numhandle < handle
% Container handle class for numeric data.
    properties
        data
    end
    %% {Con,De}structor
    methods
        function nh = numhandle(num)
            nh.data = num;
        end
    end
    %% Setter
    methods
        function set(nh, val)
            nh.data = val;
        end
    end
    %% Operators overloading
    methods
        function d = double(nh)
            d = nh.data;
        end
        
        function r = plus(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a + b;
        end
        
        function r = minus(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a - b;
        end
        
        function r = uminus(obj1)
            a = double(obj1);            
            r = -a;
        end
        
        function r = uplus(obj1)
            a = double(obj1);            
            r = +a;
        end
                
        function r = times(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a .* b;
        end
        
        function r = mtimes(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a * b;
        end
        
        function r = rdivide(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a ./ b;
        end

        function r = ldivide(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a .\ b;
        end
        
        function r = mrdivide(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a / b;
        end

        function r = mldivide(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a \ b;
        end
        
        function r = power(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a.^b;
        end

        function r = mpower(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a^b;
        end
        
        function r = eq(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a == b;
        end
        
        function r = ne(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a ~= b;
        end

        function r = lt(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a < b;
        end        

        function r = gt(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a > b;
        end        

        function r = le(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a <= b;
        end        

        function r = ge(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a >= b;
        end

        function r = and(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a & b;
        end

        function r = or(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a | b;
        end

        function r = not(obj1)
            a = double(obj1);            
            r = a.';
        end
        
        function r = trnspose(obj1)
            a = double(obj1);            
            r = ~a;
        end
        
        function r = ctrnspose(obj1)
            a = double(obj1);            
            r = a';
        end
        
        function varargout = subsref(obj1, s)
            if strcmp(s(1).type, '.')
                builtin('subsref', obj1, s);
            else
                a = double(obj1);
                varargout = {builtin('subsref', a, s)};
            end
        end
    end
end