classdef iTool < handle
    properties
        cache       % temporary storage.
        hax
        clickPoint
    end
    properties(Dependent)
        currentPoint
    end
    
    methods
        %% Constructor
        function it = iTool()
    
        end
        %% Helpers
        
    %% Setters & Getters
        function val = get.currentPoint(it)
            cp = get(it.hax, 'currentPoint');
            val = cp(1,1:2)';
        end
    end
    %% Static
    methods(Static)
        function interactivesOff(hfig)
        % Switch off interactive tools.
            curfig = gcf;
            figure(hfig)
            plotedit off, zoom off, pan off, rotate3d off, datacursormode off, brush off
            figure(curfig)
        end
        
        function escape(hfig)
        % Emergency: clear all interaction callbacks.
            if ishandle(hfig)                
                set(hfig, 'WindowButtonMotionFcn', [], ...
                          'WindowButtonUpFcn',     [], ... 
                          'WindowButtonDownFcn',   [], ...
                          'KeyPressFcn',           [], ...
                          'KeyReleaseFcn',         [] );
            end            
        end
    end

end