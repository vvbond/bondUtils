classdef FIFOBuffer < handle
    properties
        elsz
        numels
        Q
        qix
        push_count
        elix
    end
    methods
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
            D = zeros(bfr.elsz.*[1 bfr.numels]);
        end
        
        function push(bfr, el)
            
            % Consistency check:
            if ~all(size(el) == bfr.elsz)
                error('Wrong element size.');
            end
            
            bfr.push_count = bfr.push_count + 1;
            bfr.Q(bfr.elix).A = el;
            bfr.elix = mod(bfr.elix, bfr.numels) + 1;
            bfr.qix = circshift(bfr.qix, -1);
        end
        
        function D = data(bfr)
            D = [bfr.Q(bfr.qix).A];
        end        
    end
end