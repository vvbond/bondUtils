classdef IBezierChain < handle
    properties
        segment
    end
    
    properties(Dependent)
        l
    end
    
    %% {Con,De}structor
    methods        
        function bzch = IBezierChain(segment)
            if isa(segment, 'IBezier3')
                bzch.segment = segment;
            else
                error('Wrong argument type. Must be an IBezier3 segment.');
            end
        end
        
        function delete(bzch)
            delete(bzch.segment);
        end
    end
    
    %% Segments
    methods
        function add_segment(bzch)
        % Add an IBezier segment.
            bzch.segment = [bzch.segment IBezier3(bzch.segment(end).cpt(4))];
        end
        
        function toggle_controls(bzch)
            for ii=1:length(bzch.segment)
                bzch.segment(ii).toggle_controls;
            end
        end
    end
    
    %% Line
    methods
        function l = get.l(bzch)
            l = [];
            for ii=1:length(bzch.segment)
                l = [l bzch.segment(ii).l]; %#ok<AGROW>
            end
        end
    end
end