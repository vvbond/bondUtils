classdef BufferReader < handle
    properties
        bfr
        cursor = 0
        count = 0
        n = 1
        hop = 1
    end
    methods
        %% {Con,De}structor
        function bfrr = BufferReader(bfr, n, hop)
            
            % Parse input:
            narginchk(1,3);
            bfrr.bfr = bfr;
            
            if nargin == 2
                bfrr.n = n;
                bfrr.hop = n;
            elseif nargin == 3
                bfrr.n = n;
                bfrr.hop = hop;
            end
            bfrr.init();
        end
        
        function init(bfrr)
            bfrr.cursor = bfrr.bfr.cursor;
            bfrr.count = bfrr.bfr.count;
        end
        
        %% Read
        function D = read(bfrr, n, hop)
            
            % Parse input:
            if nargin == 1
                n = bfrr.n;
                hop = bfrr.hop;
            elseif nargin == 2
                hop = bfrr.hop;
            end
                       
            % Check if there is enough data in the buffer:
            if (bfrr.count+n) <= bfrr.bfr.count
                ix_linear = bfrr.cursor + (1:n);
                ix_wrap = mod(ix_linear-1, bfrr.bfr.cols)+1;
                D = bfrr.bfr.D(:, ix_wrap);
                dum = bfrr.cursor + hop;
                bfrr.cursor = mod(dum-1, bfrr.bfr.cols)+1;
                bfrr.count = bfrr.count + hop;
            else 
                D = [];
            end
        end
    end
end