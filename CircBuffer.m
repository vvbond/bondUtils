classdef CircBuffer < handle
% A circular array-based buffer.
    properties
        D
        cursor = 0
        count = 0
        rows
        cols
    end
    
    properties(Dependent)
        ix
    end
        
    methods
        function bfr = CircBuffer(m, n)
            narginchk(1,2);
            if nargin == 1
                bfr.rows = [];
                bfr.cols = floor(m);
            else
                bfr.rows = floor(m);
                bfr.cols = floor(n);
                bfr.init();
            end            
        end
        
        function init(bfr)
            bfr.D = zeros(bfr.rows, bfr.cols);
            bfr.cursor = 0;
            bfr.count = 0;
        end
        
        function push(bfr, A)
            if isempty(bfr.rows), bfr.rows = size(A,1); bfr.init; end
            if size(A,1) ~= bfr.rows
                error('Number of rows is inconsistent with the buffer definition.');
            end
            n = size(A,2);
            if n > bfr.cols, error('CircBuffer: too many columns.'); end
            ix_linear = bfr.cursor+(1:n);
            ix_wrap = mod(ix_linear-1, bfr.cols)+1;
            bfr.D(:, ix_wrap) = A;
            bfr.cursor = ix_wrap(end);
            bfr.count = bfr.count + n;
        end
        
        function D = data(bfr)
            D = bfr.D(:,bfr.ix);
        end
        
        %% Setters/Getters
        function val = get.ix(bfr)
            ix_linear = bfr.cursor+(1:bfr.cols);
            ix_wrap = mod(ix_linear-1, bfr.cols)+1;
            val = ix_wrap;
        end
        
        %% Wrappers
        function write(bfr, A)
            bfr.push(A);
        end
    end
end