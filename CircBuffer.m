classdef CircBuffer < handle
% Class implementing a circular buffer for arrays.
%
% Usage: 
%  bfr = FIFOBuffer(elsz, numels);  % Create a buffer.
%  bfr.push(el);                    % Push an element to the buffer.
%  D = bfr.data;                    % Fetch buffer data.    
%
% Examples:
%   bfr = FIFOBuffer([1 1], 10); for ii=1:13, bfr.push(rand); disp(bfr.data); end

    properties
        elsz                % {2,3}-vector describing the size of indivudual elements in the buffer.
        numels              % scalar, number of elements in the buffer.
    end
    
    properties(Hidden)
        Q                   % buffer que: an array of structures, Q.A, where A holds data of a single element.
        qix                 % rotating que index.
        elix                % index for the next element to be pushed to the Q.
        push_count          % push counter (unused, 'just in case' variable).
        
    end
    
    methods
        %% {Con,De}structor
        function bfr = FIFOBuffer(elsz, numels)
            bfr.numels = numels;
            bfr.elsz = elsz;
            % Init:
            for ii=1:bfr.numels
                bfr.Q(ii).A = zeros(bfr.elsz);
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