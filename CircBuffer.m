classdef CircBuffer < handle
% A circular array-based buffer.
    properties
        D
        cursor = 0
        rows
        cols
    end
    
    properties(Dependent)
        ix
    end
    
    methods
        function bfr = CircBuffer(m,n)
            narginchk(1,2);
            if nargin == 1
                bfr.rows = [];
                bfr.cols = m;
            else
                bfr.rows = m;
                bfr.cols = n;
                bfr.init();
            end
        end
        
        function init(bfr)
            bfr.D = zeros(bfr.rows, bfr.cols);
        end
        
        function push(bfr, A)
            if isempty(bfr.rows), bfr.rows = size(A,1); bfr.init; end
            if size(A,1) ~= bfr.rows
                error('Number of rows is inconsistent with the buffer definition.');
            end
            n = size(A,2);
            if n > bfr.cols, error('Too many columns.'); end
            ix_linear = bfr.cursor+(1:n);
            ix_wraped = mod(ix_linear-1, bfr.cols)+1;
            bfr.D(:, ix_wraped) = A;
            bfr.cursor = ix_wraped(end);
        end
        
        function D = data(bfr)
            D = bfr.D(:,bfr.ix);
        end
        
        function val = get.ix(bfr)
            ix_linear = bfr.cursor+(1:bfr.cols);
            ix_wraped = mod(ix_linear-1, bfr.cols)+1;
            val = ix_wraped;
        end
        
        %% Wrappers
        function write(bfr, A)
            bfr.push(A);
        end
    end
end