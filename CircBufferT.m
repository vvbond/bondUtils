classdef CircBufferT < Sink
% Circular buffer for typed data.
%
% Usage: 
%  bfr = CircBufferT(numels);  % Create a buffer.
%  bfr.push(el);               % Push an element to the buffer.
%  D = bfr.data;               % Fetch buffer data.    
%
% Examples:
%   bfr = CircBuffer([1 1], 10); for ii=1:13, bfr.push(rand); disp(bfr.data); end

    properties
        Q                   % buffer que: an array of structures, Q.el, where 'el' holds data of a single element.        
        width               % scalar, number of elements in the buffer.
        cursor              % index for the next element to be pushed to the Q.
        count               % push counter (unused, 'just in case' variable).
        delay = 0
    end
    properties(Dependent)
        ix                  % rotating que index.
    end
    
    events
        initialized
    end

    methods
        %% {Con,De}structor
        function bfr = CircBufferT(width)
            bfr.width = width;
            
            bfr.init();
            bfr.marker = 'd';
        end
        
        function init(bfr)

            for ii=1:bfr.width
                bfr.Q(ii).el = [];
            end
            
            bfr.cursor = 0;
            bfr.count = 0;
            % Let connected readers know:
            notify(bfr, 'initialized');
        end
        
        %% Push to buffer
        function push(bfr, el)
        % Push an element to the buffer.
            
%             n = length(el);
            n = 1;
            % Consistency check:
%             if ~all(size(el) == bfr.elsz)
%                 error('Wrong element size.');
%             end
            
            ix_linear = bfr.cursor + (1:n);
            ix_wrap   = mod(ix_linear-1, bfr.width)+1;
            bfr.Q(ix_wrap).el = el;            
            bfr.cursor = ix_wrap(end);
            bfr.count = bfr.count + n;
        end
        
        %% Fetch data
        function D = data(bfr, dIx)
            if nargin == 1
                dIx = bfr.ix;
            end
            D = [bfr.Q(dIx).el];
        end        
        
        %% Setters/Getters
        function val = get.ix(bfr)
            ix_linear = bfr.cursor+(1:bfr.width);
            ix_wrap = mod(ix_linear-1, bfr.width)+1;
            val = ix_wrap;
        end
        
        %% Wrappers
        function write(bfr, A)
            bfr.push(A);
        end
    end
end