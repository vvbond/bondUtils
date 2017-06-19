function canvas(xscale, yscale)
% Convenience function for axes setup.

    % Parse input:
    switch nargin
        case 0
            xscale = [0 10]; yscale = [0 10]; 
        case 1
            yscale = xscale;
    end
    
    % Augment scalar scale values:
    if numel(xscale) == 1, xscale = [0 xscale]; end
    if numel(yscale) == 1, yscale = [0 yscale]; end
    
    % Setup axes:
    axis([xscale yscale]);
    grid on; box on
end