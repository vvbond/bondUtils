classdef CircBufferT < handle
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
        elsz                % {2,3}-vector describing the size of indivudual elements in the buffer.
        numels              % scalar, number of elements in the buffer.
    end
    
    properties(Hidden)
        ix                 % rotating que index.
        elix                % index for the next element to be pushed to the Q.
        count               % push counter (unused, 'just in case' variable).        
    end
    
    methods
        %% {Con,De}structor
        function bfr = CircBufferT(numels)
            bfr.numels = numels;

            % Init:
            for ii=1:bfr.numels
                bfr.Q(ii).el = [];
            end
            bfr.qix = 1:bfr.numels;
            bfr.elix = 1;
            bfr.push_count = 0;
        end
        
        %% Push to buffer
        function push(bfr, el)
        % Push an element to the buffer.
            
            % Consistency check:
            if ~all(size(el) == bfr.elsz)
                error('Wrong element size.');
            end
            
            bfr.Q(bfr.elix).A = el;
            bfr.elix = mod(bfr.elix, bfr.numels) + 1;
            bfr.qix = circshift(bfr.qix, -1);
            
            bfr.push_count = bfr.push_count + 1;    
        end
        
        %% Fetch data
        function D = data(bfr)
            D = [bfr.Q(bfr.qix).A];
        end        
    end
end